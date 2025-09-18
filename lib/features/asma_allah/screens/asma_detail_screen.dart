// lib/features/asma_allah/screens/unified_asma_detail_screen.dart
import 'dart:ui';
import 'package:athkar_app/app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/asma_allah_model.dart';
import '../services/asma_allah_service.dart';
import '../extensions/asma_allah_extensions.dart';

class UnifiedAsmaAllahDetailsScreen extends StatefulWidget {
  final AsmaAllahModel item;
  final AsmaAllahService service;

  const UnifiedAsmaAllahDetailsScreen({
    super.key,
    required this.item,
    required this.service,
  });

  @override
  State<UnifiedAsmaAllahDetailsScreen> createState() => 
      _UnifiedAsmaAllahDetailsScreenState();
}

class _UnifiedAsmaAllahDetailsScreenState 
    extends State<UnifiedAsmaAllahDetailsScreen> {
  
  late AsmaAllahModel _currentItem;
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    
    final list = widget.service.asmaAllahList;
    final initialIndex = list.indexWhere((e) => e.id == widget.item.id);
    _currentIndex = initialIndex >= 0 ? initialIndex : 0;
    _currentItem = list[_currentIndex];

    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Stack(
        children: [
          // خلفية متدرجة موحدة
          _buildUnifiedBackground(),
          
          // المحتوى الرئيسي
          SafeArea(
            child: Column(
              children: [
                // شريط التطبيق المخصص
                _buildUnifiedAppBar(),
                
                // المحتوى الرئيسي مع PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.service.asmaAllahList.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                        _currentItem = widget.service.asmaAllahList[index];
                      });
                      HapticFeedback.selectionClick();
                    },
                    itemBuilder: (_, index) {
                      final item = widget.service.asmaAllahList[index];
                      return _buildContentPage(item);
                    },
                  ),
                ),
                
                // شريط التنقل السفلي
                _buildBottomNavigationBar(),
              ],
            ),
          ),
        ],
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
                  ThemeConstants.darkSurface.withValues(alpha: 0.9),
                  ThemeConstants.darkBackground,
                ]
              : [
                  ThemeConstants.lightBackground,
                  _currentItem.getColor().withValues(alpha: 0.05),
                  ThemeConstants.lightBackground,
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildUnifiedAppBar() {
    final total = widget.service.asmaAllahList.length;
    
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Row(
        children: [
          // زر الرجوع الموحد
          AppBackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          ThemeConstants.space3.w,
          
          // معلومات الاسم الحالي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اسم الله الحسنى',
                  style: context.labelMedium?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                Text(
                  '${_currentItem.id} من $total',
                  style: context.titleMedium?.copyWith(
                    fontWeight: ThemeConstants.bold,
                    color: _currentItem.getColor(),
                  ),
                ),
              ],
            ),
          ),
          
          // مؤشر التقدم الدائري
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: (_currentIndex + 1) / total,
                  backgroundColor: context.dividerColor.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation(_currentItem.getColor()),
                  strokeWidth: 3,
                ),
              ),
              Text(
                '${_currentIndex + 1}',
                style: context.labelSmall?.copyWith(
                  fontWeight: ThemeConstants.bold,
                  color: _currentItem.getColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentPage(AsmaAllahModel item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // بطاقة الاسم الرئيسية
          _buildMainNameCard(item),
          
          ThemeConstants.space4.h,
          
          // بطاقة المعنى
          _buildMeaningCard(item),
          
          // بطاقة المرجع القرآني
          if (item.reference != null) ...[
            ThemeConstants.space4.h,
            _buildReferenceCard(item),
          ],
          
          ThemeConstants.space4.h,
          
          // بطاقة الإجراءات
          _buildActionsCard(item),
          
          // مساحة إضافية في الأسفل
          ThemeConstants.space12.h,
        ],
      ),
    );
  }

  Widget _buildMainNameCard(AsmaAllahModel item) {
    final color = item.getColor();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.space6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radius2xl),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // رقم الاسم
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.space4,
              vertical: ThemeConstants.space2,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              'الاسم ${item.id}',
              style: context.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: ThemeConstants.bold,
              ),
            ),
          ),
          
          ThemeConstants.space4.h,
          
          // اسم الله بخط كبير
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              item.name,
              style: context.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: ThemeConstants.bold,
                fontFamily: ThemeConstants.fontFamilyArabic,
                height: 1,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningCard(AsmaAllahModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.space5),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radius2xl),
        border: Border.all(
          color: context.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeConstants.space2),
                decoration: BoxDecoration(
                  color: item.getColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: item.getColor(),
                  size: ThemeConstants.iconMd,
                ),
              ),
              ThemeConstants.space3.w,
              Text(
                'معنى الاسم',
                style: context.titleLarge?.copyWith(
                  fontWeight: ThemeConstants.bold,
                  color: item.getColor(),
                ),
              ),
            ],
          ),
          
          ThemeConstants.space4.h,
          
          // خط فاصل
          Container(
            height: 1,
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [item.getColor(), Colors.transparent],
              ),
            ),
          ),
          
          ThemeConstants.space4.h,
          
          // نص المعنى
          Text(
            item.meaning,
            style: context.bodyLarge?.copyWith(
              height: 2.0,
              fontSize: 17,
              color: context.textPrimaryColor,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceCard(AsmaAllahModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.space5),
      decoration: BoxDecoration(
        color: ThemeConstants.tertiary.withValues(alpha: 0.1), // استخدام tertiary
        borderRadius: BorderRadius.circular(ThemeConstants.radius2xl),
        border: Border.all(
          color: ThemeConstants.tertiary.withValues(alpha: 0.2), // استخدام tertiary
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeConstants.space2),
                decoration: BoxDecoration(
                  color: ThemeConstants.tertiary.withValues(alpha: 0.2), // استخدام tertiary
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: ThemeConstants.tertiary, // استخدام tertiary
                  size: ThemeConstants.iconMd,
                ),
              ),
              ThemeConstants.space3.w,
              Text(
                'من القرآن الكريم',
                style: context.titleLarge?.copyWith(
                  fontWeight: ThemeConstants.bold,
                  color: ThemeConstants.tertiary, // استخدام tertiary
                ),
              ),
            ],
          ),
          
          ThemeConstants.space4.h,
          
          // الآية القرآنية
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ThemeConstants.space4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
              border: Border.all(
                color: ThemeConstants.tertiary.withValues(alpha: 0.3), // استخدام tertiary
                width: 1,
              ),
            ),
            child: Text(
              '﴿${item.reference}﴾',
              style: context.titleLarge?.copyWith(
                color: ThemeConstants.tertiary, // استخدام tertiary
                fontFamily: ThemeConstants.fontFamilyQuran,
                height: 2.0,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(AsmaAllahModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.space4),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        border: Border.all(
          color: context.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإجراءات',
            style: context.titleMedium?.copyWith(
              fontWeight: ThemeConstants.bold,
            ),
          ),
          
          ThemeConstants.space3.h,
          
          // أزرار الإجراءات
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.copy_rounded,
                  label: 'نسخ النص',
                  color: ThemeConstants.primary, // من الألوان الثلاث الأساسية
                  onPressed: () => _copyContent(item),
                ),
              ),
              ThemeConstants.space3.w,
              Expanded(
                child: _buildActionButton(
                  icon: Icons.share_rounded,
                  label: 'مشاركة',
                  color: ThemeConstants.accent, // من الألوان الثلاث الأساسية
                  onPressed: () => _shareContent(item),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: ThemeConstants.iconSm),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.space3,
          vertical: ThemeConstants.space3,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          side: BorderSide(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final canPrev = _currentIndex > 0;
    final canNext = _currentIndex < widget.service.asmaAllahList.length - 1;
    
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(
          top: BorderSide(
            color: context.dividerColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // زر السابق
          Expanded(
            child: ElevatedButton.icon(
              onPressed: canPrev ? _goToPrevious : null,
              icon: const Icon(Icons.chevron_right_rounded),
              label: const Text('السابق'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.surfaceColor,
                foregroundColor: canPrev 
                    ? context.textPrimaryColor 
                    : context.textSecondaryColor,
                elevation: 0,
                side: BorderSide(
                  color: context.dividerColor.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          
          ThemeConstants.space3.w,
          
          // زر التالي
          Expanded(
            child: ElevatedButton.icon(
              onPressed: canNext ? _goToNext : null,
              icon: const Icon(Icons.chevron_left_rounded),
              label: const Text('التالي'),
              style: ElevatedButton.styleFrom(
                backgroundColor: canNext ? _currentItem.getColor() : context.surfaceColor,
                foregroundColor: canNext 
                    ? Colors.white 
                    : context.textSecondaryColor,
                elevation: 0,
                side: canNext 
                    ? null
                    : BorderSide(
                        color: context.dividerColor.withValues(alpha: 0.3),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.service.asmaAllahList.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _copyContent(AsmaAllahModel item) {
    final content = '''${item.name}

المعنى: ${item.meaning}

${item.reference != null ? 'من القرآن الكريم: ﴿${item.reference}﴾\n\n' : ''}من تطبيق أذكاري - أسماء الله الحسنى''';

    Clipboard.setData(ClipboardData(text: content));
    
    context.showSuccessSnackBar('تم نسخ المحتوى بنجاح');
    HapticFeedback.mediumImpact();
  }

  void _shareContent(AsmaAllahModel item) {
    final content = '''${item.name}

المعنى: ${item.meaning}

${item.reference != null ? 'من القرآن الكريم: ﴿${item.reference}﴾\n\n' : ''}من تطبيق أذكاري - أسماء الله الحسنى''';

    Share.share(
      content,
      subject: 'أسماء الله الحسنى - ${item.name}',
    );
    
    HapticFeedback.lightImpact();
  }
}