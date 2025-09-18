// lib/features/asma_allah/screens/asma_allah_screen.dart - المُصححة
import 'package:athkar_app/app/di/service_locator.dart';
import 'package:athkar_app/app/themes/app_theme.dart';
import 'package:athkar_app/core/infrastructure/services/storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../models/asma_allah_model.dart';
import '../services/asma_allah_service.dart';
import '../widgets/asma_allah_widgets.dart';
import '../extensions/asma_allah_extensions.dart';
import 'asma_detail_screen.dart';

class AsmaAllahScreen extends StatefulWidget {
  const AsmaAllahScreen({super.key});
  @override
  State<AsmaAllahScreen> createState() => _AsmaAllahScreenState();
}

class _AsmaAllahScreenState extends State<AsmaAllahScreen>
    with TickerProviderStateMixin {
  late AsmaAllahService _service;
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _service = AsmaAllahService(storage: getIt<StorageService>());
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text));
    
    // إعداد الأنيميشن
    _headerController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_headerController);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _headerController.dispose();
    _service.dispose();
    super.dispose();
  }

  List<AsmaAllahModel> _getFilteredList() {
    var list = _service.asmaAllahList;
    if (_searchQuery.isNotEmpty) {
      list = list.where((item) => 
        item.name.contains(_searchQuery) || 
        item.meaning.contains(_searchQuery)
      ).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _service,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: Stack(
          children: [
            // خلفية متدرجة موحدة
            _buildUnifiedBackground(),
            
            // المحتوى الرئيسي
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildUnifiedSliverAppBar(),
                _buildContentSection(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: context.isDarkMode
              ? [
                  ThemeConstants.darkBackground,
                  ThemeConstants.darkSurface.withOpacity(0.8),
                  ThemeConstants.darkBackground,
                ]
              : [
                  ThemeConstants.lightBackground,
                  ThemeConstants.primarySoft.withOpacity(0.1),
                  ThemeConstants.lightBackground,
                ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
    );
  }

  SliverAppBar _buildUnifiedSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: ThemeConstants.primary,
      foregroundColor: Colors.white,
      leading: AppBackButton(
        onPressed: () => Navigator.of(context).pop(),
        color: Colors.white,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _buildUnifiedHeader(),
      ),
    );
  }

  Widget _buildUnifiedHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // خلفية مزخرفة خفيفة
          AnimatedBuilder(
            animation: _headerAnimation,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: _IslamicPatternPainter(
                    rotation: _headerAnimation.value,
                    opacity: 0.08,
                  ),
                ),
              );
            },
          ),
          
          // دوائر تزيينية
          _buildDecorativeCircles(),
          
          // المحتوى الرئيسي
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(ThemeConstants.space4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // الأيقونة والعنوان
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(ThemeConstants.space3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.star_purple500_outlined,
                          color: Colors.white,
                          size: ThemeConstants.iconLg,
                        ),
                      ),
                      
                      ThemeConstants.space3.w,
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أسماء الله الحسنى',
                              style: context.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: ThemeConstants.bold,
                              ),
                            ),
                            Text(
                              'تسعة وتسعون اسماً من أحصاها دخل الجنة',
                              style: context.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  ThemeConstants.space3.h,
                  
                  // الآية القرآنية
                  Container(
                    padding: const EdgeInsets.all(ThemeConstants.space3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '﴿وَلِلَّهِ الْأَسْمَاءُ الْحُسْنَىٰ فَادْعُوهُ بِهَا﴾',
                      style: context.titleMedium?.copyWith(
                        color: Colors.white,
                        fontFamily: ThemeConstants.fontFamilyQuran,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeCircles() {
    return Stack(
      children: [
        Positioned(
          right: -50,
          top: 80,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
        ),
        Positioned(
          left: -30,
          bottom: 60,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.space4),
        child: Column(
          children: [
            // شريط البحث والفلتر
            _buildSearchAndFilterSection(),
            
            ThemeConstants.space4.h,
            
            // المحتوى الرئيسي
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Column(
      children: [
        // شريط البحث الموحد
        Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
            border: Border.all(
              color: context.dividerColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: context.bodyMedium,
            decoration: InputDecoration(
              hintText: 'ابحث عن اسم أو معنى...',
              hintStyle: TextStyle(
                color: context.textSecondaryColor.withOpacity(0.7),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: context.textSecondaryColor,
                size: ThemeConstants.iconMd,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: context.textSecondaryColor,
                        size: ThemeConstants.iconMd,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        HapticFeedback.lightImpact();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: ThemeConstants.space4,
                vertical: ThemeConstants.space3,
              ),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildMainContent() {
    return Consumer<AsmaAllahService>(
      builder: (_, service, __) {
        if (service.isLoading) {
          return _buildLoadingState();
        }
        
        final list = _getFilteredList();
        if (list.isEmpty) {
          return _buildEmptyState();
        }
        
        return _buildNamesList(list);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: ThemeConstants.primary,
              strokeWidth: 2,
            ),
            SizedBox(height: ThemeConstants.space3),
            Text('جاري تحميل الأسماء الحسنى...'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: context.textSecondaryColor.withOpacity(0.5),
          ),
          ThemeConstants.space3.h,
          Text(
            'لا توجد نتائج',
            style: context.titleLarge?.copyWith(
              color: context.textSecondaryColor,
              fontWeight: ThemeConstants.bold,
            ),
          ),
          ThemeConstants.space2.h,
          Text(
            'جرب البحث بكلمات أخرى',
            style: context.bodyMedium?.copyWith(
              color: context.textSecondaryColor.withOpacity(0.7),
            ),
          ),
          ThemeConstants.space4.h,
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('عرض جميع الأسماء'),
          ),
        ],
      ),
    );
  }

  Widget _buildNamesList(List<AsmaAllahModel> list) {
    return Column(
      children: list.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: ThemeConstants.space3),
          child: EnhancedAsmaAllahCard( // استخدم EnhancedAsmaAllahCard بدلاً من UnifiedAsmaAllahCard
            item: item,
            onTap: () => _openDetails(item),
          ),
        );
      }).toList(),
    );
  }

  void _openDetails(AsmaAllahModel item) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UnifiedAsmaAllahDetailsScreen( // هذا الاسم الصحيح
          item: item,
          service: _service,
        ),
      ),
    );
  }
}

// ============================================================================
// رسام الزخارف الإسلامية المبسط
// ============================================================================
class _IslamicPatternPainter extends CustomPainter {
  final double rotation;
  final double opacity;

  _IslamicPatternPainter({
    required this.rotation,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    
    // رسم نمط هندسي بسيط
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi) / 4;
      final start = Offset(
        math.cos(angle) * 30,
        math.sin(angle) * 30,
      );
      final end = Offset(
        math.cos(angle) * 80,
        math.sin(angle) * 80,
      );
      
      canvas.drawLine(start, end, paint);
    }
    
    // دائرة مركزية
    canvas.drawCircle(Offset.zero, 25, paint);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}