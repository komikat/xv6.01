#ifndef MINI2_HELPERS_H
#define MINI2_HELPERS_H


#include <netdb.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#define BUFLEN 1000
#define CHUNKLENGTH 8
#define CHUNK_CONTENT 4
#define CHUNK_ID 4
#define PORT "3010"

struct Chunk {
  char *content; // 4 bits for message
  int id;        // 4 bits for id
  int acked;     // false
  char *final_message;
};
typedef struct Chunk *chunk;

int check_ack_array(int *ack_array, int numchunks);
char *prepare_ack_string(int *ack_array, int numchunks);
char *prepare_ack_string_test(int *ack_array, int numchunks);
int prepare_socket(char *port);
char *prepare_chunk_msg(chunk curr);
void send_chunk(chunk curr, int sockfd);
void check_chunk_from_ack(char *buf, chunk *chunks);
int connect_socket_server(char *port);
void get(int sockfd, char *buf);
void post(int sockfd, char *buf);
int connect_socket_client(char *port);
chunk *chunkify(int numchunks, char *msg);
void reciever(int sockfd);
void sender(int sockfd);

#endif // MINI2_HELPERS_H
