// lib/features/asma_allah/screens/asma_allah_screen.dart - الإصدار المحسن
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
  late AnimationController _listController;
  late Animation<double> _headerAnimation;
  late Animation<double> _listAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedViewType = 'list'; // 'list', 'grid', 'compact'
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _service = AsmaAllahService(storage: getIt<StorageService>());
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text));
    
    // إعداد الأنيميشن
    _headerController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_headerController);
    
    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Curves.easeInOutCubic,
    ));
    
    // بدء أنيميشن القائمة
    _listController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _headerController.dispose();
    _listController.dispose();
    _scrollController.dispose();
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
            // خلفية متدرجة محسنة
            _buildEnhancedBackground(),
            
            // المحتوى الرئيسي
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildEnhancedSliverAppBar(),
                _buildContentSection(),
              ],
            ),
            
            // زر التمرير للأعلى
            _buildScrollToTopButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: context.isDarkMode
              ? [
                  ThemeConstants.darkBackground,
                  ThemeConstants.darkSurface.withValues(alpha: 0.9),
                  ThemeConstants.darkBackground.withValues(alpha: 0.8),
                  ThemeConstants.darkBackground,
                ]
              : [
                  ThemeConstants.lightBackground,
                  ThemeConstants.primary.withValues(alpha: 0.05),
                  ThemeConstants.accent.withValues(alpha: 0.03),
                  ThemeConstants.lightBackground,
                ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  SliverAppBar _buildEnhancedSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: ThemeConstants.tertiary,
      foregroundColor: Colors.white,
      leading: AppBackButton(
        onPressed: () => Navigator.of(context).pop(),
        color: Colors.white,
      ),
      actions: [
        // زر تغيير نوع العرض
        PopupMenuButton<String>(
          icon: const Icon(Icons.view_module_outlined),
          onSelected: (value) => setState(() => _selectedViewType = value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'list',
              child: Row(
                children: [
                  Icon(Icons.view_list),
                  SizedBox(width: 8),
                  Text('عرض قائمة'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'grid',
              child: Row(
                children: [
                  Icon(Icons.grid_view),
                  SizedBox(width: 8),
                  Text('عرض شبكي'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'compact',
              child: Row(
                children: [
                  Icon(Icons.view_compact),
                  SizedBox(width: 8),
                  Text('عرض مضغوط'),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildEnhancedHeader(),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeConstants.tertiary,
            ThemeConstants.tertiaryLight,
            ThemeConstants.tertiary.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // خلفية مزخرفة متحركة
          AnimatedBuilder(
            animation: _headerAnimation,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: _IslamicPatternPainter(
                    rotation: _headerAnimation.value,
                    opacity: 0.06,
                  ),
                ),
              );
            },
          ),
          
          // دوائر تزيينية متعددة
          _buildFloatingCircles(),
          
          // المحتوى الرئيسي
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(ThemeConstants.space4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // الأيقونة والعنوان المحسن (بدون أيقونة)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أسماء الله الحسنى',
                              style: context.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: ThemeConstants.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'تسعة وتسعون اسماً من أحصاها دخل الجنة',
                              style: context.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  ThemeConstants.space4.h,
                  
                  // الآية القرآنية المحسنة
                  Container(
                    padding: const EdgeInsets.all(ThemeConstants.space4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '﴿وَلِلَّهِ الْأَسْمَاءُ الْحُسْنَىٰ فَادْعُوهُ بِهَا﴾',
                          style: context.titleLarge?.copyWith(
                            color: Colors.white,
                            fontFamily: ThemeConstants.fontFamilyQuran,
                            height: 1.8,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        ThemeConstants.space2.h,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeConstants.space3,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                          ),
                          child: Text(
                            'سورة الأعراف - آية ١٨٠',
                            style: context.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: ThemeConstants.medium,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildFloatingCircles() {
    return Stack(
      children: [
        Positioned(
          right: -40,
          top: 60,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
          ),
        ),
        Positioned(
          right: -20,
          top: 120,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
        ),
        Positioned(
          left: -25,
          bottom: 80,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
          ),
        ),
        Positioned(
          left: 30,
          bottom: 120,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.space4),
        child: Column(
          children: [
            // شريط البحث المحسن
            _buildEnhancedSearchBar(),
            
            ThemeConstants.space4.h,
            
            // المحتوى الرئيسي
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        border: Border.all(
          color: context.dividerColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: context.bodyMedium,
        decoration: InputDecoration(
          hintText: 'ابحث في أسماء الله الحسنى أو معانيها...',
          hintStyle: TextStyle(
            color: context.textSecondaryColor.withValues(alpha: 0.7),
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              color: context.textSecondaryColor,
              size: ThemeConstants.iconMd,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.textSecondaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.clear_rounded,
                      color: context.textSecondaryColor,
                      size: 16,
                    ),
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
            vertical: ThemeConstants.space4,
          ),
        ),
      ),
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
        
        return FadeTransition(
          opacity: _listAnimation,
          child: _buildNamesList(list),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            decoration: BoxDecoration(
              color: ThemeConstants.tertiary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: ThemeConstants.tertiary,
              strokeWidth: 3,
            ),
          ),
          ThemeConstants.space4.h,
          Text(
            'جاري تحميل أسماء الله الحسنى...',
            style: context.titleMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          ThemeConstants.space2.h,
          Text(
            'يرجى الانتظار قليلاً',
            style: context.bodySmall?.copyWith(
              color: context.textSecondaryColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space6),
            decoration: BoxDecoration(
              color: context.textSecondaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 60,
              color: context.textSecondaryColor.withValues(alpha: 0.5),
            ),
          ),
          ThemeConstants.space4.h,
          Text(
            'لا توجد نتائج',
            style: context.titleLarge?.copyWith(
              color: context.textSecondaryColor,
              fontWeight: ThemeConstants.bold,
            ),
          ),
          ThemeConstants.space2.h,
          Text(
            'جرب البحث بكلمات أخرى أو امسح شريط البحث',
            style: context.bodyMedium?.copyWith(
              color: context.textSecondaryColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          ThemeConstants.space6.h,
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              HapticFeedback.lightImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.tertiary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConstants.space6,
                vertical: ThemeConstants.space3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('عرض جميع الأسماء'),
          ),
        ],
      ),
    );
  }

  Widget _buildNamesList(List<AsmaAllahModel> list) {
    switch (_selectedViewType) {
      case 'grid':
        return _buildGridView(list);
      case 'compact':
        return _buildCompactView(list);
      default:
        return _buildListView(list);
    }
  }

  Widget _buildListView(List<AsmaAllahModel> list) {
    return Column(
      children: list.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.only(bottom: ThemeConstants.space3),
          child: EnhancedAsmaAllahCard(
            item: item,
            onTap: () => _openDetails(item),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGridView(List<AsmaAllahModel> list) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: ThemeConstants.space3,
        mainAxisSpacing: ThemeConstants.space3,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildGridCard(item);
      },
    );
  }

  Widget _buildGridCard(AsmaAllahModel item) {
    final color = item.getColor();
    
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
      child: InkWell(
        onTap: () => _openDetails(item),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(ThemeConstants.space4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${item.id}',
                    style: context.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: ThemeConstants.bold,
                    ),
                  ),
                ),
              ),
              ThemeConstants.space3.h,
              Text(
                item.name,
                style: context.titleLarge?.copyWith(
                  color: color,
                  fontWeight: ThemeConstants.bold,
                  fontFamily: ThemeConstants.fontFamilyArabic,
                ),
                textAlign: TextAlign.center,
              ),
              ThemeConstants.space2.h,
              Text(
                item.meaning.length > 60 
                    ? '${item.meaning.substring(0, 60)}...'
                    : item.meaning,
                style: context.bodySmall?.copyWith(
                  color: context.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactView(List<AsmaAllahModel> list) {
    return Column(
      children: list.map((item) {
        final color = item.getColor();
        
        return Container(
          margin: const EdgeInsets.only(bottom: ThemeConstants.space2),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
            child: InkWell(
              onTap: () => _openDetails(item),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
              child: Container(
                padding: const EdgeInsets.all(ThemeConstants.space3),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                      ),
                      child: Center(
                        child: Text(
                          '${item.id}',
                          style: context.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: ThemeConstants.bold,
                          ),
                        ),
                      ),
                    ),
                    ThemeConstants.space3.w,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: context.titleMedium?.copyWith(
                              color: color,
                              fontWeight: ThemeConstants.bold,
                              fontFamily: ThemeConstants.fontFamilyArabic,
                            ),
                          ),
                          if (item.reference != null) ...[
                            Text(
                              '﴿${item.reference}﴾',
                              style: context.bodySmall?.copyWith(
                                color: context.textSecondaryColor,
                                fontFamily: ThemeConstants.fontFamilyQuran,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_left_rounded,
                      color: color,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScrollToTopButton() {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        final showButton = _scrollController.hasClients && 
                          _scrollController.offset > 200;
        
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          right: ThemeConstants.space4,
          bottom: showButton ? ThemeConstants.space4 : -80,
          child: FloatingActionButton(
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
              HapticFeedback.lightImpact();
            },
            backgroundColor: ThemeConstants.tertiary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.keyboard_arrow_up_rounded),
          ),
        );
      },
    );
  }

  void _openDetails(AsmaAllahModel item) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UnifiedAsmaAllahDetailsScreen(
          item: item,
          service: _service,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

// ============================================================================
// رسام الزخارف الإسلامية المحسن
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
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    
    // رسم نمط هندسي معقد
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi) / 6;
      final radius1 = 35.0;
      final radius2 = 65.0;
      final radius3 = 95.0;
      
      final start1 = Offset(
        math.cos(angle) * radius1,
        math.sin(angle) * radius1,
      );
      final end1 = Offset(
        math.cos(angle) * radius2,
        math.sin(angle) * radius2,
      );
      final end2 = Offset(
        math.cos(angle) * radius3,
        math.sin(angle) * radius3,
      );
      
      canvas.drawLine(start1, end1, paint);
      
      if (i % 2 == 0) {
        canvas.drawLine(end1, end2, paint..strokeWidth = 1.0);
      }
    }
    
    // دوائر متداخلة
    canvas.drawCircle(Offset.zero, 30, paint..strokeWidth = 1.5);
    canvas.drawCircle(Offset.zero, 50, paint..strokeWidth = 1.0);
    canvas.drawCircle(Offset.zero, 80, paint..strokeWidth = 0.8);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IslamicPatternPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}