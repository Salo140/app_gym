# Especificaciones del proyecto: GymMate

> Borrador de alcance y notas de trabajo. La definición oficial del entregable 1, con secciones, identificadores y navegación verificados contra el código, es [docs/definicion.md](definicion.md). Si este borrador difiere, prevalece la definición oficial.

## Problema
Muchas personas comienzan a entrenar en el gimnasio con dificultades para organizar sus entrenamientos y entender cómo llevar una alimentación adecuada de acuerdo con sus objetivos y necesidades.

Los principiantes pueden no saber qué ejercicios realizar, cómo ejecutarlos correctamente, cuánto descansar entre series o cómo organizar una rutina. Al mismo tiempo, las personas con mayor experiencia pueden necesitar herramientas para registrar sus entrenamientos, consultar su progreso y adaptar sus ejercicios cuando no cuentan con determinado equipo.

La alimentación también representa una dificultad frecuente, ya que existe mucha información contradictoria sobre qué comer, qué alimentos elegir, cómo organizar las comidas y cómo relacionar la alimentación con la actividad física.

GymMate busca solucionar estas necesidades mediante una aplicación móvil que integre entrenamiento y educación alimentaria en un mismo lugar. La aplicación permitirá al usuario consultar y realizar rutinas, aprender sobre ejercicios, registrar sus entrenamientos, visualizar su progreso y acceder a herramientas educativas que le ayuden a comprender cómo construir comidas variadas de acuerdo con sus preferencias y objetivos.

La aplicación tendrá un enfoque educativo y de acompañamiento, por lo que no pretende sustituir la orientación de entrenadores, nutricionistas o profesionales de la salud.

## Stakeholders
Usuarios principiantes

Personas que están comenzando a entrenar y necesitan orientación para organizar sus entrenamientos y aprender conceptos básicos de alimentación.


Usuarios intermedios y avanzados

Personas que ya tienen experiencia entrenando y buscan registrar sus sesiones, consultar su progreso, organizar sus rutinas y encontrar alternativas de ejercicios.


Entrenadores

Profesionales que podrían utilizar la aplicación como herramienta complementaria para orientar a sus clientes.


Profesionales de nutrición

Profesionales que podrían encontrar utilidad en una herramienta educativa que ayude a los usuarios a comprender conceptos básicos de alimentación.


Equipo desarrollador

Responsables del diseño, desarrollo, pruebas y mantenimiento de la aplicación.


Universidad y docentes

Responsables de evaluar el proyecto de acuerdo con los requisitos académicos establecidos.

## Actores
Usuario

Es el actor principal de la aplicación. Puede:

Registrarse e iniciar sesión.
Configurar su perfil.
Seleccionar sus objetivos y nivel de experiencia.
Consultar rutinas.
Consultar ejercicios.
Buscar alternativas de ejercicios.
Iniciar y registrar entrenamientos.
Utilizar el temporizador de descanso.
Consultar su historial.
Visualizar su progreso.
Consultar contenidos educativos sobre alimentación.
Construir ideas de comidas a partir de diferentes grupos de alimentos.
Consultar recomendaciones y contenidos educativos.

Sistema

Se encarga de:

Gestionar la información del usuario.
Mostrar rutinas y ejercicios.
Guardar los registros de entrenamiento.
Calcular y mostrar estadísticas básicas.
Mostrar el historial y progreso.
Presentar alternativas de ejercicios.
Organizar los contenidos educativos de alimentación.
Generar combinaciones de alimentos según las opciones seleccionadas por el usuario.

## Objetivo y metricas de exito
Objetivo general

Desarrollar una aplicación móvil que ayude a las personas a organizar y realizar sus entrenamientos, registrar su progreso y adquirir conocimientos básicos sobre alimentación de acuerdo con sus objetivos, preferencias y hábitos.

Objetivos específicos

Facilitar la organización de rutinas de entrenamiento.
Ayudar al usuario a conocer y comprender diferentes ejercicios.
Permitir registrar los datos de cada entrenamiento.
Facilitar el seguimiento del progreso.
Ofrecer alternativas cuando un ejercicio requiere un equipo que no está disponible.
Proporcionar información educativa sobre alimentación.
Ayudar al usuario a comprender cómo combinar diferentes grupos de alimentos.
Presentar la información de manera sencilla y fácil de utilizar.
Métricas de éxito

