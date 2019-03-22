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
////////////////////////////////// IMPORTS //////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h> 
#include <svdpi.h>

/////////////////////////////////////////////////////////////////////////////
////////////////////////////////// DEFINES //////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
#define READING_SOCK_ERR_MSG "ERROR reading from socket\n"
#define WRITING_SOCK_ERR_MSG "ERROR writing to socket\n"
#define CONN_SERV_ERR_MSG "ERROR connecting\n"
#define HOST_ERR_MSG "ERROR, no such host...Closing\n"
#define OPEN_SOCK_ERR_MSG "ERROR opening socket\n"
#define READING_SOCK_ERR_CODE "ERROR reading from socket\n"
#define WRITING_SOCK_ERR_CODE "ERROR writing to socket\n"
#define CONN_SERV_ERR_CODE "ERROR connecting\n"
#define HOST_ERR_CODE "ERROR, no such host...Closing\n"
#define OPEN_SOCK_ERR_CODE "ERROR opening socket\n"
#define MAX_NB_OF_ATTEMPTS 5
#define BUFFER_SIZE 512
#define TIME_TO_WAIT 10
#define COMMUNICATION_PROTOCOL 0 //0 for IP

//Client Arguments
struct client_configuration{
	int port; //the port number
	char *hostname; //the name of server's host
	char *msg; //the message to transmit to the server
	char received_msg[BUFFER_SIZE]; //the Server's response
};

/////////////////////////////////////////////////////////////////////////////
///////////////////////////////// FUNCTIONS /////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
bool interpret_errors(int, int);
void client(void*);
extern "C" const char* call_client(char* , int , char*);
/*
*bool interpret_errors(int err_code,int try_nb)
*Interprets the err_code(error code) and decides to stop the programme
 if the HOST does not exist or if the catch error is not defined. Otherwise,
 the client restarts all the procedures within TIME_TO_WAIT seconds.
 If there are MAX_NB_OF_ATTEMPTS attemps to establish a connection, 
 then the client decides to stop the programme.
*Returns True to retry establishing the connection and False to stop the
 programme
*/
bool interpret_errors(int err_code, int try_nb=0){
	switch(err_code){
		case 10:printf(OPEN_SOCK_ERR_MSG);break;
		case 20:printf(HOST_ERR_MSG);return false;
		case 30:printf(CONN_SERV_ERR_MSG);break;
		case 40:printf(WRITING_SOCK_ERR_MSG);break;
		case 50:printf(READING_SOCK_ERR_MSG);break;
		default: printf("This error is not defined: %d",err_code);return false;
	}
	
	if(try_nb<=MAX_NB_OF_ATTEMPTS)
		printf("Retrying in %d secs...\n",TIME_TO_WAIT);
	else{
		printf("MAX_NB_OF_ATTEMPTS(%d) reached!\nClosing...",MAX_NB_OF_ATTEMPTS);
		return false; 
	}
	sleep(TIME_TO_WAIT);  
	return true;
}

/*
*const char* client(void* data)
*This function implements a client app.
*data is a general pointer to a client_configuration struct
*Returns the message received from the server
*/
void client(void* data){
	int sockfd, nof_bytes; 
	struct sockaddr_in serv_addr; //used to connect with the Server
	struct hostent *host; //used to get Server's address
	client_configuration *client_config;
	
	client_config=(client_configuration*)data;
	
	///Phase 1 - Creates a socket for AF=IPV4 and for a 2 way connection
	sockfd = socket(AF_INET, SOCK_STREAM, COMMUNICATION_PROTOCOL); 
	if (sockfd < 0) {
		close(sockfd);
		throw(OPEN_SOCK_ERR_CODE);
	}
	
	///Phase 2 - Preparing data connection
	host = gethostbyname(client_config->hostname);
	if (host == NULL){
		close(sockfd);
		throw(HOST_ERR_CODE);
	}

	//Setting the Server characteristics
	bzero((char *) &serv_addr, sizeof(serv_addr));
	serv_addr.sin_family = AF_INET;
	bcopy((char *)host->h_addr,(char *)&serv_addr.sin_addr.s_addr,host->h_length);

	//Converts the port number form local machine bytes to network bytes
	serv_addr.sin_port = htons(client_config->port);
	
	//Showing Server's IP
	//printf("Server IP: %s\n",inet_ntoa(serv_addr.sin_addr));
	
	///Phase 3 - Establishing the connection between the Client and the Server
	if (connect(sockfd,(struct sockaddr *) &serv_addr,sizeof(serv_addr)) < 0) {
		close(sockfd);
		throw(CONN_SERV_ERR_CODE);
	}

	///Phase 4  - Send and receive messages
	//Sending the message to the Server
	nof_bytes = write(sockfd,client_config->msg,strlen(client_config->msg));
	if (nof_bytes < 0){
		close(sockfd);
		throw(WRITING_SOCK_ERR_CODE); 
	}	

	//Receiving the Server's response
	bzero(client_config->received_msg,BUFFER_SIZE);
	nof_bytes = read(sockfd,client_config->received_msg,BUFFER_SIZE-1);
	if (nof_bytes < 0){
		close(sockfd);
		throw(READING_SOCK_ERR_CODE); 
	}
	printf("Client received: %s\n",client_config->received_msg);
	
	///Phase 5 - Close the connection
	close(sockfd);
}

/*
*extern "C" const char* call_client(char* hostname, int client_port, char *client_msg)
*This function acts like a main. It calls the client app and deals with the errors that
 may appear while the client is running.
*Params:
*	hostname - Is a string that contains the name of the host or the IP specified in IP format
*	client_port - Is the port that the client connects to
*	client_msg - Is the message that the client is going to send to the Server
*Returns the message received from Server 
*/
extern "C" const char* call_client(char* hostname, int client_port, char *client_msg){
	client_configuration client_config; //client characteristics
	static char to_return[BUFFER_SIZE]; //string that stores the server's response
	bool e=true; //variable used for dealing with errors
	int i=0; //number of attemtps
	
	//Set the client characteristics
	client_config.port=client_port;
	client_config.hostname=new char[strlen(hostname)];
	strcpy(client_config.hostname,hostname);
	client_config.msg=new char[strlen(client_msg)];
	strcpy(client_config.msg,client_msg);

	while(e){
		try{
			bzero((char*)to_return,sizeof(to_return));
			client((void*)&client_config);
			strcpy(to_return,client_config.received_msg);
			e=false;
		}
		catch(int n){ 				//Defined exceptions
			e=interpret_errors(n,++i);
			if(!e){	
				bzero((char*)to_return,sizeof(to_return));
				strcpy(to_return,"error");
			}
		}
		catch(...){					//Undefined exceptions
			printf("Default exception...Closing!");
			bzero((char*)to_return,sizeof(to_return));
			strcpy(to_return,"error");
		}
	}

	return to_return;
}
