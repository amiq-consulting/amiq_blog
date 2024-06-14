/******************************************************************************
 * DVT CODE TEMPLATE: monitor
 * Created by serdud on Nov 1, 2023
 * uvc_company = amiq, uvc_name = smmi
 *******************************************************************************/

`ifndef IFNDEF_GUARD_amiq_smmi_monitor
`define IFNDEF_GUARD_amiq_smmi_monitor

//------------------------------------------------------------------------------
//
// CLASS: amiq_smmi_monitor
//
//------------------------------------------------------------------------------

class amiq_smmi_monitor extends uvm_monitor;

	// The virtual interface to HDL signals.
	protected virtual amiq_smmi_if m_amiq_smmi_vif;

	// Configuration object
	protected amiq_smmi_config_obj m_config_obj;

	// Collected item
	protected amiq_smmi_item m_collected_item;

	// Collected item is broadcast on this port
	uvm_analysis_port #(amiq_smmi_item) m_collected_item_port;

	`uvm_component_utils(amiq_smmi_monitor)

	function new (string name, uvm_component parent);
		super.new(name, parent);

		// Allocate collected_item_port.
		m_collected_item_port = new("m_collected_item_port", this);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Get the interface
		if(!uvm_config_db#(virtual amiq_smmi_if)::get(this, "", "m_amiq_smmi_vif", m_amiq_smmi_vif))
			`uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".m_amiq_smmi_vif"})

		// Get the configuration object
		if(!uvm_config_db#(amiq_smmi_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".m_config_obj"})
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		process main_thread; // main thread
		process rst_mon_thread; // reset monitor thread

		// Start monitoring only after an initial reset pulse
		@(negedge m_amiq_smmi_vif.reset);
		do @(posedge m_amiq_smmi_vif.clock);
		while(m_amiq_smmi_vif.reset!==1);

		`uvm_info(get_full_name(), $sformatf("Finished initial reset"), UVM_MEDIUM)

		// Start monitoring
		forever begin
			fork
				// Start the monitoring thread
				begin
					main_thread=process::self();
					collect_items();
				end
				// Monitor the reset signal
				begin
					rst_mon_thread = process::self();
					@(negedge m_amiq_smmi_vif.reset) begin
						// Interrupt current item at reset
						if(main_thread) main_thread.kill();
						// Do reset
						reset_monitor();
					end
				end
			join_any

			if (rst_mon_thread) rst_mon_thread.kill();
		end
	endtask : run_phase

	virtual protected task collect_items();
		forever begin
			m_collected_item = amiq_smmi_item::type_id::create("m_collected_item", this);

			while(m_amiq_smmi_vif.req_valid !== 1)
				@(posedge m_amiq_smmi_vif.clock);

			m_collected_item.addr   = m_amiq_smmi_vif.addr;
			m_collected_item.wdata  = m_amiq_smmi_vif.wdata;
			m_collected_item.rnw    = m_amiq_smmi_vif.rnw;

			while(m_amiq_smmi_vif.rsp_valid !== 1)
				@(posedge m_amiq_smmi_vif.clock);

			m_collected_item.rdata          = m_amiq_smmi_vif.rdata;
			m_collected_item.rsp_status     = m_amiq_smmi_vif.rsp_status;

			`uvm_info(get_full_name(), $sformatf("Item collected :\n%s", m_collected_item.sprint()), UVM_MEDIUM)
			
			if (m_config_obj.m_checks_enable)
				perform_item_checks();

			m_collected_item_port.write(m_collected_item);

		end
	endtask : collect_items

	virtual protected function void perform_item_checks();
	// TODO Perform item checks here
	endfunction : perform_item_checks

	virtual protected function void reset_monitor();
	// TODO Reset monitor specific state variables (e.g. counters, flags, buffers, queues, etc.)
	endfunction : reset_monitor

endclass : amiq_smmi_monitor

`endif // IFNDEF_GUARD_amiq_smmi_monitor
