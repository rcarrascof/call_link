import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'call_state.dart';
import '../../../data/repositories/call_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class CallCubit extends Cubit<CallState> {
  final CallRepository _callRepository;
  final Uuid _uuid = const Uuid();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  StreamSubscription? _answerSubscription;
  StreamSubscription? _iceSubscription;
  StreamSubscription? _callUpdateSubscription;
  bool _isSettingRemoteDescription = false;

  CallCubit(this._callRepository) : super(const CallState());

  // Método para manejar actualizaciones de la llamada
  void _handleCallUpdates(Map<String, dynamic>? callData) {
    if (callData == null) {
      print('📞 El otro usuario colgó - Call document eliminado');
      _remoteUserEndedCall();
    } else {
      print('📞 Call document actualizado: ${callData.keys}');
      if (callData['answer'] != null && !state.isRemoteUserConnected) {
        emit(state.copyWith(isRemoteUserConnected: true));
      }
    }
  }

  // Manejar cuando el otro usuario termina la llamada
  void _remoteUserEndedCall() {
    if (state.status != CallStatus.callDisconnected) {
      print('🔔 Notificando que el otro usuario colgó');
      
      Future.delayed(const Duration(milliseconds: 1000), () {
        _cleanupResources();
        emit(const CallState());
      });
    }
  }

  void _setupFirebaseListeners(String callId) {
    _cleanupFirebaseListeners();

    _answerSubscription = _callRepository.listenForAnswer(callId, (answer) {
      _handleRemoteAnswer(answer);
    });

    _iceSubscription = _callRepository.listenForIceCandidates(callId, (candidate) {
      _handleIceCandidate(candidate);
    });

    _callUpdateSubscription = _callRepository.listenForCallUpdates(callId, (callData) {
      _handleCallUpdates(callData);
    });
  }

  Future<void> _initializeWebRTC() async {
    try {
      final cameraStatus = await Permission.camera.status;
      final micStatus = await Permission.microphone.status;

      if (!cameraStatus.isGranted || !micStatus.isGranted) {
        final statuses = await [Permission.camera, Permission.microphone].request();
        if (!statuses[Permission.camera]!.isGranted || 
            !statuses[Permission.microphone]!.isGranted) {
          throw Exception('Permisos de cámara/micrófono denegados');
        }
      }

      final configuration = {
        'iceServers': [
           {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
        {'urls': 'stun:stun2.l.google.com:19302'},
        {'urls': 'stun:stun3.l.google.com:19302'},
        {'urls': 'stun:stun4.l.google.com:19302'},

        
        ],
        'iceTransportPolicy': 'all',
      };

      _peerConnection = await createPeerConnection(configuration);

      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true
        },
        'video': {
          'facingMode': state.isFrontCamera ? 'user' : 'environment',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        }
      });

      final localRenderer = RTCVideoRenderer();
      final remoteRenderer = RTCVideoRenderer();
      
      await localRenderer.initialize();
      await remoteRenderer.initialize();
      
      localRenderer.srcObject = _localStream;

      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      _peerConnection!.onIceCandidate = (candidate) {
        print('🧊 ICE Candidate local generado: $candidate');
        if (state.callId != null) {
          _callRepository.sendIceCandidate(state.callId!, candidate.toMap());
        }
      };

      _peerConnection!.onTrack = (event) {
        print('🎬 Stream remoto recibido');
        
        if (event.streams.isNotEmpty) {
          final remoteStream = event.streams.first;
          remoteRenderer.srcObject = remoteStream;
          
           final videoTracks = remoteStream.getVideoTracks();
          final audioTracks = remoteStream.getAudioTracks();
          final hasVideo = videoTracks.isNotEmpty;
          final hasAudio = audioTracks.isNotEmpty;
          
          
          //  Listeners para cuando los tracks terminen
          for (final track in [...videoTracks, ...audioTracks]) {
            track.onEnded = () {
              print('🔚 Track remoto finalizado: ${track.kind}');
              _updateRemoteTrackStatus();
            };
          }
          
          emit(state.copyWith(
            status: CallStatus.callConnected,
            remoteRenderer: remoteRenderer,
            hasRemoteVideo: hasVideo,
            hasRemoteAudio: hasAudio,
            isRemoteUserConnected: true,
          ));
        }
      };

      _peerConnection!.onIceConnectionState = (iceState) {
        if (iceState == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
          print('🔌 Conexión perdida con el usuario remoto');
          emit(state.copyWith(
            hasRemoteVideo: false,
            hasRemoteAudio: false,
          ));
        } else if (iceState == RTCIceConnectionState.RTCIceConnectionStateConnected) {
          print('Conexión ICE establecida');
          _updateRemoteTrackStatus();
        }
      };

      _peerConnection!.onConnectionState = (connectionState) {
        print('🔌 Peer Connection State: $connectionState');
      };

      _peerConnection!.onSignalingState = (signalingState) {
        print('📡 Signaling State: $signalingState');
      };

      emit(state.copyWith(
        localRenderer: localRenderer,
        remoteRenderer: remoteRenderer,
      ));

    } catch (e) {
      print('Error inicializando WebRTC: $e');
      emit(state.copyWith(
        status: CallStatus.error,
        error: 'Error inicializando WebRTC: ${e.toString()}',
      ));
      rethrow;
    }
  }

  // Método para actualizar estado de tracks remotos
  void _updateRemoteTrackStatus() {
    if (_peerConnection == null) return;
    
    _peerConnection!.getReceivers().then((receivers) {
      bool hasVideo = false;
      bool hasAudio = false;
      
      for (final receiver in receivers) {
        if (receiver.track != null && receiver.track!.enabled) {
          if (receiver.track!.kind == 'video') {
            hasVideo = true;
          } else if (receiver.track!.kind == 'audio') {
            hasAudio = true;
          }
        }
      }
      
      print('🔄 Actualizando tracks remotos - Video: $hasVideo, Audio: $hasAudio');
      
      emit(state.copyWith(
        hasRemoteVideo: hasVideo,
        hasRemoteAudio: hasAudio,
      ));
    });
  }

  // Crear nueva llamada
  Future<void> createCall() async {
    try {
      emit(state.copyWith(status: CallStatus.creatingCall));
      
      final callId = _generateCallId();
      
      await _initializeWebRTC();
      
      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
      });
      
      await _peerConnection!.setLocalDescription(offer);
      
      await _waitForIceGathering(5000);
      
      final currentOffer = await _peerConnection!.getLocalDescription();
      if (currentOffer == null) {
        throw Exception('No se pudo obtener la oferta local');
      }

      await _callRepository.createCallRoom(callId, {
        'sdp': offer.sdp,
        'type': offer.type,
      });
      
      _setupFirebaseListeners(callId);
      
      emit(state.copyWith(
        status: CallStatus.callCreated,
        callId: callId,
      ));
      
    } catch (e) {
      emit(state.copyWith(
        status: CallStatus.error,
        error: 'Error creando llamada: ${e.toString()}',
      ));
    }
  }

  // EndCall para notificar al otro usuario
  Future<void> endCall() async {
    try {
      print('📞 Finalizando llamada...');
      
      if (state.callId != null) {
        await _callRepository.cleanupCall(state.callId!);
      }
      
      emit(state.copyWith(
        status: CallStatus.callDisconnected,
        isRemoteUserConnected: false,
        hasRemoteVideo: false,
        hasRemoteAudio: false,
      ));
      
      await Future.delayed(const Duration(milliseconds: 300));
      await _cleanupResources();
      
      emit(const CallState());
      
    } catch (e) {
      emit(const CallState());
    }
  }

  //  limpieza de recursos
  Future<void> _cleanupResources() async {
    try {
      print('🧹 Iniciando limpieza de recursos...');
      
      _cleanupFirebaseListeners();
      
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          track.stop();
        });
        await _localStream?.dispose();
        _localStream = null;
      }

      if (_peerConnection != null) {
        await _peerConnection?.close();
        _peerConnection = null;
      }

      if (state.localRenderer != null) {
        await state.localRenderer?.dispose();
      }
      
      if (state.remoteRenderer != null) {
        await state.remoteRenderer?.dispose();
      }

      _isSettingRemoteDescription = false;
      
    } catch (e) {
      print('❌ Error durante la limpieza: $e');
    }
  }

  void _cleanupFirebaseListeners() {
    _answerSubscription?.cancel();
    _iceSubscription?.cancel();
    _callUpdateSubscription?.cancel();
    _answerSubscription = null;
    _iceSubscription = null;
    _callUpdateSubscription = null;
    print('🗑️  Todos los listeners de Firebase limpiados');
  }

  Future<void> toggleCamera() async {
    if (_localStream == null) return;
    
    try {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
      
      emit(state.copyWith(
        isFrontCamera: !state.isFrontCamera,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Error cambiando cámara: $e'));
    }
  }

  Future<void> toggleAudio() async {
    if (_localStream == null) return;
    
    final audioTracks = _localStream!.getAudioTracks();
    if (audioTracks.isNotEmpty) {
      final audioTrack = audioTracks.first;
      audioTrack.enabled = !audioTrack.enabled;
      
      emit(state.copyWith(
        isAudioEnabled: audioTrack.enabled,
      ));
    }
  }

  Future<void> toggleVideo() async {
    if (_localStream == null) return;
    
    final videoTracks = _localStream!.getVideoTracks();
    if (videoTracks.isNotEmpty) {
      final videoTrack = videoTracks.first;
      videoTrack.enabled = !videoTrack.enabled;
      
      emit(state.copyWith(
        isLocalVideoEnabled: videoTrack.enabled,
      ));
    }
  }

  Future<void> joinCall(String callId) async {
    try {
      emit(state.copyWith(status: CallStatus.joiningCall));
      
      await _initializeWebRTC();
      
      final callData = await _callRepository.getCallData(callId);
      if (callData == null) throw Exception('Llamada no encontrada');
      
      final offer = RTCSessionDescription(
        callData['offer']['sdp'],
        callData['offer']['type'],
      );
      
      await _peerConnection!.setRemoteDescription(offer);
      
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      
      await _callRepository.updateCallWithAnswer(callId, answer.toMap());
      
      _setupFirebaseListeners(callId);
      
      emit(state.copyWith(
        status: CallStatus.callConnected,
        callId: callId,
        isRemoteUserConnected: true,
      ));
      
    } catch (e) {
      emit(state.copyWith(
        status: CallStatus.error,
        error: 'Error uniéndose a llamada: ${e.toString()}',
      ));
    }
  }

  String _generateCallId() {
    return _uuid.v4().substring(0, 8).toUpperCase();
  }

  Future<bool> _waitForIceGathering(int timeoutMs) async {
    final startTime = DateTime.now();
    
    while (DateTime.now().difference(startTime).inMilliseconds < timeoutMs) {
      if (_peerConnection?.iceGatheringState == 
          RTCIceGatheringState.RTCIceGatheringStateComplete) {
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return false;
  }

  Future<void> _handleRemoteAnswer(Map<String, dynamic> answer) async {
    if (_peerConnection == null || _isSettingRemoteDescription) {
      print('⏸️  Ignorando answer - PeerConnection nulo o ya configurando');
      return;
    }

    try {
      _isSettingRemoteDescription = true;
      
      final signalingState = _peerConnection!.signalingState;
      print('📡 Estado de signaling al recibir answer: $signalingState');
      
      if (signalingState == RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
        final answerSdp = RTCSessionDescription(
          answer['sdp'],
          answer['type'],
        );
        
        print('🔄 Estableciendo remote answer...');
        await _peerConnection!.setRemoteDescription(answerSdp);
        print('✅ Remote answer establecido exitosamente');
        
        emit(state.copyWith(isRemoteUserConnected: true));
      } else {
        print('⏭️  Ignorando answer - Estado de signaling incorrecto: $signalingState');
      }
    } catch (e) {
      print('❌ Error estableciendo remote answer: $e');
    } finally {
      _isSettingRemoteDescription = false;
    }
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> candidate) async {
    if (_peerConnection == null) {
      return;
    }

    try {
      final rtcCandidate = RTCIceCandidate(
        candidate['candidate'],
        candidate['sdpMid'],
        candidate['sdpMLineIndex'],
      );
      
      await _peerConnection!.addCandidate(rtcCandidate);
      print('✅ ICE candidate agregado');
    } catch (e) {
      print('❌ Error agregando ICE candidate: $e');
    }
  }

  @override
  Future<void> close() {
    print('🔚 Cerrando CallCubit, limpiando recursos...');
    _cleanupResources();
    return super.close();
  }
}