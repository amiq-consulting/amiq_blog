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


`ifndef __SV_INIT
`define __SV_INIT

// A simple transaction class that we'll get from SC
class simple_transaction extends uvm_object;

	rand byte m_type;
	rand int unsigned m_len;
	rand int  m_data[$];

	// Generate compare method
	`uvm_object_utils(simple_transaction)
	
	function new(string name = "simple_transaction");
		super.new(name);
	endfunction

	function string convert2string();
		string s = "";
		s = $sformatf("%d @ %d @ ", m_type, m_len);

		for (int i=0; i < m_data.size(); ++i)
			s = $sformatf("%s%x ", s, m_data[i]);

		return s;
	endfunction

endclass

// Class that connects to SC and sends transactions
class sv_target extends uvm_component;

	`uvm_component_utils(sv_target)

	uvm_tlm_b_target_socket #(sv_target) sok;

	simple_transaction recv;

	// Header covergroup
	covergroup header_cg with function sample(simple_transaction recv);

		option.per_instance = 1;

		TYPE : coverpoint recv.m_type {
			ignore_bins nop = {0};
			bins all = {[1:5]};
		}
		LEN : coverpoint recv.m_len {
			illegal_bins zero = {0};
			bins min = {1};
			bins average[2] = {[2:8]};
			bins max = {9,10};
			
		}
	endgroup

	function new(string name = "sv_target", uvm_component parent=null);
		super.new(name,parent);
		header_cg = new;
		header_cg.set_inst_name({get_full_name(), ".header_cg"});
		
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		sok  = new("sok", this);
		recv = new();
		
		uvm_ml::ml_tlm2 #()::register(sok);

	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		assert(uvm_ml::connect("top.prod.sok", sok.get_full_name())) else
			`uvm_fatal("SOK_CONN_ERR", "Connect failed!");

	endfunction

	task b_transport(uvm_tlm_generic_payload gp, uvm_tlm_time delay);
		// Deserialize transaction
		{>>{recv.m_type, recv.m_len, recv.m_data}} = gp.m_data;

		`uvm_info("RECV ITEM", recv.convert2string(), UVM_LOW);

		// Sample coverage
		header_cg.sample(recv);

	endtask

endclass

`endif
