/******************************************************************************
 * DVT CODE TEMPLATE: base test
 * Created by serdud on Nov 2, 2023
 * uvc_company = amiq, uvc_name = ral_sandbox
 *******************************************************************************/

`ifndef IFNDEF_GUARD_amiq_ral_sandbox_base_test
`define IFNDEF_GUARD_amiq_ral_sandbox_base_test

class amiq_ral_sandbox_base_test extends uvm_test;

	// Env instance
	amiq_ral_sandbox_env      m_env;
	amiq_ral_sandbox_env_cfg  m_env_cfg;

	amiq_ral_sandbox_reg_model m_reg_model;

	/// TODO:Add comments --- remove all and use the env cfg
	bit send_response;
	bit instantiate_the_ral_handshake_adapter;

	time drain_time;

	`uvm_component_utils(amiq_ral_sandbox_base_test)

	function new(string name = "amiq_ral_sandbox_base_test", uvm_component parent=null);
		super.new(name,parent);
		drain_time = 10; /// TODO: make it a plusarg
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		m_env           = amiq_ral_sandbox_env::type_id::create("m_env", this);
		m_env_cfg       = amiq_ral_sandbox_env_cfg::type_id::create("m_env_cfg", this);
		m_reg_model     = amiq_ral_sandbox_reg_model::type_id::create("m_reg_model", this);

		m_reg_model.build();
		m_env_cfg.reg_model = m_reg_model;

		if(!$value$plusargs("send_response=%0d", send_response)) begin
			send_response = 0;
			`uvm_info(get_full_name(), $sformatf("No plusarg provided, setting send_response to %0d",send_response), UVM_NONE)
		end else
			`uvm_info(get_full_name(), $sformatf("Send response is %0d", send_response), UVM_NONE)

		if(!$value$plusargs("instantiate_the_ral_handshake_adapter=%0d", instantiate_the_ral_handshake_adapter)) begin
			instantiate_the_ral_handshake_adapter = 0;
			`uvm_info(get_full_name(), $sformatf("No plusarg provided, setting instantiate_the_ral_handshake_adapter to %0d",instantiate_the_ral_handshake_adapter), UVM_NONE)
		end else
			`uvm_info(get_full_name(), $sformatf("instantiate_the_ral_handshake_adapter is %0d", instantiate_the_ral_handshake_adapter), UVM_NONE)

		m_env_cfg.smmi_cfg.send_response                = send_response;
		m_env_cfg.instantiate_the_ral_handshake_adapter = instantiate_the_ral_handshake_adapter;
		uvm_config_db#(amiq_ral_sandbox_env_cfg) ::set(this, "*", "env_cfg", m_env_cfg);

	endfunction : build_phase

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this);
		
		start_sequences();
		
		phase.phase_done.set_drain_time(this, drain_time);
		phase.drop_objection(this);
	endtask : run_phase

	virtual task start_sequences();
		`uvm_warning("BASE_TEST_WARR", "No sequence has been started")
	endtask

endclass : amiq_ral_sandbox_base_test

class amiq_ral_sandbox_test extends amiq_ral_sandbox_base_test;
	`uvm_component_utils(amiq_ral_sandbox_test)

	function new(string name = "amiq_ral_sandbox_test", uvm_component parent=null);
		super.new(name,parent);

		drain_time = 20000;
	endfunction : new

	virtual task start_sequences();
		uvm_status_e status;
		uvm_reg_data_t rdata;
		m_reg_model.reg_a.write(status, 'hDA);
		m_reg_model.reg_a.read(status, rdata, .path(UVM_FRONTDOOR));

		if(rdata != 'hDA)
			`uvm_error("MISMATCH", $sformatf("Expected %0x, received %0x",'hDA,rdata))

	endtask

endclass : amiq_ral_sandbox_test

`endif // IFNDEF_GUARD_amiq_ral_sandbox_base_test