CC = gcc
FLAGS = -Wall -Wextra -Werror -Wstrict-prototypes -std=c99 -g3
RM = rm -f
NAME = reverse_shell
SRC = reverser.c

all:
	$(CC) $(FLAGS) $(SRC) -o $(NAME)


clean:
	$(RM) $(NAME)

re: clean all
