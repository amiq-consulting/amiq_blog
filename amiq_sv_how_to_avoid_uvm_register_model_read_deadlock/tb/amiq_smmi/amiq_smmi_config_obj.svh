/******************************************************************************
 * DVT CODE TEMPLATE: configuration object
 * Created by serdud on Nov 1, 2023
 * uvc_company = amiq, uvc_name = smmi
 *******************************************************************************/

`ifndef IFNDEF_GUARD_amiq_smmi_config_obj
`define IFNDEF_GUARD_amiq_smmi_config_obj

//------------------------------------------------------------------------------
//
// CLASS: amiq_smmi_config_obj
//
//------------------------------------------------------------------------------

class amiq_smmi_config_obj extends uvm_object;

	// Agent id
	int unsigned m_agent_id = 0;

	// Active/passive
	uvm_active_passive_enum m_is_active = UVM_ACTIVE;

	// Enable/disable checks
	bit m_checks_enable = 1;
	
	// If this is set, the driver will send a response item back through the sequencer
	bit send_response = 0;

	`uvm_object_utils_begin(amiq_smmi_config_obj)
		`uvm_field_int(m_agent_id, UVM_DEFAULT)
		`uvm_field_enum(uvm_active_passive_enum, m_is_active, UVM_DEFAULT)
		`uvm_field_int(m_checks_enable, UVM_DEFAULT)
	`uvm_object_utils_end

	function new(string name = "amiq_smmi_config_obj");
		super.new(name);
	endfunction: new

endclass : amiq_smmi_config_obj

`endif // IFNDEF_GUARD_amiq_smmi_config_obj
