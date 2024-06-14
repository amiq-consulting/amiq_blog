/******************************************************************************
 * DVT CODE TEMPLATE: sequencer
 * Created by serdud on Nov 1, 2023
 * uvc_company = amiq, uvc_name = smmi
 *******************************************************************************/

`ifndef IFNDEF_GUARD_amiq_smmi_sequencer
`define IFNDEF_GUARD_amiq_smmi_sequencer

//------------------------------------------------------------------------------
//
// CLASS: amiq_smmi_sequencer
//
//------------------------------------------------------------------------------

class amiq_smmi_sequencer extends uvm_sequencer #(amiq_smmi_item);
	
	`uvm_component_utils(amiq_smmi_sequencer)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : amiq_smmi_sequencer

`endif // IFNDEF_GUARD_amiq_smmi_sequencer
