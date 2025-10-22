import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/call_cubit.dart';
import '../bloc/call_state.dart';

class CallControlsWidget extends StatefulWidget {
  final CallState state;
  
  const CallControlsWidget({super.key, required this.state});

  @override
  State<CallControlsWidget> createState() => _CallControlsWidgetState();
}

class _CallControlsWidgetState extends State<CallControlsWidget> {
  String tempCallId = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.state.status == CallStatus.idle) ...[
          TextField(
            decoration: const InputDecoration(
              labelText: 'ID de llamada',
              hintText: 'Ingresa el ID para unirte',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
            onChanged: (value) {
              setState(() {
                tempCallId = value;
              });
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
        
        if (widget.state.callId != null && widget.state.status == CallStatus.callCreated) ...[
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
                  widget.state.callId!,
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
        
        if (widget.state.status.index >= CallStatus.callCreated.index &&
            widget.state.status != CallStatus.idle) ...[
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
                _buildControlButton(
                  context: context,
                  icon: widget.state.isAudioEnabled ? Icons.mic : Icons.mic_off,
                  label: widget.state.isAudioEnabled ? 'Mic ON' : 'Mic OFF',
                  color: widget.state.isAudioEnabled ? Colors.green : Colors.red,
                  onPressed: () => context.read<CallCubit>().toggleAudio(),
                ),
                
                _buildControlButton(
                  context: context,
                  icon: widget.state.isLocalVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  label: widget.state.isLocalVideoEnabled ? 'Video ON' : 'Video OFF',
                  color: widget.state.isLocalVideoEnabled ? Colors.green : Colors.red,
                  onPressed: () => context.read<CallCubit>().toggleVideo(),
                ),
                
                _buildControlButton(
                  context: context,
                  icon: Icons.cameraswitch,
                  label: 'Cambiar',
                  color: Colors.blue,
                  onPressed: () => context.read<CallCubit>().toggleCamera(),
                ),
                
                _buildControlButton(
                  context: context,
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
    required BuildContext context,
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