# GymMate

Aplicación móvil para organizar entrenamientos, registrar el progreso y aprender conceptos básicos de alimentación.

## Integrantes

- Vanessa Ospina
- Salome Caicedo

## Curso y grupo

Programación Móvil (IF2004), grupo 601

## Versión

1.0, septiembre de 2026

## Documentación

La definición formal, el alcance, los requisitos, las pantallas y el mapa de navegación están en [docs/definicion.md](docs/definicion.md). El documento es la fuente de verdad del entregable 1.

Los mockups por pantalla se encuentran en `docs/mockup/`.

La presentación para sustentación está en [docs/presentacion/index.html](docs/presentacion/index.html). Ábrela en un navegador y usa las flechas del teclado para avanzar.

## Ejecutar

```sh
flutter pub get
flutter run
```

## Navegación disponible

La app inicia en acceso/registro demostrativo. Al ingresar se llega al shell principal con Inicio, Entrenar, NutriGuía, Progreso y Perfil. Desde Entrenar se puede abrir el detalle de una categoría o crear un plan y ver su resumen.

Los datos son de demostración y todavía no se conservan al cerrar la aplicación.