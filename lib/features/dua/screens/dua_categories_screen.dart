// lib/features/dua/screens/dua_categories_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../services/dua_service.dart';
import '../models/dua_model.dart';
import '../widgets/dua_pattern_painter.dart';
import 'dua_details_screen.dart';

class DuaCategoriesScreen extends StatefulWidget {
  const DuaCategoriesScreen({super.key});

  @override
  State<DuaCategoriesScreen> createState() => _DuaCategoriesScreenState();
}

class _DuaCategoriesScreenState extends State<DuaCategoriesScreen>
    with TickerProviderStateMixin {
  late final DuaService _duaService;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  
  List<DuaCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _duaService = getService<DuaService>();
    _setupAnimations();
    _loadData();
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_backgroundController);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // تحميل البيانات
      _categories = await _duaService.getCategories();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showErrorSnackBar('حدث خطأ في تحميل البيانات');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Stack(
        children: [
          // خلفية مزخرفة متحركة
          _buildAnimatedBackground(),
          
          // المحتوى الرئيسي
          SafeArea(
            child: _isLoading ? _buildLoading() : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: DuaPatternPainter(
              rotation: _backgroundAnimation.value,
              color: ThemeConstants.primary.withValues(alpha: 0.03),
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pan_tool_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          ThemeConstants.space4.h,
          Text(
            'جاري تحميل الأدعية...',
            style: context.titleMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildCustomAppBar(),
        _buildCategoriesGrid(),
        const SliverToBoxAdapter(
          child: SizedBox(height: ThemeConstants.space6),
        ),
      ],
    );
  }

  Widget _buildCustomAppBar() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(ThemeConstants.space4),
        child: Row(
          children: [
            AppBackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
            
            ThemeConstants.space3.w,
            
            Container(
              padding: const EdgeInsets.all(ThemeConstants.space2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
                ),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              ),
              child: const Icon(
                Icons.pan_tool_rounded,
                color: Colors.white,
                size: ThemeConstants.iconMd,
              ),
            ),
            
            ThemeConstants.space3.w,
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الأدعية المأثورة',
                    style: context.titleLarge?.copyWith(
                      fontWeight: ThemeConstants.bold,
                    ),
                  ),
                  Text(
                    'أدعية من الكتاب والسنة',
                    style: context.bodySmall?.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = _categories[index];
            return Container(
              margin: const EdgeInsets.only(bottom: ThemeConstants.space4),
              child: _buildCategoryCard(category),
            );
          },
          childCount: _categories.length,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(DuaCategory category) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
      child: InkWell(
        onTap: () => _onCategoryPressed(category),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: _getCategoryGradient(category.type),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          padding: const EdgeInsets.all(ThemeConstants.space5),
          child: Row(
            children: [
              // الأيقونة
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _getCategoryIcon(category.type),
                  color: Colors.white,
                  size: 32,
                ),
              ),
              
              ThemeConstants.space5.w,
              
              // النصوص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.name,
                      style: context.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: ThemeConstants.bold,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    
                    ThemeConstants.space2.h,
                    
                    Text(
                      category.description,
                      style: context.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getCategoryGradient(DuaType type) {
    switch (type) {
      case DuaType.general:
        return const LinearGradient(
          colors: [Color(0xFF5D7052), Color(0xFF445A3B)], // أخضر زيتي
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DuaType.morning:
        return const LinearGradient(
          colors: [Color(0xFFDAA520), Color(0xFFB8860B)], // ذهبي فاتح كالشروق
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DuaType.evening:
        return const LinearGradient(
          colors: [Color(0xFF8B6F47), Color(0xFF6B5637)], // بني دافئ كالغروب
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DuaType.prayer:
        return const LinearGradient(
          colors: [Color(0xFF7A8B6F), Color(0xFF5D7052)], // أخضر زيتي فاتح
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DuaType.food:
        return const LinearGradient(
          colors: [Color(0xFF8B6F47), Color(0xFF6B5637)], // بني دافئ
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DuaType.travel:
        return const LinearGradient(
          colors: [Color(0xFF7A8B6F), Color(0xFF5D7052)], // أخضر زيتي فاتح
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DuaType.sleep:
        return const LinearGradient(
          colors: [Color(0xFF2D352D), Color(0xFF1A1F1A)], // داكن أنيق للليل
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DuaType.protection:
        return const LinearGradient(
          colors: [Color(0xFF5D7052), Color(0xFF445A3B)], // أخضر زيتي للحماية
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF5D7052), Color(0xFF445A3B)], // أخضر زيتي افتراضي
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getCategoryIcon(DuaType type) {
    switch (type) {
      case DuaType.general:
        return Icons.auto_awesome;
      case DuaType.morning:
        return Icons.wb_sunny_rounded;
      case DuaType.evening:
        return Icons.nights_stay_rounded;
      case DuaType.prayer:
        return Icons.mosque_rounded;
      case DuaType.food:
        return Icons.restaurant_rounded;
      case DuaType.travel:
        return Icons.flight_takeoff_rounded;
      case DuaType.sleep:
        return Icons.bedtime_rounded;
      case DuaType.protection:
        return Icons.shield_rounded;
      default:
        return Icons.auto_awesome;
    }
  }

  void _onCategoryPressed(DuaCategory category) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DuaDetailsScreen(
          categoryId: category.id,
          categoryName: category.name,
        ),
      ),
    );
  }
}