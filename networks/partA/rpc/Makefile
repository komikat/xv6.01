tcp_clientA.o: tcp_clientA.c
	gcc tcp_clientA.c -o tcp_clientA.o

tcp_clientB.o: tcp_clientB.c
	gcc tcp_clientB.c -o tcp_clientB.o

tcp_server.o: tcp_server.c
	gcc tcp_server.c -o tcp_server.o

tcp: tcp_clientA.o tcp_server.o tcp_clientB.o