La aplicación se considerará exitosa si:

Al menos el 80 % de los usuarios de prueba puede iniciar un entrenamiento sin ayuda.
Al menos el 80 % de los usuarios puede registrar correctamente una serie.
Los usuarios pueden encontrar un ejercicio en menos de 30 segundos.
Al menos el 80 % de los usuarios de prueba comprende cómo utilizar la sección de alimentación.
Los usuarios pueden consultar su progreso y comprender la información presentada.
La aplicación puede ser utilizada sin necesidad de conocimientos previos sobre entrenamiento o nutrición.

## Restricciones
La aplicación será desarrollada como una aplicación móvil.

El proyecto se desarrollará utilizando Flutter.

El código será administrado mediante Git y GitHub.

El tiempo de desarrollo estará limitado al establecido para el proyecto académico (3 - 4 meses).

Las funcionalidades implementadas inicialmente estarán limitadas al alcance definido para el MVP.

La aplicación dependerá de la información disponible en su base de datos.

La aplicación tendrá un enfoque educativo y no reemplazará la asesoría de profesionales.

No se realizarán diagnósticos médicos ni nutricionales.

No se establecerán tratamientos para enfermedades o condiciones de salud.

Las recomendaciones relacionadas con alimentación serán de carácter general y educativo.

## Alcance
### Incluye
Gestión del usuario

Registro e inicio de sesión.
Configuración básica del perfil.
Selección del nivel de experiencia.
Selección de objetivos.
Selección de preferencias relacionadas con entrenamiento y alimentación.

Entrenamiento

Visualización de rutinas.
Consulta de ejercicios.
Búsqueda de ejercicios.
Información básica de cada ejercicio.
Indicaciones para realizar los ejercicios.
Identificación del equipo necesario.
Alternativas para ejercicios cuando determinado equipo no esté disponible.
Inicio de una sesión de entrenamiento.
Registro de series, repeticiones y peso.
Temporizador de descanso.
Finalización del entrenamiento.
Historial de entrenamientos.

Progreso

Visualización del historial.
Estadísticas básicas.
Seguimiento de ejercicios registrados.
Visualización de mejoras y récords personales.
Logros relacionados con la constancia y realización de entrenamientos.

NutriGuía

La aplicación contará con un módulo dedicado a la educación y organización básica de la alimentación.

Incluirá:

Información básica sobre grupos de alimentos.
Contenido educativo sobre proteínas, carbohidratos, grasas, frutas, verduras y otros alimentos.
Explicaciones sencillas sobre la función de diferentes nutrientes.
Ideas generales de comidas.
Herramienta para construir una comida seleccionando diferentes grupos de alimentos.
Posibilidad de seleccionar alimentos disponibles o preferidos.
Contenido sobre alimentación antes y después del entrenamiento.
Sección de mitos y realidades sobre alimentación.

### No incluye
Para mantener un alcance adecuado al proyecto, la primera versión no incluirá:

Diagnóstico de enfermedades.
Dietas médicas.
Tratamientos nutricionales.
Prescripción nutricional personalizada.
Consulta directa con nutricionistas.
Consulta directa con entrenadores.
Compra o venta de alimentos.
Pagos dentro de la aplicación.
Red social completa.
Chat entre usuarios.
Clases virtuales en vivo.
Integración con relojes inteligentes.
Integración con dispositivos médicos.
Análisis corporal mediante fotografías.
Reconocimiento automático de ejercicios mediante cámara.
Seguimiento médico.
Funcionalidades avanzadas de inteligencia artificial.

Estas funcionalidades podrán considerarse como posibles mejoras futuras.

## Conceptos del dominio
Usuario

Persona que utiliza GymMate y registra sus entrenamientos y preferencias.

Perfil

Información básica configurada por el usuario, incluyendo nivel, objetivos y preferencias.

Objetivo

Propósito seleccionado por el usuario para orientar su experiencia dentro de la aplicación.

Rutina

Conjunto organizado de ejercicios que el usuario puede realizar durante una sesión.

Ejercicio

Actividad física incluida dentro de una rutina.

Serie

Conjunto de repeticiones realizadas de un ejercicio.

Repetición

Ejecución individual de un ejercicio.

Entrenamiento

Sesión en la que el usuario realiza una rutina y registra sus resultados.

Registro

Información almacenada sobre un ejercicio realizado, como peso, repeticiones y series.

Progreso

