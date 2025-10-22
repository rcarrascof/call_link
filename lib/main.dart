import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'package:flutter/material.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase inicializado');
  } catch (e) {
    print('Error inicializando Firebase: $e');
  }

  runApp(const App());
}
