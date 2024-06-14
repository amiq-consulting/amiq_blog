/******************************************************************************
 * DVT CODE TEMPLATE: agent
 * Created by serdud on Nov 1, 2023
 * uvc_company = amiq, uvc_name = smmi
 *******************************************************************************/

`ifndef IFNDEF_GUARD_amiq_smmi_agent
`define IFNDEF_GUARD_amiq_smmi_agent

//------------------------------------------------------------------------------
//
// CLASS: amiq_smmi_agent
//
//------------------------------------------------------------------------------

class amiq_smmi_agent extends uvm_agent;

	// Configuration object
	protected amiq_smmi_config_obj m_config_obj;

	amiq_smmi_driver m_driver;
	amiq_smmi_sequencer m_sequencer;
	amiq_smmi_monitor m_monitor;

	`uvm_component_utils(amiq_smmi_agent)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Get the configuration object
		if(!uvm_config_db#(amiq_smmi_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".m_config_obj"})

		// Propagate the configuration object to monitor
		uvm_config_db#(amiq_smmi_config_obj)::set(this, "m_monitor", "m_config_obj", m_config_obj);
		// Create the monitor
		m_monitor = amiq_smmi_monitor::type_id::create("m_monitor", this);

		if(m_config_obj.m_is_active == UVM_ACTIVE) begin
			// Propagate the configuration object to driver
			uvm_config_db#(amiq_smmi_config_obj)::set(this, "m_driver", "m_config_obj", m_config_obj);
			// Create the driver
			m_driver = amiq_smmi_driver::type_id::create("m_driver", this);

			// Create the sequencer
			m_sequencer = amiq_smmi_sequencer::type_id::create("m_sequencer", this);
		end
	endfunction : build_phase

	virtual function void connect_phase(uvm_phase phase);

		if(m_config_obj.m_is_active == UVM_ACTIVE) begin
			m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
		end
	endfunction : connect_phase

endclass : amiq_smmi_agent

`endif // IFNDEF_GUARD_amiq_smmi_agent
