import 'dart:convert';

import 'package:dishcovery_app/core/models/recipe_model.dart';
import 'package:dishcovery_app/core/models/scan_model.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class ScanResultEntity {
  @Id()
  int id;

  String? firestoreId;
  String? userId;
  String? userEmail;
  String? userName;
  bool isFood;
  String imagePath;
  String imageUrl;
  String name;
  String origin;
  String description;
  String history;
  String recipeJson;
  String tagsString;
  bool isPublic;
  bool isFavorite;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime? updatedAt;

  ScanResultEntity({
    this.id = 0,
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
    required this.recipeJson,
    required this.tagsString,
    this.isPublic = true,
    this.isFavorite = false,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ScanResultEntity.fromScanResult(ScanResult scanResult) {
    return ScanResultEntity(
      id: scanResult.id ?? 0,
      firestoreId: scanResult.firestoreId,
      userId: scanResult.userId,
      userEmail: scanResult.userEmail,
      userName: scanResult.userName,
      isFood: scanResult.isFood,
      imagePath: scanResult.imagePath,
      imageUrl: scanResult.imageUrl,
      name: scanResult.name,
      origin: scanResult.origin,
      description: scanResult.description,
      history: scanResult.history,
      recipeJson: jsonEncode(scanResult.recipe.toJson()),
      tagsString: scanResult.tags.join(','),
      isPublic: scanResult.isPublic,
      isFavorite: scanResult.isFavorite,
      createdAt: scanResult.createdAt,
      updatedAt: scanResult.updatedAt,
    );
  }

  ScanResult toScanResult() {
    return ScanResult(
      id: id == 0 ? null : id,
      firestoreId: firestoreId,
      userId: userId,
      userEmail: userEmail,
      userName: userName,
      isFood: isFood,
      imagePath: imagePath,
      imageUrl: imageUrl,
      name: name,
      origin: origin,
      description: description,
      history: history,
      recipe: Recipe.fromJson(jsonDecode(recipeJson)),
      tags: tagsString.isEmpty ? [] : tagsString.split(','),
      isPublic: isPublic,
      isFavorite: isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Helper method to get tags as list
  List<String> get tags => tagsString.isEmpty ? [] : tagsString.split(',');

  // Helper method to set tags from list
  set tags(List<String> tags) {
    tagsString = tags.join(',');
  }

  // Helper method to get Recipe object
  Recipe getRecipe() {
    return Recipe.fromJson(jsonDecode(recipeJson));
  }

  // Helper method to set Recipe object
  void setRecipe(Recipe recipe) {
    recipeJson = jsonEncode(recipe.toJson());
  }
}
