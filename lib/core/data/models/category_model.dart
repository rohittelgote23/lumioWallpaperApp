import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Category model representing a wallpaper category
///
/// This model maps to the 'categories' collection in Firestore
/// Each category contains metadata for organizing wallpapers
class CategoryModel extends Equatable {
  final String id;
  final String name;
  final int order;
  final String thumbnail;
  final bool isActive;
  final bool isVirtual;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.order,
    this.thumbnail = '',
    this.isActive = true,
    this.isVirtual = false,
    required this.createdAt,
  });

  /// Create CategoryModel from Firestore document
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      order: data['order'] ?? 0,
      thumbnail: data['thumbnail'] ?? '',
      isActive: data['isActive'] ?? true,
      isVirtual: data['isVirtual'] ?? false,
      createdAt: _parseDate(data['createdAt']),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    return DateTime.now();
  }

  /// Convert CategoryModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'order': order,
      'thumbnail': thumbnail,
      'isActive': isActive,
      'isVirtual': isVirtual,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with modified fields
  CategoryModel copyWith({
    String? id,
    String? name,
    int? order,
    String? thumbnail,
    bool? isActive,
    bool? isVirtual,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      thumbnail: thumbnail ?? this.thumbnail,
      isActive: isActive ?? this.isActive,
      isVirtual: isVirtual ?? this.isVirtual,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    order,
    thumbnail,
    isActive,
    isVirtual,
    createdAt,
  ];
}
