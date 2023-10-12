#include "helpers.h"
#include <netdb.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

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

char *prepare_ack_string(int *ack_array, int numchunks) {

  char *final = (char *)calloc(BUFLEN, sizeof(char));
  for (int t = 0; t < numchunks; t++) {
    if (ack_array[t]) {
      char ack_string[4 + CHUNK_ID] = "ACK ";
      sprintf(ack_string, "ACK%04d", t);

      strcat(final, ack_string);
    }
  }

  return final;
}

// for testing
char *prepare_ack_string_test(int *ack_array, int numchunks) {
  // skips every third ack
  char *final = (char *)calloc(BUFLEN, sizeof(char));
  for (int t = 0; t < numchunks; t++) {

    if (((t - 1) % 3 != 0) && ack_array[t]) {
      char ack_string[4 + CHUNK_ID] = "ACK ";
      sprintf(ack_string, "ACK%04d", t);

      strcat(final, ack_string);
    }
  }

  return final;
}

int prepare_socket(char *port) {
  int status;
  struct addrinfo hints, *p, *result;

  memset(&hints, 0, sizeof hints); // empty struct
  hints.ai_family = AF_UNSPEC;     // ipv4/6
  hints.ai_socktype = SOCK_DGRAM;  // UFP
  hints.ai_flags = AI_PASSIVE;     // assigns the address of local host
  // to the socket

  if ((status = getaddrinfo(NULL, port, &hints, &result)) != 0) {
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
  return sockfd;
}

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

void send_chunk(chunk curr, int sockfd) {
  char *final_content = curr->final_message;
  post(sockfd, final_content);
  return;
}

void check_chunk_from_ack(char *buf, chunk *chunks) {
  // format ACK0000ACK0024
  for (int i = 3; i < BUFLEN; i += 3 + CHUNK_ID) {
    chunks[atoi(&buf[i])]->acked = 1;
  }

  return;
}

int connect_socket_server(char *port) {
  int status;
  struct addrinfo hints, *p, *result;

  memset(&hints, 0, sizeof hints); // empty struct
  hints.ai_family = AF_UNSPEC;     // ipv4/6
  hints.ai_socktype = SOCK_DGRAM;  // UFP
  hints.ai_flags = AI_PASSIVE;     // assigns the address of local host
  // to the socket

  if ((status = getaddrinfo(NULL, port, &hints, &result)) != 0) {
    fprintf(stderr, "Error with getting address: %s\n", gai_strerror(status));
    exit(1);
  }

  int sockfd;

  // loop through the entire linked list
  for (p = result; p != NULL; p = p->ai_next) {
    if ((sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
      continue;
    }

    if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
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

  return sockfd;
}

int connect_socket_client(char *port) {
  int status;
  struct addrinfo hints, *p, *result;

  memset(&hints, 0, sizeof hints); // empty struct
  hints.ai_family = AF_UNSPEC;     // ipv4/6
  hints.ai_socktype = SOCK_DGRAM;  // UFP

  if ((status = getaddrinfo("localhost", port, &hints, &result)) != 0) {
    fprintf(stderr, "Error with getting address: %s\n", gai_strerror(status));
    exit(1);
  }

  int sockfd;

  // loop through the entire linked list
  for (p = result; p != NULL; p = p->ai_next) {
    if ((sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
      continue;
    }
    if (connect(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
      close(sockfd);
      continue;
    }
    break;
  }

  if (p == NULL) {
    fprintf(stderr, "Failed to bind\n");
    exit(1);
  }

  return sockfd;
}

void get(int sockfd, char *buf) {
  struct pollfd pfd[1];
  pfd[0].fd = sockfd;
  pfd[0].events = POLLIN;

  int num_events = poll(pfd, 1, 10000);
  if (num_events == 0) {
    printf("Quitting due to inactivity.\n");
    exit(0);
  }

  memset(buf, 0, BUFLEN);
  if (recv(sockfd, buf, BUFLEN, 0) == -1) {
    fprintf(stderr, "Issues getting reqs");
    exit(1);
  }
  return;
}

void post(int sockfd, char *buf) {
  int len = strlen(buf);
  struct pollfd pfd[1];
  pfd[0].fd = sockfd;
  pfd[0].events = POLLOUT;

  int num_events = poll(pfd, 1, 10000);
  if (num_events == 0) {
    printf("Quitting due to inactivity.\n");
    exit(0);
  }

  if ((send(sockfd, buf, len, 0)) == -1) {
    perror("talker: send");
    exit(1);
  }
  return;
}

chunk *chunkify(int numchunks, char *msg) {
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

  return chunks;
}

void reciever(int sockfd) {
  char *buf = (char *)calloc(BUFLEN, 1);
  printf("Awaiting request!\n");

  get(sockfd, buf);
  if (buf[0] == 'n') {
    int numchunks = atoi(&buf[1]);
    char **strings = (char **)calloc(numchunks, sizeof(char *));
    int *ack_array = (int *)calloc(numchunks, sizeof(int));
    for (int i = 0; i < numchunks; i++)
      ack_array[i] = 0;

    printf("Number of chunks: %d\n", numchunks);
    // start receiving chunks from a fork
    post(sockfd, "ACK");

    while (1) {
      memset(buf, 0, BUFLEN);
      get(sockfd, buf);
      if (strcmp(buf, "DONE") == 0)
        break;
      // printf("listener: packet contains \"%s\"\n", buf);

      int numchuck = atoi(buf);
      asprintf(&strings[numchuck], "%s", &buf[4]);
      ack_array[numchuck] = 1;

      // testing resending:
      // char *ack_cat_string = prepare_ack_string_test(ack_array, numchunks);
      char *ack_cat_string = prepare_ack_string(ack_array, numchunks);
      // printf("%s\n", ack_cat_string);

      post(sockfd, ack_cat_string);
    }

    for (int i = 0; i < numchunks; i++) {
      printf("%s", strings[i]);
    }
    printf("\n");
  }
}

void sender(int sockfd) {
  char *msg = (char *)calloc(BUFLEN, 1);
  char *buf = (char *)calloc(BUFLEN, 1);

  printf("%s", "Enter message to send:");
  fgets(msg, BUFLEN, stdin);

  int len = strlen(msg);
  msg[--len] = '\0'; // remove ending \n

  // number of chunks
  int numchunks = len / CHUNK_CONTENT;
  if (len % CHUNK_CONTENT != 0)
    numchunks++;

  chunk *chunks = chunkify(numchunks, msg);

  // first msg with number of chunks
  char nchunks_str[CHUNK_ID + 2] = {0};
  sprintf(nchunks_str, "n%04d", numchunks);

  post(sockfd, nchunks_str);
  get(sockfd, buf);

  if (strcmp(buf, "ACK") == 0) {
    for (int i = 0; i < numchunks; i++) {
      // in the child
      if (fork() == 0) {
        while (1) {
          send_chunk(chunks[i], sockfd);
          sleep(1);
          get(sockfd, buf);
          // printf(">%s\n", buf);
          check_chunk_from_ack(buf, chunks);
          if (chunks[i]->acked)
            exit(0);
          else {
            fprintf(stderr, "Resending: %d\n", i);
            send_chunk(chunks[i], sockfd);
          }
        }
      }
    }
  }

  // check every one second if all chunks have been sent
  while (1) {
    fflush(stdout);
    sleep(1);

    int all = 1;
    for (int x = 0; x < numchunks; x++) {
      if (chunks[x]->acked == 0) {
        send_chunk(chunks[x], sockfd);
        get(sockfd, buf);

        check_chunk_from_ack(buf, chunks);
        all = 0;
        break;
      }
    }
    if (all) {
      printf("%s", "All chunks sent!\n");
      post(sockfd, "DONE");
      break;
    }
  }
}