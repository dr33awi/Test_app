// lib/features/dua/services/dua_service.dart
import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../../../core/infrastructure/services/logging/logger_service.dart';
import '../models/dua_model.dart';
import '../data/dua_data.dart';

/// خدمة إدارة الأدعية
class DuaService {
  final StorageService _storage;
  final LoggerService _logger;

  // مفاتيح التخزين
  static const String _favoriteDuasKey = 'favorite_duas';
  static const String _duaReadCountPrefix = 'dua_read_count_';
  static const String _lastReadDuaKey = 'last_read_dua';
  static const String _fontSizeKey = 'dua_font_size';

  DuaService({
    required StorageService storage,
    required LoggerService logger,
  })  : _storage = storage,
        _logger = logger;

  /// الحصول على جميع فئات الأدعية
  Future<List<DuaCategory>> getCategories() async {
    try {
      return await DuaData.getCategories();
    } catch (e) {
      _logger.error(message: 'خطأ في الحصول على فئات الأدعية', error: e);
      return [];
    }
  }

  /// الحصول على الأدعية حسب الفئة
  Future<List<Dua>> getDuasByCategory(String categoryId) async {
    try {
      final duas = await DuaData.getDuasByCategory(categoryId);
      final favoriteDuas = getFavoriteDuas();
      
      // إضافة حالة المفضلة وعدد القراءات
      return duas.map((dua) {
        final isFavorite = favoriteDuas.contains(dua.id);
        final readCount = getDuaReadCount(dua.id);
        final lastRead = getLastReadDate(dua.id);
        
        return dua.copyWith(
          isFavorite: isFavorite,
          readCount: readCount,
          lastRead: lastRead,
        );
      }).toList();
    } catch (e) {
      _logger.error(message: 'خطأ في الحصول على الأدعية للفئة $categoryId', error: e);
      return [];
    }
  }

  /// الحصول على جميع الأدعية
  Future<List<Dua>> getAllDuas() async {
    try {
      final allDuas = await DuaData.getAllDuas();
      final favoriteDuas = getFavoriteDuas();
      
      return allDuas.map((dua) {
        final isFavorite = favoriteDuas.contains(dua.id);
        final readCount = getDuaReadCount(dua.id);
        final lastRead = getLastReadDate(dua.id);
        
        return dua.copyWith(
          isFavorite: isFavorite,
          readCount: readCount,
          lastRead: lastRead,
        );
      }).toList();
    } catch (e) {
      _logger.error(message: 'خطأ في الحصول على جميع الأدعية', error: e);
      return [];
    }
  }

