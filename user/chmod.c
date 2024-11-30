#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    if(argc != 3){
        printf("usage: chmod <filename> <perm>\n");
        exit(1);
    }

    int perm = atoi(argv[2]); // Convierte el segundo argumento en un entero

    if(chmod(argv[1], perm) < 0){ // Llama a la función chmod
        printf("chmod: failed to change permissions for %s\n", argv[1]);
    }

    exit(0);
}
