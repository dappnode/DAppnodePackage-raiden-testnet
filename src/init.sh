#!/bin/bash

########################################################################################################################
## 
## Cases
##
## 1.- Empty RAIDEN_KEYSTORE_PASSWORD and RAIDEN_ADDRESS 
## 1.1.- There is an account and its password in the path 
##          -> LOAD RAIDEN_ADDRESS, RAIDEN_KEYSTORE_PASSWORD_PATH, RAIDEN_KEYSTORE_PASSWORD
## 1.2.- There is NO address and its password in the path 
##          -> CALL FAUCET TO GET A MEW ACCOUNT
## 2.- Empty RAIDEN_KEYSTORE_PASSWORD and RAIDEN_ADDRESS set 
## 2.1.- if it exists .password_${RAIDEN_ADDRESS} 
##          -> LOAD RAIDEN_KEYSTORE_PASSWORD_PATH, RAIDEN_KEYSTORE_PASSWORD
## 3.- RAIDEN_KEYSTORE_PASSWORD and RAIDEN_ADDRESS set 
##          -> SAVE PASS TO FILE AND LOAD PATH 
## 3.- RAIDEN_KEYSTORE_PASSWORD empty and RAIDEN_ADDRESS set 
##           -> GET A MEW ACCOUNT WITH RAIDEN_KEYSTORE_PASSWORD AND LOAD RAIDEN_ADDRESS, RAIDEN_KEYSTORE_PASSWORD_PATH
########################################################################################################################

wait_for() {
    while [ ! -f "$1" ];do
        sleep 2
    done
}

print_banner() {
    echo
    echo "########################################################"
    echo "## Raiden not configured to start!                    ##"
    echo "########################################################"
}

# Create keystore dir to allow uploads
mkdir -p "/root/.raiden/keystore"

