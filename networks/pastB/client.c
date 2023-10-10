#include <netdb.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <time.h>
#include <unistd.h>

#define PORT "3000"
#define BUFLEN 1000
#define CHUNKLENGTH 8
#define CHUNK_CONTENT 4
#define CHUNK_ID 4

struct Chunk {
  char *content; // 4 bits for message
  int id;        // 4 bits for id
  int acked;     // false
  char *final_message;
};

typedef struct Chunk *chunk;

char *prepare_chunk_msg(chunk curr) {
  char temp_id_string[CHUNK_ID + 1];
  sprintf(temp_id_string, "%04d",
          curr->id); // adds a null character

  char *final_content = (char *)calloc(CHUNKLENGTH, sizeof(char));

  for (int j = 0; j < CHUNK_ID; j++) {
    final_content[j] = temp_id_string[j]; // add the id
  }
  for (int j = CHUNK_ID; j < CHUNKLENGTH; j++) {
    final_content[j] = curr->content[j - CHUNK_ID]; // add the content
  }

  return final_content;
}

void send_chunk(chunk curr, int sockfd, struct addrinfo *p) {
  char *final_content = curr->final_message;
  if ((sendto(sockfd, final_content, CHUNKLENGTH, 0, p->ai_addr,
              p->ai_addrlen)) == -1) {
    perror("talker: sendto");
    exit(1);
  }
  return;
}

void check_chunk_from_ack(char *buf, chunk* chunks) {
  // format ACK0000ACK0024
  for (int i = 3; i < BUFLEN; i+=3+CHUNK_ID) {
    chunks[atoi(&buf[i])]->acked = 1;
  }

  return;
}

int main() {
  struct addrinfo hints, *p, *result;

  memset(&hints, 0, sizeof hints);
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_DGRAM;

  int rv, status;
  if ((status = getaddrinfo("localhost", PORT, &hints, &result)) != 0) {
    fprintf(stderr, "Error with getting adrress: %s\n", gai_strerror((status)));
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

  char msg[BUFLEN];
  printf("%s", "Enter message to send:");
  fgets(msg, BUFLEN, stdin);

  int len = strlen(msg);
  msg[--len] = '\0'; // remove ending \n

  // number of chunks
  int numchunks = len / CHUNK_CONTENT;
  if (len % CHUNK_CONTENT != 0) {
    numchunks++;
  }

  chunk *chunks = (chunk *)malloc(numchunks * sizeof(chunk));

  for (int i = 0; i < numchunks; i++) {
    char *test = (char *)malloc(CHUNK_CONTENT);
    for (int j = 0; j < CHUNK_CONTENT; j++) {
      test[j] = msg[i * CHUNK_CONTENT + j];
    }

    chunks[i] = (chunk)malloc(sizeof(struct Chunk));
    chunks[i]->content = test;
    chunks[i]->id = i;
    chunks[i]->acked = 0; // not been acked
    chunks[i]->final_message = prepare_chunk_msg(chunks[i]);
  }

  struct sockaddr_storage server_addr;
  unsigned int addr_len = sizeof server_addr;

  char buf[BUFLEN] = {0};

  // first msg with number of chunks
  char nchunks_str[CHUNK_ID + 2];
  sprintf(nchunks_str, "n%04d", numchunks);
  if ((sendto(sockfd, nchunks_str, CHUNKLENGTH, 0, p->ai_addr,
              p->ai_addrlen)) == -1) {
    perror("talker: sendto");
    exit(1);
  }
  struct pollfd pfds[1];
  pfds[0].fd = sockfd;
  pfds[0].events = POLLIN;

  int num_events = poll(pfds, 1, 2500);

  if (num_events == 0) {
    fprintf(stderr, "Server timed out!\n");
    exit(1);
    printf("stdsafasf");
  } else {

    if (recvfrom(sockfd, buf, 3, 0, (struct sockaddr *)&server_addr,
                 &addr_len) == -1) {
      fprintf(stderr, "Error in getting response from server!\n");
      exit(1);
    } else {
      // working till here
      if (strcmp(buf, "ACK") == 0) {
        for (int i = 0; i < numchunks; i++) {
          // in the child
          int child;
          if ((child = fork()) == 0) {
            int events = 0;
            while (1) {
              send_chunk(chunks[i], sockfd, p);

              struct pollfd pfds_p[1];
              pfds_p[0].fd = sockfd;
              pfds_p[0].events = POLLIN;

              events = poll(pfds_p, 1, 1000);
              if (events == 0 && chunks[i]->acked == 0) {
                fprintf(stderr, "Resending: %d\n", i);
                send_chunk(chunks[i], sockfd, p);
              } else {
                if (recvfrom(sockfd, buf, BUFLEN-1, 0, (struct sockaddr *)&server_addr,
                             &addr_len) == -1) {
                  fprintf(stderr, "Error in getting response from server!\n");
                  exit(1);
                } else {
                  // printf("%s\n", buf);
                  check_chunk_from_ack(buf, chunks);
                  if (chunks[i] -> acked) {
                    exit(0);
                  }
                }
              }
            }
          }
        }
      } else {
        fprintf(stderr, "Wrong server ack. Terminating.\n");
        exit(1);
      }
    }
  }

  close(sockfd);
}
