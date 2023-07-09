HOLA! ESTE CODIGO FUE CREADO Y  EJECUTADO CON  RUBY 3.2.2 (BETA) 
EN ESTE CODIGO UTILIZO LA GEMA  gem 'launchy' PARA ABRIR EL NAVEGADOR Y MOSTRAR EL OUTPUT EN UN HTML
PERO PARECE QUE POR LA BETA QUE USEA DE RUBY (QUE ERA LA ULTIMA VERSION PARA DESCARGAR EN WINDOWS)
NO ME CARGA EL CONTENIDO.... TAMBIEN TRATE DE QUE FUERA COMO UN ENTORNO VIRTUAL 
Y DEJE EL ARCHIVO  GemFile  Y LAS INDICACIONES AQUI ABAJO:

---> gem install digest/md5
---> gem install launchy



Primero, asegúrate de tener Bundler instalado. Si no lo tienes instalado, ejecuta el siguiente comando en tu terminal:
---> gem install bundler

Ejecuta el siguiente comando para instalar las dependencias en tu entorno virtual:

---> bundle install --path vendor/bundle

Ahora puedes ejecutar tu archivo marvel_api.rb con Bundler para que utilice las gemas instaladas en el entorno virtual. Usa el siguiente comando:

---> bundle exec ruby marvel_api.rb
