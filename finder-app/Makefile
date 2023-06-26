CC=gcc
CFLAGS=-W -Wall -pedantic
LDFLAGS=
EXEC=writer
SRC= $(wildcard *.c)
OBJ= $(SRC:.c=.o)
ifeq ($(CROSS_COMPILE),aarch64-none-linux-gnu-)
	CC=~/Documents/ARM-GCC/install-lnx/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-gcc
endif
default:$(EXEC)


all:$(EXEC)

writer: $(OBJ)
ifeq ($(CROSS_COMPILE),aarch64-none-linux-gnu-)
	@echo "cross compilling..."
else
	@echo "not cross compiling..."
endif
	@$(CC)  -o $@ $^ $(LDFLAGS)

*.o: %.c
	@$(CC) -o $@ -c $< $(CFLAGS)

clean:
	@rm -rf *.o $(EXEC)
