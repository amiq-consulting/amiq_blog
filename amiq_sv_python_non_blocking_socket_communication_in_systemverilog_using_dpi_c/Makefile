# /******************************************************************************
# * (C) Copyright 2019 AMIQ Consulting
# *
# * Licensed under the Apache License, Version 2.0 (the "License");
# * you may not use this file except in compliance with the License.
# * You may obtain a copy of the License at
# *
# * http://www.apache.org/licenses/LICENSE-2.0
# *
# * Unless required by applicable law or agreed to in writing, software
# * distributed under the License is distributed on an "AS IS" BASIS,
# * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# * See the License for the specific language governing permissions and
# * limitations under the License.
# *
# * MODULE:      BLOG
# * PROJECT:     How To Connect SystemVerilog with Python
# * Description: This is a code snippet from the Blog article mentioned on PROJECT
# * Link:        https://www.amiq.com/consulting/2019/03/22/how-to-connect-systemverilog-with-python/
# *******************************************************************************/

run_xrun: build_xrun
	xrun -f ${PROJ_HOME}/sim/sim.options

run_questa: build_questa
	cd work; vsim -64 -novopt amiq_top -do vsim_cmds.do -c -lib work
	
run_vcs: build_vcs
	./simv
	
build_xrun:
	xrun -f ${PROJ_HOME}/sim/sim.options -c $(OPTIONS)

build_questa: 
	cd work; vlog -f ${PROJ_HOME}/sim/questa.options;
	
build_vcs:
	vcs -full64 -CC -std=c++11 -f ${PROJ_HOME}/sim/vcs.options	
	
clean:
	find . -type f -not \( -name '*.sv' -or -iname '*.sh' -or -iname '*.v' -or -iname '*.py' -or -iname '*.cc' -or -iname 'Makefile' -or -iname '*.options' \) -delete
	find . -type d -not \( -name 'sim' -or -iname 'sim/*' -or -name '.*' \) -exec rm -rf {} +
	
.PHONY: clean