Informe de Implementación del Sistema de Permisos en xv6
Introducción
El objetivo principal de esta tarea fue extender las funcionalidades del sistema de archivos de xv6 (para RISC-V), implementando un sistema de permisos básicos. Esto incluyó la adición de permisos de solo lectura, lectura/escritura y un permiso especial de inmutabilidad. Estas mejoras se realizaron modificando la estructura del inode, las operaciones de archivos y creando nuevas llamadas al sistema.

Objetivos Específicos
Modificar la estructura del inode para incluir un sistema de permisos básico.
Restringir operaciones de apertura, lectura y escritura según los permisos asignados al inode.
Implementar una nueva llamada al sistema chmod para modificar los permisos.
Incluir un permiso especial para hacer los archivos inmutables, bloqueando cambios posteriores.
Realizar pruebas exhaustivas para verificar la funcionalidad.
Desarrollo
El desarrollo de la tarea se dividió en dos partes principales:

Primera Parte: Sistema de Permisos Básico
Modificación de la Estructura del Inode

Se añadió un nuevo campo int permissions en la estructura del inode (struct dinode en fs.h).
Este campo utiliza bits para definir los permisos:
0: Sin permisos (ni lectura ni escritura).
1: Permiso de solo lectura.
2: Permiso de solo escritura.
3: Permiso de lectura/escritura (por defecto al crear un archivo).
Modificación de las Operaciones de Apertura, Lectura y Escritura

Se modificó la función sys_open en sysfile.c para que valide los permisos asignados al archivo. Si el modo de apertura (omode) no coincide con los permisos del inode, la operación falla con un mensaje de error.
Se adaptaron las funciones de lectura (readi) y escritura (writei) para verificar los permisos antes de procesar las solicitudes.
Implementación de la Llamada al Sistema chmod

Se creó una nueva llamada al sistema chmod(char *filename, int mode) para permitir cambiar los permisos del archivo.
Esta función valida el archivo y actualiza el campo permissions del inode, salvo que el permiso sea el especial de inmutabilidad.
Pruebas

Se desarrolló un programa que verifica las operaciones básicas:
Crear un archivo con permisos de lectura/escritura.
Cambiar los permisos a solo lectura y verificar que la escritura falle.
Restaurar permisos de lectura/escritura y confirmar que la escritura es posible.
Segunda Parte: Permiso Especial de Inmutabilidad
Implementación del Permiso de Inmutabilidad

Se definió el permiso 5 como el valor que representa un archivo inmutable.
Los archivos con este permiso:
Se tratan como de solo lectura.
Bloquean cambios posteriores en sus permisos, haciendo que chmod falle si se intenta modificar.
Modificación de chmod

Se añadió lógica para verificar si el archivo tiene el permiso especial de inmutabilidad. En este caso, la función devuelve un error.
Pruebas

Se extendió el programa de pruebas para verificar:
Que los archivos inmutables no permiten escritura.
Que los permisos no se pueden cambiar de vuelta tras activar la inmutabilidad.
Resultados
Se añadieron correctamente los permisos básicos y el permiso especial de inmutabilidad en xv6.
Las pruebas verificaron que:
Los permisos restringen adecuadamente las operaciones de apertura, lectura y escritura.
Los archivos inmutables son tratados como de solo lectura y no permiten cambios posteriores de permisos.
Se cumplió con todos los requisitos de la tarea y se validó el correcto funcionamiento mediante las pruebas automatizadas.
Conclusiones
La implementación del sistema de permisos básicos y del permiso especial de inmutabilidad en xv6 permitió fortalecer el control de acceso a archivos dentro del sistema. Estas modificaciones demostraron la flexibilidad y extensibilidad del sistema operativo, permitiendo la incorporación de características adicionales con impacto directo en la seguridad y funcionalidad.

PD: estaba trabajando en otro, pero, entre que estaba horrible y me causó un par de problemas, me cambié a uno nuevo que solo es la tarea 4
