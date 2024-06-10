#!/bin/sh
#
#SPDX-License-Identifier: GPL-3.0-or-later
#myMPD (c) 2018-2024 Juergen Mang <mail@jcgames.de>
#https://github.com/jcorporation/mympd

#exit on error
set -e

#exit on undefined variable
set -u

# Create index of lua scripts
rm -f "index.json"
exec 3<> "index.json"
printf "{\"scripts\":[" >&3
I=0
for F in */*.lua
do
    [ "$I" -gt 0 ] &&  printf "," >&3
    NAME=$(basename "$F" .lua)
    SCRIPT_HEADER=$(head -1 "$F" < $F | sed 's/^-- //')
    DESC=$(printf "%s" "$SCRIPT_HEADER" | jq -r '.desc')
    [ "$DESC" = "null" ] && DESC=""
    jq -n --arg file "$F" --arg name "$NAME" --arg desc "$DESC" \
        '{
            "file": $file,
            "name": $name,
            "desc": $desc
        }' >&3
    I=$((I+1))
done
printf "]}\n" >&3
exec 3>&-

jq "." < index.json > /dev/null
