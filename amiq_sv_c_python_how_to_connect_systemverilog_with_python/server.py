# /******************************************************************************
# * (C) Copyright 2019 AMIQ Consulting
# *
# * Licensed under the Apache License, Version 2.0 (the "License");
# * you may not use this file except in compliance with the License.
# * You may obtain a copy of the License at
# *
# * http://www.apache.org/licenses/LICENSE-2.0
# *
# * Unless required by applicable law or agreed to in writing, software
# * distributed under the License is distributed on an "AS IS" BASIS,
# * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# * See the License for the specific language governing permissions and
# * limitations under the License.
# *
# * MODULE:      BLOG
# * PROJECT:     How To Connect SystemVerilog with Python
# * Description: This is a code snippet from the Blog article mentioned on PROJECT
# * Link:        https://www.amiq.com/consulting/2019/03/22/how-to-connect-systemverilog-with-python/
# *******************************************************************************/

#############################################################################
################################## IMPORTS ##################################
#############################################################################
import socket
import time
from random import randint

#############################################################################
################################## DEFINES ##################################
#############################################################################
BUFFER_SIZE=512 #The length of the received message
PORT_SERVER=54000 #The port number to be bound with the server
DELIM=',' #The delimiter used to format the response
MAX_PENDING_CONNECTIONS=0 #The maximum number of pending connection while Server is working

#############################################################################
################################# FUNCTIONS #################################
#############################################################################
def compute_response(msg):
	'''This function interprets the message=msg received from the User and
 computes the response'''
	to_return=[];
	if 'sel' in msg or 'in' in msg:
		start_index=msg.find(':')+1;
		nb=int(msg[start_index:])
		for i in range(0,nb):
			to_return.append(str(randint(0,1)))
	elif 'delay' in msg:
		start_index=msg.find(':')+1;
		nb=int(msg[start_index:])
		for i in range(0,nb):
			to_return.append(str(randint(1,10)))
	else:
		print("[ERROR]Message not recognized!")
		return "error"
		
	return DELIM.join(to_return)

def server(PORT):
	'''Creates a server that is listening to port=PORT on the localhost'''
	#Phase1 - Creating and binding the socket
	sock=socket.socket()	
	sock.bind(('',PORT))
	
	#Phase 2 - Put the socket into listening mode
	sock.listen(MAX_PENDING_CONNECTIONS)
	
	#This server listens forever	
	while True:
		#Phase 3 - Accepting a connection
		connection_ID,client_address=sock.accept()
		
		#While data is transmitted
		while True:			
			#Phase 4 - Receive data
			data=connection_ID.recv(BUFFER_SIZE)
			
			#Client closed the connection
			if not data:
				break
			
			recv_msg=data.decode("utf-8")
			print("Mesage received from SV: ", recv_msg)

			#Phase 5 - Compute and send the response
			try:
				response=compute_response(recv_msg)
			except ValueError as ex:
				print("Got this error: "+repr(ex))
				c.send("error".encode("utf-8"))
				break
			connection_ID.send(response.encode("utf-8"))
			print("Response sent back to client!")
		
		#Phase 6-Close the connection
		connection_ID.close()
		print("Connection closed!")
	
	print("Server socket closing...")
	sock.close()

#############################################################################
################################### MAIN ####################################
#############################################################################
try:
	server(PORT_SERVER);
except Exception as ex:
	print("Got this error: "+repr(ex))
