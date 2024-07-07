#include <pthread.h>
#include <stdio.h>

void *print_nigga(void *arg) {
  printf("nigga. %s", (char *)arg);
  return NULL;
}

int main() {
  pthread_t p1;
  char *new = "asd";
  if (pthread_create(&p1, NULL, print_nigga, new) != 0) {
    printf("nigga..?");
  };

  if (pthread_join(p1, NULL) != 0) {
    perror("pthread_join");
    return 1;
  }

  print_nigga("asdfrasdf");
}
