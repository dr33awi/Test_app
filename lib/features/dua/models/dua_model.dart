// lib/features/dua/models/dua_model.dart
import 'package:equatable/equatable.dart';

/// نموذج بيانات الدعاء
class Dua extends Equatable {
  final String id;
  final String title;
  final String arabicText;
  final String? transliteration;
  final String? translation;
  final String? source;
  final String? reference;
  final String categoryId;
  final List<String> tags;
  final int? order;
  final bool isFavorite;
  final int readCount;
  final DateTime? lastRead;
  final String? audioUrl;
  final String? benefits;
  final String? occasion;
  final DuaType type;

  const Dua({
    required this.id,
    required this.title,
    required this.arabicText,
    this.transliteration,
    this.translation,
    this.source,
    this.reference,
    required this.categoryId,
    this.tags = const [],
    this.order,
    this.isFavorite = false,
    this.readCount = 0,
    this.lastRead,
    this.audioUrl,
    this.benefits,
    this.occasion,
    this.type = DuaType.general,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        arabicText,
        transliteration,
        translation,
        source,
        reference,
        categoryId,
        tags,
        order,
        isFavorite,
        readCount,
        lastRead,
        audioUrl,
        benefits,
        occasion,
        type,
      ];

  Dua copyWith({
    String? id,
    String? title,
    String? arabicText,
    String? transliteration,
    String? translation,
    String? source,
    String? reference,
    String? categoryId,
    List<String>? tags,
    int? order,
    bool? isFavorite,
    int? readCount,
    DateTime? lastRead,
    String? audioUrl,
    String? benefits,
    String? occasion,
    DuaType? type,
  }) {
    return Dua(
      id: id ?? this.id,
      title: title ?? this.title,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      source: source ?? this.source,
      reference: reference ?? this.reference,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      order: order ?? this.order,
      isFavorite: isFavorite ?? this.isFavorite,
      readCount: readCount ?? this.readCount,
      lastRead: lastRead ?? this.lastRead,
      audioUrl: audioUrl ?? this.audioUrl,
      benefits: benefits ?? this.benefits,
      occasion: occasion ?? this.occasion,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'arabicText': arabicText,
      'transliteration': transliteration,
      'translation': translation,
      'source': source,
      'reference': reference,
      'categoryId': categoryId,
      'tags': tags,
      'order': order,
      'isFavorite': isFavorite ? 1 : 0,
      'readCount': readCount,
      'lastRead': lastRead?.millisecondsSinceEpoch,
      'audioUrl': audioUrl,
      'benefits': benefits,
      'occasion': occasion,
      'type': type.index,
    };
  }

  factory Dua.fromMap(Map<String, dynamic> map) {
    return Dua(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      arabicText: map['arabicText'] ?? '',
      transliteration: map['transliteration'],
      translation: map['translation'],
      source: map['source'],
      reference: map['reference'],
      categoryId: map['categoryId'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      order: map['order'],
      isFavorite: (map['isFavorite'] ?? 0) == 1,
      readCount: map['readCount'] ?? 0,
      lastRead: map['lastRead'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastRead'])
          : null,
      audioUrl: map['audioUrl'],
      benefits: map['benefits'],
      occasion: map['occasion'],
      type: DuaType.values[map['type'] ?? 0],
    );
  }
}

/// أنواع الأدعية
enum DuaType {
  general, // عامة
  morning, // الصباح
  evening, // المساء
  prayer, // الصلاة
  food, // الطعام
  travel, // السفر
  sleep, // النوم
  protection, // الحماية
  forgiveness, // الاستغفار
  gratitude, // الشكر
  guidance, // الهداية
  health, // الصحة
  wealth, // الرزق
  knowledge, // العلم
}

extension DuaTypeExtension on DuaType {
  String get displayName {
    switch (this) {
      case DuaType.general:
        return 'أدعية عامة';
      case DuaType.morning:
        return 'أدعية الصباح';
      case DuaType.evening:
        return 'أدعية المساء';
      case DuaType.prayer:
        return 'أدعية الصلاة';
      case DuaType.food:
        return 'أدعية الطعام';
      case DuaType.travel:
        return 'أدعية السفر';
      case DuaType.sleep:
        return 'أدعية النوم';
      case DuaType.protection:
        return 'أدعية الحماية';
      case DuaType.forgiveness:
        return 'أدعية الاستغفار';
      case DuaType.gratitude:
        return 'أدعية الشكر';
      case DuaType.guidance:
        return 'أدعية الهداية';
      case DuaType.health:
        return 'أدعية الصحة';
      case DuaType.wealth:
        return 'أدعية الرزق';
      case DuaType.knowledge:
        return 'أدعية العلم';
    }
  }

  String get description {
    switch (this) {
      case DuaType.general:
        return 'أدعية متنوعة للحياة اليومية';
      case DuaType.morning:
        return 'أدعية للبدء بها في الصباح';
      case DuaType.evening:
        return 'أدعية للمساء والليل';
      case DuaType.prayer:
        return 'أدعية قبل وبعد الصلاة';
      case DuaType.food:
        return 'أدعية قبل وبعد تناول الطعام';
      case DuaType.travel:
        return 'أدعية للسفر والرحلات';
      case DuaType.sleep:
        return 'أدعية قبل النوم';
      case DuaType.protection:
        return 'أدعية للحماية من الشر';
      case DuaType.forgiveness:
        return 'أدعية طلب المغفرة والتوبة';
      case DuaType.gratitude:
        return 'أدعية الحمد والشكر';
      case DuaType.guidance:
        return 'أدعية طلب الهداية';
      case DuaType.health:
        return 'أدعية للصحة والعافية';
      case DuaType.wealth:
        return 'أدعية طلب الرزق الحلال';
      case DuaType.knowledge:
        return 'أدعية طلب العلم والحكمة';
    }
  }
}

/// نموذج فئة الأدعية
class DuaCategory extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final DuaType type;
  final int duaCount;
  final String? backgroundImage;

  const DuaCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    this.duaCount = 0,
    this.backgroundImage,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        type,
        duaCount,
        backgroundImage,
      ];

  DuaCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    DuaType? type,
    int? duaCount,
    String? backgroundImage,
  }) {
    return DuaCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      duaCount: duaCount ?? this.duaCount,
      backgroundImage: backgroundImage ?? this.backgroundImage,
    );
  }
}

/// إحصائيات الأدعية
class DuaStats extends Equatable {
  final int totalDuas;
  final int favoriteDuas;
  final int readDuas;
  final int streakDays;
  final DateTime? lastReadDate;
  final Map<DuaType, int> duasByType;

  const DuaStats({
    this.totalDuas = 0,
    this.favoriteDuas = 0,
    this.readDuas = 0,
    this.streakDays = 0,
    this.lastReadDate,
    this.duasByType = const {},
  });

  @override
  List<Object?> get props => [
        totalDuas,
        favoriteDuas,
        readDuas,
        streakDays,
        lastReadDate,
        duasByType,
      ];

  DuaStats copyWith({
    int? totalDuas,
    int? favoriteDuas,
    int? readDuas,
    int? streakDays,
    DateTime? lastReadDate,
    Map<DuaType, int>? duasByType,
  }) {
    return DuaStats(
      totalDuas: totalDuas ?? this.totalDuas,
      favoriteDuas: favoriteDuas ?? this.favoriteDuas,
      readDuas: readDuas ?? this.readDuas,
      streakDays: streakDays ?? this.streakDays,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      duasByType: duasByType ?? this.duasByType,
    );
  }
}