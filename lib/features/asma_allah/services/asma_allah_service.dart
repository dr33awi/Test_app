// lib/features/asma_allah/services/asma_allah_service.dart
import '../../../core/infrastructure/services/base_service.dart';
import '../../../core/infrastructure/services/logging/logger_service.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../models/asma_allah_model.dart';
import '../data/asma_allah_data.dart';

/// خدمة إدارة أسماء الله الحسنى
class AsmaAllahService extends BaseNotifierService {
  // قائمة الأسماء
  List<AsmaAllahModel> _asmaAllahList = [];
  List<AsmaAllahModel> get asmaAllahList => _asmaAllahList;
  
  // حالة التحميل
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  @override
  String get serviceName => 'AsmaAllah';
  
  AsmaAllahService({
    required LoggerService logger,
    required StorageService storage,
  }) : super(logger: logger, storage: storage);
  
  @override
  void onInitialize() {
    super.onInitialize();
    loadAsmaAllah();
  }
  
  /// تحميل أسماء الله الحسنى
  Future<void> loadAsmaAllah() async {
    try {
      _setLoading(true);
      
      // تحميل البيانات من الملف المحلي
      _asmaAllahList = AsmaAllahData.getAllNames()
        .map((data) => AsmaAllahModel.fromJson(data))
        .toList();
      
      logInfo('تم تحميل ${_asmaAllahList.length} من أسماء الله الحسنى');
      
    } catch (e) {
      logError('خطأ في تحميل أسماء الله الحسنى', e);
    } finally {
      _setLoading(false);
    }
  }
  
  /// الحصول على اسم بواسطة المعرف
  AsmaAllahModel? getNameById(int id) {
    try {
      return _asmaAllahList.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
  
  /// تعيين حالة التحميل
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}