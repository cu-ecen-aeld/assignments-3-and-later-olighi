CC=gcc
CFLAGS=-W -Wall -pedantic
LDFLAGS=
EXEC=writer

default: $(EXEC)

writer: writer.o
	$(CC)  -o $(EXEC) writer.o $(LDFALS)

writer.o: writer.c
	$(CC) -c -o writer.o writer.c $(CFLAGS)

clean:
	rm -rf *.o $(EXEC)