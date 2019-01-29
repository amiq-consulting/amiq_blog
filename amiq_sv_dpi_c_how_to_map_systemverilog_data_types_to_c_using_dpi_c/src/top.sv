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
* PROJECT:     How to Map SystemVerilog Data Types to C, Using DPI-C
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        https://www.amiq.com/consulting/2019/01/30/how-to-map-systemverilog-data-types-to-c-using-dpi-c/
*******************************************************************************/

module top();
   `include "dpi_c_ex_test.sv"

	dpi_c_ex_test test;

	initial begin
		test = new();
		assert(test.randomize());
		test.test();
		$display("--------------");
		$display("*** PASSED ***");
		$display("--------------");
		$finish();
	end

endmodule

