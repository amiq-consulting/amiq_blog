/******************************************************************************
 * DVT CODE TEMPLATE: driver
 * Created by serdud on Nov 1, 2023
 * uvc_company = amiq, uvc_name = smmi
 *******************************************************************************/

`ifndef IFNDEF_GUARD_amiq_smmi_driver
`define IFNDEF_GUARD_amiq_smmi_driver

//------------------------------------------------------------------------------
//
// CLASS: amiq_smmi_driver
// TODO: Add waveform with protocol handhsake
//------------------------------------------------------------------------------

class amiq_smmi_driver extends uvm_driver #(amiq_smmi_item);

	// The virtual interface to HDL signals.
	protected virtual amiq_smmi_if m_amiq_smmi_vif;

	// Configuration object
	protected amiq_smmi_config_obj m_config_obj;

	`uvm_component_utils(amiq_smmi_driver)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Get the interface
		if(!uvm_config_db#(virtual amiq_smmi_if)::get(this, "", "m_amiq_smmi_vif", m_amiq_smmi_vif))
			`uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".m_amiq_smmi_vif"})

		// Get the configuration object
		if(!uvm_config_db#(amiq_smmi_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".m_config_obj"})
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		// Driving should be triggered by an initial reset pulse
		@(negedge m_amiq_smmi_vif.reset);
		reset_interface();
		@(posedge m_amiq_smmi_vif.reset);

		// Start driving
		get_and_drive();
	endtask : run_phase

	virtual task reset_interface();
		m_amiq_smmi_vif.req_valid   <= 0;
		m_amiq_smmi_vif.addr        <= 0;
		m_amiq_smmi_vif.rnw         <= 0;
		m_amiq_smmi_vif.wdata       <= 0;
	endtask : reset_interface


	virtual protected task get_and_drive();
		forever begin
			// Don't drive during reset
			while(m_amiq_smmi_vif.reset!==1) @(posedge m_amiq_smmi_vif.clock);

			// Get the next item from the sequencer
			seq_item_port.get_next_item(req);

			$cast(rsp, req.clone());
			rsp.set_id_info(req);

			// Drive the transaction
			`uvm_info(get_type_name(), $sformatf("amiq_smmi_driver %0d start driving item :\n%s", m_config_obj.m_agent_id, rsp.sprint()), UVM_HIGH)
			drive_item(rsp);
			`uvm_info(get_type_name(), $sformatf("amiq_smmi_driver %0d done driving item :\n%s", m_config_obj.m_agent_id, rsp.sprint()), UVM_HIGH)

			// Send item_done and a response to the sequencer
			seq_item_port.item_done();

			//TODO: reset handling
			if(m_config_obj.send_response == 1) begin
				while(m_amiq_smmi_vif.rsp_valid === 0)
					@(posedge m_amiq_smmi_vif.clock);
				rsp.rdata       = m_amiq_smmi_vif.rdata;
				rsp.rsp_status  = m_amiq_smmi_vif.rsp_status;

				seq_item_port.put_response(rsp);
			end
		end
	endtask : get_and_drive


	virtual protected task drive_item(amiq_smmi_item item);
		@(posedge m_amiq_smmi_vif.clock);
		m_amiq_smmi_vif.addr        <= item.addr;
		m_amiq_smmi_vif.rnw         <= item.rnw;
		m_amiq_smmi_vif.wdata       <= item.rnw ? 0 : item.wdata;
		m_amiq_smmi_vif.req_valid   <= 1'b1;
		@(posedge m_amiq_smmi_vif.clock);
		reset_interface();

	endtask : drive_item

endclass : amiq_smmi_driver

`endif // IFNDEF_GUARD_amiq_smmi_driver
