# pillsoclock 📱

Aplicativo móvil desarrollado en **Flutter**, destinado a gestionar y controlar la toma de medicamentos de un usuario. El sistema permite registrar medicamentos, programar horarios de toma y confirmar si el medicamento fue tomado dentro de su rango correspondiente.
La aplicación evita registros duplicados y bloquea el botón una vez que la toma ha sido realizada dentro del rango horario actual.

Integrantes

- EILENE ELIZABETH CARHUAPOMA FANO (72953802@continental.edu.pe)
- KATHERYN ELENA HUAMAN BALDEON (61447275@continental.edu.pe)
- ANGEL SIMON PEREZ RAVELO (75326952@continental.edu.pe)

---

## ✨ Características principales

### ✔️ Autenticación

* Inicio de sesión mediante **Firebase Auth**.
* Sesiones persistentes del usuario.

### 💊 Gestión de medicamentos

* Lista de medicamentos asignados al paciente.
* Cada medicamento contiene:

  * Nombre
  * Dosis
  * Frecuencia
  * Horarios programados

### ⏰ Control de tomas por horario

* Cada horario programado se muestra con un checkbox.
* El usuario solo puede registrar la toma dentro del rango configurado (por ejemplo ±1 hora).
* Si ya existe un registro para ese horario en Firestore:

  * El checkbox aparece **activado**.
  * El usuario **no** puede volver a marcarlo.
  * La toma no se duplica al refrescar ni al cambiar de pantalla.

### 🎨 Interfaz moderna

* Diseño simple y amigable.
* Iconos de estado según la toma.
* Botones accesibles y enfocados en usabilidad.

---

## 🛠️ Tecnologías utilizadas

* **Flutter**
* **Firebase Auth**
* **Firestore**
* Provider (gestión de estado)
* Material Design 3

---

## 🚀 Instalación y configuración

### 1️⃣ Clonar el repositorio

```bash
git clone https://github.com/Enelie/pillsoclock
cd pilloclock
```

### 2️⃣ Instalar dependencias

```bash
flutter pub get
```

### 3️⃣ Configurar Firebase

* Crear un proyecto en Firebase.
* Agregar app Android y/o iOS.
* Descargar el archivo:

  * `google-services.json` (Android)
  * `GoogleService-Info.plist` (iOS)
* Colocar cada archivo en su carpeta correspondiente.
* Habilitar:

  * Authentication → Email/Password
  * Firestore Database

### 4️⃣ Ejecutar la app

```bash
flutter run
```

---

## 🧪 Posibles mejoras

* Notificaciones push inteligentes antes de cada toma.
* Dashboard para analizar cumplimiento.
* Integración con wearables.
* Múltiples perfiles (niños, ancianos, mascotas).
* Exportación de historial en PDF.

---

## 📜 Licencia

Este proyecto puede ser utilizado y modificado libremente con fines educativos o personales.
