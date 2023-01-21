#!/bin/bash

INSTALL_FOLDER=/usr/share/fr24
FR24_LINUX_ARCHIVE=fr24feed_1.0.34-0_amd64.tgz
echo "Creating folder fr24"
sudo mkdir ${INSTALL_FOLDER}
echo "Downloading fr24feed amd64 binary file from Flightradar24"
sudo wget -O ${INSTALL_FOLDER}/${FR24_LINUX_ARCHIVE} "https://repo-feed.flightradar24.com/linux_x86_64_binaries/${FR24_LINUX_ARCHIVE}"

echo "Unzipping downloaded file"
sudo tar xvzf ${INSTALL_FOLDER}/${FR24_LINUX_ARCHIVE} -C ${INSTALL_FOLDER}
sudo cp ${INSTALL_FOLDER}/fr24feed_amd64/fr24feed /usr/bin/

echo -e "\e[32mCreating necessary files for fr24feed......\e[39m"

CONFIG_FILE=/etc/fr24feed.ini
sudo touch ${CONFIG_FILE}
sudo chmod 666 ${CONFIG_FILE}
echo "Writing code to config file fr24feed.ini"
/bin/cat << \EOM >${CONFIG_FILE}
receiver="avr-tcp"
host="127.0.0.1:30002"
fr24key="xxxxxxxxxxxxxxxx"
bs="no"
raw="no"
logmode="1"
logpath="/var/log/fr24feed"
mlat="yes"
mlat-without-gps="yes"
EOM
sudo chmod 644 ${CONFIG_FILE}

SERVICE_FILE=/etc/systemd/system/fr24feed.service
sudo touch ${SERVICE_FILE}
sudo chmod 666 ${SERVICE_FILE}
/bin/cat << \EOM >${SERVICE_FILE}
[Unit]
Description=Flightradar24 Feeder
After=network-online.target

[Service]
Type=simple
Restart=always
LimitCORE=infinity
RuntimeDirectory=fr24feed
RuntimeDirectoryMode=0755
ExecStartPre=-/bin/mkdir -p /var/log/fr24feed
ExecStartPre=-/bin/mkdir -p /run/fr24feed
ExecStartPre=-/bin/touch /dev/shm/decoder.txt
ExecStartPre=-/bin/chown fr24:fr24 /dev/shm/decoder.txt /run/fr24feed /var/log/fr24feed
ExecStart=/usr/bin/fr24feed
User=fr24
PermissionsStartOnly=true
StandardOutput=null

[Install]
WantedBy=multi-user.target
EOM
sudo chmod 644 ${SERVICE_FILE}

sudo useradd --system fr24

sudo systemctl enable fr24feed

sudo mkdir -p /lib/lsb
INIT_FUNCTIONS=/lib/lsb/init-functions
sudo touch ${INIT_FUNCTIONS}
sudo chmod 666 ${INIT_FUNCTIONS}
/bin/cat << \EOM >${INIT_FUNCTIONS}
# /lib/lsb/init-functions for Debian -*- shell-script -*-
#
#Copyright (c) 2002-08 Chris Lawrence
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions
#are met:
#1. Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#2. Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#3. Neither the name of the author nor the names of other contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
#
#THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
#IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE
#LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
#BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
#OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
#EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

start_daemon () {
    local force nice pidfile exec args OPTIND
    force=""
    nice=0
    pidfile=/dev/null

    OPTIND=1
    while getopts fn:p: opt ; do
        case "$opt" in
            f)  force="force";;
            n)  nice="$OPTARG";;
            p)  pidfile="$OPTARG";;
        esac
    done

    shift $(($OPTIND - 1))
    if [ "$1" = '--' ]; then
        shift
    fi

    exec="$1"; shift
    args="--start --nicelevel $nice --quiet --oknodo"
    if [ "$force" ]; then
        /sbin/start-stop-daemon $args \
            --chdir "$PWD" --startas $exec --pidfile /dev/null -- "$@"
    elif [ $pidfile ]; then
        /sbin/start-stop-daemon $args \
            --chdir "$PWD" --exec $exec --oknodo --pidfile "$pidfile" -- "$@"
    else
        /sbin/start-stop-daemon $args --chdir "$PWD" --exec $exec -- "$@"
    fi
}

