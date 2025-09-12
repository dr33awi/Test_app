// lib/features/dua/screens/dua_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../services/dua_service.dart';
import '../models/dua_model.dart';
import '../widgets/dua_pattern_painter.dart';
import '../widgets/dua_card_widget.dart';

class DuaDetailsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const DuaDetailsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<DuaDetailsScreen> createState() => _DuaDetailsScreenState();
}

class _DuaDetailsScreenState extends State<DuaDetailsScreen>
    with TickerProviderStateMixin {
  late final DuaService _duaService;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  
  List<Dua> _duas = [];
  bool _isLoading = true;
  double _fontSize = 18.0;

  @override
  void initState() {
    super.initState();
    _duaService = getService<DuaService>();
    _setupAnimations();
    _loadDuas();
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
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

  Future<void> _loadDuas() async {
    try {
      setState(() => _isLoading = true);
      
      _duas = await _duaService.getDuasByCategory(widget.categoryId);
      
      // تحميل حجم الخط المحفوظ
      _fontSize = await _duaService.getSavedFontSize();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showErrorSnackBar('حدث خطأ في تحميل الأدعية');
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
              color: ThemeConstants.primary.withValues(alpha: 0.02),
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
              Icons.auto_awesome,
              color: Colors.white,
              size: 40,
            ),
          ),
          ThemeConstants.space4.h,
          Text(
            'جاري تحميل ${widget.categoryName}...',
            style: context.titleMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_duas.isEmpty) {
      return _buildEmptyState();
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildCustomAppBar(),
        _buildDuasList(),
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
                Icons.menu_book_rounded,
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
                    widget.categoryName,
                    style: context.titleLarge?.copyWith(
                      fontWeight: ThemeConstants.bold,
                    ),
                  ),
                  Text(
                    '${_duas.length} دعاء',
                    style: context.bodySmall?.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // زر حجم الخط
            Container(
              margin: const EdgeInsets.only(left: ThemeConstants.space2),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                child: InkWell(
                  onTap: _showFontSizeDialog,
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(ThemeConstants.space2),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                      border: Border.all(
                        color: context.dividerColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.text_fields_rounded,
                      color: context.textPrimaryColor,
                      size: ThemeConstants.iconMd,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuasList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final dua = _duas[index];
          
          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.space4,
              vertical: ThemeConstants.space2,
            ),
            child: DuaCardWidget(
              dua: dua,
              index: index,
              fontSize: _fontSize,
              onTap: () => _onDuaTap(dua),
              onShare: () => _shareDua(dua),
              onCopy: () => _copyDua(dua),
            ),
          );
        },
        childCount: _duas.length,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.cardColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: context.textSecondaryColor.withValues(alpha: 0.5),
            ),
          ),
          ThemeConstants.space4.h,
          Text(
            'لا توجد أدعية',
            style: context.titleLarge?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          ThemeConstants.space2.h,
          Text(
            'لا توجد أدعية في هذه الفئة حالياً',
            style: context.bodyMedium?.copyWith(
              color: context.textSecondaryColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          ThemeConstants.space4.h,
          ElevatedButton.icon(
            onPressed: _loadDuas,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.text_fields_rounded,
              color: ThemeConstants.primary,
              size: 24,
            ),
            ThemeConstants.space2.w,
            const Text('حجم الخط'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFontSizeOption('صغير', 16.0),
            _buildFontSizeOption('متوسط', 18.0),
            _buildFontSizeOption('كبير', 22.0),
            _buildFontSizeOption('كبير جداً', 26.0),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeOption(String label, double size) {
    final isSelected = _fontSize == size;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();
            setState(() => _fontSize = size);
            
            // حفظ حجم الخط المختار
            await _duaService.saveFontSize(size);
            
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? ThemeConstants.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? ThemeConstants.primary.withValues(alpha: 0.3)
                    : context.dividerColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? ThemeConstants.primary : context.textSecondaryColor,
                ),
                ThemeConstants.space3.w,
                Expanded(
                  child: Text(
                    label,
                    style: context.bodyLarge?.copyWith(
                      fontSize: size,
                      fontWeight: isSelected ? ThemeConstants.semiBold : ThemeConstants.regular,
                      color: isSelected ? ThemeConstants.primary : context.textPrimaryColor,
                    ),
                  ),
                ),
                Text(
                  '${size.toInt()}px',
                  style: context.labelSmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDuaTap(Dua dua) {
    HapticFeedback.lightImpact();
    // فقط تأثير اللمس، بدون تسجيل قراءة
  }

  void _shareDua(Dua dua) {
    HapticFeedback.lightImpact();
    
    final text = '''
${dua.title}

${dua.arabicText}

المصدر: ${dua.source ?? 'غير محدد'}
${dua.reference != null ? 'المرجع: ${dua.reference}' : ''}
    '''.trim();
    
    Clipboard.setData(ClipboardData(text: text));
    context.showSuccessSnackBar('تم نسخ الدعاء للحافظة');
  }

  void _copyDua(Dua dua) {
    HapticFeedback.lightImpact();
    
    Clipboard.setData(ClipboardData(text: dua.arabicText));
    context.showSuccessSnackBar('تم نسخ الدعاء');
  }
}