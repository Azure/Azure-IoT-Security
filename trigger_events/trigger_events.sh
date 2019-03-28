#!/bin/bash

DIRECTORY=`dirname $0`
PORT=8888
TMP_PID_FILE=".tmp.pid"
COMMAND="nc -lkp $PORT"
BAD_PROCESS_NAME="httpsd"

_exploit=0
_remidiate=0
_malicious=0
_portOutput="port$PORT.output"

usage(){
    echo "This script creates a vulnerability on your machine."
    echo "The script opens port $PORT and listens to it."
    echo "Usage:"
    echo "$0 | flags"
    echo "--exploit  -  open port $PORT, and starting listenting"
    echo "--remidiate - closes the port and stops listening"
    echo "--malicious - runs a fake malicious process"
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi
while [ "$1" != "" ]; do
    case $1 in
        -e | --exploit )            _exploit=1
                                    ;;
        -r | --remidiate )          _remidiate=1
                                    ;;
        -m | --malicious )          _malicious=1
                                    ;;
        * )                         usage
                                    exit 1
    esac
    shift
done

exploit(){
    if [ -f "$TMP_PID_FILE"  ]; then
        pid=`cat $TMP_PID_FILE`
        echo "The process $pid is already listening to port $PORT"
        return 0;
    fi

    isPortOpen=$(sudo netstat -nlutp | grep ^tcp6 -v | grep LISTEN | awk '{ print $4}'  | awk -F: '{print $2}' | grep $PORT)
    if [ ! -z "$isPortOpen" ]; then 
        echo "Port $PORT is already opened on your machine"
        return 0
    fi

    $COMMAND <&- >$_portOutput &
    pid=$!
    sleep .5
    ps -p $pid > /dev/null

    if [ $? -eq 0 ]; then
        echo $! > .tmp.pid
        echo "The process $! is now listening to port $PORT"
    else
        echo "Couldn't run $COMMAND"
    fi

    return
}

remidiate(){
    if [ -f "$TMP_PID_FILE" ]; then
        pid=`cat $TMP_PID_FILE`
        isProcessExist=$(ps -aux | grep -e "$pid.*$COMMAND")
        if [ ! -z "$isProcessExist" ]; then 
            echo "Killing process $pid"
            kill $pid
            if [ $? -eq 0 ];then
                rm "$TMP_PID_FILE"
            else    
                echo "Please make sure to run as sudo"
            fi
        fi
    else
        echo "Nothing to kill"
    fi
}

runMaliciousProc(){
    sh -c "echo cpuminer-multi" >/dev/null &

    return
}

#------Script Begins Here-------
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

currDir=$PWD
cd $DIRECTORY
if [ $_exploit -eq 1 ]; then 
    exploit
fi

if [ $_remidiate -eq 1 ]; then 
    remidiate
fi

if [ $_malicious -eq 1 ];then
    runMaliciousProc
fi

cd $currDir