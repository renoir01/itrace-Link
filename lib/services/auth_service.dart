import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  UserModel? _userModel;
  String? _verificationId;

  User? get currentUser => _currentUser;
  UserModel? get userModel => _userModel;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _currentUser = user;
    if (user != null) {
      await _loadUserModel(user.uid);
    } else {
      _userModel = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserModel(String uid) async {
    try {
      final doc = await _firestore.collection(AppConstants.collectionUsers).doc(uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromFirestore(doc);

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.keyUserId, uid);
        await prefs.setString(AppConstants.keyUserType, _userModel!.userType);
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      }
    } catch (e) {
      debugPrint('Error loading user model: $e');
    }
  }

  // Phone Authentication - Send OTP
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Verification failed: ${e.message}');
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
      return true;
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      return false;
    }
  }

  // Phone Authentication - Verify OTP
  Future<bool> verifyOTP(String otp) async {
    try {
      if (_verificationId == null) {
        throw Exception('Verification ID is null');
      }

      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return false;
    }
  }

  // Email & Password Registration
  Future<String?> registerWithEmail({
    required String email,
    required String password,
    required String phone,
    required String userType,
    required String language,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Create user document in Firestore
        final userModel = UserModel(
          id: user.uid,
          userType: userType,
          email: email,
          phone: phone,
          language: language,
          isVerified: false,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.collectionUsers)
            .doc(user.uid)
            .set(userModel.toFirestore());

        await _loadUserModel(user.uid);
        return user.uid;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error registering with email: ${e.message}');
      throw e;
    }
  }

  // Email & Password Login
  Future<bool> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error logging in: ${e.message}');
      throw e;
    }
  }

  // Phone & Password Login
  Future<bool> loginWithPhone(String phone, String password) async {
    try {
      // First, find the user by phone number
      final querySnapshot = await _firestore
          .collection(AppConstants.collectionUsers)
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('User not found');
      }

      final userDoc = querySnapshot.docs.first;
      final email = userDoc.data()['email'] as String;

      // Login with email
      return await loginWithEmail(email, password);
    } catch (e) {
      debugPrint('Error logging in with phone: $e');
      return false;
    }
  }

  // Password Reset
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Error resetting password: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserType);
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);

    _currentUser = null;
    _userModel = null;
    notifyListeners();
  }

  // Update user language
  Future<void> updateLanguage(String language) async {
    if (_currentUser != null && _userModel != null) {
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(_currentUser!.uid)
          .update({'language': language});

      _userModel = _userModel!.copyWith(language: language);
      notifyListeners();
    }
  }

  // Check if user is verified
  bool get isUserVerified => _userModel?.isVerified ?? false;
}
