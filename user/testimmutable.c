#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"  // Agrega este encabezado
#include "user/user.h"


int
main(void)
{
    // Crear un archivo
    int fd = open("immutablefile", O_CREATE | O_RDWR);
    if(fd < 0){
        printf("Failed to create file\n");
        exit(1);
    }
    write(fd, "hello", 5);
    close(fd);

    // Cambiar permisos a inmutable
    if(chmod("immutablefile", 5) < 0){
        printf("Failed to set file as immutable\n");
        exit(1);
    } else {
        printf("Set immutablefile as immutable\n");
    }

    // Intentar escribir en el archivo (debe fallar)
    fd = open("immutablefile", O_WRONLY);
    if(fd >= 0){
        if(write(fd, "world", 5) >= 0)
            printf("Error: Should not be able to write to immutable file\n");
        else
            printf("Correct: Cannot write to immutable file\n");
        close(fd);
    } else {
        printf("Correct: Cannot open immutable file for writing\n");
    }

    // Intentar cambiar permisos de vuelta a lectura/escritura (debe fallar)
    if(chmod("immutablefile", 3) < 0){
        printf("Correct: Cannot change permissions of immutable file\n");
    } else {
        printf("Error: Should not be able to change permissions of immutable file\n");
    }

    // Leer el archivo (debe funcionar)
    fd = open("immutablefile", O_RDONLY);
    if(fd >= 0){
        char buf[6] = {0};
        if(read(fd, buf, 5) == 5)
            printf("Read success: %s\n", buf);
        else
            printf("Error: Failed to read immutable file\n");
        close(fd);
    } else {
        printf("Error: Failed to open immutable file for reading\n");
    }

    exit(0);
}
