
/******************************************************************************
 * DVT CODE TEMPLATE: testbench top module
 * Created by serdud on Nov 2, 2023
 * uvc_company = amiq, uvc_name = smmi
 *******************************************************************************/

module amiq_ral_sandbox_tb_top;

	// Import the UVM package
	import uvm_pkg::*;
	
	import amiq_ral_sandbox_tc_pkg::*;

	// Clock and reset signals
	reg clock;
	reg reset;

	// The interface
	amiq_smmi_if smmi_if(clock,reset);

	// TODO add other interfaces if needed

	// TODO instantiate the DUT
	amiq_simple_reg_file dut(
		.clock(smmi_if.clock),
		.reset(smmi_if.reset),
		.addr(smmi_if.addr),
		.wdata(smmi_if.wdata),
		.rnw(smmi_if.rnw),
		.req_valid(smmi_if.req_valid),
		.rdata(smmi_if.rdata),
		.rsp_status(smmi_if.rsp_status),
		.rsp_valid(smmi_if.rsp_valid)
	);

	initial begin
		// Propagate the interface to all the components that need it
		uvm_config_db#(virtual amiq_smmi_if)::set(uvm_root::get(), "*", "m_amiq_smmi_vif", smmi_if);
		// Start the test
		run_test();
	end

// Generate clock
	always
		#5 clock=~clock;

// Generate reset
	initial begin
		reset <= 1'b1;
		clock <= 1'b1;
		#21 reset <= 1'b0;
		#51 reset <= 1'b1;
	end
endmodule