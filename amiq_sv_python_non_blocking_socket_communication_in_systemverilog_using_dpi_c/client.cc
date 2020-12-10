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

#include <arpa/inet.h>
#include <errno.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <netinet/tcp.h>
#include <thread>
#include <cstring>
#include <string>

//#include <svdpi.h>

#define BUFFER_SIZE 512

extern "C" void recv_callback(char * msg);
extern "C" void consume_time();

static int run_finished = 0;


//Client Arguments
struct ConnConfiguration {
	int port;		    // the port number
	char *hostname;     // the name of server's host
};

enum class ConnectionState {
	UNCONFIGURED, CONFIGURED, CONNECTED
};

struct Connection {
	// Use this to get the actual connection
	static Connection &instance() {
		static Connection conn;
		return conn;
	}

	~Connection() {
		if (sock_fd != -1) {
			close(sock_fd);
		}
	}

	std::string state_to_string() const {
		switch (state) {
		case ConnectionState::UNCONFIGURED:
			return "Unconfigured";
		case ConnectionState::CONFIGURED:
			return "Configured";
		case ConnectionState::CONNECTED:
			return "Connected";
		default:
			break;
		}

		return "Error";
	}

	ConnectionState get_state() const {
		return state;
	}

	void set_state(const ConnectionState new_state) {
		// blabla checks
		if (state == ConnectionState::CONNECTED
				&& new_state == ConnectionState::CONFIGURED) {
			// Cleanup
			close(sock_fd);
			sock_fd = -1;
		}

		state = new_state;
	}

	void set_sockfd(const int sockfd) {
		sock_fd = sockfd;

		// Assign pollfd events
		recv_event.fd = sockfd;
		recv_event.events = POLLIN;

		send_event.fd = sockfd;
		send_event.events = POLLOUT;
	}

	// How many miliseconds to wait for socket events when reading/writing to it
	void set_timeout(const int miliseconds) {
		timeout = miliseconds;
	}

	/**
	 * Throws:
	 * 	 -1 on error
	 * 	 1 if sending would block (unlikely)
	 *
	 * Returns number of bytes sent to remote
	 */
	int do_send(const char *data, int len) {

		int status = can_use_connection();
		if (!status) {
			return status;
		}

		int event_ready = poll(&send_event, 1, timeout);
		if (event_ready == -1) {
			throw -1;
		}

		int can_send = send_event.revents & POLLOUT;
		if (!can_send) {
			throw 1;
		}

		int sent = send(sock_fd, data, len, 0);
		return sent;
	}

	/**
	 * Throws:
	 * 	 -1 on error
	 * 	 1 if recv would block
	 *
	 * Returns number of bytes received from remote
	 */
	int do_recv(char *data, int len) {
		int status = can_use_connection();
		if (!status) {
			return status;
		}

		int event_ready = poll(&recv_event, 1, timeout);

		if (event_ready == -1) {
			throw -1;
		}

		int can_read = recv_event.revents & POLLIN;
		if (!can_read) {
			throw 1;
		}

		int received = recv(sock_fd, data, len, 0);

		return received;
	}


	void do_recv_forever() {
		int r;
		char data[BUFFER_SIZE+1];

		// receive transactions forever
		while (!run_finished) {

			try{
				r = do_recv(data, BUFFER_SIZE);
				if (r > 0) {
					data[r] = 0;
					recv_callback(data);
				}
			} catch (int e) {

				// Call to consume_time gives the SV simulator some indication that
				// it can schedule another SV thread for execution. If this exported SV
				// task is never executed, the simulator will continue to poll on the
				// socket for receive, without giving any chance to the send thread to execute.
				// This function is called only when there is nothing to read

				// (1) - means timeout on poll
				if(e == 1){
					consume_time();
				}

				else if(e == -1){
					printf("\n Error while polling socket! errno = %s \n", std::strerror(errno));
				}

			}
		}
	}

private:

	int sock_fd;

	ConnectionState state;

	pollfd recv_event;
	pollfd send_event;

	int timeout;

	Connection() {
		state = ConnectionState::UNCONFIGURED;
		sock_fd = -1;
		timeout = 0;
	}

	Connection(const Connection &) = delete;
	Connection &operator=(const Connection &) = delete;

	int can_use_connection() const {
		if (state != ConnectionState::CONNECTED) {
			//printf("Client is not connected to remote!\n");
			//printf("Client is in state '%s'", state_to_string().c_str());
			return false;
		}

		return true;
	}
};

// Use this to configure the remote host (the Python server)
// Returns 0 if the connection succedeed, 1 otherwise
extern "C" int configure(const char *hostname, int port) {
	Connection &conn = Connection::instance();

	conn.set_state(ConnectionState::CONFIGURED);

	// Create socket
	int sockfd = socket(AF_INET, SOCK_STREAM | SOCK_NONBLOCK, 0);

	if (sockfd == -1) {
		perror("Failed to create socket");
		exit(1);
	}

	// Assign PORT
	struct sockaddr_in servaddr;
	memset(&servaddr, 0, sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_port = htons(port);

	// See if we got an ip or a hostname (like localhost)
	struct hostent *server = gethostbyname(hostname);
	if (server == NULL) {
		servaddr.sin_addr.s_addr = inet_addr(hostname);
	} else {
		memcpy((char *) &(servaddr.sin_addr.s_addr), server->h_addr,
		server->h_length);
	}

	// Try to connect
	int status = 0;
	do {
		status = connect(sockfd, (sockaddr *) &servaddr, sizeof(servaddr));
	} while (status != 0 && status != EINPROGRESS);

	if (status != 0) {
		perror("Connect failed");
		exit(1);
	}

	printf("Connected to %s:%u\n", hostname, port);

	conn.set_state(ConnectionState::CONNECTED);
	conn.set_sockfd(sockfd);

	return conn.get_state() != ConnectionState::CONNECTED;
}


extern "C" void set_timeout(const int miliseconds) {
	Connection &conn = Connection::instance();
	conn.set_timeout(miliseconds);
}

extern "C" int send_data(const char *data, int len, int* result) {
	Connection &conn = Connection::instance();
	try{
		*result = conn.do_send(data, len);
	}
	catch (int i){
		if(i == -1){
			consume_time();
		}
		else if(i == 1){
			printf("\n Error while polling socket! errno = %s \n", std::strerror(errno));
		}
		return -1;
	}
	return run_finished;
}

extern "C" int recv_thread() {
	Connection &conn = Connection::instance();
	conn.do_recv_forever();

	// During the test, the task is enabled, therefore must return 0
	// At the end of the test, the task is disabled, therefore must return 1
	return run_finished;
}

extern "C" void set_run_finish() {
	printf("\n-------------------Called set_run_finish-------------------------\n");
	run_finished = 1;
}
