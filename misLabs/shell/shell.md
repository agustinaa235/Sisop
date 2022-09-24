# Lab: shell

### Búsqueda en $PATH

---
1) 
Todas hacen lo mismo:  cargar un nuevo programa en el proceso actual y proporcionarle argumentos y variables de entorno. La diferencia es que execve recibe un arreglo con las variables de entorno para poder ejecutar el programa, mientras que el resto de la familas de exec toma las variables por entono default del actual proceso

2) Exec retorna solo en caso en que falle y devuelve -1. En ese caso la shell debe liberar todos los recursos y luego ejectura un exit del error.
### Comandos built-in

---
1) pwd no es necesario implementarla como build in ya que obtener un resultado igual se podria hacer por medio de echo $PWD. A su vez porque exhiste un /bin/pwd/ por lo que no es necesario implementarolo como build in. Al hacerlo como built in, nos estamos evitando lanzar un proceso aparte y este es interpretado por la shell y se hace en el mismo proceso de la shell.

### Variables de entorno adicionales

---
1) Se hacen luego de la llamada fork porque como se tratan de variables temporales, se quiere que dejen de existir y en por eso que se ejecutan en el hijo,osea, luego del llamado a fork. 
2) En el caso de execve la funcion agrega, ademas de las variables que se le pasan, tiene acceso a todas la variables de entorno. Al contrario de setenv que solo agrega la variable que se le pasa por paramentro.
Una posible implementacion seria agregar todos los valores que se agregarian explicitamente con el execve y tambien los que se quiera setear diferente a ellos.

### Procesos en segundo plano

---
En la funcion exec_cmd en el case BACK se hace una llamada recursiva a exec_cmd, y luego en run cmd si se trata de un proceso en segundo plano se pasa a la funcion de waitpid el flag de WNOHANG en la cual hace que el wait sea no bloqueante y mientras se ejecuta un cmd la shell puede seguir procesando otros comandos. Por ejemplo si hago sleep 5 & cuando se ejecuta no debe esperar 5 segundo para poder ejecutar otro comando sino que mientras se esta ejecutando sleep 5 se puede ejecutar otro como echo hi.

### Flujo estándar

---
1) La shell nos permite combinar la salida stderr y stdout en la salida normal para poder así manipular los errores( nos permite redireccionar los errores a  la salida estandar). La diferencia es que cuando se utiliza  2>&1 se escribe en salida estandar, que fue redireccionado al archivo por lo que el archivo contiene la salida y los erroeres mientras que cuando se utiliza 2>out.txt se escribe en un archivo los errores, en cambio al usar.

ejemplo 

 ![](https://github.com/fiubatps/sisop_2021b_segura/blob/entrega_shell/shell/shellImagenes/ejemplo%20cat1.png)
 
 inversa
 
 ![](https://github.com/fiubatps/sisop_2021b_segura/blob/entrega_shell/shell/shellImagenes/cat2.png)
 
 al cambiar el orden podemos ver ver que en el archivo de out.txtx solo se escribe /home: langtecnologia, no se esta redirigiendo el error al arcxhivo de escritura, mientras que en el anterior si sucedia. 
### Tuberías simples (pipes)


---
Por medio de la la variable internar de BASH: PIPESTATUS se puede avaeriguar el valor exit code, esta es un array que posee cada ecit code de cada comando del pipe. A su vez El estado de retorno de un pipe  es el estado de salida del último comando, a menos que la opción pipefail esté habilitada. Si pipefail está habilitado, el el estado de retorno de la tubería es el valor del último comando (más a la derecha) para salir con un estado distinto de cero, o cero si todos los comandos salen correctamente completamente. Si la palabra reservada ! precede a una tubería, el estado de salida de esa tubería es la negación lógica del estado de salida como se describe encima. El shell espera a que terminen todos los comandos de la canalización antes de devolver un valor.
Si uno de los comandos en la tubería aborta, esto termina prematuramente la ejecución de la tubería. Esta condición, denominada tubería rota, envía una señal SIGPIPE.

Ejemplo:
Una tubería "rota" es aquella en la que un extremo se ha cerrado () y se está leyendo o escribiendo en el otro. Por ejemplo, en el siguiente comando de shell: cat out.txt | less
El proceso de cat sostiene el extremo de escritura de la tubería, y cuanto menos procesa el de lectura. Si el proceso del lector cierra la tubería, la tubería está rota (y por lo tanto es inútil); el proceso de escritura recibirá el error de "tubería rota" del sistema operativo.

### Pseudo-variables

---
 * Variable $$: Expande el pid del proceso actual 
 * Variable $#: Expande el numero de argumentos en $*
 * Variable $*: Expande la lista de argumentos pasada en el proceso actual
 * Variable $?: Expande el resultado del ultimo comando ejecutado.
 
  ![](https://github.com/fiubatps/sisop_2021b_segura/blob/entrega_shell/shell/shellImagenes/pseduoVariables.png)

