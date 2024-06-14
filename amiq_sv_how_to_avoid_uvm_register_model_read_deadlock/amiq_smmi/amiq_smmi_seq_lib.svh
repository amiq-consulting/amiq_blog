/******************************************************************************
 * DVT CODE TEMPLATE: sequence
 * Created by serdud on Nov 1, 2023
 * uvc_company = amiq, uvc_name = smmi
 * uvc_trans = item, seq_name = sequence
 *******************************************************************************/

`ifndef IFNDEF_GUARD_amiq_smmi_sequence
`define IFNDEF_GUARD_amiq_smmi_sequence

//------------------------------------------------------------------------------
//
// CLASS: amiq_smmi_sequence
//
//------------------------------------------------------------------------------

class amiq_smmi_sequence extends uvm_sequence#(amiq_smmi_item);

	// Item to be used by the sequence
	amiq_smmi_item this_trans;

	`uvm_object_utils(amiq_smmi_sequence)

	// new - constructor
	function new(string name = "amiq_smmi_sequence");
		super.new(name);
	endfunction : new

	// Sequence body
	virtual task body();
		`uvm_do(this_trans)
	endtask

endclass : amiq_smmi_sequence

`endif // IFNDEF_GUARD_amiq_smmi_sequence