import 'package:flutter/material.dart';
import '../bloc/call_state.dart';

class ConnectionIndicatorsWidget extends StatelessWidget {
  final CallState state;
  
  const ConnectionIndicatorsWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: state.isRemoteUserConnected ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
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
}