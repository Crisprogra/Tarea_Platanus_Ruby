require 'net/http'
require 'digest/md5'
require 'json'
require 'openssl'
require 'erb'
require 'launchy'

=begin

En estas líneas, se están importando las librerías necesarias para el código. 
Estas librerías proporcionan funciones y métodos para realizar solicitudes HTTP, generar hashes MD5, 
manejar datos JSON, procesar plantillas ERB y abrir archivos HTML en el navegador utilizando Launchy.  

=end

def generate_hash(timestamp, private_key, public_key)
  Digest::MD5.hexdigest("#{timestamp}#{private_key}#{public_key}")
end

=begin

Esta función toma un timestamp, una clave privada y una clave pública como parámetros y genera 
un hash MD5 concatenando los valores de los parámetros. 
Este hash se utiliza para autenticar las solicitudes a la API de Marvel.

=end

def get_creator_id(last_name)
  credentials = JSON.parse(File.read('credentials.json'))
  public_key = credentials['public_key']
  private_key = credentials['private_key']
  timestamp = Time.now.to_i.to_s
  hash = generate_hash(timestamp, private_key, public_key)
  base_url = 'https://gateway.marvel.com/v1/public'
  endpoint = '/creators'
  params = "?lastName=#{last_name}&apikey=#{public_key}&ts=#{timestamp}&hash=#{hash}"
  url = base_url + endpoint + params
  response = Net::HTTP.get(URI(url))
  data = JSON.parse(response)

  if data['data'] && data['data']['results']
    creator = data['data']['results'].first
    if creator
      creator['id']
    else
      puts "No se encontró el creador con el apellido '#{last_name}'"
      nil
    end
  else
    puts "Error al obtener los datos de la API de Marvel: #{response}"
    nil
  end
end

=begin

En esta función se obtiene el ID del creador de cómics correspondiente al apellido proporcionado. 
Veamos el análisis línea por línea:

Se lee el archivo 'credentials.json' y se analiza su contenido JSON utilizando JSON.parse. 
Esto carga las claves public_key y private_key en la variable credentials.
Se asignan las claves public_key y private_key a las variables public_key y private_key, respectivamente.
Se obtiene la marca de tiempo actual en formato entero utilizando Time.now.to_i y se convierte a cadena.
Se genera un hash utilizando la función generate_hash(timestamp, private_key, public_key). 
Este hash se utilizará en la autenticación de la API de Marvel.
Se definen las variables base_url, endpoint y params que conformarán la URL para obtener los datos del creador.
Se construye la URL concatenando base_url, endpoint y params.
Se realiza una solicitud GET a la URL utilizando Net::HTTP.get(URI(url)) 
y se guarda la respuesta en la variable response.
Se analiza el contenido JSON de la respuesta utilizando JSON.parse(response) y se guarda en la variable data.
A partir de este punto, se realiza la validación y manipulación de los datos obtenidos:

Se verifica si la clave 'data' existe en data y si también existe la clave 'results' dentro de 'data'.
 Esto asegura que se haya recibido una respuesta válida de la API.
Si se cumple la condición anterior, se accede al primer resultado de la lista de creadores 
obtenida (data['data']['results'].first) y se asigna a la variable creator.
Si creator existe (no es nulo), se accede al ID del creador (creator['id']) 
y se retorna ese valor como resultado de la función.
Si creator es nulo, se imprime un mensaje indicando que no se encontró el creador con el 
apellido proporcionado y se retorna nil.
Si no se cumple la condición inicial (no se obtuvo una respuesta válida de la API), 
se imprime un mensaje de error con los detalles de la respuesta y se retorna nil.
En resumen, esta función utiliza las claves de API obtenidas del archivo 'credentials.json' 
para autenticarse y realizar una solicitud a la API de Marvel. Luego, se analiza la respuesta obtenida 
y se extrae el ID del creador correspondiente al apellido proporcionado. Si se encuentra un creador, 
se devuelve su ID; de lo contrario, se imprime un mensaje de error y se devuelve nil.

Teniendo en cuenta los requerimientos, esta función parece cumplir con el objetivo de obtener el ID 
del creador de cómics correspondiente al apellido proporcionado.

=end




