// lib/features/dua/data/dua_data.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/dua_model.dart';

/// بيانات الأدعية من ملف JSON
class DuaData {
  static Map<String, dynamic>? _cachedData;
  
  /// تحميل البيانات من ملف JSON
  static Future<Map<String, dynamic>> _loadData() async {
    if (_cachedData != null) {
      return _cachedData!;
    }
    
    try {
      final String jsonString = await rootBundle.loadString('assets/data/duas_data.json');
      _cachedData = json.decode(jsonString);
      return _cachedData!;
    } catch (e) {
      throw Exception('فشل في تحميل بيانات الأدعية: $e');
    }
  }

  static Future<List<DuaCategory>> getCategories() async {
    try {
      final data = await _loadData();
      final List categoriesData = data['categories'] ?? [];
      
      List<DuaCategory> categories = [];
      
      for (var categoryData in categoriesData) {
        final categoryId = categoryData['id'];
        final duasData = data['duas'][categoryId] ?? [];
        
        categories.add(DuaCategory(
          id: categoryData['id'] ?? '',
          name: categoryData['name'] ?? '',
          description: categoryData['description'] ?? '',
          icon: categoryData['icon'] ?? '',
          type: DuaType.values[categoryData['type'] ?? 0],
          duaCount: duasData.length,
        ));
      }
      
      return categories;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Dua>> getAllDuas() async {
    try {
      final data = await _loadData();
      final Map<String, dynamic> duasData = data['duas'] ?? {};
      
      List<Dua> allDuas = [];
      
      for (var categoryDuas in duasData.values) {
        for (var duaData in categoryDuas) {
          allDuas.add(Dua(
            id: duaData['id'] ?? '',
            title: duaData['title'] ?? '',
            arabicText: duaData['arabicText'] ?? '',
            transliteration: duaData['transliteration'],
            translation: duaData['translation'],
            source: duaData['source'],
            reference: duaData['reference'],
            categoryId: duaData['categoryId'] ?? '',
            tags: List<String>.from(duaData['tags'] ?? []),
            order: duaData['order'],
            type: DuaType.values[duaData['type'] ?? 0],
          ));
        }
      }
      
      return allDuas;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Dua>> getDuasByCategory(String categoryId) async {
    try {
      final data = await _loadData();
      final List categoryDuas = data['duas'][categoryId] ?? [];
      
      return categoryDuas.map<Dua>((duaData) => Dua(
        id: duaData['id'] ?? '',
        title: duaData['title'] ?? '',
        arabicText: duaData['arabicText'] ?? '',
        transliteration: duaData['transliteration'],
        translation: duaData['translation'],
        source: duaData['source'],
        reference: duaData['reference'],
        categoryId: duaData['categoryId'] ?? '',
        tags: List<String>.from(duaData['tags'] ?? []),
        order: duaData['order'],
        type: DuaType.values[duaData['type'] ?? 0],
      )).toList();
    } catch (e) {
      return [];
    }
  }
}