Información obtenida a partir de los registros históricos del usuario para visualizar su evolución.

Equipo

Elemento necesario para realizar determinado ejercicio.

Ejercicio alternativo

Ejercicio que puede realizarse como reemplazo de otro cuando el equipo requerido no está disponible.

Grupo de alimentos

Categoría utilizada para organizar diferentes alimentos dentro del módulo de alimentación.

Comida

Combinación de diferentes alimentos seleccionados por el usuario.

Contenido educativo

Información presentada en la aplicación para enseñar conceptos básicos relacionados con entrenamiento y alimentación.

Logro

Reconocimiento obtenido por cumplir determinadas condiciones dentro de la aplicación, como completar cierta cantidad de entrenamientos.

## Reglas de negocio
Un usuario debe estar registrado para utilizar las funcionalidades principales de la aplicación.

Cada usuario debe contar con un perfil básico antes de utilizar las recomendaciones y rutinas.

Una rutina debe contener al menos un ejercicio.

Un ejercicio puede pertenecer a diferentes rutinas.

Cada entrenamiento debe estar asociado a un usuario.

El usuario solamente podrá modificar sus propios registros.

Cada registro de entrenamiento debe estar asociado a un ejercicio y a una sesión de entrenamiento.

Un ejercicio puede tener una o varias alternativas.

Las alternativas de ejercicios deben considerar el equipo disponible.

Un entrenamiento debe conservarse en el historial una vez que haya sido finalizado.

Los logros se desbloquearán cuando el usuario cumpla las condiciones establecidas por el sistema.

Los contenidos de alimentación deben presentarse con un enfoque educativo y general.

La aplicación no debe presentar recomendaciones como sustituto de una consulta con un profesional de nutrición.

El usuario podrá seleccionar diferentes alimentos para construir una comida.

Una comida puede estar compuesta por alimentos pertenecientes a diferentes grupos.

El usuario podrá consultar nuevamente sus registros históricos para comparar su progreso.

## Historias de usuario
HU01 — Crear una cuenta

Como usuario nuevo,
quiero crear una cuenta,
para guardar mi información, rutinas y progreso.

HU02 — Configurar perfil

Como usuario,
quiero seleccionar mi nivel de experiencia, objetivos y preferencias,
para adaptar mi experiencia dentro de la aplicación.

HU03 — Consultar una rutina

Como usuario,
quiero consultar una rutina de entrenamiento,
para conocer los ejercicios que debo realizar.

HU04 — Buscar ejercicio

Como usuario,
quiero buscar ejercicios por nombre, grupo muscular o equipo,
para encontrar rápidamente el ejercicio que necesito.

HU05 — Conocer un ejercicio

Como usuario,
quiero consultar información e instrucciones de un ejercicio,
para comprender cómo realizarlo.

HU06 — Sustituir ejercicio

Como usuario,
quiero encontrar alternativas para un ejercicio,
para poder continuar mi entrenamiento cuando no tenga disponible determinado equipo.

HU07 — Iniciar entrenamiento

Como usuario,
quiero iniciar una rutina,
para realizar mi entrenamiento de manera organizada.

HU08 — Registrar entrenamiento

Como usuario,
quiero registrar las series, repeticiones y peso utilizados,
para conservar un historial de mis entrenamientos.

HU09 — Utilizar temporizador

Como usuario,
quiero utilizar un temporizador de descanso,
para organizar los intervalos entre mis series.

HU10 — Consultar progreso

Como usuario,
quiero visualizar mi historial y estadísticas,
para conocer mi evolución.

HU11 — Aprender sobre alimentación

Como usuario,
quiero consultar información sencilla sobre alimentación,
para comprender mejor cómo organizar mis comidas.

HU12 — Construir una comida

Como usuario,
quiero seleccionar alimentos de diferentes grupos,
para obtener ideas de cómo combinar diferentes alimentos en una comida.

HU13 — Consultar ideas de comidas

Como usuario,
quiero consultar diferentes ideas de comidas,
para tener opciones que se adapten a mis preferencias y alimentos disponibles.

HU14 — Consultar mitos y realidades

Como usuario,
quiero consultar información sobre mitos relacionados con entrenamiento y alimentación,
para diferenciar información confiable de creencias comunes.

HU15 — Obtener logros

Como usuario,
quiero obtener logros por mantener mi constancia,
para sentirme motivado a continuar utilizando la aplicación.

