#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <syslog.h>



int main(int argc, char *argv[]){

    const char* baseStr1 = "Writing ";
    const char* baseStr2 = " to ";
    struct stat s = {0};
    int fd;
    ssize_t nw;
    openlog("",LOG_PERROR,LOG_USER);
    if(argc < 3) {
        syslog(LOG_ERR,"Not enough argument");
        closelog();
        exit(EXIT_FAILURE);
    }


    //fd = open(argv[1],O_CREAT|O_WRONLY|O_TRUNC|S_IRWXU);
    fd = creat(argv[1],S_IRWXU|S_IRWXG|S_IROTH);
    if(fd==-1) {

        syslog(LOG_ERR,"Error accessing file");
        perror("open");
        closelog();
        exit(EXIT_SUCCESS);
    }
   if(nw=write(fd,argv[2],strlen(argv[2]))==-1){
        syslog(LOG_ERR,"Error writing file");
        perror("write");
        closelog();
        exit(EXIT_SUCCESS);

   }
   close(fd);
   ssize_t sizeStr = strlen(argv[1]) + strlen(argv[2]) + strlen(baseStr1) + strlen(baseStr2);
   char *outStr = malloc(sizeStr) ;
    strcat(outStr,baseStr1);
    strcat(outStr,argv[2]);
    strcat(outStr,baseStr2);
    strcat(outStr,argv[1]);
    syslog(LOG_DEBUG,outStr);
    printf(outStr);
    free(outStr);
    closelog();

}