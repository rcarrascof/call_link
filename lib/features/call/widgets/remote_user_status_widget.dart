import 'package:flutter/material.dart';
import '../bloc/call_state.dart';

class RemoteUserStatusWidget extends StatelessWidget {
  final CallState state;
  
  const RemoteUserStatusWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          Text(
            'Usuario Conectado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
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
            state.hasRemoteVideo ? 'Video y audio' : 'Solo audio',
            style: TextStyle(
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }
}