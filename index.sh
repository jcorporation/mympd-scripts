#!/bin/sh
#
#SPDX-License-Identifier: GPL-3.0-or-later
#myMPD (c) 2018-2026 Juergen Mang <mail@jcgames.de>
#https://github.com/jcorporation/mympd-sciprts

# Exit on error
set -e

# Exit on undefined variable
set -u

sig_create() {
    FILE=$1
    openssl dgst -sha256 -sign privatekey.pem -out "/tmp/sig" "$FILE"
    openssl base64 -in "/tmp/sig" -out "$FILE.sig"
    rm /tmp/sig
}

sig_check() {
    FILE=$1
    openssl base64 -d -in "$FILE.sig" -out "/tmp/sig"
    openssl dgst -sha256 -verify publickey.pem -signature "/tmp/sig" "$FILE"
    rm /tmp/sig
}

# Create signatures and index of lua scripts
if [ -f privatekey.pem ]
then
    echo "--"
    echo "Creating index and signatures"
    rm -f "index.json"
    exec 3<> "index.json"
    printf "{" >&3
    I=0
    for F in */*.lua
    do
        echo "    $F"
        [ "$I" -gt 0 ] &&  printf "," >&3
        NAME=$(basename "$F" .lua | jq -Ra .)
        FILE=$(printf "%s" "$F" | jq -Ra .)
        SCRIPT_HEADER=$(head -1 "$F" < $F | sed 's/^-- //')
        DESC=$(printf "%s" "$SCRIPT_HEADER" | jq -r '.desc' | jq -Ra .)
        VERSION=$(printf "%s" "$SCRIPT_HEADER" | jq -r '.version')
        [ "$DESC" = "null" ] && DESC=""
        [ "$VERSION" = "null" ] && VERSION="0"
        printf '%s:{"name":%s,"desc":%s,"version":%s}' "$FILE" "$NAME" "$DESC" "$VERSION" >&3
        I=$((I+1))
        if [ -f privatekey.pem ]
        then
            sig_create "$F"
        fi
    done
    printf "}\n" >&3
    exec 3>&-
    # Sign index
    sig_create index.json
fi

# Check index for valid JSON
jq "." < index.json > /dev/null

echo "--"
echo "Checking signatures"
echo -n "    index.json..."
sig_check index.json

for F in */*.lua
do
    echo -n "    $F..."
    sig_check "$F"
done
