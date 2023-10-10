#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#define PORT "3000"
#define BUFLEN 1000
#define CHUNKLENGTH 8
#define CHUNK_CONTENT 4
#define CHUNK_ID 4

int check_ack_array(int *ack_array, int numchunks) {
  int all_recvd = 0;
  for (int i = 0; i < numchunks; i++) {
    if (ack_array[i] != 1) {
      all_recvd = 1;
      break;
    }
  }

  return all_recvd;
}

char * prepare_ack_string(int * ack_array, int numchunks) {

  char * final = (char *) calloc(BUFLEN, sizeof (char));
  for (int t = 0; t < numchunks; t++) {
    if (ack_array[t]) {
      char ack_string[4 + CHUNK_ID] = "ACK ";
      sprintf(ack_string, "ACK%04d", t);

      strcat(final, ack_string);
    }
  }

  return final;
}

char * prepare_ack_string_test(int * ack_array, int numchunks) {
  // skips every third ack
  char * final = (char *) calloc(BUFLEN, sizeof (char));
  for (int t = 0; t < numchunks; t++) {

    if (((t-1) % 3 != 0) && ack_array[t]) {
      char ack_string[4 + CHUNK_ID] = "ACK ";
      sprintf(ack_string, "ACK%04d", t);

      strcat(final, ack_string);
    }
  }

  return final;
}

int main() {
  int status;
  struct addrinfo hints, *p, *result;

  memset(&hints, 0, sizeof hints); // empty struct
  hints.ai_family = AF_UNSPEC;     // ipv4/6
  hints.ai_socktype = SOCK_DGRAM;  // UFP
  hints.ai_flags = AI_PASSIVE;     // assigns the address of local host
                                   // to the socket

  if ((status = getaddrinfo(NULL, PORT, &hints, &result)) != 0) {
    fprintf(stderr, "Error with getting address: %s\n", gai_strerror(status));
    exit(1);
  }

  int sockfd;

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

  freeaddrinfo(result);
  printf("Server up and listening at %s\n", PORT);

  struct sockaddr_storage client_addr;
  unsigned int addr_len = sizeof client_addr;

  char buf[BUFLEN] = {0};

  if (recvfrom(sockfd, buf, BUFLEN - 1, 0, (struct sockaddr *)&client_addr,
               &addr_len) == -1) {
    fprintf(stderr, "Issues getting reqs");
    exit(1);
  }

  // if num chunks msg
  if (buf[0] == 'n') {
    // start receiving chunks from a fork
    if ((sendto(sockfd, "ACK", 3, 0, (struct sockaddr *)&client_addr,
                addr_len)) == -1) {
      perror("talker: sendto");
      exit(1);
    }
    int numchunks = atoi(&buf[1]);

    char ** strings = (char **) calloc(numchunks, sizeof(char*));
    int *ack_array = (int *)calloc(numchunks, sizeof(int));
    for (int i = 0; i < numchunks; i++)
      ack_array[i] = 0;

    printf("Number of chunks: %d\n", numchunks);
    while (check_ack_array(ack_array, numchunks)) {
      if (recvfrom(sockfd, buf, CHUNKLENGTH, 0, (struct sockaddr *)&client_addr,
                   &addr_len) == -1) {
        fprintf(stderr, "Issues getting reqs");
        exit(1);
      }

      // printf("listener: packet contains \"%s\"\n", buf);

      int numchuck = atoi(buf);
      asprintf(&strings[numchuck], "%s", &buf[4]);
      ack_array[numchuck] = 1;

      // test resending:
      // char *ack_cat_string = prepare_ack_string_test(ack_array, numchunks);
      char *ack_cat_string = prepare_ack_string(ack_array, numchunks);
      // printf("%s\n", ack_cat_string);

      if ((sendto(sockfd, ack_cat_string, BUFLEN-1, 0,
                  (struct sockaddr *)&client_addr, addr_len)) == -1) {
        perror("talker: sendto");
        exit(1);
      } else {
        // printf("Sent ack.\n");
      }
    }

    for (int i = 0; i < numchunks; i++) {
      printf("%s", strings[i]);
    }
    printf("\n");
  }

  close(sockfd);
  return 0;
}
