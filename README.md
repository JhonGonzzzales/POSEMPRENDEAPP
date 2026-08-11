# POS EMPRENDE APP

**POS EMPRENDE APP** es una solución de Punto de Venta (POS) móvil desarrollada en **Flutter**, diseñada para microempresas y comercios locales que requieren una herramienta rápida, clara e intuitiva para gestionar sus ventas diarias, recibos y métricas clave en tiempo real.

---

## Captura de Pantalla

| POS Terminal (Caja) | Onboarding / Flujo Inicial |
| :---: | :---: |
| ![POS Terminal](docs/screenshots/caja_view.png) | ![Onboarding](docs/screenshots/onboarding.png) |

---

## Características Principales

* **Terminal de Venta Rápida (Caja):** Selección ágil de productos, gestión de carrito y procesamiento instantáneo de cobros (Efectivo, QR).
* **Historial de Transacciones:** Consulta detallada de ventas realizadas con filtros por fecha y método de pago.
* **Dashboard y Analítica:** Visualización en tiempo real del rendimiento del negocio y métricas clave.
* **Onboarding Interactivo:** Flujo de bienvenida guiado para nuevos usuarios con persistencia de estado local (`shared_preferences`).
* **Interfaz Material Design 3:** Diseño moderno, limpio y optimizado para ergonomía móvil.

---

## Tecnologías Utilizadas

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Gestión de Estado:** [Provider](https://pub.dev/packages/provider) (`ChangeNotifier`)
* **Almacenamiento Local:** `shared_preferences` / SQLite
* **Sistema de Diseño:** Material Design 3 (MD3)

---

## Instalación y Configuración

### Requisitos Previos

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (versión 3.x o superior)
* [Dart SDK](https://dart.dev/get-dart)
* Android Studio / VS Code con extensión de Flutter

### Pasos para Ejecutar

1. Clonar el repositorio:

   ```bash
   git clone [https://github.com/TU_USUARIO/carnicaja.git](https://github.com/TU_USUARIO/carnicaja.git)
   cd carnicaja

2. Instalar dependencias:

    ```bash
    flutter pub get

3. Ejecutar la aplicación:

    ```bash
    flutter run

4. Ejecutar pruebas unitarias / widgets:

    ```bash
    flutter test

### Estructura del Proyecto

```Plaintext
lib/
├── main.dart                 # Punto de entrada de la aplicación y configuración de rutas/tema
├── providers/                # Gestión de estado (VentaProvider)
└── views/                    # Pantallas de la aplicación
    ├── caja_view.dart        # Terminal POS principal
    ├── base_datos_view.dart  # Historial de transacciones
    ├── dashboard_view.dart   # Panel de métricas e indicadores
    ├── menu_principal.dart   # Navegación inferior (NavigationBar MD3)
    └── onboarding_view.dart  # Pantallas de bienvenida e introducción
```

### Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo LICENSE para obtener más detalles.