#!/bin/bash
#/******************************************************************************
#* (C) Copyright 2019 AMIQ Consulting
#*
#* Licensed under the Apache License, Version 2.0 (the "License");
#* you may not use this file except in compliance with the License.
#* You may obtain a copy of the License at
#*
#* http://www.apache.org/licenses/LICENSE-2.0
#*
#* Unless required by applicable law or agreed to in writing, software
#* distributed under the License is distributed on an "AS IS" BASIS,
#* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#* See the License for the specific language governing permissions and
#* limitations under the License.
#*
#* MODULE:      BLOG
#* PROJECT:     How To Connect SystemVerilog with Python
#* Description: This is a code snippet from the Blog article mentioned on PROJECT
#* Link:        https://www.amiq.com/consulting/2019/03/22/how-to-connect-systemverilog-with-python/
# NAME:        arun.sh
# PROJECT:     dpi_c_ex
# Description: Script example to compile and run simulation with different simulators
# Usage:  arun.sh    [-tool  { xrun | questa | vcs} ] --> specify what simulator to use (default: xrun)"
#
#              arun.sh  -h[elp]                      --> print this message"
# Example of using : ./arun.sh -tool xrun
#******************************************************************************/

##########################################################################################
#  Methods
##########################################################################################

help() {
    echo "Usage:    run.sh [-tool   { xrun | questa | vcs} ]  --> specify what simulator to use (default: xrun)"
    echo "          run.sh -h[elp]                           --> print this message"
    echo "Example: ./run.sh -tool xrun"
}

# Compile and run with xrun
run_with_xrun() {
    make run_xrun
}

# Compile and run with QUESTA
run_with_questa() {
 	if [ -d work ]; then
	   rm -rf work
	fi
	mkdir work
	
	cd work
    vlib work
    echo "run -all;"  > vsim_cmds.do
    echo "exit;"     >> vsim_cmds.do
  	cd ${PROJ_HOME}
  	
    make run_questa
}

# Compile and run with VCS
run_with_vcs() {
	make run_vcs
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
#  Verify that the simulator is one of IRUN, QUESTA or VCS
##########################################################################################
case $tool in
    xrun)
        echo "Selected tool: XRUN..."
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
