import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Wallpaper model representing a single wallpaper
///
/// This model maps to the 'wallpapers' collection in Firestore
/// Each wallpaper has three versions: thumbnail, display, and download
class WallpaperModel extends Equatable {
  final String id;
  final String title;
  final List<String> categoryIds;
  final String thumbnailUrl;
  final String fullUrl;
  final List<String> colorPalette;
  final bool isActive;
  final int downloads;
  final int likes;
  final int views;
  final bool isPremium;
  final DateTime createdAt;
  final List<String> tags;
  final String info;
  final String type; // Kept for backward compatibility, default 'image'
  final DocumentSnapshot? documentSnapshot; // Reference for pagination

  const WallpaperModel({
    required this.id,
    required this.title,
    required this.categoryIds,
    required this.thumbnailUrl,
    required this.fullUrl,
    required this.colorPalette,
    this.isActive = true,
    this.downloads = 0,
    this.likes = 0,
    this.views = 0,
    this.isPremium = false,
    required this.createdAt,
    required this.tags,
    this.info = '',
    this.type = 'image',
    this.documentSnapshot,
  });

  /// Create WallpaperModel from Firestore document
  factory WallpaperModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WallpaperModel(
      id: doc.id,
      title: data['title'] ?? '',
      categoryIds: List<String>.from(data['categoryIds'] ?? []),
      thumbnailUrl: data['thumbnail_url'] ?? '',
      fullUrl: data['full_url'] ?? '',
      colorPalette: List<String>.from(data['color_palette'] ?? []),
      isActive: data['isActive'] ?? true,
      downloads: data['downloads'] ?? 0,
      likes: data['likes'] ?? 0,
      views: data['views'] ?? 0,
      isPremium: data['isPremium'] ?? false,
      createdAt: _parseDate(data['createdAt']),
      tags: List<String>.from(data['tags'] ?? []),
      info: data['info'] ?? '',
      type: data['type'] ?? 'image',
      documentSnapshot: doc,
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    return DateTime.now();
  }

  /// Convert WallpaperModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'categoryIds': categoryIds,
      'thumbnail_url': thumbnailUrl,
      'full_url': fullUrl,
      'color_palette': colorPalette,
      'isActive': isActive,
      'downloads': downloads,
      'likes': likes,
      'views': views,
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
      'info': info,
      'type': type,
    };
  }

  /// Create a copy with modified fields
  WallpaperModel copyWith({
    String? id,
    String? title,
    List<String>? categoryIds,
    String? thumbnailUrl,
    String? fullUrl,
    List<String>? colorPalette,
    bool? isActive,
    int? downloads,
    int? likes,
    int? views,
    bool? isPremium,
    DateTime? createdAt,
    List<String>? tags,
    String? info,
    String? type,
    DocumentSnapshot? documentSnapshot,
  }) {
    return WallpaperModel(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryIds: categoryIds ?? this.categoryIds,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fullUrl: fullUrl ?? this.fullUrl,
      colorPalette: colorPalette ?? this.colorPalette,
      isActive: isActive ?? this.isActive,
      downloads: downloads ?? this.downloads,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      info: info ?? this.info,
      type: type ?? this.type,
      documentSnapshot: documentSnapshot ?? this.documentSnapshot,
    );
  }

  bool get isVideo {
    return type == 'video' ||
        fullUrl.toLowerCase().endsWith('.mp4') ||
        fullUrl.toLowerCase().endsWith('.mov');
  }

  bool get hasValidUrl {
    return fullUrl.isNotEmpty &&
        (fullUrl.startsWith('http') || fullUrl.startsWith('https'));
  }

  @override
  List<Object?> get props => [
    id,
    title,
    categoryIds,
    thumbnailUrl,
    fullUrl,
    colorPalette,
    isActive,
    downloads,
    likes,
    views,
    isPremium,
    createdAt,
    tags,
    info,
    type,
    // Note: intentionally excluding documentSnapshot from equatable to prevent false inequality
  ];
}
