# Implementacion

Se realizo un navegador por el historial en el cual se puede ver el historial por medio del comando history, como tambien se puede indicar la cantidad de comandos a
ver del historial por medio de history n (siendo n la cantidad de comandos a ver). Tambien se implemento el poder moverse con el historial por medio de las flechas
de arriba y abajo, el poder borrar de una linea caracteres y los event designators.

Consideraciones:
* los archivos donde se guarda el historial deben existir
* se tuvo que hacer una modificacion en split_line para que se pudieran ejecutar algunos comandos al moverse por el historial por medio de las flechas de arriba
  y abajo que sin esta modificacion fallaba, por lo si se escribe un comando del tipo pipe no lo va a ejcutar bien( no se consideran comandos pipe).
* Los event designators no se guardan en el historial ya que en su implementacion origial esto no sucede.
* al ejecutar el comando history n, se muestra el comando history y los otros n-1 comandos ya que en su implemantcion original sucede de esta forma.


# Pregunta teorica

Cuál es la función de los parámetros MIN y TIME del modo no canónico? ¿Qué se logra en el ejemplo dado al establecer a MIN en 1 y a TIME en 0?

El parametro MIN indica la cantidad de minima de caracteres a leer en el modo no canonico y el parametro TIME  indica cuánto tiempo se debe esperar después
de cada carácter de entrada para ver si llega otro.
En el caso en que MIN = 1 y TIME = 0 read espera hasta que al menos 1 bytes disponible en la cola. Luego, read devuelve tantos caracteres como estén
disponibles, hasta el número solicitado. read puede devolver más de 1 caracter si hay más de 1 en la cola.
(https://www.gnu.org/software/libc/manual/html_node/Noncanonical-Input.html)
(https://www.gnu.org/software/libc/manual/html_node/Noncanon-Example.html)

Comentario:
hice la correcciones de shell en el desafio.

# Reentrega del desafio shell

Para la parte del parceo lo primero que se hace es se verifica si lo que esta llegando es una flecha. La forma de dectectar esto es cuando llega una secuencia de escape, seguido de una serie de caracteres(es como un medio de comunicacion entre el programa y la terminal). El caracter 27 indica que lo que sigue es una secuencia de control y debe ser interpretada.
Todos los codigos de escape comienzan por los caracteres ESC y son seguidos de [. Una vez detectado este caracter se procede al parceo de las distintas flechas(ARRIBA, ABAJO, DERECHA, IZQUIERDA). Despues se veriica si lo que llego es un backspace donde dentro de su logica se tiene en cuenta si llego una fecla para los costados para borrar el caracter correspondiente y lo mismo si llega otro caracter para escribirlo. En esta parte tambien se tiene en cuenta si llego una flecha para los costados para insertar el caracter en su correspondiente posicion.
Para la parte de las flechitas hacia los costados lo que hago es dependiendo de si se trata de derecha o izquierda aumento o disminuyo en 1 la posicion actual en mi vector. Luego si quiero escribir un caracter me guardo en un vector auxiliar los caracteres hasta la posicion i luego borro por consola el resto de los caracteres, me guardo el caracter a escribir y lo escribo por la pantalla y luego concateno el resto de los caracteres del buffer en mi vector auxiliar y los voy escribiendo por consola, actualizo mi buffer y muevo el cursor a la posicion donde estaba. Algo similar se hace para cuando quiero borrar en una posicion donde en vez de escribir un caracter directamente contaneo el resto de caracteres. 
