#!/usr/bin/env bash

# Copyright (c) 2019, University of Kaiserslautern
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
set -x

DIR="$(cd "$(dirname "$0")" && pwd)"
TOPDIR=$DIR/../..
source $TOPDIR/common/defaults.in
source $TOPDIR/common/util.in
currtime=$(date "+%Y.%m.%d-%H.%M.%S")

arch="ARM"
mode="opt"
gem5_elf="build/$arch/gem5.$mode"

sysver="20180409"
syspath="$FSDIRARM/aarch-system-${sysver}"
imgdir="${syspath}/disks"

usage="Usage: $(basename "$0") {-h | [DISK NUM_CPUS MEM_SIZE_GB [BENCHMARK [CPU_TYPE]]]}
Boot Linux aarch64. Optionally, a DISK image can be specified.
	-h    display this help and exit
	DISK  raw disk image file (.img)
	NUM_CPUS  number of CPUS
	MEM_SIZE_GB memory size in GiB
	BENCHMARK
			lat_mem_rd <SIZE_MB> <STRIDE1_SIZE_B> [stride2 in byte]…

			sysbench [--num-threads=<num-threads>] --test=memory --memory-block-size=[in MB] --memory-total-size=[in MB] run

			bw_mem [size in byte optional + K or M] [benchmark option:	rd
											wr
											rdwr
											cp
											fwr
											frd
											fcp
											bzero
											memcpy]

	CPU_TYPE for running benchmarks: minor or hpi"

if [ "$#" = "0" ]; then
	img="$imgdir/linaro-minimal-aarch64.img"
	#cpu_type="hpi"
	#cpu_type="atomic"
	cpu_type="minor"
	ncpus="2"
	mem_size="4GB"
	
elif [ "$#" = "1" ] && [ "$1" = "-h" ]; then
	echo "$usage"
	exit 0

elif [ "$#" = "3" ]; then
	img="$1"
	#cpu_type="hpi"
	#cpu_type="atomic"
	cpu_type="minor"
	ncpus="$2"
	mem_size="${3}GB"

elif [ "$#" = "4" ]; then
	img="$1"
	#cpu_type="hpi"
	#cpu_type="atomic"
	cpu_type="minor"
	ncpus="$2"
	mem_size="${3}GB"
	cmd="$4"

elif [ "$#" = "5" ]; then
	img="$1"
	ncpus="$2"
	mem_size="${3}GB"
	cmd="$4"
	cpu_type="$5"

else
	echo "$usage"
	exit 1
fi

if [ ! -e "$img" ]; then
	printf "\n${Red}Error. File \"$img\" not found.${NC}\n\n"
	echo "$usage"
	exit 1
fi


disk_opts="--disk-image=$img"

target="boot-lin-starter-fs"
config_script="configs/example/arm/starter_fs.py"

cpu_opts="--cpu=${cpu_type} --num-cores=$ncpus"
mem_opts="--mem-size=${mem_size}"

kernel="${syspath}/binaries/vmlinux.vexpress_gem5_v1_64"
kernel_opts="--kernel=${kernel}"
dtb_opts="--dtb=${syspath}/binaries/armv8_gem5_v1_${ncpus}cpu.dtb"
gem5_opts="--remote-gdb-port=0"
tlm_opts="--tlm-memory=transactor"

if [ -z ${tlm_opts+x} ]; then
	echo "TLM option disabled"
	exit 1
else
	echo "TLM option enabled"
	pushd $ROOTDIR/gem5
	git checkout configs/example/arm/starter_fs.py
	patch -p1 < $DIR/starter_fs-tlm.patch
	popd
	exit 1
fi

sim_name="${target}-${cpu_type}-${ncpus}c-${mem_size}-${currtime}"


if [[ ! -e $gem5_elf ]]; then
	$TOPDIR/build_gem5.sh
fi

bootscript="${sim_name}.rcS"
printf '#!/bin/bash\n' > $bootscript
printf "echo \"Greetings from gem5.TnT!\"\n" >> $bootscript
printf "echo \"Executing $bootscript now\"\n" >> $bootscript
printf '/sbin/m5 -h\n' >> $bootscript
#for_bash
if [ "$#" != "4" ] && [ "$#" != "5" ]; then
	printf '/bin/bash\n' >> $bootscript
else
	#for_benchmark
	printf "echo \"Command: ${cmd}\"\n" >> $bootscript
	printf 'ls\n' >> $bootscript
	printf 'cd arm64\n' >> $bootscript
	printf "./${cmd}\n" >> $bootscript
	printf "echo \"***********************\"\n" >> $bootscript
	printf "dmesg\n" >> $bootscript
	printf 'sleep 1\n' >> $bootscript
	printf '/sbin/m5 exit \n' >> $bootscript
fi


script_opt="--script=$ROOTDIR/gem5/$bootscript"

output_dir="${sim_name}"
mkdir -p ${output_dir}
logfile=${output_dir}/gem5.log

export M5_PATH="${syspath}":${M5_PATH}

# Start simulation
time $gem5_elf $gem5_opts \
	-d $output_dir \
	$config_script \
	$cpu_opts \
	$mem_opts \
	$kernel_opts \
	$dtb_opts \
	$disk_opts \
	$script_opt 2>&1 | tee $logfile

echo "***********************" >> $logfile
echo ${cmd} >> $logfile

popd
