# AUTENTICACION DEVISE 

Agregar gem 'devise' al Gemfile

Correr bundle en la terminal

Correr en la terminal el generador de devise: rails g devise:install

Seguir el initializer con las instrucciones que indica la terminal:
    - Copiar codigo y pegarlo en la carpeta config > environments > development , dentro de las configuraciones de actionmailer.
    - definir root_url 'home#index' en config > routes.rb (luego de crear el controlador Home index)
    - agregar mensajes flash en layout > application.html.erb, antes del yield
    - generar las vistas de devise con el comando rails g devise:views (lo dejaremos para mas adelante)

En config > initializers > devise.rb se encuentra la descripcion de todas las configuraciones de devise.

Crearemos el modelo con Devise en funcion del modelo que queramos autenticar. Por ejemplo: user, customer, admin, driver, etc.

Correr el comando rails g devise User. En migrations, por defecto agrega los atributos de user en 3 modulos (authenticable, recoverable y rememberable). Ademas agrega los indices necesarios.

Revisaremos el modelo user.rb, las rutas en routes.erb y en rails routes.

Correr migracion rails db:migrate y el servidor rails s. Probaremos la ruta para sign in escribiendo localhost:3000/users/sign_in

Probar creando un usuario en la ruta de sign_up

Agregar rails g controller Home y un scaffold solo si autenticamos. Correr rails g controller Home index y tambien correr rails g scaffold Tweet name user:references

Correr migraciones con rails db:migrate

