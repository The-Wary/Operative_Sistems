# Informe del Sistema de Permisos y Archivos Inmutables en xv6

## 1. Funcionamiento y Lógica

El objetivo de esta entrega fue implementar un sistema de permisos en xv6 que permita definir los permisos de lectura/escritura de los archivos, así como agregar un nuevo permiso especial para marcar archivos como inmutables.

- **Permisos Básicos:**
  Se implementó un sistema de permisos representado por el campo `perm` en `struct inode`, que define:
  - `0`: Sin permisos.
  - `1`: Solo lectura.
  - `2`: Solo escritura.
  - `3`: Lectura y escritura.
  - `5`: Inmutable (nuevo permiso especial).

- **Permiso Especial (Inmutable):**
  Los archivos con este permiso serán considerados como **solo lectura** y no será posible modificar sus permisos ni escribir en ellos. Sin embargo, la lectura estará permitida.

## 2. Explicación de las Modificaciones Realizadas

### Modificaciones al Kernel

1. **Estructura `struct inode` en file.h:**
   - Se agregó el campo `perm` para almacenar los permisos de cada archivo:
     ```c
     uchar perm;
     ```
   - Este campo se inicializa con el valor `3` (lectura y escritura) por defecto.

2. **Funciones del Kernel Modificadas:**
   - **`iget`:** Recupera un inodo de la tabla. La lógica se ajustó para inicializar el campo `perm` correctamente al asignar nuevos inodos.
   - **`readi`:** Verifica si el archivo tiene permiso de lectura. Retorna un error si `perm == 2` (solo escritura) o `perm == 0` (sin permisos).
   - **`writei`:** Verifica si el archivo tiene permiso de escritura o si es inmutable (`perm == 5`). Retorna un error en ambos casos.

3. **Llamada al Sistema `chmod`:**
   - Se implementó una nueva syscall para cambiar los permisos de un archivo:
     ```c
     uint64 sys_chmod(void);
     ```
   - La syscall verifica:
     - Si el archivo es inmutable (`perm == 5`), no permite cambiar los permisos.
     - Si el permiso solicitado está fuera del rango permitido (0-5), retorna un error.

4. **Comando `chmod`:**
   - Se creó un comando de usuario que utiliza la syscall `chmod` para cambiar los permisos de un archivo:
     ```sh
     chmod <archivo> <perm>
     ```
   - Se validan los permisos ingresados para evitar valores inválidos.

5. **Nuevo Programa de Pruebas:**
   - Se implementó el programa `testimmutable` para probar el funcionamiento del permiso especial inmutable:
     - Marca un archivo como inmutable.
     - Intenta escribir en el archivo (debe fallar).
     - Intenta cambiar sus permisos (debe fallar).
     - Verifica que la lectura funciona correctamente.

### Archivos Modificados y Nuevos
- **`file.h`:**
  - Se agregó el campo `perm` en `struct inode`.

- **`fs.c`:**
  - Modificaciones en `iget`, `readi`, y `writei` para manejar los permisos.

- **`sysfile.c`:**
  - Implementación de la syscall `chmod`.

- **`syscall.c`:**
  - Conexión de la syscall `chmod`.

- **`Makefile`:**
  - Se agregaron los binarios `_chmod` y `_testimmutable` a `UPROGS`.

- **Archivos nuevos:**
  - `user/chmod.c`: Comando para cambiar permisos.
  - `user/testimmutable.c`: Programa de pruebas.

---

## 3. Dificultades Encontradas y Soluciones Implementadas

1. **Error en la compilación de la syscall `chmod`:**
   - **Problema:** `argint` y `argstr` causaban errores porque `argint` no retorna valores.
   - **Solución:** Ajustamos la lógica para extraer los argumentos en pasos separados, evitando usar `argint` en condiciones.

2. **Errores con constantes como `O_CREATE` y `O_RDWR`:**
   - **Problema:** El programa `testimmutable` no encontraba las constantes necesarias para manejar archivos.
   - **Solución:** Incluimos el archivo `kernel/fcntl.h` en los programas de usuario que lo requerían.

3. **Pruebas del Permiso Inmutable:**
   - **Problema:** Verificar todas las combinaciones de operaciones con permisos.
   - **Solución:** Implementamos un programa de pruebas exhaustivo (`testimmutable`) para validar cada escenario.

---

## 4. Conclusión

Este proyecto implementa un sistema funcional de permisos en xv6, incluyendo un permiso especial inmutable. Los cambios se integraron correctamente en el kernel y el espacio de usuario, y las pruebas confirman que el comportamiento es el esperado.

---



