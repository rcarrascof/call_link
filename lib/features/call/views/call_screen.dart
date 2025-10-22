import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../bloc/call_cubit.dart';
import '../bloc/call_state.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<CallCubit, CallState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Indicador de estado
                _buildConnectionStatus(state),
                const SizedBox(height: 20),
                
                // Vista de videos
                Expanded(
                  child: _buildVideoViews(state),
                ),
                
                const SizedBox(height: 20),
                
                // Controles
                _buildControls(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

Widget _buildConnectionStatus(CallState state) {
  Color statusColor;
  String statusText;
  
  switch (state.status) {
    case CallStatus.callConnected:
      statusColor = Colors.green;
      statusText = '✅ Conectado';
      break;
    case CallStatus.creatingCall:
      statusColor = Colors.orange;
      statusText = '⏳ Creando llamada...';
      break;
    case CallStatus.joiningCall:
      statusColor = Colors.orange;
      statusText = '⏳ Uniéndose a llamada...';
      break;
    case CallStatus.callCreated:
      statusColor = Colors.blue;
      statusText = '📞 Llamada creada';
      break;
    case CallStatus.error:
      statusColor = Colors.red;
      statusText = '❌ Error';
      break;
    default:
      statusColor = Colors.grey;
      statusText = '📱 Desconectado';
  }
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: statusColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: statusColor),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
    
      ],
    ),
  );
}

Widget _buildVideoViews(CallState state) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Stack(
      children: [
        // Video remoto (fondo)
        if (state.remoteRenderer != null && state.hasRemoteVideo)
          RTCVideoView(
            state.remoteRenderer!,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          )
        else if (state.status == CallStatus.callConnected && state.isRemoteUserConnected)
          // 🆕 Mostrar estado cuando hay conexión pero no video
          _buildRemoteUserStatus(state)
        else
          _buildWaitingConnection(),

        // Video local (picture-in-picture)
        if (state.localRenderer != null && state.isLocalVideoEnabled)
          Positioned(
            bottom: 20,
            right: 20,
            width: 120,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: RTCVideoView(state.localRenderer!),
              ),
            ),
          ),
          
        // 🆕 Indicador de estado de conexión remota
        if (state.isRemoteUserConnected)
          Positioned(
            top: 20,
            left: 20,
            child: _buildConnectionIndicators(state),
          ),
      ],
    ),
  );
}

// 🆕 Widget para estado de usuario remoto
Widget _buildRemoteUserStatus(CallState state) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Avatar o icono del usuario
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blue.shade800,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        
        // Estado de conexión
        Text(
          'Usuario Conectado',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        
        // Estado de medios
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.hasRemoteAudio ? Icons.mic : Icons.mic_off,
              color: state.hasRemoteAudio ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Icon(
              state.hasRemoteVideo ? Icons.videocam : Icons.videocam_off,
              color: state.hasRemoteVideo ? Colors.green : Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          state.hasRemoteVideo ? 
            'Video y audio' : 
            'Solo audio',
          style: TextStyle(
            color: Colors.grey.shade300,
          ),
        ),
      ],
    ),
  );
}

// 🆕 Widget para estado de espera
Widget _buildWaitingConnection() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.videocam_off,
          size: 64,
          color: Colors.grey.shade600,
        ),
        const SizedBox(height: 16),
        Text(
          'Esperando conexión...',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}

// 🆕 Widget para indicadores de conexión
Widget _buildConnectionIndicators(CallState state) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.6),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        // Indicador de conexión
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: state.isRemoteUserConnected ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        
        // Indicadores de audio/video
        Icon(
          state.hasRemoteAudio ? Icons.mic : Icons.mic_off,
          color: state.hasRemoteAudio ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 4),
        Icon(
          state.hasRemoteVideo ? Icons.videocam : Icons.videocam_off,
          color: state.hasRemoteVideo ? Colors.green : Colors.red,
          size: 16,
        ),
      ],
    ),
  );
}





  Widget _buildControls(BuildContext context, CallState state) {
    String tempCallId = '';

    return Column(
      children: [
        // Campo para unirse a llamada - SOLO cuando está idle
        if (state.status == CallStatus.idle) ...[
          TextField(
            decoration: const InputDecoration(
              labelText: 'ID de llamada',
              hintText: 'Ingresa el ID para unirte',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
            onChanged: (value) {
              tempCallId = value;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_call),
                  label: const Text('Crear Llamada'),
                  onPressed: () => context.read<CallCubit>().createCall(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Unirse'),
                  onPressed: () {
                    if (tempCallId.isNotEmpty) {
                      context.read<CallCubit>().joinCall(tempCallId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor ingresa un ID de llamada'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
        
        // Mostrar ID de llamada cuando esté creada
        if (state.callId != null && state.status == CallStatus.callCreated) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue),
            ),
            child: Column(
              children: [
                const Text(
                  'Comparte este ID:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.callId!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Otra persona debe ingresar este ID para unirse',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Controles durante la llamada
        if (state.status.index >= CallStatus.callCreated.index &&
            state.status != CallStatus.idle) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute/Unmute audio
                _buildControlButton(
                  icon: state.isAudioEnabled ? Icons.mic : Icons.mic_off,
                  label: state.isAudioEnabled ? 'Mic ON' : 'Mic OFF',
                  color: state.isAudioEnabled ? Colors.green : Colors.red,
                  onPressed: () => context.read<CallCubit>().toggleAudio(),
                ),
                
                // Encender/apagar video
                _buildControlButton(
                  icon: state.isLocalVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  label: state.isLocalVideoEnabled ? 'Video ON' : 'Video OFF',
                  color: state.isLocalVideoEnabled ? Colors.green : Colors.red,
                  onPressed: () => context.read<CallCubit>().toggleVideo(),
                ),
                
                // Cambiar cámara
                _buildControlButton(
                  icon: Icons.cameraswitch,
                  label: 'Cambiar',
                  color: Colors.blue,
                  onPressed: () => context.read<CallCubit>().toggleCamera(),
                ),
                
                // Finalizar llamada
                _buildControlButton(
                  icon: Icons.call_end,
                  label: 'Finalizar',
                  color: Colors.red,
                  onPressed: () => context.read<CallCubit>().endCall(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            foregroundColor: color,
          ),
          iconSize: 32,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}