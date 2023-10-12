client.o: server.o
	gcc -Wall client.c helpers.c -o client.o

server.o:
	gcc -Wall server.c helpers.c -o server.o

client: server.o client.o
	./server.o & ./client.o