Configurar en routes.rb la ruta raiz: root 'home#index' (recordar usar # cuando es root)

Editar application.html.erb y agregar una especie de navbar.
    <% if current_user %>
        <%= link_to 'Log out', destroy_user_session_path, method: :delete %>
    <% else %>
        <%= link_to 'Log in', new_user_session_path %>
    <% end %>

Probar localhost:3000 y verificar en routes.rb 

En el controlador de Tweet vamos a agregar un callback de before_action :authenticate_user! (o admin o worker u otro, dependiendo del nombre del modelo).

Dentro del controlador de Tweet, en el metodo create, agregaremos un nuevo parametro permitido, que sera el usuario actual: @tweet = Tweet.new(tweet_params.merge(user: current_user))

Ya no necesitamos traer la relacion desde la vista de user_id, por lo tanto en el form de tweets borrar el campo user_id. Ya viene encriptado dentro de las cookies. Tambien lo borraremos del strong params.

Para que no nos retorne solo el objeto de User en el form de tweet, crearemos el metodo en el modelo User:
    def to_s
        name
    end

Ahora si, generaremos las vistas de devise que nos solicitaba el inicializador de devise con el comando:
rails g devise:views

Generaremos la migracion rails g migration addNicknameToUser nickname:string

Correr la migracion rails db:migrate

Ir a views > devise > registrations > new.html.erb y edit.html.erb, donde agregaremos el campo para nickname

Generar controlador de devise asi: rails g devise:controllers users

En config > routes.rb agregaremos a las rutas de devise_for :users, controllers: {registrations: 'users/registrations'}

Dentro de los controladores encontraremos la carpeta users > registrations . Descomentar la primera linea de before_action con metodo create y tambien la segunda linea con metodo update

Descomentar el metodo configure_sign_up_params y cambiaremos attribute por los nuevos atributos, en este caso :nickname 

Descomentar el metodo configure_account_update_params y cambiaremos attribute por los nuevos atributos, en este caso :nickname 

Para editar ir a localhost:3000/users/edit

En el modelo user cambiaremos el metodo to_s y en lugar de pasar el email, pasaremos el nickname 


# AUTORIZACIÓN CON ROLES 

Forkear en Github el repositorio de nuestro proyecto

Hacer click en clone or download y copiar el link que nos aparece

Para clonar el repositorio en nuestro computador, iremos a la terminal y scribiremos git clone (+ pegar link + nombre que le queremos asignar a la carpeta, como por ejemplo: old_project). 

Siempre que clonamos un proyecto, debemos correr bundle en la terminal.

Correr migraciones existentes en la carpeta migrate con rails db:migrate

Abrimos old_project con visual studio code.

Para generar estos datos dentro de nuestra bbdd y no esté vacío nuestro proyecto, corremos el comando rails db:seed . De esta forma, todos los datos dentro del archivo seeds.rb se implementarán dentro de la bbdd de nuestro proyecto.

Rails s y comprobamos que funcione localhost:3000

Revisamos el archivo routes y los modelos con sus respectivos belongs_to y has_many

En la terminal esribir el comando: git checkout -b add_authentication . Con esta nueva rama agregaremos devise al gemfile y correremos bundle.

rails g devise:install y seguir los pasos que solicita (por ahora, solo el paso 1 y 3. El paso 2 viene incorporado por defecto).

rails g devise User y revisar nueva migración (se genera un cambio en el modelo User ya existente, no uno nuevo desde cero). 

Tener cuidado de no tener datos ingresados aun en la base de datos.

Si ya existen datos, dado que el campo email no puede estar vacío, ingresar a la última migración y poner un # para comentar null:false, default:  ¨¨ . Mantener la condición unique de más abajo.

rails db:migrate

Cambiar los links del navbar en la carpeta shared o en application.html.erb

Crear vistas de devise: rails g devise:views

En la carpeta views > devise > registrations, ingresar al formulario edit y agregar el campo name. Borrar el autofocus true.

Copiar el campo name y pegarlo tal cual en el formulario new.

rails g devise:controllers users

En la carpeta registrations_controller, descomentar las primeras dos lineas, ademas de los metodos que corresponden en la seccion protected. En attribute colocar :name

En application_controller.rb agregar el callback: before_action :authenticate_user!

Para que la solicitud de acceso sea despues de revisar la pagina principal de posts, debo ir a home_controller.rb y escribir: skip_before_action :authenticate_user!

Agregar datos de email, password y password confirmation en el archivo seeds. Correr rails db:seed

Dentro del archivo routes.rb agregar el controlador que cargaremos dentro de nuestro proyecto para que tenga prioridad por sobre las rutas por defecto de devise:
    devise_for :users, :controllers {
        registrations: 'users/registrations'
    }

En posts_controller.rb, con el fin de ver solo los posts del usuario, en el metodo index modificaremos: @posts = current_user.posts . En el metodo create agregaremos la relacion: @posts.user = current_user

En comments_controller.rb agregaremos al metodo create  @post = Post.find(params[:post_id]) para identificar el post al que pertenece el comentario (por eso :post_id)
Agregaremos ademas las relaciones en el metodo create @comment.post = @post y tambien @comment.user = current_user

rails g migration add_admin_to_users admin:boolean

Antes de correr la migracion iremos al archivo nuevo recien generado y agregaremos , default:false

rails db:migrate

En application_controller.rb crearemos el metodo:
    def after_sing_in_path_for(resource)
        if current_user.admin ?
            comments_path
        else
            super
        end
    end

En el documento routes.rb quitaremos el index de comments fuera del nesteo, escribiendo: resources :comments, only: :index . Ademas, las rutas de comments anidadas las dejaremos asi: recources :comments, shallow :true 

Las rutas se modificaron, por lo tanto pueden aparecer errores como por ejemplo new_post_comment_path ,  en lugar de new_comment_path

En comments_controller.rb, agregar al metodo destroy:
    if current_user.admin
        (codigo que ya se encontraba en destroy)
    else
        redirect_to comments_url, notice: 'You are not allowed to delete comments'
    end

# Testing

rails test

Entrar a test > fixtures > post.yml donde agregaremos una imagen y un usuario para que se graben. Lueog entrar a users.yml y agregar el campo email y admin. Por ultimo a comments.yml para agregar las dependencias de post y user.

En el archivo comments_controller_test.rb agregaremos:
1. Agregar al inicio, dentro de la clase la sgte integracion:
    include Devise::Test::IntegrationHelpers
2. En el setup agregaremos:
    @comment = comments(:one)
    @user = users(:one)
    sign_in(@user)
3. Eliminar tests de show y new, dado que se ven dentro de la vista de post
4. En el test should_destroy_comment agregar al inicio
    sign_out (@user)
    sign_in (users(:one))
5. Modificar en should_create_comment lo sgte:
    post post_comments_url(@comment.post) (segun la ruta que indica rails routes)
    Ademas, ahora vamos a redireccionar al show de post, no de comments, por lo tanto modificaremos:
    assert_redirected_to post_url(@comment.post)

rails test

En el archivo posts_controller_test haremos los dos primeros pasos anteriores pero en lugar de comments es posts

Crearemos dentro de test > controllers el documento sessions_controller_test.rb y escribiremos:
    
    require 'test_helper'
    class SessionsControllerTest < ActionDispatch::IntegratonTest
        include Devise::Test::IntegrationHelpers

        test "admins should redirect to comments_url" do
            sign_in(users(:one))
            post user_session_url
            assert_redirected_to comments_url
        end

        test "No admins should redirect to home"
            sign_in(users(:two))
            poxt user_session_url
            assert_redirected_to root_url
        end
    end
rails test

# SSO con Facebook

Crearse una cuenta en Facebook Developers.

Activar producto 'iniciar sesion con Facebook'
    Inidicar que sera app web
    Indicar URL del sitio. Si estamos en desarrollo ingresar https://localhost:3000
Saltarse los pasos indicados y hacerlo asi:
Agregar gemas en el Gemfile:
    gem 'omniauth-facebook'
    gem 'dotenv-rails', groups [:development, :test]
bundle install
En la carpeta principal de nuestro rpoyecto crear el archivo .env y escribir:
    APP_ID=
    APP_SECRET= 
(Encontraremos estos datos en la configuracion basica de Facebook) 
Agregar dentro de .gitignore el archivo .env porque no queremos que se vayan al repositorio nuestras claves secretas

rails g provider addOmniauthToUser provider:string uid:string

Verificar migracion en la carpeta db > migrate

rails db:migrate

En config > initializers > devise.rb descomentaremos la linea de configuracion de Omniauth y lo modificaremos para que quede asi:
    config.omniauth :facebook , ENV['APP_ID'], ENV['APP_SECRET']

Dentro del modelo user.rb, a continuacion de todas las configuraciones de Devise:
    :omniauthable, omniauth_providers: %i[facebook]

En views > shared > navbar.html.erb agregaremos una nueva linea:
    <li><%= link_to 'Sign in with Facebook', user_facebook_omniauth_authorize_path %><li>

En routes.rb, dentro de devise_for agregaremos:
    omniauth_callbacks: 'users/omniauth/callback'



 