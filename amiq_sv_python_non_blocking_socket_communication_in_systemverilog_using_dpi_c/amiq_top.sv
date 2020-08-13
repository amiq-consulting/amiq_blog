/******************************************************************************
 * (C) Copyright 2020 AMIQ Consulting
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * MODULE:      BLOG
 * PROJECT:     Non-blocking socket communication in SV using DPI-C
 * Description: This is a code snippet from the Blog article mentioned on PROJECT
 * Link:        
 *******************************************************************************/
import amiq_sv_c_python_pkg::*;

module amiq_top();
	
	amiq_server_connector#(
		.hostname("127.0.0.1"), 
		.port(54000), 
		.delim("\n")
		) client = new();
	
	
	initial begin
		fork 
			// Connect to server and start communication threads 
			begin
				client.start();
			end
			
			// Send thread:
			//   Sends 1000 items to the server through the connector's send mailbox with a random command
			//   Command can be either "div" or "nop"
			//     div: return all the divisors of the number that follows this command
			//     nop: no operation 
			//   The nop command was added as a proof of concept to ensure that the system 
			//   won't be blocked on waiting a response that is not coming
			
			begin
				string cmd;
				for(int i=1;i<1000;i++) begin
					cmd = get_random_command();
					$display($sformatf("Sending command %s with data %3d \n", cmd, i));
					// An item has the following structure: cmd:value
					client.send_mbox.put($sformatf("%s:%0d", cmd, i));
				end
				
				// End of test mechanism:
				// the last item sent for processing is recognized by the server  
				// the server after receiving this item sends back a particular response
				// which is recognized by the testbench
				
				$display("Sending end of test item \n");
				client.send_mbox.put("end_test");
			end
			
			// Recv thread:
			// 	 Collecting received items through the connector's recv mailbox
			begin
				string recv_msg;
				forever begin
					client.recv_mbox.get(recv_msg);
					$display($sformatf("Received item: {%s}", recv_msg));
					
					// End of test mechanism:
					// recognizing the end of test item as a received item
					if(recv_msg == "end_test") begin
						$display("End of test");
						set_run_finish();
						$finish();
					end
				end
			end
		join	
	end
	
	// Get random command (div/nop)
	function string get_random_command();
		if($urandom_range(1,0)) 
			return "div";
		else 
			return "nop";
	endfunction
	
	
endmodule
