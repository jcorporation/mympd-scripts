#!/bin/sh
#
#SPDX-License-Identifier: GPL-3.0-or-later
#myMPD (c) 2018-2024 Juergen Mang <mail@jcgames.de>
#https://github.com/jcorporation/mympd

#exit on error
set -e

#exit on undefined variable
set -u

luacheck */*.lua