pidofproc () {
    local pidfile base status specified pid OPTIND
    pidfile=
    specified=
    OPTIND=1
    while getopts p: opt ; do
        case "$opt" in
            p)  pidfile="$OPTARG"
                specified="specified"
                ;;
        esac
    done

    shift $(($OPTIND - 1))
    if [ $# -ne 1 ]; then
        echo "$0: invalid arguments" >&2
        return 4
    fi

    base=${1##*/}
    if [ ! "$specified" ]; then
        pidfile="/var/run/$base.pid"
    fi

    if [ -n "${pidfile:-}" ]; then
     if [ -e "$pidfile" ]; then
      if [ -r "$pidfile" ]; then
        read pid < "$pidfile"
        if [ -n "${pid:-}" ]; then
            if $(kill -0 "${pid:-}" 2> /dev/null); then
                echo "$pid" || true
                return 0
            elif ps "${pid:-}" >/dev/null 2>&1; then
                echo "$pid" || true
                return 0 # program is running, but not owned by this user
            else
                return 1 # program is dead and /var/run pid file exists
            fi
        fi
      else
        return 4 # pid file not readable, hence status is unknown.
      fi
     else
       # pid file doesn't exist, try to find the pid nevertheless
       if [ -x /bin/pidof ] && [ ! "$specified" ]; then
         status="0"
         /bin/pidof -c -o %PPID -x $1 || status="$?"
         if [ "$status" = 1 ]; then
             return 3 # program is not running
         fi
         return 0
       fi
       return 3 # specified pid file doesn't exist, program probably stopped
     fi
    fi
    if [ "$specified" ]; then
        return 3 # almost certain it's not running
    fi
    return 4 # Unable to determine status
}

# start-stop-daemon uses the same algorithm as "pidofproc" above.
killproc () {
    local pidfile sig status base name_param is_term_sig OPTIND
    pidfile=
    name_param=
    is_term_sig=
    OPTIND=1
    while getopts p: opt ; do
        case "$opt" in
            p)  pidfile="$OPTARG";;
        esac
    done
    shift $(($OPTIND - 1))

    base=${1##*/}
    if [ ! $pidfile ]; then
        name_param="--name $base --pidfile /var/run/$base.pid"
    else
        name_param="--name $base --pidfile $pidfile"
    fi

    sig=$(echo ${2:-} | sed -e 's/^-\(.*\)/\1/')
    sig=$(echo $sig | sed -e 's/^SIG\(.*\)/\1/')
    if [ "$sig" = 15 ] || [ "$sig" = TERM ]; then
        is_term_sig="terminate_signal"
    fi
    status=0
    if [ ! "$is_term_sig" ]; then
        if [ -n "$sig" ]; then
            /sbin/start-stop-daemon --stop --signal "$sig" \
                --quiet $name_param || status="$?"
        else
            /sbin/start-stop-daemon --stop \
                --retry 5 \
                --quiet $name_param || status="$?"
        fi
    else
        /sbin/start-stop-daemon --stop --quiet \
            --oknodo $name_param || status="$?"
    fi
    if [ "$status" = 1 ]; then
        if [ -z "$sig" ]; then
            return 0
        fi
        return 3 # program is not running
    fi

    if [ "$status" = 0 ] && [ "$is_term_sig" ] && [ "$pidfile" ]; then
        pidofproc -p "$pidfile" "$1" >/dev/null || rm -f "$pidfile"
    fi
    return 0
}

# Return LSB status
status_of_proc () {
    local pidfile daemon name status OPTIND
    pidfile=
    OPTIND=1
    while getopts p: opt ; do
        case "$opt" in
            p)  pidfile="$OPTARG";;
        esac
    done
    shift $(($OPTIND - 1))

    if [ -n "$pidfile" ]; then
        pidfile="-p $pidfile"
    fi
    daemon="$1"
    name="$2"

    status="0"
    pidofproc $pidfile $daemon >/dev/null || status="$?"
    if [ "$status" = 0 ]; then
        log_success_msg "$name is running"
        return 0
    elif [ "$status" = 4 ]; then
        log_failure_msg "could not access PID file for $name"
        return $status
    else
        log_failure_msg "$name is not running"
        return $status
    fi
}

