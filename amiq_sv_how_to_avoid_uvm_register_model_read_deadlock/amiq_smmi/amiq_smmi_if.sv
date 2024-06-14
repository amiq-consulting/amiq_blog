interface amiq_smmi_if(input clock, input reset);
	logic[31:0] addr;
	logic[31:0] wdata;
	logic rnw;
	logic req_valid;
	
	logic[31:0] rdata;
	logic[1:0] rsp_status;
	logic rsp_valid;
endinterface
