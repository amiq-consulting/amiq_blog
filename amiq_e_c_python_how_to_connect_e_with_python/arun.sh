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
#* PROJECT:     How To Connect e-Language with Python
#* Description: This is a code snippet from the Blog article mentioned on PROJECT
#* Link:        https://www.amiq.com/consulting/2019/04/25/how-to-connect-e-language-with-python/
# NAME:        arun.sh
# PROJECT:     dpi_c_ex
# Description: Script example to compile and run simulation 
#              arun.sh  -h[elp]                      --> print this message"
# Example of using : ./arun.sh
#******************************************************************************/


##########################################################################################
#  Methods
##########################################################################################

help() {
    echo "          arun.sh -h[elp]                           --> print this message"
    echo "Example: ./arun.sh"
}

# Run the e-language example with irun
run() {
    echo "Running e-language example with irun..."
	make run_e
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
    esac
    shift
done

##########################################################################################
#  Verify that the simulator is one of IRUN, QUESTA, VCS or run the e-language example
##########################################################################################

run

