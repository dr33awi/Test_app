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

/// الصفحة الرئيسية لأسماء الله الحسنى (مبسطة)
class AsmaAllahScreen extends StatefulWidget {
  const AsmaAllahScreen({super.key});

  @override
  State<AsmaAllahScreen> createState() => _AsmaAllahScreenState();
}

class _AsmaAllahScreenState extends State<AsmaAllahScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // الخدمة
  late AsmaAllahService _service;
  
  @override
  void initState() {
    super.initState();
    
    // تهيئة الخدمة
    _service = AsmaAllahService(
      storage: getIt<StorageService>(),
    );
    
    // تهيئة الأنيميشن
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    // بدء الأنيميشن
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
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
    return SliverAppBar(
      expandedHeight: 220,
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFF6B46C1),
      foregroundColor: Colors.white,
      elevation: 0,
      
      // العنوان عند التصغير
      title: const Text(
        'أسماء الله الحسنى',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // المحتوى المرن
      flexibleSpace: FlexibleSpaceBar(
        background: AsmaAllahHeader(
          fadeAnimation: _fadeAnimation,
          scaleAnimation: _scaleAnimation,
        ),
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
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: ThemeConstants.space3,
                    ),
                    child: AsmaAllahCard(
                      item: item,
                      onTap: () => _openDetails(item),
                    ),
                  ),
                ),
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