  /// البحث في الأدعية
  Future<List<Dua>> searchDuas(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      
      final allDuas = await getAllDuas();
      final lowerQuery = query.toLowerCase();
      
      return allDuas.where((dua) {
        return dua.title.toLowerCase().contains(lowerQuery) ||
               dua.arabicText.contains(query) ||
               (dua.translation?.toLowerCase().contains(lowerQuery) ?? false) ||
               dua.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();
    } catch (e) {
      _logger.error(message: 'خطأ في البحث عن الأدعية', error: e);
      return [];
    }
  }

  /// الحصول على الأدعية المفضلة
  List<String> getFavoriteDuas() {
    try {
      return _storage.getStringList(_favoriteDuasKey) ?? [];
    } catch (e) {
      _logger.error(message: 'خطأ في الحصول على الأدعية المفضلة', error: e);
      return [];
    }
  }

  /// إضافة/إزالة دعاء من المفضلة
  Future<bool> toggleFavorite(String duaId) async {
    try {
      final favorites = getFavoriteDuas();
      final isFavorite = favorites.contains(duaId);
      
      if (isFavorite) {
        favorites.remove(duaId);
      } else {
        favorites.add(duaId);
      }
      
      await _storage.setStringList(_favoriteDuasKey, favorites);
      _logger.info(message: 'تم تحديث حالة المفضلة للدعاء: $duaId');
      return !isFavorite;
    } catch (e) {
      _logger.error(message: 'خطأ في تحديث المفضلة للدعاء $duaId', error: e);
      return false;
    }
  }

  /// الحصول على الأدعية المفضلة مع التفاصيل
  Future<List<Dua>> getFavoriteDuasWithDetails() async {
    try {
      final favoriteIds = getFavoriteDuas();
      final allDuas = await getAllDuas();
      
      return allDuas.where((dua) => favoriteIds.contains(dua.id)).toList();
    } catch (e) {
      _logger.error(message: 'خطأ في الحصول على تفاصيل الأدعية المفضلة', error: e);
      return [];
    }
  }

  /// تسجيل قراءة دعاء
  Future<void> markDuaAsRead(String duaId) async {
    try {
      // زيادة عدد القراءات
      final currentCount = getDuaReadCount(duaId);
      await _storage.setInt('${_duaReadCountPrefix}$duaId', currentCount + 1);
      
      // تحديث تاريخ آخر قراءة
      await _storage.setString('last_read_$duaId', DateTime.now().toIso8601String());
      
      // تحديث آخر دعاء مقروء
      await _storage.setString(_lastReadDuaKey, duaId);
      
      _logger.info(message: 'تم تسجيل قراءة الدعاء: $duaId');
    } catch (e) {
      _logger.error(message: 'خطأ في تسجيل قراءة الدعاء $duaId', error: e);
    }
  }

  /// الحصول على عدد قراءات دعاء
  int getDuaReadCount(String duaId) {
    try {
      return _storage.getInt('${_duaReadCountPrefix}$duaId') ?? 0;
    } catch (e) {
      _logger.error(message: 'خطأ في الحصول على عدد قراءات الدعاء $duaId', error: e);
      return 0;
    }
  }

  /// الحصول على تاريخ آخر قراءة لدعاء
  DateTime? getLastReadDate(String duaId) {
    try {
      final dateString = _storage.getString('last_read_$duaId');
      return dateString != null ? DateTime.parse(dateString) : null;
    } catch (e) {
      _logger.error(message: 'خطأ في الحصول على تاريخ آخر قراءة للدعاء $duaId', error: e);
      return null;
    }
  }

  /// تصفير عداد قراءة دعاء معين
  Future<void> resetDuaReadCount(String duaId) async {
    try {
      // تصفير عدد القراءات
      await _storage.remove('${_duaReadCountPrefix}$duaId');
      
      // تصفير تاريخ آخر قراءة
      await _storage.remove('last_read_$duaId');
      
      _logger.info(message: 'تم تصفير عداد الدعاء: $duaId');
    } catch (e) {
      _logger.error(message: 'خطأ في تصفير عداد الدعاء $duaId', error: e);
    }
  }

  /// تصفير عداد القراءة لجميع الأدعية في فئة معينة
  Future<void> resetCategoryReadCount(String categoryId) async {
    try {
      final duas = await getDuasByCategory(categoryId);
      for (final dua in duas) {
        await resetDuaReadCount(dua.id);
      }
      
      _logger.info(message: 'تم تصفير عداد الفئة: $categoryId');
    } catch (e) {
      _logger.error(message: 'خطأ في تصفير عداد الفئة $categoryId', error: e);
    }
  }

  /// حفظ حجم الخط المختار
  Future<void> saveFontSize(double fontSize) async {
    try {
      await _storage.setDouble(_fontSizeKey, fontSize);
      _logger.info(message: 'تم حفظ حجم الخط: $fontSize');
    } catch (e) {
      _logger.error(message: 'خطأ في حفظ حجم الخط', error: e);
    }
  }

  /// الحصول على حجم الخط المحفوظ
  Future<double> getSavedFontSize() async {
    try {
      return _storage.getDouble(_fontSizeKey) ?? 18.0; // الافتراضي متوسط
    } catch (e) {
      _logger.error(message: 'خطأ في الحصول على حجم الخط المحفوظ', error: e);
      return 18.0; // الافتراضي متوسط
    }
  }

  /// الحصول على دعاء عشوائي
  Future<Dua?> getRandomDua({DuaType? type}) async {
    try {
      final allDuas = type != null 
          ? (await getAllDuas()).where((dua) => dua.type == type).toList()
          : await getAllDuas();
      
      if (allDuas.isEmpty) return null;
      
      final random = DateTime.now().millisecondsSinceEpoch % allDuas.length;
      return allDuas[random];
    } catch (e) {
      _logger.error(message: 'خطأ في الحصول على دعاء عشوائي', error: e);
      return null;
    }
  }

  /// الحصول على دعاء بالمعرف
  Future<Dua?> getDuaById(String duaId) async {
    try {
      final allDuas = await getAllDuas();
      return allDuas.firstWhere(
        (dua) => dua.id == duaId,
        orElse: () => throw Exception('الدعاء غير موجود'),
      );
    } catch (e) {
      _logger.error(message: 'خطأ في الحصول على الدعاء $duaId', error: e);
      return null;
    }
  }

  /// الحصول على التوصيات الذكية
  Future<List<Dua>> getRecommendations() async {
    try {
      final now = DateTime.now();
      final hour = now.hour;
      
      // توصيات حسب الوقت
      if (hour >= 6 && hour < 12) {
        // الصباح
        return (await getDuasByCategory('morning')).take(3).toList();
      } else if (hour >= 12 && hour < 18) {
        // الظهيرة
        return (await getDuasByCategory('general')).take(3).toList();
      } else if (hour >= 18 && hour < 22) {
        // المساء
        return (await getDuasByCategory('evening')).take(3).toList();
      } else {
        // الليل
        return (await getDuasByCategory('sleep')).take(3).toList();
      }
    } catch (e) {
      _logger.error(message: 'خطأ في الحصول على التوصيات', error: e);
      return [];
    }
  }

  /// مسح جميع البيانات
  Future<void> clearAllData() async {
    try {
      await _storage.remove(_favoriteDuasKey);
      await _storage.remove(_lastReadDuaKey);
      await _storage.remove(_fontSizeKey);
      
      // مسح عدادات القراءة
      final allDuas = await DuaData.getAllDuas();
      for (final dua in allDuas) {
        await _storage.remove('${_duaReadCountPrefix}${dua.id}');
        await _storage.remove('last_read_${dua.id}');
      }
      
      _logger.info(message: 'تم مسح جميع بيانات الأدعية');
    } catch (e) {
      _logger.error(message: 'خطأ في مسح بيانات الأدعية', error: e);
    }
  }

  /// تصدير البيانات
  Future<Map<String, dynamic>> exportData() async {
    try {
      final favorites = getFavoriteDuas();
      final allDuas = await getAllDuas();
      final readDuas = allDuas.where((dua) => getDuaReadCount(dua.id) > 0).length;
      
      return {
        'favorites': favorites,
        'totalDuas': allDuas.length,
        'readDuas': readDuas,
        'exportDate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.error(message: 'خطأ في تصدير بيانات الأدعية', error: e);
      return {};
    }
  }
}