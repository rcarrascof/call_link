# 📱 Call Link — VideoCall App

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)  
![Firebase](https://img.shields.io/badge/Firebase-Firestore-orange?logo=firebase)  
![WebRTC](https://img.shields.io/badge/WebRTC-Enabled-green?logo=webrtc)  
![License](https://img.shields.io/badge/License-MIT-lightgrey)

Aplicación Flutter para **videollamadas 1 a 1 en tiempo real** utilizando  
**WebRTC** para comunicación de audio/video y **Firebase** para señalización.

---

## 🚀 Características

✅ Videollamadas en tiempo real 1 a 1  
✅ Interfaz moderna e intuitiva  
✅ Cambio de cámara (frontal/trasera)  
✅ Mute / Unmute de audio  
✅ Encendido / apagado de video local  
✅ Indicador de conexión  
✅ Limpieza automática de recursos  
✅ Soporte para Android e iOS  

---

## 🛠️ Tecnologías Utilizadas

| Paquete | Descripción |
|----------|--------------|
| **flutter_webrtc** | Comunicación de video/audio en tiempo real |
| **cloud_firestore** | Base de datos en tiempo real para señalización |
| **firebase_core** | Inicialización del proyecto Firebase |
| **flutter_bloc** | Manejo del estado y separación de lógica |
| **equatable** | Estados inmutables y comparación eficiente |
| **permission_handler** | Control de permisos de cámara y micrófono |
| **uuid** | Generación de identificadores únicos |

---

## 📋 Prerrequisitos

- Flutter SDK **3.0 o superior**  
- Proyecto en [Firebase Console](https://console.firebase.google.com)  
- Dispositivo físico o emulador Android/iOS  

---

## ⚙️ Configuración Rápida

### 1️⃣ Clonar y configurar dependencias

```bash
git clone <repository-url>
cd call_link
flutter pub get
```

### 2️⃣ Configurar Firebase

1. Crear un proyecto en **Firebase Console**.  
2. Agregar aplicaciones:  
   - Android: `com.example.call_link`  
   - iOS: `com.rcdev.callLink`  
3. Descargar los archivos de configuración y colocarlos en:  
   - `android/app/google-services.json`  
   - `ios/Runner/GoogleService-Info.plist`  

### 3️⃣ Configurar Firestore

Agrega estas reglas de seguridad básicas:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /calls/{callId} {
      allow read, write: if true;
    }
    match /calls/{callId}/iceCandidates/{document} {
      allow read, write: if true;
    }
  }
}
```

### 4️⃣ Ejecutar la aplicación

```bash
flutter run
```

---

## 📱 Uso

1. Presiona **“Crear Llamada”** → se genera un ID único.  
2. El otro usuario ingresa ese ID y presiona **“Unirse”**.  
3. Ambos usuarios podrán verse y escucharse.  
4. Se pueden usar los controles de **mute**, **cambiar cámara** o **finalizar llamada**.  

---

## 🧱 Arquitectura del Proyecto

```
lib/
├── main.dart
├── firebase_options.dart
├── app/
│   ├── bloc/
│   └── view/app.dart
├── core/
│   ├── constants/
│   ├── themes/
│   ├── utils/
│   └── widgets/
├── data/
│   ├── datasource/
│   ├── models/
│   └── repositories/call_repository.dart
└── features/call/
    ├── bloc/call_cubit.dart
    ├── bloc/call_state.dart
    ├── views/call_screen.dart
    └── widgets/
```

---

## 🔄 Flujo WebRTC

1. **Offer:** El usuario A crea una oferta y la guarda en Firebase.  
2. **Answer:** El usuario B recibe la oferta y responde.  
3. **ICE Candidates:** Ambos intercambian candidatos ICE para establecer conexión P2P.  
4. **Media Stream:** Se establece el flujo de audio/video entre ambos usuarios.  

---

## 📊 Estructura de Datos — Firestore

**Colección `calls`**
```json
{
  "offer": { "sdp": "string", "type": "offer" },
  "answer": { "sdp": "string", "type": "answer" },
  "createdAt": "Timestamp"
}
```

**Subcolección `iceCandidates`**
```json
{
  "candidate": "string",
  "sdpMid": "string",
  "sdpMLineIndex": 0,
  "createdAt": "Timestamp"
}
```


---

## 🧑‍💻 Autor

**Reinold Carrasco**  

