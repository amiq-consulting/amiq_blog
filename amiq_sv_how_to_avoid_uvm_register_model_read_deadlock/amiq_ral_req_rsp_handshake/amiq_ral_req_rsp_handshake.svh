/******************************************************************************
 * DVT CODE TEMPLATE: component
 * Created by serdud on Nov 8, 2023
 * uvc_company = amiq, uvc_name = ral_adapter_handshake
 *******************************************************************************/

`ifndef IFNDEF_GUARD_amiq_ral_adapter_handshake
`define IFNDEF_GUARD_amiq_ral_adapter_handshake

//------------------------------------------------------------------------------
//
// CLASS: amiq_ral_adapter_handshake
//
//------------------------------------------------------------------------------

class amiq_ral_req_rsp_handshake#(type T = uvm_sequence_item) extends uvm_component;

	typedef amiq_ral_req_rsp_handshake#(T)  amiq_ral_adapter_handshake_t;

	`uvm_component_utils(amiq_ral_adapter_handshake_t)

	uvm_analysis_imp#(T, amiq_ral_adapter_handshake_t) rsp_port;
	uvm_seq_item_pull_port#(T,T) seq_item_port;

	uvm_sequencer#(T) seqr;

	function new (string name, uvm_component parent);
		super.new(name, parent);

		rsp_port        = new("rsp_port", this);
		seq_item_port   = new("seq_item_port", this);
	endfunction : new

	virtual function void write(T rsp_item);
		T req;

		req = seqr.last_req();
		rsp_item.set_id_info(req);

		fork
			seq_item_port.put(rsp_item);
		join_none
	endfunction

endclass : amiq_ral_req_rsp_handshake

`endif // IFNDEF_GUARD_amiq_ral_adapter_handshake