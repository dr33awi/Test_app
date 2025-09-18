// lib/features/asma_allah/screens/asma_allah_details_screen.dart
import 'package:athkar_app/app/themes/widgets/core/islamic_pattern_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:athkar_app/app/themes/app_theme.dart';
import '../models/asma_allah_model.dart';
import '../services/asma_allah_service.dart';

/// صفحة تفاصيل اسم من أسماء الله الحسنى (بدون أنيميشن)
class AsmaAllahDetailsScreen extends StatefulWidget {
  final AsmaAllahModel item;
  final AsmaAllahService service;
  
  const AsmaAllahDetailsScreen({
    super.key,
    required this.item,
    required this.service,
  });
  
  @override
  State<AsmaAllahDetailsScreen> createState() => _AsmaAllahDetailsScreenState();
}

class _AsmaAllahDetailsScreenState extends State<AsmaAllahDetailsScreen> {
  late AsmaAllahModel _currentItem;
  late PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    
    _currentItem = widget.item;
    _pageController = PageController(
      initialPage: widget.item.id - 1,
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final color = _currentItem.getColor();
    
    return Scaffold(
      backgroundColor: color,
      body: Stack(
        children: [
          // الخلفية بنمط إسلامي
          Positioned.fill(
            child: CustomPaint(
              painter: IslamicPatternPainter(
                rotation: 0,
                color: Colors.white,
                patternType: PatternType.geometric,
                opacity: 0.08,
              ),
            ),
          ),
          
          // المحتوى
          SafeArea(
            child: Column(
              children: [
                // الهيدر
                _buildHeader(),
                
                // المحتوى الرئيسي
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentItem = widget.service.asmaAllahList[index];
                      });
                    },
                    itemCount: widget.service.asmaAllahList.length,
                    itemBuilder: (context, index) {
                      return _buildContent(widget.service.asmaAllahList[index]);
                    },
                  ),
                ),
                
                // الفوتر مع الإجراءات
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الرجوع
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.white,
          ),
          
          // الرقم
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.space4,
              vertical: ThemeConstants.space2,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
            ),
            child: Text(
              'الاسم ${_currentItem.id} من 99',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // مساحة فارغة
          const SizedBox(width: 48),
        ],
      ),
    );
  }
  
  Widget _buildContent(AsmaAllahModel item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConstants.space5),
      child: Column(
        children: [
          // الأيقونة
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.getIcon(),
              size: 50,
              color: Colors.white,
            ),
          ),
          
          ThemeConstants.space5.h,
          
          // الاسم الكبير
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
              height: 1.2,
            ),
          ),
          
          ThemeConstants.space5.h,
          
          // بطاقة المعنى
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ThemeConstants.space5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // عنوان المعنى
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.book,
                      color: item.getColor(),
                      size: 20,
                    ),
                    ThemeConstants.space2.w,
                    Text(
                      'المعنى',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: item.getColor(),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                
                ThemeConstants.space4.h,
                const Divider(),
                ThemeConstants.space4.h,
                
                // نص المعنى
                Text(
                  item.meaning,
                  style: const TextStyle(
                    fontSize: 18,
                    color: ThemeConstants.lightTextPrimary,
                    height: 1.8,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // المرجع إن وجد
          if (item.reference != null) ...[
            ThemeConstants.space4.h,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ThemeConstants.space4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: item.getColor(),
                        size: 20,
                      ),
                      ThemeConstants.space2.w,
                      Text(
                        'من القرآن الكريم',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: item.getColor(),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  
                  ThemeConstants.space3.h,
                  
                  Text(
                    '﴿${item.reference}﴾',
                    style: const TextStyle(
                      fontSize: 20,
                      color: ThemeConstants.lightTextPrimary,
                      fontFamily: 'Amiri',
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(ThemeConstants.radiusXl),
          topRight: Radius.circular(ThemeConstants.radiusXl),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // زر النسخ
          _ActionButton(
            icon: Icons.copy,
            label: 'نسخ',
            onPressed: () {
              HapticFeedback.lightImpact();
              _copyToClipboard();
            },
          ),
          
          // زر المشاركة
          _ActionButton(
            icon: Icons.share,
            label: 'مشاركة',
            onPressed: () {
              HapticFeedback.lightImpact();
              _share();
            },
          ),
          
          // زر السابق
          _ActionButton(
            icon: Icons.arrow_back,
            label: 'السابق',
            onPressed: _currentItem.id > 1
                ? () {
                    HapticFeedback.lightImpact();
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
          ),
          
          // زر التالي
          _ActionButton(
            icon: Icons.arrow_forward,
            label: 'التالي',
            onPressed: _currentItem.id < 99
                ? () {
                    HapticFeedback.lightImpact();
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
  
  void _copyToClipboard() {
    final text = '''${_currentItem.name}
    
المعنى: ${_currentItem.meaning}
${_currentItem.reference != null ? '\nالآية: ${_currentItem.reference}' : ''}''';
    
    Clipboard.setData(ClipboardData(text: text));
    
    context.showSuccessSnackBar('تم النسخ إلى الحافظة');
  }
  
  void _share() {
    final text = '''${_currentItem.name}
    
المعنى: ${_currentItem.meaning}
${_currentItem.reference != null ? '\nالآية: ${_currentItem.reference}' : ''}

من تطبيق أذكاري''';
    
    Share.share(text);
  }
}

/// زر إجراء في الفوتر
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  
  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.space3,
            vertical: ThemeConstants.space2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: onPressed != null 
                    ? Colors.white 
                    : Colors.white.withValues(alpha: 0.3),
              ),
              ThemeConstants.space1.h,
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: onPressed != null 
                      ? Colors.white 
                      : Colors.white.withValues(alpha: 0.3),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}