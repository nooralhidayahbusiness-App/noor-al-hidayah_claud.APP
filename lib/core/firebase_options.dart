import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for the "noor-al-hidaiyah" project (web build).
/// Shared with the website so accounts and data stay in sync.
class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCICNIKmUE-jIeCLfLhSUopSRRbYlL4aBc',
    authDomain: 'noor-al-hidaiyah.firebaseapp.com',
    projectId: 'noor-al-hidaiyah',
    storageBucket: 'noor-al-hidaiyah.firebasestorage.app',
    messagingSenderId: '762471094332',
    appId: '1:762471094332:web:68fe063e9282d7441d8b39',
    measurementId: 'G-63KL180LP2',
  );
}
