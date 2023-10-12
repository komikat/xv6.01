#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#define PORT "8080"
#define BACKLOG 10
#define BUFFER 100

// Inspired (and learnt) a lot from:
// https://beej.us/guide/bgnet/html//index.html
int main() {
  int status;
  struct addrinfo hints;
  struct addrinfo *result, *p;

  memset(&hints, 0, sizeof hints); // empty struct
  hints.ai_family = AF_UNSPEC;     // ipv4/6
  hints.ai_socktype = SOCK_DGRAM; // tcp

  if ((status = getaddrinfo("localhost", PORT, &hints, &result)) != 0) {
    fprintf(stderr, "Error with getting address: %s\n", gai_strerror(status));
    exit(1);
  }

  int sockfd;
  // loop through the linked list
  for (p = result; p != NULL; p = p->ai_next) {
    if ((sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
      continue;
    }
    break;
  }

  if (p == NULL) {
    fprintf(stderr, "Failed to find a socket\n");
    exit(1);
  }

  char msg[100] = {0};
  printf("%s", "Message: ");
  fgets(msg, BUFFER, stdin);

  int len = strlen(msg);

  if ((sendto(sockfd, msg, len, 0, p->ai_addr,
              p->ai_addrlen)) == -1) {
    perror("talker: sendto");
    exit(1);
  }

  struct sockaddr_storage server_addr;
  unsigned int addr_len = sizeof server_addr;

  char buf[BUFFER] = {0};

  if (recvfrom(sockfd, buf, BUFFER, 0, (struct sockaddr *)&server_addr,
               &addr_len) == -1) {
    fprintf(stderr, "Error in getting response from server!\n");
    exit(1);
  }

  printf("Server: %s\n", buf);
  close(sockfd);
  freeaddrinfo(result); // don't really need to call since the program
                        // ends anyway but eh
}
