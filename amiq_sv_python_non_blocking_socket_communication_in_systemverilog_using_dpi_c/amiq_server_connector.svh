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

///////////////////////////////////////////////////////////////////////////////// 
////////////////////////////// GLOBAL VARIABLES /////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

// used for notifying other components that a message has been received
event receive_from_server;
// used for storing messages from server that are ready to be processed
string msgs_q[$];
// used for storing incomplete messages
string msg_saved = "";

///////////////////////////////////////////////////////////////////////////////// 
///////////////////// DEFINITIONS OF EXPORTED FUNCTIONS /////////////////////////
///////////////////////////////////////////////////////////////////////////////// 

// Each time the DPI-C layer receives a message 
// from the server the recv_callback function is called.
// The message received is stored in a queue
// and an event is triggered to notify the amiq_server_connector
function void recv_callback(input string msg);
	int last_index;
	last_index = msg.len()-1;
	
	// Check if the message is complete
	// A message is complete if the last character corresponds to a newline
	while(last_index >= 0 && msg[last_index] != "\n") begin
		last_index--;
	end
	if (last_index < 0) begin
		$error("No delimitator character found in message!");
	end	
	
	// If the message is complete
	// store and trigger event
	if (last_index == msg.len()-1) 
	begin
		msg = {msg_saved,msg};
		msgs_q.push_back(msg);
		msg_saved = "";
		-> receive_from_server;
	end 
	// If the message is incomplete 
	// it is stored until a complete message is received 
	else begin
		msg_saved = {msg_saved,msg};
	end
	msg = "";
endfunction

// This function is used when a context switch is required
task consume_time();
	#1;
endtask
 
 
///////////////////////////////////////////////////////////////////////////////// 
//////////////////////////////// CONNECTOR CLASS ////////////////////////////////
///////////////////////////////////////////////////////////////////////////////// 
 
 class amiq_server_connector#(string hostname="", int port=0, byte delim="");
	
	mailbox#(string) send_mbox = new(); // used for sending items from testbench to server
	mailbox#(string) recv_mbox = new(); // used for receiving items from server
	
	virtual task start;
		
		configure_connection();
		
		// Start recv thread in DPI-C layer
		fork 	
			recv_thread();		
		join_none
		
		fork   
			forever begin
				send_to_remote();
			end
			
			forever begin
				recv_from_remote();
			end
		join
	
	endtask
	
	
	function void configure_connection();
		// Create connection to server
		if(configure(hostname, port) != 0)
			$error("Could not establish connection!");
		// Set how many miliseconds to wait for socket events when reading/writing to it
		set_timeout(1);
	endfunction
		
	
	// Send item received through mailbox to server
	task send_to_remote();
		int send_rsp = 0;
		string item_str;
		string send_item;
		
		send_mbox.get(item_str);
				
		send_item = {item_str, delim};
		
		do begin
			send_data(send_item, send_item.len(), send_rsp);
			
			if (send_rsp > 0) begin
				// While only part of the message was sent to the server
				// save the other part so it can be sent at next iteration
				send_item = send_item.substr(send_rsp, send_item.len()-1);
			end
				
		//exit loop when entire message was sent	
		end while (send_rsp != send_item.len()) ;	
	endtask
	
	
	// Store received item from server into mailbox
	task recv_from_remote();
		string items[];
				
		// Wait for the notification from the receive thread (triggered by recv_callback)
		@receive_from_server;
		// consume all transactions in queue each time we receive a notification.
		while (msgs_q.size() > 0) begin
			// split message into items
			split(msgs_q.pop_front(), delim, items);
			foreach (items[i]) begin
				recv_mbox.put(items[i]);
			end	
		end
	endtask
	
	
	// Function used for splitting received items
	// -> every message can contain multiple items
	// -> each item ends with an endline character 
	// -> the input string always ends with the delimiter character
	// -> (the recv_callback() function takes care of that)
	function void split(string in, byte separator, output string out[]);
		int out_index = 0;
		int start_index = 0;
		int end_index = 0;
		out = new[0];
		foreach(in[i]) begin
			if(in[i] == separator) begin
				out = new[out.size() + 1] (out);
				end_index = i - 1;
				out[out_index] = in.substr(start_index, end_index);
				out_index = out_index + 1;
				start_index = i + 1;
			end			
		end
	endfunction
	
	
 endclass
