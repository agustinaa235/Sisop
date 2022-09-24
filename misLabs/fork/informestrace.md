# Informe del desafio Strace 

## Parte 1

 1. ej: strace cat texto.txt
  ![corrida de strace para el comando cat](https://github.com/fiubatps/sisop_2021b_segura/blob/entrega_fork/fork/images/cat1.png)
  
  ![corrida de strace para el comando cat parte 2](https://github.com/fiubatps/sisop_2021b_segura/blob/entrega_fork/fork/images/cat1.png)
  
 2. ej: strace ls fork
  ![corrida de strace para el comando ls](https://github.com/fiubatps/sisop_2021b_segura/blob/entrega_fork/fork/ls1.png)
  
  ![corrida de strace para el comando ls parte 2](https://github.com/fiubatps/sisop_2021b_segura/blob/entrega_fork/fork/images/ls2.png)
  
 3. ej: strace pwd 
  ![corrida de strace para el comando pwd](https://github.com/fiubatps/sisop_2021b_segura/blob/entrega_fork/fork/images/pwd.png)
  
  * alguna de las syscalls conocidas son:
      * write
      * read
      * execvp
      * openat
      * close 
     
   * Salida de strace:
   
   Strace puede rastrear todas la llamadas del  sistema y las seniales recibidas durante la ejecucion de un programa, incluidos los parámetros, los valores de retorno y el tiempo de ejecución.
   Cada linea que se muestra por pantalla es una llamada al sistema donde primero aparece el nombre de la syscall, luego los paraemtros que esta recibe y por ultimo luego del igual muestra lo que retorna.
   Como se menciono arriba strace puede traquear llamadas del sistema como tambien seniales como por ejemplo ` +++ exited with 0 +++ ` que inidca que el programa termino con exito y no hubo algun error como 
   
   ![ejemplo con signals](https://github.com/fiubatps/sisop_2021b_segura/blob/entrega_fork/fork/images/signals.png)
   
   * corrida de strace sobre strace 
   
   ![corrida de strace sobre strace](https://github.com/fiubatps/sisop_2021b_segura/blob/entrega_fork/fork/images/strace1.png)
   
   ![corrida de strace sobre strace](https://github.com/fiubatps/sisop_2021b_segura/blob/entrega_fork/fork/images/strace2.png)
   
   ![corrida de strace sobre strace](https://github.com/fiubatps/sisop_2021b_segura/blob/entrega_fork/fork/images/strace3.png)
   
 ## Parte 2 
 ### Explicacion codigo
 En el main, se realiza un fork donde por un lado el hijo es el que va a ser el "traqueado" mientras que el proceso padre va a ser el traqueador. 
 En el porceso hijo se inova la funcion ptrace con el flag PTRACE_TRACEME para que luego el padre pueda traquearlo y luego ejecutar el comando. Por otro lado en el proceso padre esperamos al que hijo indique alguna senial con waitpid e inmediatamente continuamos con el traquedo. Luego entra al loop seguir realizando el traqueo de syscalls hasta que el proceso hijo termine o mande una senial. En el loop, tenemos por un lado que el proceso hijo esta entrando a una syscall y ahi tenemos que averiguar el codio/id de la syscall que esta siendo lladama y por el otro lado tenemos cuando el proceso hijo esta saliendo de la syscall y tenemos que obtener el valor de retorno. Para eso a pstrace se le pasa como un argumento PTRACE_GETREGS, este comando permite copia del contenido de los registros del proceso hijo, en la memoria del proceso padre y asi poder acceder al id de la syscall invocada(se encuentra en el campo orin_rax) y al valor de retorno( se encuentra en el campo rax).
 
 ### Pruebas de corridas
  ### corrida de prueba con pwd
  
  ![corrida de prueba con pwd](https://github.com/fiubatps/sisop_2021b_segura/blob/entrega_fork/fork/images/prueba1.png)
  
  ### corrida de prueba con echo hi
  ![corrida de prueba con echo hi](https://github.com/fiubatps/sisop_2021b_segura/blob/entrega_fork/fork/images/prueba2.png)
  
  ### corrida de prueba con programa hola mundo
  
  ![corrida de prueba con programa hola mundo](https://github.com/fiubatps/sisop_2021b_segura/blob/entrega_fork/fork/images/prueba3.png)
 
