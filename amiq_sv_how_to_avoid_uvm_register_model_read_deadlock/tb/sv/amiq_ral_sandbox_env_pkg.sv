/******************************************************************************
 * DVT CODE TEMPLATE: package
 * Created by serdud on Nov 2, 2023
 * uvc_company = amiq, uvc_name = ral_adapter_handshake
 *******************************************************************************/

package amiq_ral_sandbox_env_pkg;

	// UVM macros
	`include "uvm_macros.svh"
	// UVM class library compiled in a package
	import uvm_pkg::*;

	import amiq_smmi_pkg::*;
	import amiq_ral_req_rsp_handshake_pkg::*;

	`include "amiq_ral_sandbox_reg_model.svh"
	`include "amiq_ral_sandbox_env_cfg.svh"
	`include "amiq_ral_req_rsp_handshake.svh"
	`include "amiq_ral_sandbox_env.svh"


endpackage : amiq_ral_sandbox_env_pkg