def get_comics_for_creator(creator_id)
  credentials = JSON.parse(File.read('credentials.json'))
  public_key = credentials['public_key']
  private_key = credentials['private_key']
  timestamp = Time.now.to_i.to_s
  hash = generate_hash(timestamp, private_key, public_key)
  base_url = 'https://gateway.marvel.com/v1/public'
  endpoint = "/creators/#{creator_id}/comics"
  params = "?apikey=#{public_key}&ts=#{timestamp}&hash=#{hash}"
  url = base_url + endpoint + params
  response = Net::HTTP.get(URI(url))
  data = JSON.parse(response)

  if data['data'] && data['data']['results']
    comics = data['data']['results']
    if comics.any?
      character_names = []
      comics.each do |comic|
        comic['characters']['items'].each do |character|
          character_names << character['name']
        end
      end
      character_names = character_names.uniq.sort

      generate_html_file(comics.first['creators']['items'].first['name'], character_names)
      puts "Creador con menos cómics disponibles: #{comics.first['creators']['items'].first['name']}"
      puts "Personajes en los cómics:"
      comics.each do |comic|
        comic['characters']['items'].each do |character|
          puts character['name']
        end
      end
    else
      puts "No se encontraron cómics para el creador con ID '#{creator_id}'"
    end
  else
    puts "Error al obtener los datos de la API de Marvel: #{response}"
  end
end


=begin

En esta función, se utiliza el ID del creador obtenido previamente para buscar los cómics asociados 
a ese creador en la API de Marvel. Veamos el análisis línea por línea:

Se obtienen las credenciales (clave pública y clave privada) 
de la API de Marvel desde un archivo JSON  llamado 'credentials.json'.
Se genera un timestamp y un hash utilizando las claves públicas y privadas, mediante la función 
generate_hash(timestamp, private_key, public_key).
Se establece la URL base de la API de Marvel y se construye la URL específica para obtener 
los cómics del creador con el ID correspondiente.
Se realiza una solicitud HTTP GET a la URL construida utilizando Net::HTTP.get(URI(url)), 
y la respuesta se guarda en la variable response.
La respuesta se parsea como un objeto JSON y se almacena en la variable data.
Se verifica si la respuesta contiene los campos 'data' y 'results', lo que indica que se obtuvieron datos válidos.
Si hay cómics disponibles (la lista de resultados no está vacía), se extraen los nombres de los personajes 
asociados a cada cómic y se almacenan en la variable character_names. Los nombres de los personajes 
se obtienen iterando sobre cada cómic y sus elementos de 'characters'.
Se ordenan los nombres de los personajes alfabéticamente y se eliminan duplicados utilizando uniq.sort.
Se llama a la función generate_html_file para generar un archivo HTML con el nombre del primer creador 
obtenido y la lista de nombres de personajes. Luego, se abrea ese archivo HTML.
Se muestra el nombre del creador con menos cómics disponibles mediante puts "Creador con menos cómics 
disponibles: #{comics.first['creators']['items'].first['name']}".
Se muestra la lista de personajes en los cómics mediante puts "Personajes en los cómics:". 
Los nombres de los personajes se obtienen iterando sobre cada cómic y sus elementos de 'characters'.
Si no se encontraron cómics para el creador con el ID proporcionado, 
se muestra un mensaje indicando que no se encontraron cómics.
Si ocurrió un error al obtener los datos de la API de Marvel, 
se muestra un mensaje de error con la respuesta obtenida.
En general, el código busca obtener los cómics asociados a un creador específico y mostrar tanto 
el nombre del creador como la lista de personajes presentes en esos cómics. La lógica parece estar 
correctamente implementada en relación con los requerimientos de obtener los cómics del creador y los personajes asociados.

=end

def generate_html_file(creator_name, character_names)
  template = File.read('template.erb')
  renderer = ERB.new(template)

  if character_names.nil? || character_names.empty?
    character_names = ['No hay personajes disponibles']
  end

  output = renderer.result(binding)
  File.write('output.html', output)
  Launchy.open('output.html')
end

=begin

En esta función se genera un archivo HTML válido que contiene el nombre del creador y una tabla con los nombres
de los personajes. Veamos el análisis línea por línea:

