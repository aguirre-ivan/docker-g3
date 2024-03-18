<?php

use Monolog\Logger;
use SIU\Chulupi\util\log\log;
use siu\modelo\autenticacion\fuente_usuarios_guarani;
use SIU\Chulupi\util\mail;
use PHPMailer\PHPMailer\SMTP;

return [
	'global' =>
	[
		'produccion' => false,
		'usar_personalizaciones' => true,
		'sesion_timeout' => 10000,
		'sesion_maxtime' => 10000,
		'dir_attachment' => '/tmp',
		'ssl' => [
			'alcance' => 'none',//'none' | 'all'
			'redirigir_ssl' => true,//true | false
		],
		//	'server_name' => '192.168.126.180',
		'imagen_alumno_dir' => '<PATH_TO_3W>/src/siu/www/_comp/_img_alumnos/',
		'imagen_alumno_url' => '<URL_TO_3W>/_comp/_img_alumnos/',
		'salt' => '9bf057558b90263987bd8f99caf2e92f7efc1a13',
		'url_kolla' => 'http://localhost/kolla/3.4/',

		
		/**
		* URL del frontend de Sanaviron-Quilmes
		*/
		'url_sq_pagos' => 'http://localhost/sq_pagos/',

		// Directorio donde se guardar los archivos de metadata de operaciones inactivas
		// por defecto se guardan en instalacion/operaciones_inactivas
		//    'dir_ops_inactivas' => '/tmp/ops',

		/**
		 * Configuraci�n de reCAPTCHA 2
		 * Para obtener el par de API keys ('site_key' y 'secret_key')
		 * ir a http://www.google.com/recaptcha/admin
		 * opciones: Son las opciones de Guzzle (http://docs.guzzlephp.org/en/stable/request-options.html)
		 */
		'captcha' =>
		[
			'activo' => false,
			'intentos_login' => 3,
			'site_key' => '', //Ej: '6LfeSwgUAAAAAIwfEadYVIsp_-D8xRHi_qTEGS-x'
			'secret_key' => '', //Ej: '6LfeSwgUAAAAABXZhiGF0vmABVgyyUZ7eIgk_vLD'
			'opciones' => [
				//'proxy' => 'tcp://localhost:8125',
				//'verify' => false,
			]
		],
		'proxy' => 
		[
			'activo' => false,
			'proxy_host' => 'proxy.xxxxxxxxx',
			'proxy_port' => 8080,
			'proxy_username' => 'PROXY-USERNAME',
			'proxy_password' => 'PROXY-PASSWORD'
		],
		'google_analytics' =>
		[
			'activo'  => true,
			'account' => 'UA-xxx-y'
		],
		'log' =>
		[
			'activo' => true,
			/**
			 * Niveles de log: 
			 *  - 'log::NIVEL_DEBUG'	-> Recomendado en Desarrollo
			 *  - 'log::NIVEL_INFO'		-> Solo muestra informaci�n de tiempo y memoria consumida
			 *  - 'log::NIVEL_ERROR'	-> Recomendado en Producci�n
			 */
			'nivel' => log::NIVEL_DEBUG,
			
			/**
			 * Nivel m�nimo de log para consola (CLI): 
			 *  - 'Logger::DEBUG'	-> Recomendado en Desarrollo
			 *  - 'Logger::INFO'
			 *  - 'Logger::NOTICE'
			 *  - 'Logger::WARNING'
			 *  - 'Logger::ERROR'	-> Recomendado en Producci�n
			 *  - 'Logger::CRITICAL'
			 *  - 'Logger::ALERT'
			 *  - 'Logger::EMERGENCY'
			 */
			'nivel_consola' => Logger::DEBUG,
			
			/**
			 * Nivel m�nimo de log para Web: 
			 *  - 'Logger::DEBUG'	-> Recomendado en Desarrollo
			 *  - 'Logger::INFO'
			 *  - 'Logger::NOTICE'
			 *  - 'Logger::WARNING'
			 *  - 'Logger::ERROR'	-> Recomendado en Producci�n
			 *  - 'Logger::CRITICAL'
			 *  - 'Logger::ALERT'
			 *  - 'Logger::EMERGENCY'
			 */
			'nivel_web' => Logger::DEBUG,
			
			'barra_dev' => true,
		],
		'ini_debug' => false,
		/**
		* Indica el manejador de cache a utilizar.
		* NOTA: si utiliza un esquema de servidores distribuidos se recomienda
		* utilizar 'memcached' y configurar uno o m�s servidores de cache.
		*  - Valores posibles: apc|memcached
		*/
		'manejador_cache_memoria' => 'apc',
		/**
		* Configuraci�n de servidores de memcached
		*/
		'memcached' =>
		[
			'server_1' =>
			[
				'host' => '127.0.0.1',
				'port' => 11211,
				'peso' => 1,
			],
		],
		'smtp' =>
		[
			'from' => 'guarani.siu@gmail.com',
			'host' => 'smtp.gmail.com',
			'seguridad' => mail::SSL,
			'auth' => true,
			'port' => 465,
			'reply_to' => 'guarani.siu@gmail.com',
			/**
			 * Debug output level.
			 * Options:
			 * * SMTP::DEBUG_OFF (`0`) No debug output, default
			 * * SMTP::DEBUG_CLIENT (`1`) Client commands
			 * * SMTP::DEBUG_SERVER (`2`) Client commands and server responses
			 * * SMTP::DEBUG_CONNECTION (`3`) As DEBUG_SERVER plus connection status
			 * * SMTP::DEBUG_LOWLEVEL (`4`) Low-level data output, all messages.
			 */
			'smtp_debug' => SMTP::DEBUG_OFF,
			
			/**
			 * RECOMENDADO
			 * Si se usa OAUTH2 se debe configurar lo siguiente
			 * Obtener los tokens de aqu�: https://github.com/PHPMailer/PHPMailer/wiki/Using-Gmail-with-XOAUTH2
			 */
			'auth_type' => mail::AUTH_TYPE_XOAUTH2,
			'oauth2_email' => 'guarani.siu@gmail.com',
			'oauth2_client_id' => 'RANDOMCHARS-----duv1n2.apps.googleusercontent.com',
			'oauth2_client_secret' => 'RANDOMCHARS-----lGyjPcRtvP',
			'oauth2_refresh_token' => 'RANDOMCHARS-----DWxgOvPT003r-yFUV49TQYag7_Aod7y0',
			
			/**
			 * NO RECOMENDADO: Se debe dar "Acceso de apps menos seguras" en Gmail
			 * Si se usa autenticaci�n simple configurar 'usuario' y 'clave'
			 */
			//'auth_type' => mail::AUTH_TYPE_USER_PASS,
			//'usuario' => 'guarani.siu@gmail.com',
			//'clave' => '',
			
			/* 
			 * Decido si verifico los certificados en una conexi�n SSL
			 * Ver: https://github.com/PHPMailer/PHPMailer/wiki/Troubleshooting#php-56-certificate-verification-failure
			 */
			/*'ssl' => [
				'verify_peer' => false,
				'verify_peer_name' => false,
				'allow_self_signed' => true
			]*/
		],
		//Cantidad de emails que se desencolaran y enviaran cada vez que se ejecute el cron o tarea programada (0 para ilimitado)
		'cant_emails_a_enviar_por_corrida_cron' => 0,

		//Cantidad m�xima de destinatarios por email, los emails ser�n paginados por esta cantidad (0 para ilimitado)
		'cant_max_destinatarios_por_email' => 0,

		//Cantidad m�xima de opciones de respuestas devueltas por kolla (0 para ilimitado)
		'encuestas_cantidad_maxima_respuestas_kolla' => 100,

		//Evaluacion y eliminacion de rtas de kolla con texto libre que esten incluidas en
		//regex: "/^[\.\-\,\ ]+$/","/no.*tu/i","/no.*ten/i","/no fue mi/i","/no opin/i","/sin coment/i","/^ningun./i","/^sin observ/i","/no hay observ/i","/nada para agregar/i","/nada en especial/i","/sin opini/i","/^sin descripc/i"
		'encuesta_evaluar_rtas_libres_expreg' => false,

		/**
		* Indica si habilitar el autocompletado de los inputs o no (por defecto NO)
		*  - Valores posibles: true|false
		*/
		'habilitar_sugerencias_autocompletar_input' => false,

		/**
		 * Indica si habilitar el modo prueba de stress o no
		 *  - Valores posibles: true|false
		 */
		'habilitar_prueba_stress' => false,
		
		/**
		 * Indica si habilitar el chequeo de version de php vs BD (deshabilitarl al momento de poner en producci�n)
		 *  - Valores posibles: true|false
		 */
		'chequear_version_bd' => true,
		
		/**
		 * Indica si habilitar la vista de agenda del Alumno (cursadas y examenes vigentes)
		 *  - Valores posibles: true|false
		 */
		'habilitar_agenda_alumno' => true,

		/**
		 * Configuraci�n de Repositorio Digital Integrado (RDI). 
		 * Para utilizarlo, es necesario tener establecido el par�metro del sistema
		 * "usa_repositorio_digital" en "S: Se almacenan los documentos en el repositorio digital"
		 */
		'rdi' => [
			'config' => [
				'proyecto' => 'guarani3w',
				'repositorio' => 'url_repositorio', // Ejemplo: 'http://192.168.125.1:8081/nuxeo/atom/cmis',
				'usuario' => '****',
				'clave' => '****',
				'conector' => 'CMIS_ATOM',
			],
		],
		
		/**
		 * URL de la aplicaci�n SIU-Huarpe, se puede obtener desde 'SIU-Ara� Usuarios' solapa 'Aplicaciones'.
		 *  - Ejemplo: http://localhost/huarpe
		 */
		'huarpe_url' => 'URL_SIU_HUARPE',
		
		/**
		 * URL de la bandeja de documentos pendientes de autorizaci�n de SIU-Huarpe.
		 *  - Ejemplo: http://localhost/huarpe/documentos
		 */
		'huarpe_url_bandeja' => 'URL_SIU_HUARPE/documentos',
		
		/**
		 * URL de la de ayuda para identidad de genero
		 *  - Ejemplo: https://drive.google.com/file/d/1WFW6s9CAZro2mtOs1JIkBX0la6fzJP_o/view
		 */
		'url_identidad_genero' => 'https://drive.google.com/file/d/1WFW6s9CAZro2mtOs1JIkBX0la6fzJP_o/view',

		/**
		 * E-mail de ayuda para contactarse con la Universidad.
		 *  - Ejemplo: uunn@edu.ar
		 */
		'email_ayuda' => 'aguirre.ivang@gmail.com',

		'accesos' =>
		[
			'des01' =>
			[
				'personalizacion' => 'filo',
				'database' =>
				[
					'vendor' => 'pgsql',
					'dbname' => 'toba_3_3',
					'schema' => 'negocio',
					'schema_toba' => 'desarrollo',
					'host' => 'postgres',
					'port' => 5432,
					'pdo_user' => 'postgres',
					'pdo_passwd' => '123456',
				],

			// Colocar aqu� los ids de responsables acad�micas por punto de acceso. Si el array es vac�o no filtra por responsable acad�mica ej:'ptoacc_ra'=> ['21'].
			'ptoacc_ra' => [],
				// M�todos de autenticaci�n habilitados para este punto de acceso, si se deja vac�o incluye todos.
				// Ej: [fuente_usuarios_guarani::AUTH_FORM] solo habilita autenticaci�n por formulario  
				// Ej: [fuente_usuarios_guarani::AUTH_FORM, fuente_usuarios_guarani::AUTH_SAML] habilita autenticaci�n por formulario y SAML  
				'metodos_autenticacion_habilitados' => [],
			],

		],
		'registrar_log_ingresos' => true,

		/**
		 * Host donde se corre Jasper
		 *  - Ejemplo: 127.0.0.1
		 */
		'jasper_host' => '127.0.0.1',

		/**
		 * Puerto donde se corre Jasper
		 *  - Ejemplo: 8081
		 */
		'jasper_port' => '8081',

        /**
         * Tiempo de expiraci�n del token para recuperar contrase�a (mdp_personas.token)
         * Debe ser un interval de PostgreSQL (ver: https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-interval/)
         *  - Ejemplos: '30 minutes', '1 hour', '2 hours', '1 day', '3 days', '1 month'
         */
        'ttl_token' => '1 day',

        /**
         * Control de acceso simult�neo a operaciones
         */
        'control_simultaneidad_operaciones' => [

            'activo' => false,

            'ttl_segundos' => 1,
            
        ],

        /**
         * El n�mero m�nimo de caracteres que un usuario debe escribir antes de realizar una b�squeda.
         * El cero es �til para datos locales con solo unos pocos elementos,
         * pero se debe usar un valor m�s alto cuando una b�squeda de un solo car�cter puede coincidir con unos pocos miles de elementos.
         * https://api.jqueryui.com/autocomplete/#option-minLength
         */
        'ui_autocomplete_min_length' => 3,
    ],
];
