#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>



int main(int argc, char *argv[]){

    struct stat s = {0};
    int fd;
    ssize_t nw;
    if(argc < 3) {
        printf("Not enough arg");
        exit(EXIT_FAILURE);
    }
    // if(stat(argv[1],&s)==-1){
    //     perror("stat");
    //     exit(EXIT_SUCCESS);
    // }
    // if(!(s.st_mode & __S_IFDIR)){
    //     printf("Not a dir");
    //     exit(EXIT_SUCCESS);
    // }

    fd = open(argv[1],O_CREAT|O_WRONLY);
    if(fd==-1) {

        printf("Error accessing file \n");
        exit(EXIT_SUCCESS);
    }
   if(nw=write(fd,argv[2],strlen(argv[2]))==-1){
        printf("Error writing file \n");
        perror("write");
        exit(EXIT_SUCCESS);

   }
   printf("File wrote \n");

}