log_use_fancy_output () {
    TPUT=/usr/bin/tput
    EXPR=/usr/bin/expr
    if  [ -t 1 ] &&
        [ "x${TERM:-}" != "x" ] &&
        [ "x${TERM:-}" != "xdumb" ] &&
        [ -x $TPUT ] && [ -x $EXPR ] &&
        $TPUT hpa 60 >/dev/null 2>&1 &&
        $TPUT setaf 1 >/dev/null 2>&1
    then
        [ -z $FANCYTTY ] && FANCYTTY=1 || true
    else
        FANCYTTY=0
    fi
    case "$FANCYTTY" in
        1|Y|yes|true)   true;;
        *)              false;;
    esac
}



log_success_msg () {
    if [ -n "${1:-}" ]; then
        log_begin_msg $@
    fi
    log_end_msg 0
}

log_failure_msg () {
    if [ -n "${1:-}" ]; then
        log_begin_msg $@ "..."
    fi
    log_end_msg 1 || true
}

log_warning_msg () {
    if [ -n "${1:-}" ]; then
        log_begin_msg $@ "..."
    fi
    log_end_msg 255 || true
}

#
# NON-LSB HELPER FUNCTIONS
#
# int get_lsb_header_val (char *scriptpathname, char *key)
get_lsb_header_val () {
        if [ ! -f "$1" ] || [ -z "${2:-}" ]; then
                return 1
        fi
        LSB_S="### BEGIN INIT INFO"
        LSB_E="### END INIT INFO"
        sed -n "/$LSB_S/,/$LSB_E/ s/# $2: \+\(.*\)/\1/p" "$1"
}

# If the currently running init daemon is upstart, return zero; if the
# calling init script belongs to a package which also provides a native
# upstart job, it should generally exit non-zero in this case.
init_is_upstart()
{
   if [ -x /sbin/initctl ] && /sbin/initctl version 2>/dev/null | /bin/grep -q upstart; then
       return 0
   fi
   return 1
}

# int log_begin_message (char *message)
log_begin_msg () {
    log_begin_msg_pre "$@"
    if [ -z "${1:-}" ]; then
        return 1
    fi
    echo -n "$@" || true
    log_begin_msg_post "$@"
}

# Sample usage:
# log_daemon_msg "Starting GNOME Login Manager" "gdm"
#
# On Debian, would output "Starting GNOME Login Manager: gdm"
# On Ubuntu, would output " * Starting GNOME Login Manager..."
#
# If the second argument is omitted, logging suitable for use with
# log_progress_msg() is used:
#
# log_daemon_msg "Starting remote filesystem services"
#
# On Debian, would output "Starting remote filesystem services:"
# On Ubuntu, would output " * Starting remote filesystem services..."

log_daemon_msg () {
    if [ -z "${1:-}" ]; then
        return 1
    fi
    log_daemon_msg_pre "$@"

    if [ -z "${2:-}" ]; then
        echo -n "$1:" || true
        return
    fi


    echo -n "$1: $2" || true
    log_daemon_msg_post "$@"
}
# #319739
#
# Per policy docs:
#
#     log_daemon_msg "Starting remote file system services"
#     log_progress_msg "nfsd"; start-stop-daemon --start --quiet nfsd
#     log_progress_msg "mountd"; start-stop-daemon --start --quiet mountd
#     log_progress_msg "ugidd"; start-stop-daemon --start --quiet ugidd
#     log_end_msg 0
#
# You could also do something fancy with log_end_msg here based on the
# return values of start-stop-daemon; this is left as an exercise for
# the reader...
#
# On Ubuntu, one would expect log_progress_msg to be a no-op.
log_progress_msg () {
    if [ -z "${1:-}" ]; then
        return 1
    fi
    echo -n " $@" || true
}