## Casos de uso
Caso de uso	                          Actor
Registrarse	                          Usuario

Iniciar sesión	                      Usuario

Configurar perfil	                  Usuario

Seleccionar objetivos	              Usuario

Consultar rutina	                  Usuario

Buscar ejercicio	                  Usuario

Consultar información de ejercicio	  Usuario

Consultar alternativa de ejercicio	  Usuario

Iniciar entrenamiento	              Usuario

Registrar serie	                      Usuario

Iniciar temporizador	              Usuario

Finalizar entrenamiento	              Usuario

Consultar historial	                  Usuario

Consultar progreso	                  Usuario

Consultar logros	                  Usuario

Consultar contenido de alimentación	  Usuario

Consultar grupos de alimentos	      Usuario

Construir una comida	              Usuario

Consultar ideas de comidas	          Usuario

Consultar mitos y realidades	      Usuario

## Flujo de pantallas
El flujo principal de la aplicación será:

                         SPLASH
                           │
                           ↓
                  REGISTRO / LOGIN
                           │
                           ↓
                 CONFIGURAR PERFIL
                           │
                           ↓
                         HOME
                           │
          ┌────────────────┼────────────────┐
          ↓                ↓                ↓
      ENTRENAR         NUTRIGUÍA         PROGRESO
          │                │                │
          ↓                ↓                ↓
       RUTINAS          APRENDER        HISTORIAL
          │                │             ESTADÍSTICAS
          ↓                ↓
      EJERCICIOS       GRUPOS DE
          │            ALIMENTOS
          ↓                │
    DETALLE EJERCICIO      ↓
          │             ARMAR PLATO
          ↓                │
   ALTERNATIVAS            ↓
          │            IDEAS DE COMIDA
          ↓
     ENTRENAMIENTO
          │
          ↓
   REGISTRAR SERIES
          │
          ↓
      TEMPORIZADOR
          │
          ↓
  SIGUIENTE EJERCICIO
          │
          ↓
   FINALIZAR SESIÓN
          │
          ↓
       RESUMEN
          │
          ↓
     ACTUALIZAR
       PROGRESO

Navegación principal:

La aplicación contará con una barra de navegación inferior:

Inicio | Entrenar | NutriGuía | Progreso | Perfil

## Propuestas de diseno y mockups
La interfaz tendrá un diseño sencillo, moderno y fácil de utilizar, dirigido tanto a personas que están comenzando a entrenar como a usuarios con experiencia.

Se buscará evitar una interfaz excesivamente compleja y presentar la información de manera visual y organizada.

Pantallas principales
1. Splash

Presentará el logo y nombre de GymMate.

2. Registro / Inicio de sesión

Permitirá al usuario crear una cuenta o ingresar a una cuenta existente.

3. Configuración inicial

Permitirá seleccionar:

Nivel de experiencia.
Objetivos.
Preferencias de entrenamiento.
Preferencias generales de alimentación.
4. Inicio

Mostrará un resumen del día:

Entrenamiento recomendado o programado.
Acceso rápido a NutriGuía.
Progreso reciente.
Consejo educativo.
5. Rutina

Mostrará los ejercicios de la sesión actual junto con series y repeticiones.

6. Detalle del ejercicio

Mostrará:

Nombre.
Imagen o demostración.
Instrucciones.
Equipo necesario.
Información básica.
Ejercicios alternativos.
7. Entrenamiento activo

Permitirá registrar:

Series.
Repeticiones.
Peso.
Descanso.

También contará con un temporizador.

8. NutriGuía

Contará con accesos a:

Aprende sobre alimentación.
Grupos de alimentos.
Arma tu plato.
Ideas de comidas.
Mitos y realidades.
9. Arma tu plato

Permitirá seleccionar diferentes grupos de alimentos y construir una combinación de comida.

10. Progreso

Mostrará:

Entrenamientos realizados.
Historial.
Estadísticas.
Evolución de registros.
Logros.
11. Perfil

Permitirá consultar y modificar la información básica del usuario, sus objetivos y preferencias.

## Requisitos funcionales

