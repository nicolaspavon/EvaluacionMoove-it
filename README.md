"# EvaluacionMoove-it"

Nicolás Pavón

Aclaraciones importantes:

Para iniciar el servidor, ejecuto server.rb. Los tests fueron realizados con Rspec, se ubican en los archivos client_MEM_spec.rb y
client_BD_spec.rb
(Aclaro por las dudas, ejecuto los tests y el servidor en consolas distintas.)

El comando stats, (el cual no es requerido), lo implemente para averiguar que keys estan almacenadas en la memoria.

Agreque sleeps a la base de datos para que se note la diferencia entre la carga y descarga entre bdd y en memoria

TESTS-----
En la carpeta spec se encuentran las clases a ejecutar

Existe la opcion de "desactivar" la base de datos, para poder probar las funciones relacionadas con la memoria,
sin interferencias con la base de datos.
Por ejemplo, utilizar el comando get, y asegurarse que la key que se pide sea obtenida desde la memoria y no desde la base de datos.
Para desactivarla, se debe modificar la variable FALSE_DB (ubicada en la clase Memory) a true, para que el programa utilize una bdd falsa.
En cuanto a los tests, existen dos clases: client_MEM_spec.rb y client_BD_spec.rb (estas deben ser testeadas con: FALSE_DB = true si se testea MEM|| FALSE_DB = false si se testea BDD)

client_BD_spec.rb espera que las respuestas del servidor sean acordes a las de un servidor con base de datos.
client_MEM_spec.rb espera que las respuestas del servidor sean acordes a las de un servidor sin base de datos y con 50 bytes de memoria.
Ademas la clase client_MEM_spec.rb testea, (a diferencia de client_BD_spec.rb), el algoritmo LRU.

Tambien existe la clase client_specific_spec.rb, en la cual se facilita la prueba de comandos
------------------------------------------------------------------------------------------------------------------------------------------------------------
Casos de uso testeados:
--
Con base de datos:
    10 usuarios intentando ejecutar el comando set al mismo tiempo
    -
    Con errores del cliente en el comando:
        Comandos testeados con almenos un parametro faltante, y/o parametros erroneos (ej: letras en el parametro flags):
            [set, add, replace, append, prepend, get, cas, gets]
    -
    Sin errores del cliente en el comando:
        Casos de uso testeados:
            set-
            add-     con key existente y sin key existente
            replace- con key existente y sin key existente
            append-  con key existente y sin key existente
            prepend- con key existente y sin key existente
            cas-     con key existente y sin key existente, testeados los resultados posibles (exists, stored)
            get-     con key existente, sin key existente y con varias keys
            gets-    con key existente, sin key existente y con varias keys

        Funciones testeadas:
            Expiracion de claves
            Base de datos

Sin base de datos:
    Todos los casos de uso anteriores mas el testeo de el algoritmo LRU.
