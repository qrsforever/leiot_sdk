#!/bin/bash

if [[ x$ARES_TOP_DIR == x ]]
then
    ARES_TOP_DIR=`cd ../../; pwd`
fi

CERTS_DIR=$ARES_TOP_DIR/doc/shadow
SERVER_HOST=10.58.64.12
SERVER_PORT=1883

LEIOT_UPDATE_TOPIC_PREFIX="/shadow/update"
LEIOT_GET_TOPIC_PREFIX="/shadow/get"
SUB_CMD=`which mosquitto_sub`
PUB_CMD=`which mosquitto_pub`
SHOW_TIPIC="-v"
FIX_TIME_STAMP=`date +%s`
MAX_SIZE=1024

if [[ x$SUB_CMD == x || x$PUB_CMD == x ]]
then
    echo "Please install mosquitto_sub and mosquitto_pub"
    exit 0
fi

# utils tool{{{
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
#}}}

__main() { #{{{
    while (( 1 ))
    do
        msg=`$SUB_CMD -h $SERVER_HOST -p $SERVER_PORT $SHOW_TIPIC -q 1 \
            -t "$LEIOT_UPDATE_TOPIC_PREFIX/#" \
            --cafile $CERTS_DIR/certs/ca.crt \
            --cert $CERTS_DIR/certs/client.crt \
            --key $CERTS_DIR/certs/client.key \
            -C 1`
        __PRINTF $msg
        topic=`echo $msg | cut -d\  -f1`
        payload=`echo $msg | cut -d\  -f2-`
        __receive_mqtt_message $topic "$payload"
    done
} #}}}

__receive_mqtt_message() { #{{{
    topic=$1
    payload=$2
    tmpstr=${topic#${LEIOT_UPDATE_TOPIC_PREFIX}}
    product_id=`echo $tmpstr | cut -d\/ -f2`
    device_name=`echo $tmpstr | cut -d\/ -f3`

    if [[ x$product_id == x"9RrZXcGctqe" ]]
    then
        case $device_name in
            "air-1")
                __do_rule_engine_for_air1 $product_id $device_name "$payload"
                ;;
            "*")
                ;;
        esac
    else
        echo "Unkown product id: $product_id"
    fi
} #}}}

######################################## Aircond Sample  ########################
AUTO_INC_VERSION=2
TEMPERATURE=0.0

__do_rule_engine_for_air1() { #{{{
    __PRINTF "call __do_rule_engine_for_air1"
    if [[ $# != 3 ]]
    then
        echo "Use: $0 product_id device_name payload"
        return
    fi
    op_type=$(__parse_json "$3" "method")
    token=$(__parse_json "$3" "clientToken")
    __PRINTF "type=[$op_type] token=[$token]"
    case $op_type in
        "get" | "GET")
            json_result="{ \"clientToken\":\"$token\",
                \"method\":\"reply\", \
                \"timestamp\":$timestamp, \
                \"payload\":{ \
                    \"status\":\"success\",
                     \"state\":{ \
                        \"reported\":{ \
                            \"temperature\":${TEMPERATURE}, \
                            \"switch\":\"1000\"
                        } \
                    }, \
                    \"metadata\":{ \
                        \"reported\":{ \
                            \"temperature\":{ \
                                \"timestamp\":$FIX_TIME_STAMP \
                             } \
                         } \
                     }, \
                    \"timestamp\":$FIX_TIME_STAMP, \
                    \"version\":$AUTO_INC_VERSION \
                } \
            }"
            # trim off space character
            json_result=$(__trim_space "$json_result")
            buffsize=${#json_result}
            if (( $buffsize > $MAX_SIZE ))
            then
                echo "Max buffer size: $MAX_SIZE"
                return
            fi
            __PRINTF $json_result
            $PUB_CMD -h $SERVER_HOST -p $SERVER_PORT -q 1 \
                -t "$LEIOT_GET_TOPIC_PREFIX/$1/$2" -m "$json_result" \
                --cafile $CERTS_DIR/certs/ca.crt \
                --cert $CERTS_DIR/certs/client.crt \
                --key $CERTS_DIR/certs/client.key
            $ARES_TOP_DIR/leiot/script/rule_engine_for_desire.sh $$ $1 $2 "temperature=$TEMPERATURE switch=10" &
            ;;
        "update" | "UPDATE")
            AUTO_INC_VERSION=`expr $AUTO_INC_VERSION + 1`
            temperature=$(__parse_json "$3" "temperature")
            __PRINTF "temperature = $temperature"
            timestamp=`date +%s`
            json_result="{ \"clientToken\":\"$token\",
                \"method\":\"reply\", \
                \"timestamp\":$timestamp, \
                \"payload\":{ \
                    \"status\":\"success\", \
                    \"version\":$AUTO_INC_VERSION \
                }, \
                \"timestamp\":$FIX_TIME_STAMP\
            }"
            # trim off space character
            json_result=$(__trim_space "$json_result")
            buffsize=${#json_result}
            if (( $buffsize > $MAX_SIZE ))
            then
                echo "Max buffer size: $MAX_SIZE"
                return
            fi
            __PRINTF $json_result
            $PUB_CMD -h $SERVER_HOST -p $SERVER_PORT -q 1 \
                -t "$LEIOT_GET_TOPIC_PREFIX/$1/$2" -m "$json_result" \
                --cafile $CERTS_DIR/certs/ca.crt \
                --cert $CERTS_DIR/certs/client.crt \
                --key $CERTS_DIR/certs/client.key
            ;;
        "*")
            ;;
    esac
} #}}}

__main
