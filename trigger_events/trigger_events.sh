#!/bin/bash

DIRECTORY=`dirname $0`
PORT=8888
TMP_PID_FILE=".tmp.pid"
COMMAND="nc -lkp "
BAD_PROCESS_NAME="httpsd"
NUMERIC_REGEX='^[0-9]+$'


_exploit=0
_remidiate=0
_malicious=0
_portsArr=($PORT)
_portOutput="port$PORT.output"

usage(){
    echo "This script creates a vulnerability on your machine."
    echo "The script opens port $PORT and listens to it."
    echo "Usage:"
    echo "$0 | flags"
    echo "--exploit (?additional ports)     - open and listen to ports $PORT and additional ports"
    echo "      additional ports            - number of additional ports. i.e `-e 3` will open ports 8888,8889,8900"
    echo "--remidiate                       - closes the port and stops listening"
    echo "--malicious                       - runs a fake malicious process"
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi
while [ "$1" != "" ]; do
    case $1 in
        -e | --exploit )
            _exploit=1

            _endPort=$(($PORT+${2:-0}))
            if [[ $_endPort =~ $NUMERIC_REGEX ]] && [ "$_endPort" != "$PORT" ] ; then
                _portsArr=($(seq $PORT 1 $_endPort))
                shift
            fi

            shift
            ;;
        -r | --remidiate )
            _remidiate=1
            shift
            ;;
        -m | --malicious )
            _malicious=1
            shift
            ;;
        * )
            usage
            exit 1
    esac
done

exploit(){
    CURRENT_PORT=$1

    isPortOpen=$(sudo netstat -ntlp | grep LISTEN | awk '{ print $4}'  | awk -F: '{print $2}' | grep $CURRENT_PORT)
    if [ ! -z "$isPortOpen" ]; then
        echo "Port $CURRENT_PORT is already opened on your machine"
        return 0
    fi

    CURRENT_COMMAND="nc -lkp $CURRENT_PORT"
    PORT_OUTPUT_FILE="port$CURRENT_PORT.output"
    $CURRENT_COMMAND <&- >>$PORT_OUTPUT_FILE &
    pid=$!
    sleep .5
    ps -p $pid > /dev/null

    if [ $? -eq 0 ]; then
        echo $! >> .tmp.pid
        echo "The process $! is now listening to port $CURRENT_PORT"
    else
        echo "Couldn't run $CURRENT_COMMAND"
    fi

    return
}

remidiate(){
    if [ -f "$TMP_PID_FILE" ]; then
        for pid in `cat $TMP_PID_FILE`
        do
            isProcessExist=$(ps -aux | grep -e "$pid.*$COMMAND $pid")
            if [ ! -z "$isProcessExist" ]; then
                echo "Killing process $pid"
                kill $pid
            fi
        done

        # cleanup
        rm "$TMP_PID_FILE" *.output || true
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
    for i in "${_portsArr[@]}"
    do
        exploit $i
    done
fi

if [ $_remidiate -eq 1 ]; then
    remidiate
fi

if [ $_malicious -eq 1 ];then
    runMaliciousProc
fi

cd $currDir