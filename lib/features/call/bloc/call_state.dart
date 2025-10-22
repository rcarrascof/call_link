import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallState extends Equatable {
  final CallStatus status;
  final String? callId;
  final String? error;
  final bool isLocalVideoEnabled;
  final bool isAudioEnabled;
  final bool isFrontCamera;
  final RTCVideoRenderer? localRenderer;
  final RTCVideoRenderer? remoteRenderer;
  final bool hasRemoteVideo;
  final bool hasRemoteAudio;
  final bool isRemoteUserConnected;

  const CallState({
    this.status = CallStatus.idle,
    this.callId,
    this.error,
    this.isLocalVideoEnabled = true,
    this.isAudioEnabled = true,
    this.isFrontCamera = true,
    this.localRenderer,
    this.remoteRenderer,
    this.hasRemoteVideo = false,
    this.hasRemoteAudio = false,
    this.isRemoteUserConnected = false,
  });

  CallState copyWith({
    CallStatus? status,
    String? callId,
    String? error,
    bool? isLocalVideoEnabled,
    bool? isAudioEnabled,
    bool? isFrontCamera,
    RTCVideoRenderer? localRenderer,
    RTCVideoRenderer? remoteRenderer,
    bool? hasRemoteVideo,
    bool? hasRemoteAudio,
    bool? isRemoteUserConnected,
  }) {
    return CallState(
      status: status ?? this.status,
      callId: callId ?? this.callId,
      error: error,
      isLocalVideoEnabled: isLocalVideoEnabled ?? this.isLocalVideoEnabled,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      localRenderer: localRenderer ?? this.localRenderer,
      remoteRenderer: remoteRenderer ?? this.remoteRenderer,
      hasRemoteVideo: hasRemoteVideo ?? this.hasRemoteVideo,
      hasRemoteAudio: hasRemoteAudio ?? this.hasRemoteAudio,
      isRemoteUserConnected: isRemoteUserConnected ?? this.isRemoteUserConnected,
    );
  }

  @override
  List<Object?> get props => [
        status,
        callId,
        error,
        isLocalVideoEnabled,
        isAudioEnabled,
        isFrontCamera,
        localRenderer,
        remoteRenderer,
        hasRemoteVideo,
        hasRemoteAudio,
        isRemoteUserConnected,
      ];
}

enum CallStatus {
  idle,
  creatingCall,
  callCreated,
  joiningCall,
  callConnected,   
  callDisconnected,
  error,
}