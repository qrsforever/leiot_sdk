#!/bin/bash

if [[ x$ARES_TOP_DIR == x ]]
then
    ARES_TOP_DIR=`cd ../../; pwd`
fi

if [[ $# < 3 ]]
then
    echo "Warn: $0 only be called by rule_engine_for_shadow.sh"
    exit 0
fi

if [ -f /tmp/rule_engine_for_desire.pid ]
then
    pid=`cat /tmp/rule_engine_for_desire.pid`
    kill -9 $pid 2> /dev/null
fi
echo "$$" > /tmp/rule_engine_for_desire.pid

parent_pid=$1
product_id=$2
device_name=$3

names=()
values=()
i=0
for nv in ${@:4:$#}
do
    names[i]=`echo ${nv} | cut -d= -f1`
    values[i]=`echo ${nv} | cut -d= -f2`
    (( i = i + 1 ))
done

CERTS_DIR=$ARES_TOP_DIR/doc/shadow
SERVER_HOST=10.58.64.12
SERVER_PORT=1883

LEIOT_GET_TOPIC_PREFIX="/shadow/get"
SUB_CMD=`which mosquitto_sub`
PUB_CMD=`which mosquitto_pub`
SHOW_TIPIC="-v"
MAX_SIZE=1024

if [[ x$SUB_CMD == x || x$PUB_CMD == x ]]
then
    echo "Please install mosquitto_sub and mosquitto_pub"
    exit 0
fi

# utils tool {{{
DEBUG_ON=1
__PRINTF() {
    if [[ x$DEBUG_ON == x1 ]]
    then
        echo $*
    fi
}

__add_quo_escape() {
    tmp=${1//\"/\\\"}
    echo $tmp
}

__del_quo_escape() {
    tmp=${1//\\/}
    echo $tmp
}

__parse_json() {
    tmp=$(__del_quo_escape "$1")
    echo "${tmp//\"/}" | sed "s/.*$2:\([^,}]*\).*/\1/"
}

__trim_space() {
    echo $1 | sed "s/\ //g"
}

__check_parent_process_die() {
    result=`ps -p $parent_pid | grep "$parent_pid"`
    if [[ x$result == x ]]
    then
        echo "exit [$parent_pid] die" >> /tmp/${product_id}_${device_name}-desire.log
        exit 0
    fi
}
#}}}

__main() { #{{{
    echo "" > /tmp/${product_id}_${device_name}-desire.log
    len=${#names[@]}
    while (( 1 ))
    do
        sleep 8
        FIX_TIME_STAMP=`date +%s`
        desire_str=""
        for (( i = 0; i < $len; i++ ))
        do
            if (( i != 0 ))
            then
                desire_str="$desire_str, "
            fi
            desire_str="$desire_str\"${names[i]}\":\"${values[i]}\""
        done
        metadata_str=""
        for (( i = 0; i < $len; i++ ))
        do
            if (( i != 0 ))
            then
                metadata_str="$metadata_str, "
            fi
            metadata_str="$metadata_str\"${names[i]}\":{\"timestamp\":$FIX_TIME_STAMP}"
        done
        json_result="{ \
            \"method\":\"control\", \
            \"payload\":{ \
                \"state\":{ \
                    \"desired\":{ \
                        $desire_str \
                    } \
                } \
            }, \
            \"metadata\":{ \
                \"desired\":{ \
                    $metadata_str \
                } \
            }, \
            \"timestamp\":$FIX_TIME_STAMP, \
            \"version\":99 \
        }"
        # trim off space character
        json_result=$(__trim_space "$json_result")
        buffsize=${#json_result}
        if (( $buffsize > $MAX_SIZE ))
        then
            echo "Max buffer size: $MAX_SIZE"
            return
        fi
        # __PRINTF $json_result
        $PUB_CMD -h $SERVER_HOST -p $SERVER_PORT -q 1 \
            -t "$LEIOT_GET_TOPIC_PREFIX/$product_id/$device_name" -m "$json_result" \
            --cafile $CERTS_DIR/certs/ca.crt \
            --cert $CERTS_DIR/certs/client.crt \
            --key $CERTS_DIR/certs/client.key
        echo "$json_result" >> /tmp/${product_id}_${device_name}-desire.log

        __check_parent_process_die
    done
} #}}}

__main
