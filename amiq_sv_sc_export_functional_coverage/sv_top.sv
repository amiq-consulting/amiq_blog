/******************************************************************************
* (C) Copyright 2017 AMIQ Consulting
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
* MODULE:      BLOG
* PROJECT:     How To Export Functional Coverage from SystemC to SystemVerilog
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        https://www.amiq.com/consulting/2017/08/18/how-to-export-functional-coverage-from-systemc-to-systemverilog/
*******************************************************************************/


`include "uvm_macros.svh"
import uvm_pkg::*;
import uvm_ml::*;

`include "sv_target.sv"

class sv_top extends uvm_test;
	
	`uvm_component_utils(sv_top)

	sv_target init;

	function new (string name = "sv_top", uvm_component parent=null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		init = sv_target::type_id::create("init", this);
	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
		#5000;
		phase.drop_objection(this);
	endtask

endclass

module topmodule;

	initial begin
		uvm_ml_run_test(.tops('{""}), .test(""));
	end

endmodule
