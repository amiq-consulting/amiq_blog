module amiq_simple_reg_file(
		input logic clock,
		input logic reset,

		input logic[31:0] addr,
		input logic[31:0] wdata,
		input logic rnw,
		input logic req_valid,

		output logic[31:0] rdata,
		output logic[1:0] rsp_status,
		output logic rsp_valid
	);

	typedef enum int {
		REG_A_ADDR = 0,
		REG_B_ADDR = 20,
		REG_C_ADDR = 32,
		REG_D_ADDR = 60
	} address_t;

	typedef enum int {
		RESET = 0,
		GET_REQ = 1,
		SEND_RESP = 2
	} state_t;

	bit[31:0] reg_a;
	bit[31:0] reg_b;
	bit[31:0] reg_c;
	bit[31:0] reg_d;

	bit[1:0]  int_status;
	bit[31:0] int_rdata;
	bit int_rsp_valid;

	state_t int_state;
	state_t int_state_next;

	always @(posedge clock) begin
		if(reset === 0) begin
			rsp_status  <= 2'b0;
			rdata       <= 31'b0;
			rsp_valid   <= 0;
			int_state <= RESET;
		end
		else begin
			rsp_status  <= int_status;
			rdata       <= int_rdata;
			rsp_valid   <= int_rsp_valid;
			int_state   <= int_state_next;
		end
	end

	always @(*) begin

		int_status = 0;
		int_rdata = 0;
		int_rsp_valid = 0;

		case(int_state)
			RESET: begin
				reg_a = 0;
				reg_b = 0;
				reg_c = 0;
				reg_d = 0;
				int_state_next = GET_REQ;
			end
			GET_REQ: begin
				if(req_valid === 1) begin
					case(addr)
						REG_A_ADDR:begin
							if(rnw === 1)
								int_rdata = reg_a;
							else if(rnw === 0)
								reg_a = wdata;
						end
						REG_B_ADDR:begin
							if(rnw === 1)
								int_rdata = reg_b;
							else if(rnw === 0)
								reg_b = wdata;
						end
						REG_C_ADDR:begin
							if(rnw === 1)
								int_rdata = reg_c;
							else if(rnw === 0)
								reg_c = wdata;
						end
						REG_D_ADDR:begin
							if(rnw === 1)
								int_rdata = reg_d;
							else if(rnw === 0)
								reg_d = wdata;
						end
						default:
							int_status = 2'b11;
					endcase
					int_rsp_valid = 1;
					int_state_next = SEND_RESP;
				end
			end
			SEND_RESP : begin
				int_state_next = GET_REQ;
			end
		endcase

	end

endmodule