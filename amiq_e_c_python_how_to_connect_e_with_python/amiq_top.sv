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
* PROJECT:     How To Connect e-language with Python
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        https://www.amiq.com/consulting/2019/04/25/how-to-connect-e-language-with-python/
*******************************************************************************/

module amiq_top_e;
	reg in0, in1; //the inputs of the mux
	reg sel; //the selection of the mux
	reg out; //the output of the mux
	reg clk; //the clock signal
	
	//Instantiate the DUT
	amiq_mux2_1 dut(clk,sel,in0,in1,out);
	
	//Signals initialization
	initial begin
		in0=0;
		in1=0;
		sel=0;
		clk=0;
	end
	
	//Clock generator
	always#5 clk =~clk;
endmodule
