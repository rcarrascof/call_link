import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class CallRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _iceSubscription;

  Future<void> createCallRoom(String callId, Map<String, dynamic> offer) async {
    await _firestore.collection('calls').doc(callId).set({
      'offer': offer,
      'answer': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getCallData(String callId) async {
    final doc = await _firestore.collection('calls').doc(callId).get();
    return doc.data();
  }

  Future<void> updateCallWithAnswer(String callId, Map<String, dynamic> answer) async {
    await _firestore.collection('calls').doc(callId).update({
      'answer': answer,
    });
  }

  Future<void> sendIceCandidate(String callId, Map<String, dynamic> candidate) async {
    await _firestore.collection('calls').doc(callId).collection('iceCandidates').add({
      'candidate': candidate['candidate'],
      'sdpMid': candidate['sdpMid'],
      'sdpMLineIndex': candidate['sdpMLineIndex'],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  StreamSubscription<DocumentSnapshot> listenForAnswer(
    String callId, 
    Function(Map<String, dynamic>) onAnswer) {
    
    return _firestore.collection('calls').doc(callId).snapshots().listen((snapshot) {
      final data = snapshot.data();
      if (data != null && data['answer'] != null) {
        print('📥 Answer recibido de Firebase: ${data['answer']}');
        onAnswer(data['answer']);
      }
    });
  }

  StreamSubscription<QuerySnapshot> listenForIceCandidates(
    String callId, 
    Function(Map<String, dynamic>) onCandidate) {
    
    _iceSubscription = _firestore
        .collection('calls')
        .doc(callId)
        .collection('iceCandidates')
        .snapshots()
        .listen((snapshot) {
      for (final doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          final candidate = doc.doc.data() as Map<String, dynamic>;
          print('🧊 ICE Candidate recibido: $candidate');
          onCandidate(candidate);
        }
      }
    });

    return _iceSubscription!;
  }

  StreamSubscription<DocumentSnapshot> listenForCallUpdates(
  String callId, 
  Function(Map<String, dynamic>?) onCallUpdated) {
  
  return _firestore.collection('calls').doc(callId).snapshots().listen((snapshot) {
    final data = snapshot.data();
    onCallUpdated(data);
  });
}

  Future<void> cleanupCall(String callId) async {
    try {
      // Eliminar todos los ICE candidates primero
      final candidates = await _firestore
          .collection('calls')
          .doc(callId)
          .collection('iceCandidates')
          .get();
      
      for (final doc in candidates.docs) {
        await doc.reference.delete();
      }
      
      // Eliminar la llamada principal
      await _firestore.collection('calls').doc(callId).delete();
    } catch (e) {
      print('Error limpiando llamada: $e');
    }
  }

  
}