/*

  MirrorFaceCoreSource/Source/Linux/parallelPortServer.cpp		
  
  COMPILE WITH: gcc -O2 -o parallelPortServer parallelPortServer.cpp
  
  USAGE: parallelPortServer [udpport=2000] [parallelport=0] [debug=0]
  
			- Optional udpport is UDP port to listen on (default is 2000).
			- Optional parallelport is parallel port to use (0-2, default is 0 for lp0).
			- Optional debug, if non-zero, prints out more debug output (default is 0).
			- Process must be run/made "suid root" for realtime scheduling and low-level port access!

  DATA FORMAT:
  
			Send 1 byte UDP packet with letter 'E' to exit server.
			Send a 3 byte UDP packet starting with letter 'S' in first byte,
			followed by 1 byte value to write to port and 1 byte duration value:
			A 0 duration means -- "forever". A non-zero value t means to keep port
			at value for t msecs, then lower all pins to zero.

  PROJECTS: MirrorFace, but can be used for any setup that needs to
			emit TTL triggers over the parallel port of a Linux box.
  
  AUTHORS:
  
  mario.kleiner at tuebingen.mpg.de		mk
  
  PLATFORMS:
  
  This file should compile on GNU/Linux.
    
  HISTORY:
  
  5.10.2009		mk		Created. 

*/

// Needed for general i/o and network communication:
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/uio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/time.h>

/* These are needed for realtime scheduling and memory locking control: */
#include <pthread.h>
#include <sched.h>
#include <errno.h>
#include <sys/mman.h>

/* IOPort access macros for accessing the parallel port: */
#include <sys/io.h>

/* IOPorts for different parallel ports: */
#define BASEPORT0 0x378 /* lp0 */
#define BASEPORT1 0x278 /* lp1 */
#define BASEPORT2 0x3bc /* lp2 */

// Maximum size of a command packet (UDP raw packet):
// CAUTION! THIS MUST BE DIVIDABLE BY 4 FOR PROPER MEMORY ALIGNMENT!!!
#define MAX_MESG_SIZE 4
char __attribute__ ((aligned(4))) mesg[MAX_MESG_SIZE] = "";

// Convert timeval - struct to timevalue in milliseconds.
double toMilliseconds(struct timeval tv)
{
  return(( (double)tv.tv_sec * 1000000.0 + (double)tv.tv_usec ) / 1000.0);
}

int udpSocket = 0, status = 0, size = 0, clientLength = 0, portid = 0;
struct sockaddr_in serverName = { 0 }, clientName = { 0 };

int acknowledgeUDP(void)
{
  status = sendto(udpSocket, mesg, size, 0, (struct sockaddr *) &clientName, (socklen_t) clientLength);
  if (status != size) {
    perror("parallelPortServer: WARNING, UDP acknowledge sendto() op failed: ");
    return(1);
  }
  
  return(0);
}

