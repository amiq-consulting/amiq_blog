# /******************************************************************************
# * (C) Copyright 2020 AMIQ Consulting
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
import math
from random import randint
from _socket import SO_REUSEADDR

#############################################################################
################################## DEFINES ##################################
#############################################################################
BUFFER_SIZE=512 #The length of the received message
PORT_SERVER=54000 #The port number to be bound with the server
DELIM='\n' #The delimiter used to format the response
MAX_PENDING_CONNECTIONS=0 #The maximum number of pending connection while Server is working

#############################################################################
################################# FUNCTIONS #################################
#############################################################################

truncated_item = ""
def send_response(msg, connection_ID):
    '''This function interprets the message=msg received from the User and
 computes the response'''
    
    
    # Handle truncated messages from client 
    # These messages appear due to the buffer size
    # An items integrity is established based on its last character (DELIM)
    response = ""
    global truncated_item
    
    msg = truncated_item + msg
    items = msg.split(DELIM)
    
    if msg[-1] != DELIM:
        truncated_item = items[-1]
        items = items[:-1]
    else:
        truncated_item = ""
        
    # Process each item within the message 
    # An items structure looks like this: <command>:<value>
    for item in items:
    
        if ":" in item:
            cmd = item[0:item.find(":")]
            val = int(item[item.find(":")+1:len(item)])
            
            # get divisors
            if cmd == "div":
                div_no = 0;
                for i in range(1, val // 2 + 1):
                    if val%i == 0: 
                        div_no = div_no + 1
                        header = "[d_"+ str(val) + "(" + str(div_no) + ")]"
                        response = header + str(i) + DELIM    
                        print("Response to be sent: [{}]".format(response[:-1])) # don't print the delim character       
                        # Send to client
                        connection_ID.send(response.encode("utf-8"))
                div_no = div_no + 1
                header = "[d_"+ str(val) + "(" + str(div_no) + ")]"
                response = header + str(val) + DELIM     
                print("Response to be sent: [{}]".format(response[:-1])) # don't print the delim character       
                # Send to client
                connection_ID.send(response.encode("utf-8"))
            
        # To signal the end of test, the client sends a certain item to the server
        # When receiving this item, the server sends back to the testbench a certain response
        # This response is recognized by the testbench 
        # and when it's received the test may be considered finished
        if "end_test" in item:
            response = "end_test" + DELIM            
            # Send to client
            connection_ID.send(response.encode("utf-8"))
            break

def server(PORT):
    '''Creates a server that is listening to port=PORT on the localhost'''
    #Phase1 - Creating and binding the socket
    sock=socket.socket()  
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)  
    sock.bind(('',PORT))
    
    #Phase 2 - Put the socket into listening mode
    sock.listen(MAX_PENDING_CONNECTIONS)
    
    print("Server is up!")
    
    #This server listens forever    
    while True:
        #Phase 3 - Accepting a connection
        connection_ID,client_address=sock.accept()
        print("Connection accepted!")
        
        #While data is transmitted
        while True:            
            #Phase 4 - Receive data
            data=connection_ID.recv(BUFFER_SIZE)
            
            #Client closed the connection
            if not data:
                break
            
            recv_msg=data.decode("utf-8")
            print("Mesage received from SV: \n", recv_msg)

            #Phase 5 - Compute and send the response
            try:
                send_response(recv_msg, connection_ID)
            except ValueError as ex:
                print("Got this error: "+repr(ex))
                c.send("error".encode("utf-8"))
                break
            
        
        #Phase 6-Close the connection
        connection_ID.close()
        print("Connection closed!")
    
    print("Server socket closing...")
    sock.close()

#############################################################################
################################### MAIN ####################################
#############################################################################
try:
    print("Starting server ... ", end="")
    server(PORT_SERVER);
except Exception as ex:
    print("Got this error: "+repr(ex))