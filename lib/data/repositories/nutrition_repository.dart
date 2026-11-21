import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../local/app_database.dart';

class ApiFood {
  const ApiFood({
    required this.name,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.calories,
    this.brand,
  });

  final String name;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double calories;
  final String? brand;

  factory ApiFood.fromJson(Map<String, dynamic> json) {
    final nutriments = json['nutriments'];
    if (nutriments is! Map<String, dynamic>) {
      throw const FormatException(
        'El alimento no incluye información nutricional.',
      );
    }

    double nutrient(String key) {
      final value = nutriments[key];
      return value is num ? value.toDouble() : 0;
    }

    return ApiFood(
      name: json['product_name'] as String,
      brand: json['brands'] as String?,
      protein: nutrient('proteins_100g'),
      carbohydrates: nutrient('carbohydrates_100g'),
      fat: nutrient('fat_100g'),
      calories: nutrient('energy-kcal_100g'),
    );
  }

  Map<String, Object?> toJson() => {
    'name': name,
    'brand': brand,
    'protein': protein,
    'carbohydrates': carbohydrates,
    'fat': fat,
    'calories': calories,
  };

  factory ApiFood.fromCacheJson(Map<String, dynamic> json) => ApiFood(
    name: json['name']! as String,
    brand: json['brand'] as String?,
    protein: (json['protein']! as num).toDouble(),
    carbohydrates: (json['carbohydrates']! as num).toDouble(),
    fat: (json['fat']! as num).toDouble(),
    calories: (json['calories']! as num).toDouble(),
  );
}

class FoodSearchResult {
  const FoodSearchResult({required this.foods, required this.isCached});

  final List<ApiFood> foods;
  final bool isCached;
}

class NutritionApiException implements Exception {
  const NutritionApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NutritionRepository {
  NutritionRepository({required this.database, http.Client? client})
    : _client = client ?? http.Client();

  final AppDatabase database;
  final http.Client _client;

  Future<FoodSearchResult> searchFoods(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 2) {
      throw const NutritionApiException('Escribe al menos 2 caracteres.');
    }
    if (normalizedQuery.length > 64) {
      throw const NutritionApiException(
        'La búsqueda no puede superar 64 caracteres.',
      );
    }

    final cacheKey = normalizedQuery.toLowerCase();
    try {
      final response = await _client
          .get(
            Uri.https('world.openfoodfacts.org', '/cgi/search.pl', {
              'search_terms': normalizedQuery,
              'search_simple': '1',
              'action': 'process',
              'json': '1',
              'page_size': '10',
              'fields':
                  'product_name,brands,nutriments,'
                  'nutriments.proteins_100g,nutriments.carbohydrates_100g,'
                  'nutriments.fat_100g,nutriments.energy-kcal_100g',
            }),
            headers: const {
              'User-Agent': 'GymMate/1.0 (educational mobile app)',
            },
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        return await _cachedResult(
          cacheKey,
          cause: 'El catálogo respondió con código ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['products'] is! List) {
        throw const NutritionApiException(
          'La respuesta del catálogo no es válida.',
        );
      }
      final foods = (decoded['products'] as List)
          .whereType<Map<String, dynamic>>()
          .where(
            (product) =>
                product['product_name'] is String &&
                (product['product_name'] as String).trim().isNotEmpty &&
                product['nutriments'] is Map<String, dynamic>,
          )
          .map(ApiFood.fromJson)
          .toList(growable: false);
      if (foods.isEmpty) {
        throw const NutritionApiException(
          'No se encontraron alimentos con datos nutricionales.',
        );
      }

      await database.database.insert('api_cache', {
        'cache_key': cacheKey,
        'payload': jsonEncode(foods.map((food) => food.toJson()).toList()),
        'saved_at': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return FoodSearchResult(foods: foods, isCached: false);
    } on TimeoutException {
      return _cachedResult(
        cacheKey,
        cause: 'La consulta superó el tiempo de espera.',
      );
    } on SocketException {
      return _cachedResult(cacheKey, cause: 'No se pudo conectar al catálogo.');
    } on http.ClientException {
      return _cachedResult(cacheKey, cause: 'No se pudo conectar al catálogo.');
    } on FormatException {
      throw const NutritionApiException(
        'El catálogo envió datos que no se pudieron leer.',
      );
    }
  }

  Future<FoodSearchResult> _cachedResult(
    String key, {
    required String cause,
  }) async {
    final rows = await database.database.query(
      'api_cache',
      where: 'cache_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw NutritionApiException(
        '$cause Esta búsqueda aún no está guardada en el dispositivo.',
      );
    }
    dynamic decoded;
    try {
      decoded = jsonDecode(rows.single['payload']! as String);
    } on FormatException {
      throw const NutritionApiException(
        'La respuesta guardada del catálogo está dañada.',
      );
    }
    if (decoded is! List) {
      throw const NutritionApiException(
        'Los datos guardados no se pueden leer.',
      );
    }
    final foods = decoded
        .whereType<Map<String, dynamic>>()
        .map(ApiFood.fromCacheJson)
        .toList(growable: false);
    return FoodSearchResult(foods: foods, isCached: true);
  }

  void close() => _client.close();
}
