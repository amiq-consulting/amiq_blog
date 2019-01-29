#!/bin/bash
 #########################################################################################
 # (C) Copyright 2015 AMIQ Consulting
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 # http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
 #
 # NAME:        arun.sh
 # PROJECT:     dpi_c_ex
 # Description: Script example to compile and run simulation with different simulators
 # Usage:  arun.sh    [-tool  { ius | questa | vcs} ] --> specify what simulator to use (default: ius)"
 #
 #              arun.sh  -h[elp]                      --> print this message"
 # Example of using : ./arun.sh -tool ius
 #########################################################################################

##########################################################################################
#  Setting the variables
##########################################################################################
# Setting the SCRIPT_DIR variable used to find out where the script is stored
SCRIPT_DIR=`dirname $0`
SCRIPT_DIR=`cd ${SCRIPT_DIR} && pwd`

# Setting the PROJ_HOME variable used to find out where the current project is stored
export PROJ_HOME=`cd ${SCRIPT_DIR}/../ && pwd`


##########################################################################################
#  Methods
##########################################################################################

help() {
    echo "Usage:    run.sh [-tool   { ius | questa | vcs} ]  --> specify what simulator to use (default: ius)"
    echo "          run.sh -h[elp]                           --> print this message"
    echo "Example: ./run.sh -tool ius"
}

prepare_sim_nest() {
	cd ${PROJ_HOME}/sim
	if [ -d work ]; then
	   rm -rf work
	fi

	mkdir work
	cd work

	sim_dir=`pwd`
    echo "Start running in ${sim_dir}";
}

# Compile and run with IUS
run_with_ius() {
	prepare_sim_nest

    export NCROOT=`ncroot`
	gcc -I${NCROOT}/tools/inca/include -I${PROJ_HOME}/src -L${PROJ_HOME}/src \
		-Wall -m64 -fPIC -shared -o libdpi_c_ex.so \
	    ${PROJ_HOME}/src/dpi_c_ex.c

	export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PROJ_HOME}/sim

    irun -f ${PROJ_HOME}/sim/ius.options
}

# Compile and run with QUESTA
run_with_questa() {
    prepare_sim_nest
    echo "run -all;"  > vsim_cmds.do
    echo "exit;"     >> vsim_cmds.do


    vlib work
    vlog -f ${PROJ_HOME}/sim/questa.options

    vsim -64 -novopt top -sv_seed random -do vsim_cmds.do -c -lib work
}

# Compile and run with VCS
run_with_vcs() {

    prepare_sim_nest
    
	gcc -I${NCROOT}/tools/inca/include -I${PROJ_HOME}/src -L${PROJ_HOME}/src \
		-Wall -m64 -fPIC -shared -o libdpi_c_ex.so \
	    ${PROJ_HOME}/src/dpi_c_ex.c

	export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PROJ_HOME}/sim/work

    vcs -full64 -f ${PROJ_HOME}/sim/vcs.options +ntb_random_seed=random
	./simv
}


##########################################################################################
#  Extract options
##########################################################################################
while [ $# -gt 0 ]; do
   case `echo $1 | tr "[A-Z]" "[a-z]"` in
      -h|-help)
                help
                exit 0
                ;;
      -tool)
                tool=$2
                ;;
    esac
    shift
done

##########################################################################################
#  Verify that the simulator is one of IUS, QUESTA or VCS
##########################################################################################
case $tool in
    ius)
        echo "Selected tool: IUS..."
    ;;
    vcs)
        echo "Selected tool: VCS..."
    ;;
    questa)
        echo "Selected tool: Questa..."
    ;;
    *)
        echo "Illegal option for tool: $tool"
        exit 1;
    ;;
esac

run_with_${tool}

