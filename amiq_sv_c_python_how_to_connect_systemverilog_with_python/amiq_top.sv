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

/////////////////////////////////////////////////////////////////////////////
////////////////////////////////// DEFINES //////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
`define HOSTNAME "heket"
`define PORT 54000
`define DELIM ","
`define NOF_VALUES 20

typedef struct{
	bit in0[$], in1[$];
	bit sel[$];
	int delay0[$];
	int delay1[$];
	int delay_sel[$];
	int nof_samples;
} stimuli_struct;

module amiq_top();
/////////////////////////////////////////////////////////////////////////////
//////////////////////////////// DECLARATIONS ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////
	reg in0, in1; //the inputs of the mux
	reg sel; //the selection of the mux
	reg out; //the output of the mux
	reg clk;

	string msg; //message used to store the Server's response
	stimuli_struct packed_stimuli; //this structure is used to pack the received stimuli

	amiq_mux2_1 dut(clk, sel, in0, in1, out);

	always#5 clk =~clk;

/////////////////////////////////////////////////////////////////////////////
///////////////////////////////// FUNCTIONS /////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
	/*
	 * The decoder function takes the Server's response(message) and stores the
		decoded values in the ref stimuli according to the given value_type.
	 * If an error occurs, then the simulation will finish.
	 */
	function automatic void decoder(string message, string value_type, ref stimuli_struct stimuli);
		int offset;
		string aux;

		offset=0;

		if(message.compare("error")==0)
			$finish();

		for (int i = 0; i < message.len(); i=i+1) 
		if (message.getc(i) == `DELIM || i==(message.len()-1)) begin
		   case(value_type)
			"in0":begin
				if(i==(message.len()-1))
					aux=message.substr(offset,i);
				else
					aux=message.substr(offset,i-1);
				stimuli.in0.push_back(aux.atoi());
			end
			"delay0":begin
				if(i==(message.len()-1))
					aux=message.substr(offset,i);
				else
					aux=message.substr(offset,i-1);
				stimuli.delay0.push_back(aux.atoi());
			end
			"in1":begin
				if(i==(message.len()-1))
					aux=message.substr(offset,i);
				else
					aux=message.substr(offset,i-1);
				packed_stimuli.in1.push_back(aux.atoi());
			end
			"delay1":begin
				if(i==(message.len()-1))
					aux=message.substr(offset,i);
				else
					aux=message.substr(offset,i-1);
				stimuli.delay1.push_back(aux.atoi());
			end
			"sel":begin
				if(i==(message.len()-1))
					aux=message.substr(offset,i);
				else
					aux=message.substr(offset,i-1);
				stimuli.sel.push_back(aux.atoi());
			end
			"delay_sel":begin
				if(i==(message.len()-1))
					aux=message.substr(offset,i);
				else
					aux=message.substr(offset,i-1);
				stimuli.delay_sel.push_back(aux.atoi());
			end
		   endcase
		   offset=i+1;
		end

	endfunction
	
	/*
	 * The display_items function prints all packed items from the given parameter, items
	 */
	function void display_items(stimuli_struct items);
		string msg;
	
		for(int i=0;i<items.nof_samples;i++) begin
			msg=$sformatf("[#%0d]\nin0=%b\nin1=%b\nsel=%b\ndelay0=%0d\ndelay1=%0d\ndelay_sel=%0d\n",i,
			items.in0[i],items.in1[i],items.sel[i],items.delay0[i],
			items.delay1[i],items.delay_sel[i]);
			$display(msg);
		end
	endfunction
	
	task automatic drive_in0(stimuli_struct stimuli);
		int delay=0;
		while(stimuli.in0.size()>0) begin
			repeat(delay)
				@(posedge clk);
				
			in0=stimuli.in0.pop_front();
			delay=stimuli.delay0.pop_front();
		end
	endtask

	task automatic drive_in1(stimuli_struct stimuli);
		int delay=0;
		while(stimuli.in1.size()>0) begin
			repeat(delay)
				@(posedge clk);
				
			in1=stimuli.in1.pop_front();
			delay=stimuli.delay1.pop_front();
		end
	endtask

	task automatic drive_sel(stimuli_struct stimuli);
		int delay=0;
		while(stimuli.sel.size()>0) begin
			repeat(delay)
				@(posedge clk);
				
			sel=stimuli.sel.pop_front();
			delay=stimuli.sel.pop_front();
		end
	endtask
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////// INITIAL SETUP ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////
	initial begin
		in0=0;
		in1=0;
		sel=0;
		packed_stimuli.nof_samples=`NOF_VALUES;
		clk=0;
	end
	
	//Importing call_client from client.cc using DPI-C
	import "DPI-C" function string call_client(string hostname, int port, string message);
	
/////////////////////////////////////////////////////////////////////////////
////////////////////////////// ACQUIRING DATA ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////
	initial begin
		msg=call_client(`HOSTNAME,`PORT,{"sel:",$sformatf("%0d",`NOF_VALUES)});
		decoder(msg,"sel",packed_stimuli);
		msg=call_client(`HOSTNAME,`PORT,{"delay:",$sformatf("%0d",`NOF_VALUES)});
		decoder(msg,"delay0",packed_stimuli);
		msg=call_client(`HOSTNAME,`PORT,{"delay:",$sformatf("%0d",`NOF_VALUES)});
		decoder(msg,"delay1",packed_stimuli);
		msg=call_client(`HOSTNAME,`PORT,{"in:",$sformatf("%0d",`NOF_VALUES)});
		decoder(msg,"in1",packed_stimuli);
		msg=call_client(`HOSTNAME,`PORT,{"in:",$sformatf("%0d",`NOF_VALUES)});
		decoder(msg,"in0",packed_stimuli);
		msg=call_client(`HOSTNAME,`PORT,{"delay:",$sformatf("%0d",`NOF_VALUES)});
		decoder(msg,"delay_sel",packed_stimuli);

		display_items(packed_stimuli);
	end
	
/////////////////////////////////////////////////////////////////////////////
////////////////////////////// TESTING THE RTL //////////////////////////////
/////////////////////////////////////////////////////////////////////////////	
	initial begin
		fork
			begin
				drive_in0(packed_stimuli);
			end
			
			begin
				drive_in1(packed_stimuli);
			end
			
			begin
				drive_sel(packed_stimuli);
			end
		join
		
		$finish();
	end
endmodule
