import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String photoURL;
  final DateTime? lastLogin;
  final Subscription subscription;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.photoURL,
    this.lastLogin,
    this.subscription = const Subscription(),
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'] ?? '',
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      subscription: Subscription.fromMap(data['subscription'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'lastLogin': lastLogin != null
          ? Timestamp.fromDate(lastLogin!)
          : FieldValue.serverTimestamp(),
      'subscription': subscription.toMap(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? lastLogin,
    Subscription? subscription,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      lastLogin: lastLogin ?? this.lastLogin,
      subscription: subscription ?? this.subscription,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoURL,
    lastLogin,
    subscription,
  ];
}

class Subscription extends Equatable {
  final bool isPremium;
  final String? activeEntitlement; // 'Weekly', 'Monthly', or null
  final DateTime? lastUpdated;

  const Subscription({
    this.isPremium = false,
    this.activeEntitlement,
    this.lastUpdated,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      isPremium: map['isPremium'] ?? false,
      activeEntitlement: map['activeEntitlement'],
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isPremium': isPremium,
      'activeEntitlement': activeEntitlement,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
    };
  }

  @override
  List<Object?> get props => [isPremium, activeEntitlement, lastUpdated];
}
