#include <errno.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#define PORT1 "8001"
#define PORT2 "8002"
#define BACKLOG 10

// Inspired (and learnt) a lot from:
// https://beej.us/guide/bgnet/html//index.html

int decision(int a1, int a2) {
  // rock 0
  // paper 1
  // scissor 2

  // rock > sc
  // paper > rock
  // sc > paper

  // 0 -> a1 won
  // 1 -> a2 won
  // -1 -> tie

  if (a1 == a2)
    return -1;

  // a1 rock
  if (a1 == 0)
    return a2%2;

  // a1 paper
  if (a1 == 1)
    return a2/2;

  // a1 scissor
  if (a1 == 2)
    return (a2+1)%2;

  else return 2;
}

int setup_socket(char * port)
{
  int status, sockfd;
  struct addrinfo hints;
  struct addrinfo *result, *p;

  memset(&hints, 0, sizeof hints); // empty struct
  hints.ai_family = AF_UNSPEC;     // ipv4/6
  hints.ai_socktype = SOCK_STREAM; // tcp
  hints.ai_flags = AI_PASSIVE;     // assigns the address of local host
                                   // to the socket

  if ((status = getaddrinfo("localhost", port, &hints, &result)) != 0) {
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

  printf("Server up! -- %s\n", port);
  return sockfd;
}

int main() {

  int sockfd1 = setup_socket(PORT1);
  int sockfd2 = setup_socket(PORT2);

  struct sockaddr_storage client_addr1;
  socklen_t addr_size1 = sizeof client_addr1;

  struct sockaddr_storage client_addr2;
  socklen_t addr_size2 = sizeof client_addr2;

  int new_fd1, new_fd2;
  if ((new_fd1 = accept(sockfd1, (struct sockaddr *)&client_addr1,
                        &addr_size1)) == -1) {
    fprintf(stderr, "Issues accepting reqs: %d\n", errno);
    exit(1);
  };

  if ((new_fd2 = accept(sockfd2, (struct sockaddr *)&client_addr2,
                        &addr_size2)) == -1) {
    fprintf(stderr, "Issues accepting reqs: %d\n", errno);
    exit(1);
  };

  // keep accepting requests
  for (;;) {
    char buf[2] = {0};
    if (recv(new_fd1, buf, 1, 0) == -1) {
      fprintf(stderr, "Issues recv reqs: %d\n", errno);
      exit(1);
    };
    int a1 = buf[0] - '0';

    if (recv(new_fd2, buf, 1, 0) == -1) {
      fprintf(stderr, "Issues recv reqs: %d\n", errno);
      exit(1);
    };
    int a2 = buf[0] - '0';

    int dec = decision(a1, a2);
    char *msg1, *msg2;
    if (dec == -1)
      msg1 = msg2 = "Draw!";
    else if (dec == 1) {
      msg1 = "Lost! :(";
      msg2 = "Win! :)";
    }
    else if (dec == 0) {
      msg1 = "Won! :)";
      msg2 = "Lose! :(";
    }

    int len1 = strlen(msg1);
    int len2 = strlen(msg2);

    if (send(new_fd1, msg1, len1, 0) == -1) {
      fprintf(stderr, "Issues sending reqs: %d\n", errno);
      exit(1);
    }

    if (send(new_fd2, msg2, len2, 0) == -1) {
      fprintf(stderr, "Issues sending reqs: %d\n", errno);
      exit(1);
    }

    if (recv(new_fd1, buf, 1, 0) == -1) {
      fprintf(stderr, "Issues recv reqs: %d\n", errno);
      exit(1);
    };

    int d1 = buf[0] - '0';

    if (recv(new_fd2, buf, 1, 0) == -1) {
      fprintf(stderr, "Issues recv reqs: %d\n", errno);
      exit(1);
    };

    int d2 = buf[0] - '0';

    if (!(d1 && d2)) {
      if (send(new_fd1, "0", 1, 0) == -1) {
        fprintf(stderr, "Issues sending reqs: %d\n", errno);
        exit(1);
      }
      if (send(new_fd2, "0", 1, 0) == -1) {
        fprintf(stderr, "Issues sending reqs: %d\n", errno);
        exit(1);
      }
      break;
    }
    else {
      if (send(new_fd1, "1", 1, 0) == -1) {
        fprintf(stderr, "Issues sending reqs: %d\n", errno);
        exit(1);
      }
      if (send(new_fd2, "1", 1, 0) == -1) {
        fprintf(stderr, "Issues sending reqs: %d\n", errno);
        exit(1);
      }
    }

  }

  close(sockfd1);
  close(sockfd2);
}
