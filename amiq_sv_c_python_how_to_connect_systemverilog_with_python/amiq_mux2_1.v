/******************************************************************************
* (C) Copyright 2019 AMIQ Consulting
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
* PROJECT:     How To Connect SystemVerilog with Python
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        https://www.amiq.com/consulting/2019/03/22/how-to-connect-systemverilog-with-python/
*******************************************************************************/

module amiq_mux2_1(input clk, input sel, input in0, input in1, output reg out);
	initial out=0;
	
	always@(posedge clk) begin
		out<=sel?in1:in0;	
	end
endmodule