int main(int argc, char* argv[])
{
	unsigned char pValue, duration;
	unsigned char sendpriority;	
	int priorityLevel;
	struct sched_param schedulingparam;
	int pport;
	
	// Need effective root permissions to access the raw I/O Port for the
	// parallel port, and for switching to memory locked realtime scheduling.
	// Check if we are effectively uid 0 aka root:
	if (geteuid() != 0) {
		printf("parallelPortServer: Not running with effective user id of root (0)! You must start me as root, or suid root!!\n");
		return(1);
	}

	// Create network command receive connection via UDP/IP protocol:
	// --------------------------------------------------------------
	
	// UDP-IP portnumber to listen to provided?
	if (argc > 1) {
		// Yes: Assign it.
		portid = atoi(argv[1]);
	}
	else {
		// No: Default to 2000:
		portid = 2000;
	}
	
	printf("parallelPortServer: Trying to open receive UDP socket at port %i.\n", portid);
	
	// Create a UDP receive socket:
	int value = 1;
	int receivebuffersize, receivebufferdec;
	socklen_t dummy;

	// Create standard UDP/IP socket:
	udpSocket = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (-1 == udpSocket) {
		perror("parallelPortServer: Socket creation failed: ");
		return(1);
	}

	// Prepare socket connection specifier:
	memset(&serverName, 0, sizeof(serverName));
	memset(&clientName, 0, sizeof(clientName));
	
	// We accept connections from any IP host:
	serverName.sin_family = AF_INET;
	serverName.sin_addr.s_addr = htonl(INADDR_ANY);
	
	// We expect connection requests at port 'portid':
	serverName.sin_port = htons(portid);
	
	// Bind the socket to port portid:
	status = bind(udpSocket, (struct sockaddr *) &serverName, sizeof(serverName));
	if (-1 == status) {
		perror("parallelPortServer: Binding the socket failed: ");
		close(udpSocket);
		udpSocket = 0;
		return(2);
	}
	
	// Try to enable kernel level timestamping of received trackingpackets, aka UDP packets:
	if (-1==setsockopt(udpSocket, SOL_SOCKET, SO_TIMESTAMP, &value, sizeof(int))) {
		perror("parallelPortServer: Warning: Enabling timestamping on the socket failed: ");
	}

	// Try to enable low delay, high priority data transmission:
	sendpriority = IPTOS_LOWDELAY;
	if (-1==setsockopt(udpSocket, SOL_IP, IP_TOS, &sendpriority, sizeof(sendpriority))) {
		perror("parallelPortServer: Warning: Couldn't setsockopt() IPTOS_LOWDELAY for UDP send socket: ");
	}

	// Switch process to memory-locked realtime scheduling:
	// ----------------------------------------------------
	
	// Use 2nd highest realtime priority level 98 (max would be 99):
	priorityLevel = 5;
	
	if (priorityLevel > 0) {
		// Realtime FIFO scheduling and all pages locked into memory:
		schedulingparam.sched_priority = priorityLevel;
		sched_setscheduler(0, SCHED_FIFO, &schedulingparam);
		priorityLevel = pthread_setschedparam(pthread_self(), SCHED_FIFO, &schedulingparam);
		if (priorityLevel != 0) {
			// Failed!
			perror("parallelPortServer: Failed to enable realtime-scheduling: ");
		}
		else {
			// RT-Scheduling active. Lock all current and future memory:
			priorityLevel = mlockall(MCL_CURRENT | MCL_FUTURE);
			if (priorityLevel!=0) {
				// Failed! Report problem as warning, but don't worry too much:
				perror("parallelPortServer: Failed to enable system memory locking: ");

				// Undo any possibly partial mlocks....
				munlockall();
				errno=0;
			}
		}
	}
	
	// Open the parallel port:
	if (argc > 2) {
		pport = atoi(argv[2]);
		switch (pport) {
			case 0:
				pport = BASEPORT0;
			break;
			
			case 1:
				pport = BASEPORT1;
			break;

			case 2:
				pport = BASEPORT2;
			break;

			default:
				printf("Invalid portid %i provided! Aborting.\n", pport);
			return(3);
		}
	}
	else {
		// Use default port 0:
		pport = BASEPORT0;
	}
	
	// Get access to the port: ioperm sets state of a total of 1 consecutive ports, starting at base port id "pport",
	// to (1) == Enabled. This will allow high speed (about 1 microsecond delay) port i/o via outb, inb et al.:
	if (ioperm(pport, 1, 1)) {
		perror("parallelPortServer: Failed to enable parallel port access via ioperm(): ");
		return(4);
	}
	
	// Set the data signals (D0-D7) of the port to all low (0):
	outb(0, pport);

	printf("parallelPortServer: Entering server loop. Waiting for parallel port command packets from network...\n\n");
	fflush(NULL);

	// Main server loop:
	while(1) {
		// Blocking receive operation:
		clientLength = sizeof(clientName);
		size = recvfrom(udpSocket, mesg, MAX_MESG_SIZE, 0, (struct sockaddr *) &clientName, (socklen_t*) &clientLength);
		if (size == -1) {
			perror("parallelPortServer: recvfrom(): ");
			return(3);
		}
		
		// Query and record receive timestamp:
		struct timeval timestamp;
		ioctl(udpSocket, SIOCGSTAMP, (struct timeval*) &timestamp);
		
		// Parse message: Byte 1 should be "S"et or "E"xit:
		if (size == 1 && mesg[0] == 'E') {
			// Exit from server process requested: Break out of server loop:
			break;
		}
		
		if (size == 3 && mesg[0] == 'S') {
			// Parallel port write request: Byte 2 contains the new 1 Byte, 8 bit TTL values
			// to write:
			pValue = mesg[1];
			
			// Byte 3 contains duration of signal. Iff zero, then just set the signal level persistently,
			// otherwise set it for roughly given number of milliseconds:
			duration = mesg[2];
			
			// Write it to parallel port:
			if (duration == 0) {
				// Instant write, keep it until next network request:
				outb(pValue, pport);
				acknowledgeUDP();
			}
			else {
				// Keep it for roughly (at least) 'duration' milliseconds, then lower to zero:
				
				// Set value:
				outb(pValue, pport);
				acknowledgeUDP();

				// Delay...
				if (1) {
					usleep(duration * 1000);
				}
				else {
					// For microsecond delays, one could use a looping call to outb like this:
					while (duration--) outb(pValue, pport);

					// This is pretty precise, as outb() on these ports takes almost exactly 1
					// microsecond by system design, but it would block the system, as we're a RT-FIFO scheduled
					// process and this would be basically busy-waiting and blocking the machine...
				}
				
				// Reset to all low, aka zero:
				outb(0, pport);
			}

			// Acknowledge in log:
			if ((argc > 3) && (atoi(argv[3]) > 0)) {
			  printf("parallelPortServer: Writing value %i to parallel port, according to command at t = %f seconds.\n", (int) pValue, (float) toMilliseconds(timestamp) / 1000.0f);
			  fflush(NULL);
			}
		}
		
		// Next loop iteration...
	}

	printf("parallelPortServer: Shutting down...\n\n");
	fflush(NULL);

	// Set the data signals (D0-D7) of the port to all low (0):
	outb(0, pport);

	// Unlock core memory:
	munlockall();

	// Close UDP socket:
	if (udpSocket) {
		close(udpSocket);
		udpSocket = 0;
	}
	
	// Exit with success:
	return(0);
}