if [ "${RAIDEN_KEYSTORE_PASSWORD}" == '' ]; then 
    if [ -z "${RAIDEN_ADDRESS}" ]; then
        while read -r ADDRESS; do
            if [ -f "/root/.raiden/keystore/.password_$ADDRESS" ];then
                export RAIDEN_ADDRESS=${ADDRESS/ /}
                export RAIDEN_KEYSTORE_PASSWORD_PATH=/root/.raiden/keystore/.password_${ADDRESS}
                export RAIDEN_KEYSTORE_PASSWORD=$(cat /root/.raiden/keystore/.password_${ADDRESS})
                break
            fi
        done <<< "$(find /root/.raiden/keystore -maxdepth 1 -type f -not -name ".*" -exec basename \{} \;)"
        if [ -z "${RAIDEN_ADDRESS}" ];then
            export RAIDEN_KEYSTORE_PASSWORD=$(echo $(LC_CTYPE=C tr -dc 'A-HJ-NPR-Za-km-z2-9' < /dev/urandom | head -c 20))
            onboarder -p "${RAIDEN_KEYSTORE_PASSWORD}"
            while read -r ADDRESS; do
                if [ -f "/root/.raiden/keystore/.password_$ADDRESS" ];then
                    export RAIDEN_ADDRESS=$ADDRESS
                    export RAIDEN_KEYSTORE_PASSWORD_PATH=/root/.raiden/keystore/.password_$ADDRESS
                    export RAIDEN_KEYSTORE_PASSWORD=$(cat /root/.raiden/keystore/.password_${ADDRESS})
                    break
                fi
            done <<< "$(find /root/.raiden/keystore -maxdepth 1 -type f -not -name ".*" -exec basename \{} \;)"
        fi
    else
        RAIDEN_ADDRESS=$(to_checksum_address -a ${RAIDEN_ADDRESS})
        EXISTS=$(grep -qi "${RAIDEN_ADDRESS/0x/}" /root/.raiden/keystore/*)
        RESULT=$?
        if [ ${RESULT} -eq 0 ] && [ -f "/root/.raiden/keystore/.password_${RAIDEN_ADDRESS}" ];then
            export RAIDEN_KEYSTORE_PASSWORD_PATH="/root/.raiden/keystore/.password_${RAIDEN_ADDRESS}"
            export RAIDEN_KEYSTORE_PASSWORD=$(cat ${RAIDEN_KEYSTORE_PASSWORD_PATH})
        else
            if [ ${RESULT} -ne 0 ];then
                print_banner
                echo "* The account ${RAIDEN_ADDRESS} file could not be found."
                echo "* Upload it with the filename ${RAIDEN_ADDRESS} to the path:"
                echo "  /root/.raiden/keystore/"
                wait_for "/root/.raiden/keystore/${RAIDEN_ADDRESS}"
            elif [ ! -f "/root/.raiden/keystore/.password_${RAIDEN_ADDRESS}" ];then
                print_banner
                echo "* The password file for the account ${RAIDEN_ADDRESS} could not be found"
                echo "* Upload it with the filename .password_${RAIDEN_ADDRESS} to the path:"
                echo " /root/.raiden/keystore/"
                wait_for "/root/.raiden/keystore/.password_${RAIDEN_ADDRESS}"
                export RAIDEN_KEYSTORE_PASSWORD_PATH="/root/.raiden/keystore/.password_${RAIDEN_ADDRESS}"
                export RAIDEN_KEYSTORE_PASSWORD=$(cat ${RAIDEN_KEYSTORE_PASSWORD_PATH})
            fi
        fi
    fi
else
    if [ -n "${RAIDEN_ADDRESS}" ]; then
        echo "$RAIDEN_KEYSTORE_PASSWORD" > "/root/.raiden/keystore/.password_${RAIDEN_ADDRESS}"
        RAIDEN_KEYSTORE_PASSWORD_PATH="/root/.raiden/keystore/.password_${RAIDEN_ADDRESS}"
        RAIDEN_ADDRESS=$(to_checksum_address -a "${RAIDEN_ADDRESS}")
        EXISTS=$(grep -qi "${RAIDEN_ADDRESS/0x/}" /root/.raiden/keystore/*)
        RESULT=$?
        if [ ${RESULT} -eq 0 ];then
            export RAIDEN_KEYSTORE_PASSWORD_PATH="/root/.raiden/keystore/.password_${RAIDEN_ADDRESS}"
            export RAIDEN_KEYSTORE_PASSWORD=$(cat "${RAIDEN_KEYSTORE_PASSWORD_PATH}")
        else
            if [ ${RESULT} -ne 0 ];then
                print_banner
                echo "* The account ${RAIDEN_ADDRESS} file could not be found."
                echo "* Upload it with the filename ${RAIDEN_ADDRESS} to the path:"
                echo "  /root/.raiden/keystore/"
                wait_for "/root/.raiden/keystore/${RAIDEN_ADDRESS}"
            fi
        fi
    else
        EXISTS=$(grep -il "${RAIDEN_KEYSTORE_PASSWORD}" /root/.raiden/keystore/.*)
        RESULT=$?
        if [ ${RESULT} -eq 0 ];then
            export RAIDEN_ADDRESS=$(echo "${EXISTS}" | awk -F "_" '{print $2}')
            export RAIDEN_KEYSTORE_PASSWORD_PATH=${EXISTS}
            export RAIDEN_KEYSTORE_PASSWORD=$(cat "${RAIDEN_KEYSTORE_PASSWORD_PATH}")
        else
            onboarder -p "${RAIDEN_KEYSTORE_PASSWORD}"
            EXISTS=$(grep -il "${RAIDEN_KEYSTORE_PASSWORD}" /root/.raiden/keystore/.*)
            RESULT=$?
            if [ ${RESULT} -eq 0 ];then
                export RAIDEN_ADDRESS=$(echo "${EXISTS}" | awk -F "_" '{print $2}')
                export RAIDEN_KEYSTORE_PASSWORD_PATH=${EXISTS}
                export RAIDEN_KEYSTORE_PASSWORD=$(cat "${RAIDEN_KEYSTORE_PASSWORD_PATH}")
            fi
        fi
    fi
fi

# Check if password is set, and at least one file has been uploaded
if [ -n "${RAIDEN_ADDRESS}" ] && [ -n "${RAIDEN_KEYSTORE_PASSWORD}" ]; then
    raiden --keystore-path /root/.raiden/keystore --accept-disclaimer --password-file "${RAIDEN_KEYSTORE_PASSWORD_PATH}" "${EXTRA_OPTS}"
else
    print_banner
    while true; do sleep 5; done
fi
