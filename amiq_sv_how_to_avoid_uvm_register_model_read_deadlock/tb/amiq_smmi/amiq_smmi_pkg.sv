/******************************************************************************
 * DVT CODE TEMPLATE: package
 * Created by serdud on Nov 1, 2023
 * uvc_company = amiq, uvc_name = smmi
 * UVC for a Simple Memory Mapped Interface
 *******************************************************************************/

package amiq_smmi_pkg;

	// UVM macros
	`include "uvm_macros.svh"
	// UVM class library compiled in a package
	import uvm_pkg::*;

	// Configuration object
	`include "amiq_smmi_config_obj.svh"
	// Sequence item
	`include "amiq_smmi_item.svh"
	// Monitor
	`include "amiq_smmi_monitor.svh"
	// Driver
	`include "amiq_smmi_driver.svh"
	// Sequencer
	`include "amiq_smmi_sequencer.svh"
	// Agent
	`include "amiq_smmi_agent.svh"
	// Sequence library
	`include "amiq_smmi_seq_lib.svh"
	
	`include "amiq_smmi_reg_adapter.svh"
endpackage : amiq_smmi_pkg
