// lib/features/asma_allah/screens/asma_detail_screen.dart - محسن ومتناسق مع الشرح المفصل
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
      body: SafeArea(
        child: Column(
          children: [
            // شريط التطبيق المحسن (متناسق مع صفحة الصلوات)
            _buildEnhancedAppBar(),
            
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
    );
  }

  Widget _buildEnhancedAppBar() {
    final total = widget.service.asmaAllahList.length;
    final color = _currentItem.getColor();
    
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Row(
        children: [
          // زر الرجوع (متناسق مع صفحة الصلوات)
          AppBackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          ThemeConstants.space3.w,
          
          // أيقونة مميزة (نفس ستايل صفحة الصلوات)
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '${_currentItem.id}',
              style: context.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: ThemeConstants.bold,
              ),
            ),
          ),
          
          ThemeConstants.space3.w,
          
          // معلومات الاسم الحالي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentItem.name,
                  style: context.titleLarge?.copyWith(
                    fontWeight: ThemeConstants.bold,
                    color: color,
                    fontFamily: ThemeConstants.fontFamilyArabic,
                  ),
                ),
                Text(
                  '${_currentIndex + 1} من $total',
                  style: context.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // أزرار الإجراءات (نفس ستايل صفحة الصلوات)
          _buildActionButton(
            icon: Icons.copy_rounded,
            onTap: () => _copyContent(_currentItem),
          ),
          
          _buildActionButton(
            icon: Icons.share_rounded,
            onTap: () => _shareContent(_currentItem),
            isSecondary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: ThemeConstants.space2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(ThemeConstants.space2),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              border: Border.all(
                color: context.dividerColor.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isSecondary ? context.textSecondaryColor : _currentItem.getColor(),
              size: ThemeConstants.iconMd,
            ),
          ),
        ),
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
          
          // بطاقة الشرح المفصل مع الآيات المميزة
          _buildEnhancedExplanationCard(item),
          
          // مساحة إضافية في الأسفل
          ThemeConstants.space8.h,
        ],
      ),
    );
  }

  Widget _buildMainNameCard(AsmaAllahModel item) {
    final color = item.getColor();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          item.name,
          style: context.displayMedium?.copyWith(
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
                'المعنى',
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
            height: 2,
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [item.getColor(), Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          
          ThemeConstants.space4.h,
          
          // نص المعنى المختصر
          Text(
            item.meaning,
            style: context.bodyLarge?.copyWith(
              height: 2.0,
              fontSize: 16,
              color: context.textPrimaryColor,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedExplanationCard(AsmaAllahModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.space5),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radius2xl),
        border: Border.all(
          color: item.getColor().withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: item.getColor().withValues(alpha: 0.05),
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
                  color: item.getColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: item.getColor(),
                  size: ThemeConstants.iconMd,
                ),
              ),
              ThemeConstants.space3.w,
              Text(
                'الشرح والتفسير',
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
            height: 2,
            width: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [item.getColor(), Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          
          ThemeConstants.space4.h,
          
          // نص الشرح المفصل مع الآيات المميزة
          _buildFormattedExplanationText(item),
        ],
      ),
    );
  }

  Widget _buildFormattedExplanationText(AsmaAllahModel item) {
    return RichText(
      textAlign: TextAlign.justify,
      text: _buildFormattedTextSpan(item.explanation, context, item.getColor()),
    );
  }

  TextSpan _buildFormattedTextSpan(String text, BuildContext context, Color itemColor) {
    final List<TextSpan> spans = [];
    
    // البحث عن الآيات بين ﴿ و ﴾
    final RegExp ayahPattern = RegExp(r'﴿([^﴾]+)﴾');
    int lastIndex = 0;
    
    for (final match in ayahPattern.allMatches(text)) {
      // إضافة النص العادي قبل الآية
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: context.bodyLarge?.copyWith(
            height: 2.2,
            fontSize: 17,
            color: context.textPrimaryColor,
            letterSpacing: 0.3,
          ),
        ));
      }
      
      // إضافة الآية مميزة
      spans.add(TextSpan(
        text: match.group(0), // النص الكامل مع ﴿ و ﴾
        style: context.titleMedium?.copyWith(
          color: ThemeConstants.tertiary,
          fontFamily: ThemeConstants.fontFamilyQuran,
          fontSize: 18,
          fontWeight: ThemeConstants.medium,
          height: 2.0,
          backgroundColor: ThemeConstants.tertiary.withValues(alpha: 0.08),
        ),
      ));
      
      lastIndex = match.end;
    }
    
    // إضافة باقي النص بعد آخر آية
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: context.bodyLarge?.copyWith(
          height: 2.2,
          fontSize: 17,
          color: context.textPrimaryColor,
          letterSpacing: 0.3,
        ),
      ));
    }
    
    // إذا لم توجد آيات، عرض النص كاملاً بالتنسيق العادي
    if (spans.isEmpty) {
      spans.add(TextSpan(
        text: text,
        style: context.bodyLarge?.copyWith(
          height: 2.2,
          fontSize: 17,
          color: context.textPrimaryColor,
          letterSpacing: 0.3,
        ),
      ));
    }
    
    return TextSpan(children: spans);
  }

  Widget _buildReferenceCard(AsmaAllahModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.space5),
      decoration: BoxDecoration(
        color: ThemeConstants.tertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ThemeConstants.radius2xl),
        border: Border.all(
          color: ThemeConstants.tertiary.withValues(alpha: 0.2),
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
                  color: ThemeConstants.tertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: ThemeConstants.tertiary,
                  size: ThemeConstants.iconMd,
                ),
              ),
              ThemeConstants.space3.w,
              Text(
                'من القرآن الكريم',
                style: context.titleLarge?.copyWith(
                  fontWeight: ThemeConstants.bold,
                  color: ThemeConstants.tertiary,
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
                color: ThemeConstants.tertiary.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeConstants.tertiary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '﴿${item.reference}﴾',
              style: context.titleLarge?.copyWith(
                color: ThemeConstants.tertiary,
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

  Widget _buildBottomNavigationBar() {
    final canPrev = _currentIndex > 0;
    final canNext = _currentIndex < widget.service.asmaAllahList.length - 1;
    final color = _currentItem.getColor();
    
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر السابق
          Expanded(
            child: ElevatedButton.icon(
              onPressed: canPrev ? _goToPrevious : null,
              icon: const Icon(Icons.chevron_left_rounded),
              label: const Text('السابق'),
              style: ElevatedButton.styleFrom(
                backgroundColor: canPrev ? context.surfaceColor : context.surfaceColor.withOpacity(0.5),
                foregroundColor: canPrev 
                    ? context.textPrimaryColor 
                    : context.textSecondaryColor.withOpacity(0.5),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: ThemeConstants.space3),
                side: BorderSide(
                  color: context.dividerColor.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                ),
              ),
            ),
          ),
          
          ThemeConstants.space3.w,
          
          // مؤشر الصفحة
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.space3,
              vertical: ThemeConstants.space2,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              '${_currentIndex + 1} / ${widget.service.asmaAllahList.length}',
              style: context.labelMedium?.copyWith(
                color: color,
                fontWeight: ThemeConstants.bold,
              ),
            ),
          ),
          
          ThemeConstants.space3.w,
          
          // زر التالي
          Expanded(
            child: ElevatedButton.icon(
              onPressed: canNext ? _goToNext : null,
              icon: const Icon(Icons.chevron_right_rounded),
              label: const Text('التالي'),
              style: ElevatedButton.styleFrom(
                backgroundColor: canNext ? color : context.surfaceColor.withOpacity(0.5),
                foregroundColor: canNext 
                    ? Colors.white 
                    : context.textSecondaryColor.withOpacity(0.5),
                elevation: canNext ? 2 : 0,
                padding: const EdgeInsets.symmetric(vertical: ThemeConstants.space3),
                side: canNext 
                    ? null
                    : BorderSide(
                        color: context.dividerColor.withValues(alpha: 0.3),
                      ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                ),
                shadowColor: canNext ? color.withValues(alpha: 0.3) : null,
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

الشرح والتفسير: ${item.explanation}

من تطبيق أذكاري - أسماء الله الحسنى''';

    Clipboard.setData(ClipboardData(text: content));
    
    context.showSuccessSnackBar('تم نسخ المحتوى بنجاح');
    HapticFeedback.mediumImpact();
  }

  void _shareContent(AsmaAllahModel item) {
    final content = '''${item.name}

الشرح والتفسير: ${item.explanation}

من تطبيق أذكاري - أسماء الله الحسنى''';

    Share.share(
      content,
      subject: 'أسماء الله الحسنى - ${item.name}',
    );
    
    HapticFeedback.lightImpact();
  }
}
