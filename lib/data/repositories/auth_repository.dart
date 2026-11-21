import 'package:firebase_auth/firebase_auth.dart';

abstract interface class AuthRepository {
  String get userId;
  String get email;
  bool get isDemo;
  bool get hasSession;

  Future<void> signIn(String email, String password);
  Future<void> createAccount(String email, String password);
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  String get userId => _auth.currentUser!.uid;

  @override
  String get email => _auth.currentUser?.email ?? '';

  @override
  bool get isDemo => false;

  @override
  bool get hasSession => _auth.currentUser != null;

  @override
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> createAccount(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

class DemoAuthRepository implements AuthRepository {
  static const demoEmail = 'demo@gymmate.app';
  static const demoPassword = 'GymMate2026';
  bool _isSignedIn = false;

  @override
  String get userId => 'local-demo';

  @override
  String get email => demoEmail;

  @override
  bool get isDemo => true;

  @override
  bool get hasSession => _isSignedIn;

  @override
  Future<void> signIn(String email, String password) async {
    if (email.trim().toLowerCase() != demoEmail || password != demoPassword) {
      throw const DemoAuthenticationException();
    }
    _isSignedIn = true;
  }

  @override
  Future<void> createAccount(String email, String password) async {
    throw const DemoRegistrationUnavailableException();
  }

  @override
  Future<void> signOut() async {
    _isSignedIn = false;
  }
}

class DemoAuthenticationException implements Exception {
  const DemoAuthenticationException();
}

class DemoRegistrationUnavailableException implements Exception {
  const DemoRegistrationUnavailableException();
}