# int log_end_message (int exitstatus)
log_end_msg () {
    # If no arguments were passed, return
    if [ -z "${1:-}" ]; then
        return 1
    fi

    local retval
    retval=$1
    log_end_msg_pre "$@"
    # Only do the fancy stuff if we have an appropriate terminal
    # and if /usr is already mounted
    if log_use_fancy_output; then
        RED=$( $TPUT setaf 1)
        YELLOW=$( $TPUT setaf 3)
        NORMAL=$( $TPUT op)
    else
        RED=''
        YELLOW=''
        NORMAL=''
    fi

    if [ $1 -eq 0 ]; then
        echo "." || true
    elif [ $1 -eq 255 ]; then
        /bin/echo -e " ${YELLOW}(warning).${NORMAL}" || true
    else
        /bin/echo -e " ${RED}failed!${NORMAL}" || true
    fi
    log_end_msg_post "$@"
    return $retval
}

log_action_msg () {
    log_action_msg_pre "$@"
    echo "$@." || true
    log_action_msg_post "$@"
}

log_action_begin_msg () {
    log_action_begin_msg_pre "$@"
    echo -n "$@..." || true
    log_action_begin_msg_post "$@"
}

log_action_cont_msg () {
    echo -n "$@..." || true
}

log_action_end_msg () {
    local end
    log_action_end_msg_pre "$@"
    if [ -z "${2:-}" ]; then
        end="."
    else
        end=" ($2)."
    fi
    if [ $1 -eq 0 ]; then
        echo "done${end}" || true
    else
        if log_use_fancy_output; then
            RED=$( $TPUT setaf 1)
            NORMAL=$( $TPUT op)
            /bin/echo -e "${RED}failed${end}${NORMAL}" || true
        else
            echo "failed${end}" || true
        fi
    fi
    log_action_end_msg_post "$@"
}

# Pre&Post empty function declaration, to be overriden from /lib/lsb/init-functions.d/*
log_daemon_msg_pre () { :; }
log_daemon_msg_post () { :; }
log_begin_msg_pre () { :; }
log_begin_msg_post () { :; }
log_end_msg_pre () { :; }
log_end_msg_post () { :; }
log_action_msg_pre () { :; }
log_action_msg_post () { :; }
log_action_begin_msg_pre () { :; }
log_action_begin_msg_post () { :; }
log_action_end_msg_pre () { :; }
log_action_end_msg_post () { :; }

# Include hooks from other packages in /lib/lsb/init-functions.d
for hook in $(run-parts --lsbsysinit --list /lib/lsb/init-functions.d 2>/dev/null); do
    [ -r $hook ] && . $hook || true
done
FANCYTTY=
[ -e /etc/lsb-base-logging.sh ] && . /etc/lsb-base-logging.sh || true
EOM
sudo chmod 644 ${INIT_FUNCTIONS}

STATUS_FILE=/usr/bin/fr24feed-status
sudo touch ${STATUS_FILE}
sudo chmod 666 ${STATUS_FILE}
/bin/cat << \EOM >${STATUS_FILE}
#!/bin/bash

. /lib/lsb/init-functions

MONITOR_FILE=/dev/shm/decoder.txt

systemctl status fr24feed 2>&1 >/dev/null || {
    log_failure_msg "FR24 Feeder/Decoder Process"
    exit 0
}

log_success_msg "FR24 Feeder/Decoder Process: running"
DATE=`grep time_update_utc_s= ${MONITOR_FILE} 2>/dev/null | cut -d'=' -f2`
log_success_msg "FR24 Stats Timestamp: $DATE"
FEED=`grep 'feed_status=' ${MONITOR_FILE} 2>/dev/null | cut -d'=' -f2`
if [ "$FEED" == "" ]; then
    FEED="unknown"