| ID | Requisito | Prioridad |
|---|---|---|
| RF01 | El sistema debe permitir registrar usuarios e iniciar sesión. | Alta |
| RF02 | El sistema debe permitir configurar nivel, objetivos y preferencias. | Alta |
| RF03 | El sistema debe mostrar rutinas y ejercicios con instrucciones, equipo y alternativas. | Alta |
| RF04 | El sistema debe permitir iniciar, registrar y finalizar entrenamientos. | Alta |
| RF05 | El sistema debe guardar series, repeticiones, peso, descanso e historial por usuario. | Alta |
| RF06 | El sistema debe mostrar progreso, estadísticas básicas y logros. | Media |
| RF07 | El sistema debe mostrar contenidos educativos de alimentación. | Alta |
| RF08 | El sistema debe permitir construir ideas de comidas por grupos de alimentos. | Alta |
| RF09 | El sistema debe mostrar ideas de comidas y mitos y realidades. | Media |
| RF10 | El sistema debe permitir consultar y actualizar el perfil. | Media |

## Requisitos no funcionales

| ID | Requisito |
|---|---|
| RNF01 | La aplicación debe funcionar como aplicación móvil desarrollada con Flutter. |
| RNF02 | La interfaz debe ser clara, consistente, accesible y usable sin conocimientos previos. |
| RNF03 | Cada usuario solo debe poder consultar y modificar sus propios registros. |
| RNF04 | La información debe conservarse de forma consistente al finalizar un entrenamiento. |
| RNF05 | Las pantallas principales deben responder en un tiempo adecuado para una interacción normal. |
| RNF06 | El código debe mantenerse versionado en Git y el proyecto debe conservar una estructura mantenible. |
| RNF07 | Los contenidos de alimentación deben incluir un aviso de carácter educativo y general. |

## Modelo de datos

Entidades principales:

| Entidad | Datos principales | Relaciones |
|---|---|---|
| Usuario | id, correo, credenciales | Tiene un perfil, entrenamientos y logros. |
| Perfil | nivel, objetivos, preferencias | Pertenece a un usuario. |
| Rutina | id, nombre, descripción | Contiene uno o más ejercicios. |
| Ejercicio | id, nombre, grupo muscular, equipo, instrucciones | Puede pertenecer a varias rutinas y tener alternativas. |
| Entrenamiento | id, usuario, rutina, fecha, duración, estado | Contiene registros de ejercicios. |
| Registro | id, ejercicio, series, repeticiones, peso, descanso | Pertenece a un entrenamiento. |
| Alimento | id, nombre, grupo | Puede formar parte de una comida. |
| Comida | id, usuario, selección de alimentos | Está compuesta por alimentos de uno o varios grupos. |
| Logro | id, nombre, condición, fecha | Se asigna a un usuario cuando cumple una condición. |

## Arquitectura y navegación implementada

La aplicación seguirá una arquitectura por capas para separar la interfaz, la lógica de presentación y el acceso a datos:

- Presentación: pantallas y widgets Flutter.
- Dominio: entidades, reglas de negocio y casos de uso.
- Datos: repositorios y fuentes de datos locales o remotas.

La navegación principal será `Inicio`, `Entrenar`, `NutriGuía`, `Progreso` y `Perfil`. La implementación se completará de forma incremental según las prioridades del MVP; este documento describe el comportamiento objetivo y no implica que todas las pantallas estén terminadas.

## Supuestos

- El usuario cuenta con un dispositivo móvil compatible con Flutter y conexión cuando la fuente de datos lo requiera.
- Los ejercicios, alimentos y contenidos iniciales serán cargados por el equipo del proyecto.
- Las recomendaciones se mostrarán como información general y no como planes personalizados.
- El MVP prioriza el registro manual de entrenamientos; no depende de sensores ni reconocimiento por cámara.

## Historial de cambios



## Referencias

- Flutter Documentation: https://docs.flutter.dev/
- Material Design: https://m3.material.io/
- Organización Mundial de la Salud, actividad física: https://www.who.int/news-room/fact-sheets/detail/physical-activity

Las referencias se utilizarán como apoyo general para el diseño y los contenidos educativos. No sustituyen la revisión de profesionales de salud o nutrición.

## Declaración de uso de inteligencia artificial

Se podrá utilizar inteligencia artificial como apoyo para generar ideas, revisar redacción, proponer estructuras y detectar errores durante el desarrollo. El equipo será responsable de verificar, adaptar y aprobar todo el contenido y código utilizado. No se incorporarán respuestas generadas automáticamente como diagnóstico médico, tratamiento nutricional ni recomendación profesional personalizada.