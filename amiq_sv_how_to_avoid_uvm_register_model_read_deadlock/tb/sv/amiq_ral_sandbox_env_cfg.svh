/******************************************************************************
 * DVT CODE TEMPLATE: configuration object
 * Created by serdud on Nov 7, 2023
 * uvc_company = amiq, uvc_name = ral_adapter_handhshake_env
 *******************************************************************************/

`ifndef IFNDEF_GUARD_amiq_ral_adapter_handshake_env_cfg
`define IFNDEF_GUARD_amiq_ral_adapter_handshake_env_cfg

//------------------------------------------------------------------------------
//
// CLASS: amiq_ral_adapter_handshake_env_cfg
//
//------------------------------------------------------------------------------

class amiq_ral_sandbox_env_cfg extends uvm_object;
	  
	// Active/passive
	uvm_active_passive_enum m_is_active = UVM_ACTIVE;

	// Enable/disable checks
	bit m_checks_enable = 1;

	// Agent config
	amiq_smmi_config_obj smmi_cfg;
	
	// Controls if the Handshake adapter is instantiated and connected to the RAL env.
	bit instantiate_the_ral_handshake_adapter;

	amiq_ral_sandbox_reg_model reg_model;	

	// TODO It's very important that you use these macros on all the configuration fields. If you miss any field it will not be propagated correctly.
	`uvm_object_utils_begin(amiq_ral_sandbox_env_cfg)
		`uvm_field_enum(uvm_active_passive_enum, m_is_active, UVM_DEFAULT)
		`uvm_field_int(m_checks_enable, UVM_DEFAULT)
	`uvm_object_utils_end

	function new(string name = "amiq_ral_adapter_handshake_env_cfg");
		super.new(name);
		
		smmi_cfg = amiq_smmi_config_obj::type_id::create("smmi_cfg");
	endfunction: new

endclass : amiq_ral_sandbox_env_cfg

`endif // IFNDEF_GUARD_amiq_ral_adapter_handshake_env_cfg