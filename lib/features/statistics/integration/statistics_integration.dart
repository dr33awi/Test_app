// lib/features/statistics/integration/statistics_integration.dart

import '../../../app/di/service_locator.dart';
import '../services/statistics_service.dart';


/// مدير التكامل بين الإحصائيات والخدمات الأخرى
class StatisticsIntegration {
  static final StatisticsIntegration _instance = StatisticsIntegration._internal();
  factory StatisticsIntegration() => _instance;
  StatisticsIntegration._internal();

  late final StatisticsService _statisticsService;
  DateTime? _sessionStartTime;

  /// تهيئة التكامل
  void initialize() {
    _statisticsService = getIt<StatisticsService>();
  }

  /// بدء جلسة أذكار
  void startAthkarSession(String categoryId) {
    _sessionStartTime = DateTime.now();
  }

  /// إنهاء جلسة أذكار وتسجيل النتائج
  Future<void> endAthkarSession({
    required String categoryId,
    required String categoryName,
    required int itemsCompleted,
    required int totalItems,
  }) async {
    if (_sessionStartTime == null) return;

    final duration = DateTime.now().difference(_sessionStartTime!);
    
    await _statisticsService.recordAthkarActivity(
      categoryId: categoryId,
      categoryName: categoryName,
      itemsCompleted: itemsCompleted,
      totalItems: totalItems,
      duration: duration,
    );

    _sessionStartTime = null;
  }

  /// بدء جلسة تسبيح
  void startTasbihSession(String dhikrType) {
    _sessionStartTime = DateTime.now();
  }

  /// إنهاء جلسة تسبيح وتسجيل النتائج
  Future<void> endTasbihSession({
    required String dhikrType,
    required int count,
  }) async {
    if (_sessionStartTime == null) return;

    final duration = DateTime.now().difference(_sessionStartTime!);
    
    await _statisticsService.recordTasbihActivity(
      dhikrType: dhikrType,
      count: count,
      duration: duration,
    );

    _sessionStartTime = null;
  }

  /// تسجيل إكمال ذكر واحد
  Future<void> recordSingleAthkar({
    required String categoryId,
    required String categoryName,
    required String itemText,
  }) async {
    // تسجيل سريع لذكر واحد
    await _statisticsService.recordAthkarActivity(
      categoryId: categoryId,
      categoryName: categoryName,
      itemsCompleted: 1,
      totalItems: 1,
      duration: const Duration(seconds: 30), // تقدير تقريبي
    );
  }

  /// تسجيل تسبيحة واحدة
  Future<void> recordSingleTasbih(String dhikrType) async {
    // يمكن تجميع التسبيحات وإرسالها دفعة واحدة
    await _statisticsService.recordTasbihActivity(
      dhikrType: dhikrType,
      count: 1,
      duration: const Duration(seconds: 1),
    );
  }
}

