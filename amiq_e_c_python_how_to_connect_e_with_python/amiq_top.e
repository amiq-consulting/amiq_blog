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
<'

//Importing the C function: call_client
import client.e;

define HOSTNAME "heket"; //change with your hostname
define CLIENT_PORT 54000; //must be the same with server's port
define NOF_SAMPLES 10; //number of items to drive
define DELIM ","; //depends on how data is packed by the server

//Structure used to pack items for the DUT
struct stimuli_struct{
	!in0 : list of bit;
	!in1 : list of bit;
	!sel : list of bit;
	!delay0 : list of uint;
	!delay1 : list of uint;
	!delay_sel : list of uint;
};

//Mapping amiq_top_e.sv signals with e-language variables
unit signal_map{
	clk_p: in simple_port of bit is instance;
	event clk_r is rise(clk_p$)@sim;
	keep soft clk_p.hdl_path()=="clk";

	sel_p: out simple_port of bit is instance;
	keep soft sel_p.hdl_path()=="sel";

	in0_p: out simple_port of bit is instance;
	keep soft in0_p.hdl_path()=="in0";

	in1_p: out simple_port of bit is instance;
	keep soft in1_p.hdl_path()=="in1";

	out_p: in simple_port of bit is instance;
	keep soft out_p.hdl_path()=="out";
};

//An instance of this unit drives signals to DUT
unit e_driver{
	packed_stimuli: stimuli_struct; //this structure is used to pack the received stimuli
	
	!smp_p: signal_map;
	event clock is cycle @smp_p.clk_r; //clock posedge event
	
	//Driving in0 to DUT
	drive_in0()@clock is{
		var in0 : bit;
		var dly_in0 : uint; 
		for i from 0 to NOF_SAMPLES-1 do {
			dly_in0= packed_stimuli.delay0.pop0();
			in0 = packed_stimuli.in0.pop0();
			smp_p.in0_p$ = in0;
			wait [dly_in0];
		};
	};
	
	//Driving in1 to DUT
	drive_in1()@clock is{
		var in1 : bit;
		var dly_in1 : uint;
		for i from 0 to NOF_SAMPLES-1 do {
			dly_in1= packed_stimuli.delay1.pop0();
			in1 = packed_stimuli.in1.pop0();
			smp_p.in1_p$ = in1;
			wait [dly_in1];
		};
	};
	
	//Driving sel to DUT
	drive_sel()@clock is{
		var sel : bit;
		var dly_sel : uint;
		for i from 0 to NOF_SAMPLES-1{
			dly_sel= packed_stimuli.delay_sel.pop0();
			sel = packed_stimuli.sel.pop0();
			smp_p.sel_p$ = sel;
			wait [dly_sel];
		};
	};
	
	//Drive all signals to DUT in parallel 
	drive_signals()@sys.any is{
		all of{
			{drive_in0()};
			{drive_in1()};
			{drive_sel()};
		};
		stop_run();
	};
	
	//Ask the python Server to send item data and push it into packed_stimuli
	get_data_from_python() is{
		var data_from_python : string; //Values received as a string from python
		var list_of_values: list of string; //Split by DELIM string values 
		
		//Get NOF_SAMPLES sel values to complete packed_stimuli.sel queue
		data_from_python = sys.call_client(HOSTNAME,CLIENT_PORT,appendf("sel:%0d",NOF_SAMPLES));
		list_of_values = str_split(data_from_python,DELIM);
		for each in list_of_values do{
			packed_stimuli.sel.push(it.as_a(uint));
		};
		
		//Get NOF_SAMPLES in values to complete packed_stimuli.in0 queue
		data_from_python = sys.call_client(HOSTNAME,CLIENT_PORT,appendf("in:%0d",NOF_SAMPLES));
		list_of_values = str_split(data_from_python,DELIM);
		for each in list_of_values do{
			packed_stimuli.in0.push(it.as_a(uint));
		};
		
		//Get NOF_SAMPLES in values to complete packed_stimuli.in1 queue
		data_from_python = sys.call_client(HOSTNAME,CLIENT_PORT,appendf("in:%0d",NOF_SAMPLES));
		list_of_values = str_split(data_from_python,DELIM);
		for each in list_of_values do{
			packed_stimuli.in1.push(it.as_a(uint));
		};
		
		//Get NOF_SAMPLES delay values to complete packed_stimuli.delay0 queue
		data_from_python = sys.call_client(HOSTNAME,CLIENT_PORT,appendf("delay:%0d",NOF_SAMPLES));
		list_of_values = str_split(data_from_python,DELIM);
		for each in list_of_values do{
			packed_stimuli.delay0.push(it.as_a(uint));
		};
		
		//Get NOF_SAMPLES delay values to complete packed_stimuli.delay1 queue
		data_from_python = sys.call_client(HOSTNAME,CLIENT_PORT,appendf("delay:%0d",NOF_SAMPLES));
		list_of_values = str_split(data_from_python,DELIM);
		for each in list_of_values do{
			packed_stimuli.delay1.push(it.as_a(uint));
		};
		
		//Get NOF_SAMPLES delay values to complete packed_stimuli.delay_sel queue
		data_from_python = sys.call_client(HOSTNAME,CLIENT_PORT,appendf("delay:%0d",NOF_SAMPLES));
		list_of_values = str_split(data_from_python,DELIM);
		for each in list_of_values do{
			packed_stimuli.delay_sel.push(it.as_a(uint));
		};
	};
	
	run() is also{
		get_data_from_python();
		start drive_signals();
	};
};

extend sys {
	driver: e_driver is instance;
	smp: signal_map is instance;
	
	//Set the path to SV top
	keep smp.hdl_path() == "amiq_top_e";
	
	//Make signals mapping available for the driver
	connect_pointers() is also{
		driver.smp_p=smp;
	};
};
'>