fi
if [ "$FEED" == "connected" ]; then
    MODE=`grep feed_current_mode= ${MONITOR_FILE} 2>/dev/null | cut -d'=' -f2`
    log_success_msg "FR24-2 Link: $FEED [$MODE]"
    FEED=`grep feed_alias= ${MONITOR_FILE} 2>/dev/null | cut -d'=' -f2`
    log_success_msg "FR24-2 Radar: $FEED"
    FEED=`grep feed_num_ac_tracked= ${MONITOR_FILE} 2>/dev/null | cut -d'=' -f2`
    log_success_msg "FR24-2 Tracked AC: ${FEED}"
else
    log_failure_msg "FR24 Link: $FEED"
fi

RX=`grep rx_connected= ${MONITOR_FILE} 2>/dev/null | cut -d'=' -f2`
RX1=`grep num_messages= ${MONITOR_FILE} 2>/dev/null | cut -d'=' -f2`
RX2=`grep num_resyncs= ${MONITOR_FILE} 2>/dev/null | cut -d'=' -f2`
if [ "$RX" == "1" ]; then
    log_success_msg "Receiver: connected ($RX1 MSGS/$RX2 SYNC)"
else
    log_failure_msg "Receiver: down"
fi

MLAT=`grep 'mlat-ok=' ${MONITOR_FILE} 2>/dev/null | cut -d'=' -f2`
if [ "$MLAT" == "" ]; then
    MLAT="unknown"
fi

if [ "$MLAT" == "YES" ]; then
    MLAT_MODE=`grep mlat-mode= ${MONITOR_FILE} 2>/dev/null | cut -d'=' -f2`
    log_success_msg "FR24 MLAT: ok [$MLAT_MODE]"
    MLAT_SEEN=`grep mlat-number-seen= ${MONITOR_FILE} 2>/dev/null | cut -d'=' -f2`
    log_success_msg "FR24 MLAT AC seen: $MLAT_SEEN"
else
    log_failure_msg "FR24 MLAT: not running"
fi
EOM

sudo chmod +x ${STATUS_FILE}

echo -e "\e[32mCreation of necessary files of \"fr24feed\" completed...\e[39m"

echo -e "\e[32mSignup for \"fr24feed\" ...\e[39m"
sudo fr24feed --signup

sed -i '/receiver/c\receiver=\"avr-tcp\"' /etc/fr24feed.ini
sed -i '/host/c\host=\"127.0.0.1:30002\"' /etc/fr24feed.ini
if [[ ! `grep 'host' /etc/fr24feed.ini` ]]; then echo 'host="127.0.0.1:30002"' >>  /etc/fr24feed.ini; fi
sed -i '/logpath/c\logpath=\"/var/log/fr24feed\"' /etc/fr24feed.ini
sed -i '/raw/c\raw=\"no\"' /etc/fr24feed.ini
sed -i '/bs/c\bs=\"no\"' /etc/fr24feed.ini
sed -i '/mlat=/c\mlat=\"yes\"' /etc/fr24feed.ini
sed -i '/mlat-without-gps=/c\mlat-without-gps=\"yes\"' /etc/fr24feed.ini
echo " "
echo " "
echo -e "\e[01;32mInstallation of fr24feed completed...\e[39m"
echo " "
echo -e "\e[01;32m    Your fr24keys are in following config file\e[39m"
echo -e "\e[01;33m    sudo nano /etc/fr24feed.ini  \e[39m"
echo " "
echo -e "\e[01;33m    To restart fr24feed:  sudo systemctl restart fr24feed  \e[39m"
echo " "
echo -e "\e[01;33m    To check log of fr24feed:  cat /var/log/fr24feed/fr24feed.log  \e[39m"
echo " "
echo -e "\e[01;33m    To check status of fr24feed:  sudo fr24feed-status  \e[39m"
echo " "
echo -e "\e[01;31mRESTART fr24feed ... RESTART fr24feed ... RESTART fr24feed ... \e[39m"
echo -e "\e[01;31mRESTART fr24feed ... RESTART fr24feed ... RESTART fr24feed ... \e[39m"
echo " "
echo -e "\e[01;33m    sudo systemctl restart fr24feed \e[39m"
echo " "



