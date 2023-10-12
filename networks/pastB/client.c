#include "helpers.h"

int main() {
  int sockfd = connect_socket_client(PORT);

  post(sockfd, "ECHO");

  for (;;)
  {
    printf("%s", "Mode (1: send; 0: recv): ");
    char mode[BUFLEN] = {0};
    fgets(mode, 2, stdin);
    post(sockfd, mode);
    fgetc(stdin);

    if (mode[0] == '0')
      reciever(sockfd);
    else if (mode[0] == '1')
      sender(sockfd);
    else
      break;
  }

}
