/******************************************************************************
 * DVT CODE TEMPLATE: env
 * Created by serdud on Nov 2, 2023
 * uvc_company = amiq, uvc_name = ral_sandbox
 *******************************************************************************/

`ifndef IFNDEF_GUARD_amiq_ral_sandbox_env
`define IFNDEF_GUARD_amiq_ral_sandbox_env

//------------------------------------------------------------------------------
//
// CLASS: amiq_ral_sandbox_env
//
//------------------------------------------------------------------------------

class amiq_ral_sandbox_env extends uvm_env;

	amiq_ral_sandbox_env_cfg  env_cfg;

	// Components of the environment
	amiq_smmi_agent smmi_agent;
	
	/// TODO: Move to agent
	uvm_reg_predictor#(amiq_smmi_item) smmi_reg_predictor;
	amiq_smmi_reg_adapter smmi_reg_adapter;

	amiq_ral_req_rsp_handshake#(amiq_smmi_item) adapter_handshake;

	`uvm_component_utils(amiq_ral_sandbox_env)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db #(amiq_ral_sandbox_env_cfg)::get(this,"*","env_cfg", env_cfg))
			`uvm_fatal("ENV_FATAL", "env_cfg not found in the UVM factory!")

		uvm_config_db#(amiq_smmi_config_obj)::set(this,"*smmi_agent*", "m_config_obj", env_cfg.smmi_cfg);

		smmi_agent = amiq_smmi_agent::type_id::create("smmi_agent", this);
		smmi_reg_predictor = uvm_reg_predictor#(amiq_smmi_item)::type_id::create("smmi_reg_predictor", this);
		smmi_reg_adapter = amiq_smmi_reg_adapter::type_id::create("smmi_reg_adapter");

		if(env_cfg.instantiate_the_ral_handshake_adapter)
			adapter_handshake = amiq_ral_req_rsp_handshake#(amiq_smmi_item)::type_id::create("adapter_handshake", this);

	endfunction : build_phase

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		// Register model connections
		env_cfg.reg_model.default_map.set_sequencer(.sequencer(smmi_agent.m_sequencer), .adapter(smmi_reg_adapter));
		smmi_reg_predictor.map = env_cfg.reg_model.default_map;
		smmi_reg_predictor.adapter = smmi_reg_adapter;
		smmi_agent.m_monitor.m_collected_item_port.connect(smmi_reg_predictor.bus_in);

		/// Manual Handshake
		if(env_cfg.instantiate_the_ral_handshake_adapter) begin
			smmi_agent.m_monitor.m_collected_item_port.connect(adapter_handshake.rsp_port);
			adapter_handshake.seq_item_port.connect(smmi_agent.m_sequencer.seq_item_export);
			adapter_handshake.seqr = smmi_agent.m_sequencer;
		end

	endfunction : connect_phase

endclass : amiq_ral_sandbox_env

`endif // IFNDEF_GUARD_amiq_ral_sandbox_env
