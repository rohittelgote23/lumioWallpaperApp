import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../../utils/constants.dart';

/// Repository for category-related operations
///
/// Handles all Firestore interactions for categories
/// Provides methods to fetch and manage category data
class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  List<CategoryModel>? _cachedCategories;

  /// Get all active categories ordered by the 'order' field
  ///
  /// Returns a list of categories sorted by their order value
  /// Only returns categories where isActive is true
  Future<List<CategoryModel>> getCategories({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _cachedCategories != null) {
        return _cachedCategories!;
      }

      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          // .where('isActive', isEqualTo: true) // Fetch all to allow virtual/inactive in slider
          .get();

      final categories = querySnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();

      categories.sort((a, b) => a.order.compareTo(b.order));

      _cachedCategories = categories;
      return categories;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Get categories as a stream for real-time updates
  ///
  /// Useful for listening to category changes in real-time
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore
        .collection(AppConstants.categoriesCollection)
        // .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final categories = snapshot.docs
              .map((doc) => CategoryModel.fromFirestore(doc))
              .toList();
          categories.sort((a, b) => a.order.compareTo(b.order));
          return categories;
        });
  }

  /// Get a single category by ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .get();

      if (doc.exists) {
        return CategoryModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }
}
