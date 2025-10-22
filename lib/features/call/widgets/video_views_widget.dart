import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../bloc/call_state.dart';
import 'remote_user_status_widget.dart';
import 'waiting_connection_widget.dart';
import 'connection_indicators_widget.dart';

class VideoViewsWidget extends StatelessWidget {
  final CallState state;
  
  const VideoViewsWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
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
            RemoteUserStatusWidget(state: state)
          else
            const WaitingConnectionWidget(),

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
          
          // Indicador de estado de conexión remota
          if (state.isRemoteUserConnected)
            Positioned(
              top: 20,
              left: 20,
              child: ConnectionIndicatorsWidget(state: state),
            ),
        ],
      ),
    );
  }
}