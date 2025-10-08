import 'dart:convert';

import 'package:dishcovery_app/core/models/recipe_model.dart';

class ScanResult {
  final int? id; // Local ObjectBox ID
  final String? firestoreId; // Firestore document ID
  final String? userId; // User who created the scan
  final String? userEmail;
  final String? userName;
  final bool isFood;
  final String imagePath;
  final String imageUrl; // Firebase Storage URL for public feeds
  final String name;
  final String origin;
  final String description;
  final String history;
  final Recipe recipe;
  final List<String> tags;
  final bool isPublic; // Whether this is visible in feeds
  final bool isFavorite; // Local favorite/collection flag
  final DateTime createdAt;
  final DateTime? updatedAt;

  ScanResult({
    this.id,
    this.firestoreId,
    this.userId,
    this.userEmail,
    this.userName,
    required this.isFood,
    required this.imagePath,
    this.imageUrl = '',
    required this.name,
    required this.origin,
    required this.description,
    required this.history,
    required this.recipe,
    required this.tags,
    this.isPublic = true,
    this.isFavorite = false,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final rawName = (json['name'] ?? '').toString().trim();
    final isFood =
        rawName.isNotEmpty &&
        !rawName.toLowerCase().contains("bukan makanan") &&
        !rawName.toLowerCase().contains("not food");

    return ScanResult(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      firestoreId: json['firestoreId']?.toString(),
      userId: json['userId']?.toString(),
      userEmail: json['userEmail']?.toString(),
      userName: json['userName']?.toString(),
      isFood: isFood,
      imagePath: (json['imagePath'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      name: rawName,
      origin: (json['origin'] ?? 'Tidak diketahui').toString(),
      description: (json['description'] ?? 'Deskripsi tidak tersedia')
          .toString(),
      history: (json['history'] ?? '').toString(),
      recipe: Recipe.fromJson(
        json['recipe'] is Map<String, dynamic> ? json['recipe'] : {},
      ),
      tags: (json['tags'] is List)
          ? List<String>.from(json['tags'].map((e) => e.toString()))
          : const [],
      isPublic: json['isPublic'] ?? true,
      isFavorite: json['isFavorite'] ?? false,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
                ? DateTime.parse(json['createdAt'])
                : (json['createdAt'] as dynamic).toDate())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is String
                ? DateTime.parse(json['updatedAt'])
                : (json['updatedAt'] as dynamic).toDate())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firestoreId': firestoreId,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'isFood': isFood,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'name': name,
      'origin': origin,
      'description': description,
      'history': history,
      'recipe': recipe.toJson(),
      'tags': tags,
      'isPublic': isPublic,
      'isFavorite': isFavorite,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'isFood': isFood,
      'imageUrl': imageUrl,
      'name': name,
      'origin': origin,
      'description': description,
      'history': history,
      'recipe': recipe.toJson(),
      'tags': tags,
      'isPublic': isPublic,
      'createdAt': createdAt,
      'updatedAt': DateTime.now(),
    };
  }

  factory ScanResult.fromDbMap(Map<String, dynamic> dbMap) {
    return ScanResult(
      id: dbMap['id'],
      firestoreId: dbMap['firestoreId'],
      userId: dbMap['userId'],
      userEmail: dbMap['userEmail'],
      userName: dbMap['userName'],
      isFood: dbMap['isFood'] == 1,
      imagePath: dbMap['imagePath'],
      imageUrl: dbMap['imageUrl'] ?? '',
      name: dbMap['name'],
      origin: dbMap['origin'],
      description: dbMap['description'],
      history: dbMap['history'],
      recipe: Recipe.fromJson(jsonDecode(dbMap['recipe'] ?? '{}')),
      tags: (jsonDecode(dbMap['tags'] ?? '[]') as List).cast<String>(),
      isPublic: dbMap['isPublic'] == 1,
      isFavorite: dbMap['isFavorite'] == 1,
      createdAt: DateTime.parse(dbMap['createdAt']),
      updatedAt: dbMap['updatedAt'] != null
          ? DateTime.parse(dbMap['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'firestoreId': firestoreId,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'isFood': isFood ? 1 : 0,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'name': name,
      'origin': origin,
      'description': description,
      'history': history,
      'recipe': jsonEncode(recipe.toJson()),
      'tags': jsonEncode(tags),
      'isPublic': isPublic ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ScanResult copyWith({
    int? id,
    String? firestoreId,
    String? userId,
    String? userEmail,
    String? userName,
    bool? isFood,
    String? imagePath,
    String? imageUrl,
    String? name,
    String? origin,
    String? description,
    String? history,
    Recipe? recipe,
    List<String>? tags,
    bool? isPublic,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScanResult(
      id: id ?? this.id,
      firestoreId: firestoreId ?? this.firestoreId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      isFood: isFood ?? this.isFood,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      description: description ?? this.description,
      history: history ?? this.history,
      recipe: recipe ?? this.recipe,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