Se lee el contenido del archivo 'template.erb' y se guarda en la variable template. Es probable 
que este archivo contenga una plantilla HTML con marcadores de posición para el 
nombre del creador y la tabla de personajes.
Se crea un objeto ERB utilizando la plantilla leída anteriormente. ERB es una clase de Ruby 
que permite generar contenido dinámico utilizando plantillas.
Se verifica si la lista de character_names está vacía o es nula. Si es así, se asigna un array 
con el único elemento "No hay personajes disponibles" a la variable character_names.
Se evalúa la plantilla template utilizando renderer.result(binding). Esto reemplazará los marcadores 
de posición en la plantilla con los valores actuales de creator_name 
y character_names. El resultado se guarda en la variable output.
Se escribe el contenido de output en un archivo llamado 'output.html' 
utilizando File.write('output.html', output). Esto crea un archivo HTML con el contenido generado.
Finalmente, se abre el archivo 'output.html' utilizando Launchy.open('output.html'), 
lo que debería abrir el archivo en el navegador web predeterminado.
En resumen, esta función genera un archivo HTML válido con el nombre del creador y una tabla de personajes.
 Verifica si la lista de personajes está vacía y asigna un valor predeterminado si es necesario. 
 Luego, utiliza una plantilla HTML para reemplazar los marcadores de posición con los valores actuales 
 y crea el archivo HTML. Por último, abre el archivo generado en el navegador web.

Teniendo en cuenta los requerimientos, esta función parece cumplir con la tarea de generar un archivo HTML 
válido con el nombre del creador y los personajes en una tabla, de acuerdo con la plantilla proporcionada 
en 'template.erb'.

=end

creator_ids = []     # Lista vacía para almacenar los IDs de los creadores de cómics
last_names = []      # Lista vacía para almacenar los apellidos de los creadores

2.times do
  print "Ingrese el apellido del creador de cómics: "
  last_name = gets.chomp
  last_names << last_name   # Agregar el apellido ingresado a la lista de apellidos
end

# Obtener los IDs de los creadores de cómics correspondientes a los apellidos ingresados
creators = last_names.map { |last_name| get_creator_id(last_name) }
creator_ids = creators.compact   # Eliminar los valores nulos de la lista de IDs

if creator_ids.any?
  min_comics_creator_id = creator_ids.min   # Obtener el ID del creador con menos cómics
  get_comics_for_creator(min_comics_creator_id)   # Obtener los cómics del creador con menos cómics
end




=begin

Se inicializan las variables creator_ids y last_names como listas vacías para almacenar los IDs de 
los creadores y los apellidos ingresados respectivamente.

Se solicita al usuario que ingrese los apellidos de dos creadores de cómics utilizando un 
bucle times que se ejecuta dos veces. En cada iteración, se muestra el mensaje "Ingrese el apellido 
del creador de cómics:" y se recibe la entrada del usuario utilizando gets.chomp. Luego, el apellido 
ingresado se agrega a la lista last_names.

Se utiliza el método map en la lista last_names para obtener una lista de creadores correspondientes 
a los apellidos ingresados. En cada iteración, se llama a la función get_creator_id para obtener el ID 
del creador asociado al apellido. Los IDs obtenidos se almacenan en la lista creators.

Se elimina cualquier valor nulo de la lista creators utilizando el método compact, y se asigna el 
resultado a la lista creator_ids. Esto se hace para asegurarse de que solo se consideren los IDs válidos 
de los creadores.

Se verifica si hay al menos un ID de creador disponible en la lista creator_ids utilizando el método any?. 
Si es cierto, significa que se obtuvieron IDs válidos.

Si hay IDs disponibles, se encuentra el ID del creador con la menor cantidad de cómics utilizando 
el método min en la lista creator_ids, y se asigna a la variable min_comics_creator_id.

Finalmente, se llama a la función get_comics_for_creator con el ID del creador con menos cómics 
para obtener los cómics asociados a ese creador.

En resumen, este código permite al usuario ingresar los apellidos de dos creadores de cómics y 
obtiene los cómics asociados al creador con menos cómics entre los dos ingresados. Los pasos 
incluyen la obtención de los IDs de los creadores, la eliminación de valores nulos, la búsqueda 
del creador con menos cómics y la obtención de los cómics correspondientes.

=end
