# 📱 Call Link - VideoCall App

Una aplicación Flutter para videollamadas 1 a 1 en tiempo real utilizando WebRTC para la comunicación de audio/video y Firebase para la señalización.

## 🚀 Características

- Videollamadas en tiempo real 1 a 1
- Interfaz intuitiva con controles fáciles de usar
- Cambio de cámara frontal/trasera
- Mute/Unmute de audio
- Encendido/apagado de video local
- Indicadores de estado de conexión
- Limpieza automática de recursos
- Compatible con Android e iOS

## 🛠️ Tecnologías

- **Flutter** - Framework UI multiplataforma
- **flutter_webrtc** - Comunicación WebRTC
- **cloud_firestore** - Base de datos en tiempo real
- **firebase_core** - Core de Firebase
- **flutter_bloc** - Gestión de estado
- **equatable** - Estados inmutables
- **permission_handler** - Manejo de permisos
- **uuid** - Generación de IDs únicos

## 📋 Prerrequisitos

- Flutter SDK 3.0 o superior
- Cuenta de Firebase
- Dispositivo Android/iOS o emulador

## 🔧 Configuración Rápida

### 1. Clonar y Configurar

```bash
git clone <repository-url>
cd call_link
flutter pub get

2. Configurar Firebase

Crear proyecto en Firebase Console
Agregar apps Android e iOS:

Android: com.example.call_link
iOS: com.rcdev.callLink
Descargar archivos de configuración:

google-services.json en android/app/
GoogleService-Info.plist en ios/Runner/
3. Configurar Firestore

Crear base de datos con las siguientes reglas:

javascript
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
4. Ejecutar la Aplicación

bash
flutter run
📱 Uso

Crear Llamada: Presionar "Crear Llamada" y compartir el ID generado
Unirse a Llamada: Ingresar el ID y presionar "Unirse"
Controles: Mute/Unmute audio, encender/apagar video, cambiar cámara, finalizar llamada
🏗️ Arquitectura

text
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
🔄 Flujo WebRTC

Offer: Usuario A crea oferta y la envía a Firebase
Answer: Usuario B recibe oferta y envía respuesta
ICE Candidates: Intercambio de candidatos para conexión P2P
Media Stream: Establecimiento de flujo de audio/video
📊 Estructura de Datos

Colección calls

javascript
{
  offer: { sdp: string, type: string },
  answer: { sdp: string, type: string },
  createdAt: Timestamp
}
Subcolección iceCandidates

javascript
{
  candidate: string,
  sdpMid: string,
  sdpMLineIndex: number,
  createdAt: Timestamp
}