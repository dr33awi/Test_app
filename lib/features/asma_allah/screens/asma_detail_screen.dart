// lib/features/asma_allah/screens/asma_detail_screen.dart

import 'package:athkar_app/app/themes/widgets/core/islamic_pattern_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/themes/app_theme.dart';
import '../models/asma_allah_model.dart';

class AsmaDetailScreen extends StatefulWidget {
  final AsmaAllahModel asmaAllah;
  final VoidCallback onFavoriteToggle;

  const AsmaDetailScreen({
    super.key,
    required this.asmaAllah,
    required this.onFavoriteToggle,
  });

  @override
  State<AsmaDetailScreen> createState() => _AsmaDetailScreenState();
}

class _AsmaDetailScreenState extends State<AsmaDetailScreen> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  int dhikrCount = 0;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: ThemeConstants.durationSlow,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _incrementDhikr() {
    setState(() {
      dhikrCount++;
    });
    HapticFeedback.lightImpact();
  }
  
  void _resetDhikr() {
    setState(() {
      dhikrCount = 0;
    });
    HapticFeedback.mediumImpact();
  }
  
  void _copyName() {
    Clipboard.setData(ClipboardData(text: widget.asmaAllah.name));
    context.showSuccessSnackBar('تم نسخ الاسم');
    HapticFeedback.mediumImpact();
  }
  
  void _shareName() {
    final text = '''
أسماء الله الحسنى

${widget.asmaAllah.name}
${widget.asmaAllah.transliteration}

المعنى: ${widget.asmaAllah.meaning}

${widget.asmaAllah.explanation}

الفوائد: ${widget.asmaAllah.benefits}

من تطبيق الأذكار
''';
    Share.share(text);
    HapticFeedback.lightImpact();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF6B46C1),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // خلفية متدرجة
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF6B46C1),
                          Color(0xFF9F7AEA),
                        ],
                      ),
                    ),
                  ),
                  
                  // نمط إسلامي
                  CustomPaint(
                    painter: IslamicPatternPainter(
                      color: Colors.white.withValues(alpha: 0.1),
                      patternType: PatternType.floral,
                      rotation: 0,
                      opacity: 0.15,
                    ),
                  ),
                  
                  // محتوى الرأس
                  SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // رقم الاسم
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.asmaAllah.id.toString().padLeft(2, '0'),
                                style: context.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: ThemeConstants.bold,
                                ),
                              ),
                            ),
                          ),
                          
                          ThemeConstants.space4.h,
                          
                          // الاسم بالعربية
                          Text(
                            widget.asmaAllah.name,
                            style: context.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: ThemeConstants.bold,
                              fontSize: 42,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          
                          ThemeConstants.space2.h,
                          
                          // النطق
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
                              widget.asmaAllah.transliteration,
                              style: context.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: ThemeConstants.medium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // أزرار الإجراءات
            actions: [
              IconButton(
                icon: Icon(
                  widget.asmaAllah.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  widget.onFavoriteToggle();
                  setState(() {});
                },
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _shareName,
              ),
            ],
          ),
          
          // المحتوى
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Padding(
                      padding: const EdgeInsets.all(ThemeConstants.space4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // بطاقة المعنى
                          _buildCard(
                            title: 'المعنى',
                            icon: Icons.book_outlined,
                            content: widget.asmaAllah.meaning,
                            color: const Color(0xFF6B46C1),
                          ),
                          
                          ThemeConstants.space4.h,
                          
                          // بطاقة الشرح
                          _buildCard(
                            title: 'الشرح التفصيلي',
                            icon: Icons.description_outlined,
                            content: widget.asmaAllah.explanation,
                            color: const Color(0xFF9F7AEA),
                          ),
                          
                          ThemeConstants.space4.h,
                          
                          // بطاقة الفوائد
                          _buildCard(
                            title: 'الفوائد والآثار',
                            icon: Icons.star_outline,
                            content: widget.asmaAllah.benefits,
                            color: const Color(0xFF805AD5),
                          ),
                          
                          ThemeConstants.space4.h,
                          
                          // بطاقة المرجع
                          if (widget.asmaAllah.reference.isNotEmpty)
                            _buildCard(
                              title: 'المرجع من القرآن',
                              icon: Icons.menu_book,
                              content: widget.asmaAllah.reference,
                              color: const Color(0xFF6B46C1),
                              isQuran: true,
                            ),
                          
                          ThemeConstants.space4.h,
                          
                          // عداد الذكر
                          _buildDhikrCounter(),
                          
                          ThemeConstants.space4.h,
                          
                          // أزرار الإجراءات
                          _buildActionButtons(),
                          
                          ThemeConstants.space8.h,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCard({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
    bool isQuran = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(ThemeConstants.radiusLg),
                topRight: Radius.circular(ThemeConstants.radiusLg),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                ThemeConstants.space3.w,
                Text(
                  title,
                  style: context.titleMedium?.copyWith(
                    color: color,
                    fontWeight: ThemeConstants.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // المحتوى
          Padding(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            child: Text(
              content,
              style: context.bodyLarge?.copyWith(
                fontFamily: isQuran ? ThemeConstants.fontFamilyQuran : null,
                height: isQuran ? 2.0 : 1.6,
                fontSize: isQuran ? 20 : 16,
              ),
              textAlign: isQuran ? TextAlign.center : TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDhikrCounter() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6B46C1).withValues(alpha: 0.1),
            const Color(0xFF9F7AEA).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        border: Border.all(
          color: const Color(0xFF6B46C1).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            'عداد الذكر',
            style: context.titleMedium?.copyWith(
              fontWeight: ThemeConstants.bold,
            ),
          ),
          
          ThemeConstants.space3.h,
          
          // العداد
          GestureDetector(
            onTap: _incrementDhikr,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF6B46C1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B46C1).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  dhikrCount.toString(),
                  style: context.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: ThemeConstants.bold,
                    fontSize: 36,
                  ),
                ),
              ),
            ),
          ),
          
          ThemeConstants.space3.h,
          
          // معلومات الذكر
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.space4,
              vertical: ThemeConstants.space2,
            ),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
            ),
            child: Text(
              'عدد مرات الذكر المستحب: ${widget.asmaAllah.dhikrCount}',
              style: context.bodyMedium?.copyWith(
                color: const Color(0xFF6B46C1),
                fontWeight: ThemeConstants.medium,
              ),
            ),
          ),
          
          ThemeConstants.space3.h,
          
          // أزرار التحكم
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // زر الإعادة
              TextButton.icon(
                onPressed: _resetDhikr,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة تعيين'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6B46C1),
                ),
              ),
              
              ThemeConstants.space4.w,
              
              // زر الزيادة
              ElevatedButton.icon(
                onPressed: _incrementDhikr,
                icon: const Icon(Icons.add),
                label: const Text('ذكر'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B46C1),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      children: [
        // زر النسخ
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _copyName,
            icon: const Icon(Icons.copy),
            label: const Text('نسخ الاسم'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6B46C1),
              side: const BorderSide(color: Color(0xFF6B46C1)),
              padding: const EdgeInsets.symmetric(
                vertical: ThemeConstants.space3,
              ),
            ),
          ),
        ),
        
        ThemeConstants.space3.w,
        
        // زر المشاركة
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareName,
            icon: const Icon(Icons.share),
            label: const Text('مشاركة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B46C1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: ThemeConstants.space3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}