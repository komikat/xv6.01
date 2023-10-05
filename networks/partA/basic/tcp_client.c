#include <errno.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>

#define PORT "8080"
#define BACKLOG 10
#define BUFFER 100

// Inspired (and learnt) a lot from:
// https://beej.us/guide/bgnet/html//index.html
int main() {
  int status;
  struct addrinfo hints;
  struct addrinfo *result;

  memset(&hints, 0, sizeof hints); // empty struct
  hints.ai_family = AF_UNSPEC;     // ipv4/6
  hints.ai_socktype = SOCK_STREAM; // tcp
  hints.ai_flags = AI_PASSIVE;     // assigns the address of local host
                                   // to the socket

  if ((status = getaddrinfo("localhost", PORT, &hints, &result)) != 0) {
    fprintf(stderr, "Error with getting address: %s\n", gai_strerror(status));
    exit(1);
  }

  int sockfd; // socket descriptor
  if ((sockfd = socket(result->ai_family, result->ai_socktype,
                       result->ai_protocol)) == -1) {
    fprintf(stderr, "Error creating a socket: %d\n", errno);
    exit(1);
  };

  if (connect(sockfd, result->ai_addr, result->ai_addrlen) == -1) {
    fprintf(
        stderr,
        "Error connecting to the server.\nAre you sure the server is up?\n");
    exit(1);
  } else {
    printf("Connection established!\n");
  }

  char msg[100] = {0};
  printf("%s", "Message: ");
  fgets(msg, BUFFER, stdin);

  int len = strlen(msg);
  if ((send(sockfd, msg, BUFFER, 0)) == -1) {
    fprintf(stderr, "Issues sending req: %d\n", errno);
    exit(1);
  };

  char buf[BUFFER] = {0};
  if (recv(sockfd, buf, BUFFER, 0) == -1) {
    fprintf(stderr, "Issues recv req: %d\n", errno);
    exit(1);
  }

  printf("Server: %s\n", buf);
  freeaddrinfo(result); // don't really need to call since the program
                        // ends anyway but eh
}
