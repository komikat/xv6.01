#include <errno.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#define PORT "8080"
#define BACKLOG 10

// Inspired (and learnt) a lot from:
// https://beej.us/guide/bgnet/html//index.html
int main() {
  int status, sockfd;
  struct addrinfo hints;
  struct addrinfo *result, *p;

  memset(&hints, 0, sizeof hints); // empty struct
  hints.ai_family = AF_UNSPEC;     // ipv4/6
  hints.ai_socktype = SOCK_STREAM; // tcp
  hints.ai_flags = AI_PASSIVE;     // assigns the address of local host
                                   // to the socket

  if ((status = getaddrinfo("localhost", PORT, &hints, &result)) != 0) {
    fprintf(stderr, "Error with getting address: %s\n", gai_strerror(status));
    exit(1);
  }

  // result -> linked list of addrinfos for localhost:PORT
  // loop through the entire linked list
  for (p = result; p != NULL; p = p->ai_next) {
    if ((sockfd = socket(result->ai_family, result->ai_socktype,
                         result->ai_protocol)) == -1) {
      continue;
    }

    if (bind(sockfd, result->ai_addr, result->ai_addrlen) == -1) {
      close(sockfd);
      continue;
    }

    break;
  }

  if (p == NULL) {
    fprintf(stderr, "Failed to bind\n");
    exit(1);
  }



  // listen for incoming connections
  if (listen(sockfd, BACKLOG) == -1) {
    fprintf(stderr, "Error listening: %d\n", errno);
    exit(1);
  }

  printf("Server up!\n");
  // keep accepting requests
  for (;;) {
    struct sockaddr_storage client_addr;
    socklen_t addr_size = sizeof client_addr;
    int new_fd;
    if ((new_fd = accept(sockfd, (struct sockaddr *)&client_addr,
                         &addr_size)) == -1) {
      fprintf(stderr, "Issues accepting reqs: %d\n", errno);
      exit(1);
    };

    char buf[100] = {0};
    if (recv(new_fd, buf, 100, 0) == -1) {
      fprintf(stderr, "Issues recv reqs: %d\n", errno);
      exit(1);
    };

    printf("%s\n", buf);

    char *msg = "Greetings from the server!";
    int len = strlen(msg);

    if (send(new_fd, msg, len, 0) == -1) {
      fprintf(stderr, "Issues sending reqs: %d\n", errno);
      exit(1);
    }
  }

  close(sockfd);
  freeaddrinfo(result); // don't really need to call since the program
                        // ends anyway but eh
}
