#include "helpers.h"

int main() {
  int sockfd = connect_socket_server(PORT);

  // setup client stuff
  struct sockaddr_storage client_addr;
  unsigned int addr_len = sizeof client_addr;

  char mode[BUFLEN];

  if (recvfrom(sockfd, mode, 2, 0, (struct sockaddr *)&client_addr,
               &addr_len) == -1) {
    fprintf(stderr, "Issues getting reqs");
    exit(1);
  }

  if (connect(sockfd, (struct sockaddr *)&client_addr, addr_len) == -1) {
    fprintf(stderr, "Couldnt connect to client");
    exit(1);
  }

  printf("Connected!\n");

  // test connection
  // will block

  for (;;) {
    printf("%s", "Waiting for client to select mode.\n");
    get(sockfd, mode);

    if (mode[0] == '1')
      reciever(sockfd);
    else if (mode[0] == '0')
      sender(sockfd);
    else
      break;

  }
  close(sockfd);
  return 0;
}
