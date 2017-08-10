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
* PROJECT:     How to Align SystemVerilog-to-SystemC TLM Transactions Definitions
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        https://www.amiq.com/consulting/2017/09/29/how-to-align-systemverilog-to-systemc-tlm-transactions-definitions/
*******************************************************************************/

`ifndef __SV_INITIATOR
`define __SV_INITIATOR

// A simple transaction class that we'll send to SC
class simple_transaction extends uvm_object;

	rand byte m_type;
	rand int unsigned m_len;
	rand int  m_data[$];

	// Generate compare method
	`uvm_object_utils_begin(simple_transaction)
		`uvm_field_int(m_type, UVM_COMPARE)
		`uvm_field_int(m_len, UVM_COMPARE)
		`uvm_field_queue_int(m_data, UVM_COMPARE)
	`uvm_object_utils_end

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
class sv_initiator extends uvm_component;

	`uvm_component_utils(sv_initiator)

	uvm_tlm_b_initiator_socket #() sok;

	function new(string name = "sv_initiator", uvm_component parent=null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		sok  = new("sok", this);

		uvm_ml::ml_tlm2 #()::register(sok);

	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		assert(uvm_ml::connect(sok.get_full_name(), "top.cons.sok")) else
			`uvm_fatal("SOK_CONN_ERR", "Connect failed!");

	endfunction

	function void print_arr(string label, byte unsigned data[]);

		string s = "";

		for (int i=0; i<data.size(); ++i)
			s= $sformatf("%s%x ", s, data[i]);
		
		`uvm_info(label, s, UVM_HIGH);

	endfunction


	task run_test();

		// Create a new GP object
		uvm_tlm_generic_payload gp = new();
		uvm_tlm_time delay = new();

		simple_transaction sent = new();
		simple_transaction recv = new();

		byte unsigned data[];

		// Create a new transaction
		sent.randomize() with {
			solve m_len before m_data;
			m_len < 10;
			m_type inside {[1:5]};
			m_data.size() == m_len;
		};

		`uvm_info("SEND ITEM", sent.convert2string(), UVM_HIGH);
		
		// Pack transaction
		data = {>>{sent.m_type,sent.m_len,sent.m_data}};
		
		print_arr("SEND STREAM", data);

		// Put the serialized transaction in the GP
		gp.set_data_length(data.size());
		gp.set_data(data);
		gp.set_command(UVM_TLM_READ_COMMAND);

		// Send to SC
		sok.b_transport(gp, delay);

		// Deserialize response
		{>>{recv.m_type, recv.m_len, recv.m_data}} = gp.m_data;

		`uvm_info("RECV ITEM", recv.convert2string(), UVM_HIGH);

		// Compare items
		if (sent.compare(recv)) begin
			`uvm_info("PASS", "Got same data", UVM_LOW);
		end else begin
			`uvm_info("FAIL", "Got diff data", UVM_LOW);
		end

		wait(delay);

	endtask

	function uvm_tlm_sync_e nb_transport_bw(uvm_tlm_generic_payload t,
			ref uvm_tlm_phase_e p,
			input uvm_tlm_time delay);
	endfunction

endclass

`endif
