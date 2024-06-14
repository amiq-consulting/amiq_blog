/******************************************************************************
 * DVT CODE TEMPLATE: sequence item
 * Created by serdud on Nov 1, 2023
 * uvc_company = amiq, uvc_name = smmi
 *******************************************************************************/

`ifndef IFNDEF_GUARD_amiq_smmi_item
`define IFNDEF_GUARD_amiq_smmi_item

//------------------------------------------------------------------------------
//
// CLASS: amiq_smmi_item
//
//------------------------------------------------------------------------------

class amiq_smmi_item extends uvm_sequence_item;
	
	// TODO add comment
	rand int addr;
	rand int wdata;
	rand bit rnw;
	
	// TODO add comment
	int 	 rdata;
	bit[1:0] rsp_status;

	`uvm_object_utils_begin(amiq_smmi_item)
		`uvm_field_int(addr, UVM_DEFAULT)
		`uvm_field_int(wdata, UVM_DEFAULT)
		`uvm_field_int(rnw, UVM_DEFAULT)
		`uvm_field_int(rdata, UVM_DEFAULT)
		`uvm_field_int(rsp_status, UVM_DEFAULT)
	`uvm_object_utils_end

	function new (string name = "amiq_smmi_item");
		super.new(name);
	endfunction : new

endclass :  amiq_smmi_item

`endif // IFNDEF_GUARD_amiq_smmi_item
