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
SCRIPTNAME=$(basename "$F")
printf "\"%s\"" "$SCRIPTNAME" >&3
I=$((I+1))
done
printf "]}\n" >&3
exec 3>&-

jq "." < index.json > /dev/null
