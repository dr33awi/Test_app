// lib/features/asma_allah/screens/asma_allah_screen.dart
import 'package:athkar_app/core/infrastructure/services/storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:athkar_app/app/themes/app_theme.dart';
import 'package:athkar_app/app/di/service_locator.dart';
import '../services/asma_allah_service.dart';
import '../models/asma_allah_model.dart';
import '../widgets/asma_allah_widgets.dart';
import 'package:athkar_app/features/asma_allah/screens/asma_detail_screen.dart';

/// الصفحة الرئيسية لأسماء الله الحسنى (بدون أنيميشن)
class AsmaAllahScreen extends StatefulWidget {
  const AsmaAllahScreen({super.key});

  @override
  State<AsmaAllahScreen> createState() => _AsmaAllahScreenState();
}

class _AsmaAllahScreenState extends State<AsmaAllahScreen> {
  // الخدمة
  late AsmaAllahService _service;
  
  @override
  void initState() {
    super.initState();
    
    // تهيئة الخدمة
    _service = AsmaAllahService(
      storage: getIt<StorageService>(),
    );
  }
  
  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _service,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: CustomScrollView(
          slivers: [
            // الهيدر الجميل
            _buildSliverAppBar(),
            
            // المحتوى الرئيسي - قائمة فقط
            _buildContent(),
          ],
        ),
      ),
    );
  }
  
  /// بناء شريط التطبيق
  Widget _buildSliverAppBar() {
    return const SliverAppBar(
      expandedHeight: 220,
      floating: true,
      pinned: true,
      backgroundColor: Color(0xFF6B46C1),
      foregroundColor: Colors.white,
      elevation: 0,
      
      // العنوان عند التصغير
      title: Text(
        'أسماء الله الحسنى',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // المحتوى المرن
      flexibleSpace: FlexibleSpaceBar(
        background: AsmaAllahHeader(),
      ),
    );
  }
  
  /// بناء المحتوى
  Widget _buildContent() {
    return Consumer<AsmaAllahService>(
      builder: (context, service, _) {
        // التحقق من التحميل
        if (service.isLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: AppLoading(
                type: LoadingType.circular,
                size: LoadingSize.large,
                color: Color(0xFF6B46C1),
              ),
            ),
          );
        }
        
        // الحصول على القائمة
        final list = service.asmaAllahList;
        
        // التحقق من وجود نتائج
        if (list.isEmpty) {
          return SliverFillRemaining(
            child: AppEmptyState.noData(
              message: 'لا توجد بيانات للعرض',
            ),
          );
        }
        
        // عرض القائمة
        return _buildListView(list);
      },
    );
  }
  
  /// بناء عرض القائمة
  Widget _buildListView(List<AsmaAllahModel> list) {
    return SliverPadding(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = list[index];
            return Padding(
              padding: const EdgeInsets.only(
                bottom: ThemeConstants.space3,
              ),
              child: AsmaAllahCard(
                item: item,
                onTap: () => _openDetails(item),
              ),
            );
          },
          childCount: list.length,
        ),
      ),
    );
  }
  
  /// فتح صفحة التفاصيل
  void _openDetails(AsmaAllahModel item) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AsmaAllahDetailsScreen(
          item: item,
          service: _service,
        ),
      ),
    );
  }
}