#! /bin/bash

# Copyright (c) 2017, University of Kaiserslautern
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Author: Éder F. Zulian

source ./defaults.in
source ./util.in

wgethis=(
"$BENCHMARKSDIR:http://www.gem5.org/dist/m5_benchmarks/v1-splash-alpha.tgz"
"$BENCHMARKSDIR:http://downloads.sourceforge.net/project/dacapobench/9.12-bach/dacapo-9.12-bach.jar"
"$BENCHMARKSDIR:http://parsec.cs.princeton.edu/download/3.0/parsec-3.0.tar.gz"
"$BBENCHANDROIDARMDIR:http://bbench.eecs.umich.edu/bbench/bbench_2.0.tgz"
"$BBENCHANDROIDARMDIR:http://bbench.eecs.umich.edu/bbench/bbench_3.0.tgz"
"$BBENCHANDROIDARMDIR:http://bbench.eecs.umich.edu/bbench/Gingerbread_disk_image.tgz"
"$BBENCHANDROIDARMDIR:http://bbench.eecs.umich.edu/bbench/ICS_disk_image.tgz"
"$BBENCHANDROIDARMDIR:http://bbench.eecs.umich.edu/bbench/vmlinux_and_config_arm.tgz"
)

greetings
wgettodir wgethis[@]
