#include "history.h"


/*
* devuelve el path del history. El archivo por default debe existir.
*/
char* obtener_path_history(){
  char* ruta = calloc(BUFLEN, sizeof(char));
  char* history_path = getenv(HISTFILE_RUTA);
  if (!history_path){
      char* home_path = getenv("HOME");
      strcat(ruta, home_path);
      char* history_omision = HISTFILE_OMISION;
      strcat(ruta, history_omision);
  } else {
      strncat(ruta, history_path, BUFLEN);
      ruta[strlen(ruta)] = '\0';
  }
  return ruta;
}

/*
* Recibe un string ya inicializado y la funcion se encuarga
* de escribir el comando en el archivo que guarda el historial
* de los comandos utilizados.
*/
void guardar_history(char* cmd){
    if (!cmd){
        return;
    }
    char enter = '\n';
    char* ruta = NULL;
    ruta = obtener_path_history();
    if (ruta != NULL){
        FILE* fhistory = fopen(ruta, "a+");
        if (!fhistory){
            free(ruta);
            return;
        } else {
          fwrite(cmd, sizeof(char), strlen(cmd), fhistory);
          fwrite(&enter,sizeof(char),1,fhistory);
		      fclose(fhistory);
        }
    }
    free(ruta);
}
/*
* devuelve la cantidad de comandos en el archivo de fhistory.
* El archivo history debe estar previamente abierto y la funcion lo deja
* en la posicion inicial.
*/
int cant_de_comandos(FILE* fhistory){
    char* aux = NULL;
    size_t len = 0;
    int cant_comandos = 0;
    while(getline(&aux, &len, fhistory) != -1){
      cant_comandos++;
      free(aux);
      aux = NULL;
      len = 0;
    }
    free(aux);
    rewind(fhistory);
    return cant_comandos;
}
/*
* almacena en el vector que recibe los comandos del file history
*/
void obtener_comandos(FILE* fhistory, char** comandos){
    char* comando = NULL;
    size_t len = 0;
    int pos = 0;
    while(getline(&comando, &len, fhistory) != -1){
        comando[strlen(comando) -1] = '\0';
        strncpy(comandos[pos],comando, len);
        pos++;
        free(comando);
        comando = NULL;
        len = 0;
    }
    free(comando);
}

/*
 * deulvel el comando que se encuentra en la posicion
 * total_comando - cant_comandos.
 * El archivo debe etsra previamente abierto.
*/
char* buscar_comando(FILE* fhistory, int cant_comandos, bool* falla){
    int cant_total = cant_de_comandos(fhistory);
    if (cant_total < cant_comandos){
        (*falla) = false;
        return NULL;
    }
    int borrar = 0;
    if (cant_total - cant_comandos > 0){
        borrar = cant_total - cant_comandos;
    }
    char* comando = NULL;
    size_t len = 0;
    int aux = 0;
    getline(&comando, &len, fhistory);
    while (!feof(fhistory) && aux < borrar && comando != NULL){
        aux++;
        free(comando);
        comando = NULL;
        len = 0;
        getline(&comando, &len, fhistory);
    }
    len = strlen(comando);
    comando[len - 1] = '\0';
    return comando;
  }
