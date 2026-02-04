import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  // Placeholder service — expand with auth / firestore methods
  static Future<void> init() async {
    // If using generated options, call:
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp();
  }
}
