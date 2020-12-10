`ifndef AMIQ_PKG
`define AMIQ_PKG


package amiq_sv_c_python_pkg;

	
	// used to configure connection to server at the beginning of the simulation 
	import "DPI-C" function int configure(string hostname, int port);
	// used to set the timeout for send and recv functions
	import "DPI-C" function void set_timeout(int miliseconds);
	// used to send data to server
	import "DPI-C" context task send_data(string data, int len, output int result);
	// used to start a thread waiting for data as long as the simulation is running
	import "DPI-C" context task recv_thread();
	// used to inform the client that simulation is completed
	import "DPI-C" function void set_run_finish();
	// callback function which is called whenever a message is received
	export "DPI-C" function recv_callback;
	// used to give simulator chance to make a context switch
	export "DPI-C" task consume_time;
	
	
	`include "amiq_server_connector.svh";
	
endpackage 

`endif
