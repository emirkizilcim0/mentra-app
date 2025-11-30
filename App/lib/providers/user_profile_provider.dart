import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _firstName = "";
  String _lastName = "";
  String _zodiac = "";
  String _birthDate = "";
  String _mbtiType = "";
  String _mbtiTitle = "";
  String _mbtiDesc = "";

  bool _isLoaded = false;

  // Getters
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get zodiac => _zodiac;
  String get birthDate => _birthDate;
  String get mbtiType => _mbtiType;
  String get mbtiTitle => _mbtiTitle;
  String get mbtiDesc => _mbtiDesc;
  bool get isLoaded => _isLoaded;

  // User data'yi önceden yükle
  Future<void> preloadUserData() async {
    if (_isLoaded) return; // Zaten yüklenmişse tekrar yükleme

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          final data = doc.data()!;
          _firstName = data['firstName'] ?? "";
          _lastName = data['lastName'] ?? "";
          _zodiac = data['zodiac'] ?? "";
          _birthDate = data['birthDate'] ?? "";
          _mbtiType = data['mbtiType'] ?? "";
          _mbtiTitle = data['mbtiTitle'] ?? "";
          _mbtiDesc = data['mbtiDesc'] ?? "";

          _isLoaded = true;
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error preloading user data: $e");
    }
  }

  // Verileri güncelle
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? zodiac,
    String? birthDate,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final updateData = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (firstName != null) {
          _firstName = firstName;
          updateData['firstName'] = firstName;
        }
        if (lastName != null) {
          _lastName = lastName;
          updateData['lastName'] = lastName;
        }
        if (zodiac != null) {
          _zodiac = zodiac;
          updateData['zodiac'] = zodiac;
        }
        if (birthDate != null) {
          _birthDate = birthDate;
          updateData['birthDate'] = birthDate;
        }

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(updateData, SetOptions(merge: true));

        notifyListeners();
      }
    } catch (e) {
      print("Error updating profile: $e");
      rethrow;
    }
  }
}
