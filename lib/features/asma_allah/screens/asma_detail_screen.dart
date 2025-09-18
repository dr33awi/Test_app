// File: lib/features/asma_allah/screens/asma_detail_screen.dart
// ============================================
import 'dart:math' as math;
import 'dart:ui';

import 'package:athkar_app/app/themes/app_theme.dart';
import 'package:athkar_app/app/themes/widgets/core/islamic_pattern_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/asma_allah_model.dart';
import '../services/asma_allah_service.dart';
import '../extensions/asma_allah_extensions.dart';

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

class _AsmaAllahDetailsScreenState extends State<AsmaAllahDetailsScreen>
    with TickerProviderStateMixin {
  late AsmaAllahModel _currentItem;
  late PageController _pageController;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    final list = widget.service.asmaAllahList;
    final initialIndex = list.indexWhere((e) => e.id == widget.item.id);
    _currentIndex = initialIndex >= 0 ? initialIndex : 0;
    _currentItem = list[_currentIndex];

    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 1.0,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack));
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_rotationController);

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg1 = _currentItem.getColor();
    final bg2 = _currentItem.getColor().withOpacity(0.80);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bg1, bg2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // خلفية زخرفية متحركة
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (_, __) {
                  return Positioned.fill(
                    child: CustomPaint(
                      painter: IslamicPatternPainter(
                        rotation: _rotationAnimation.value,
                        color: Colors.white,
                        patternType: PatternType.geometric,
                        opacity: 0.08,
                      ),
                    ),
                  );
                },
              ),
              // دوائر تجميلية
              ..._buildDecorativeCircles(),
              // المحتوى
              SafeArea(
                child: Column(
                  children: [
                    FadeTransition(opacity: _fadeAnimation, child: _buildHeader()),
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
                          _scaleController.forward(from: 0); // why: لإبراز الأيقونة عند التبديل
                        },
                        itemBuilder: (_, index) {
                          final item = widget.service.asmaAllahList[index];
                          return SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildContent(item),
                            ),
                          );
                        },
                      ),
                    ),
                    FadeTransition(opacity: _fadeAnimation, child: _buildFooter()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDecorativeCircles() {
    final positions = [
      const {'right': -50.0, 'top': 100.0},
      const {'left': -30.0, 'bottom': 200.0},
      const {'right': 20.0, 'bottom': 50.0},
    ];
    return List.generate(3, (i) {
      return Positioned(
        right: positions[i]['right'] as double?,
        left: positions[i]['left'] as double?,
        top: positions[i]['top'] as double?,
        bottom: positions[i]['bottom'] as double?,
        child: Container(
          width: 120 + (i * 30.0),
          height: 120 + (i * 30.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
          ),
        ),
      );
    });
  }

  Widget _buildHeader() {
    final total = widget.service.asmaAllahList.length;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _glassButton(
            onTap: () => Navigator.pop(context),
            icon: Icons.arrow_back_ios_new,
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.30)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'الاسم ${_currentItem.id}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'من $total',
                style: TextStyle(color: Colors.white.withOpacity(0.70), fontSize: 12),
              ),
            ],
          ),
          _glassButton(
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم الإضافة للمفضلة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(20),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: Icons.favorite_border,
          ),
        ],
      ),
    );
  }

  Widget _glassButton({required VoidCallback onTap, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.20), borderRadius: BorderRadius.circular(12)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AsmaAllahModel item) {
    final accent = item.getColor();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.30), Colors.white.withOpacity(0.10)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.30), width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.20), blurRadius: 20, spreadRadius: 5)],
              ),
              child: Icon(item.getIcon(), size: 55, color: Colors.white),
            ),
          ),
          const SizedBox(height: 30),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: ShaderMask(
              key: ValueKey(item.id),
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFFFC107), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  height: 1,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // بطاقة المعنى - فروست جلاس
          _FrostCard(
            accent: accent,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accent.withOpacity(0.10), accent.withOpacity(0.05)]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accent.withOpacity(0.20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book, color: accent, size: 22),
                      const SizedBox(width: 8),
                      Text('معنى الاسم',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accent, fontFamily: 'Cairo')),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  item.meaning,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey[800], height: 1.8, fontFamily: 'Cairo'),
                ),
              ],
            ),
          ),
          if (item.reference != null) ...[
            const SizedBox(height: 20),
            _FrostCard(
              accent: accent,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: accent.withOpacity(0.10), shape: BoxShape.circle),
                      child: Icon(Icons.format_quote, color: accent, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text('من القرآن الكريم',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: accent, fontFamily: 'Cairo')),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: accent.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '﴿${item.reference}﴾',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        color: ThemeConstants.lightTextPrimary,
                        fontFamily: 'Amiri',
                        height: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final lastIndex = widget.service.asmaAllahList.length - 1;
    final canPrev = _currentIndex > 0;
    final canNext = _currentIndex < lastIndex;

    Color inactive(Color c) => c.withOpacity(0.30);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(25, 0, 0, 0), Colors.transparent],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _EnhancedActionButton(
            icon: Icons.copy,
            label: 'نسخ',
            color: Colors.white,
            onPressed: () {
              HapticFeedback.lightImpact();
              _copyToClipboard();
            },
          ),
          _EnhancedActionButton(
            icon: Icons.share,
            label: 'مشاركة',
            color: Colors.white,
            onPressed: () {
              HapticFeedback.lightImpact();
              _share();
            },
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.30)),
            ),
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                    onTap: canPrev
                        ? () {
                            HapticFeedback.lightImpact();
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Icon(Icons.chevron_right, color: canPrev ? Colors.white : inactive(Colors.white)),
                    ),
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.white.withOpacity(0.20)),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                    onTap: canNext
                        ? () {
                            HapticFeedback.lightImpact();
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Icon(Icons.chevron_left, color: canNext ? Colors.white : inactive(Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard() {
    final b = StringBuffer()
      ..writeln(_currentItem.name)
      ..writeln()
      ..writeln('المعنى: ${_currentItem.meaning}');
    if (_currentItem.reference != null && _currentItem.reference!.trim().isNotEmpty) {
      b..writeln()..writeln('الآية: ﴿${_currentItem.reference}﴾');
    }
    b..writeln()..writeln('من تطبيق أذكاري');

    Clipboard.setData(ClipboardData(text: b.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          const Text('تم النسخ بنجاح', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        ]),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _share() {
    final b = StringBuffer()
      ..writeln(_currentItem.name)
      ..writeln()
      ..writeln('المعنى: ${_currentItem.meaning}');
    if (_currentItem.reference != null && _currentItem.reference!.trim().isNotEmpty) {
      b..writeln()..writeln('الآية: ﴿${_currentItem.reference}﴾');
    }
    b..writeln()..writeln('من تطبيق أذكاري - أسماء الله الحسنى');

    Share.share(b.toString(), subject: 'أسماء الله الحسنى - ${_currentItem.name}');
  }
}

class _FrostCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color accent;

  const _FrostCard({required this.child, required this.padding, required this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // why: تأثير زجاجي مريح بصريًا
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            boxShadow: [BoxShadow(color: accent.withOpacity(0.30), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _EnhancedActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _EnhancedActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  State<_EnhancedActionButton> createState() => _EnhancedActionButtonState();
}

class _EnhancedActionButtonState extends State<_EnhancedActionButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
  late final Animation<double> _scaleAnimation =
      Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final color = enabled ? widget.color : widget.color.withOpacity(0.40);

    return GestureDetector(
      onTapDown: enabled ? (_) => _controller.forward() : null,
      onTapUp: enabled
          ? (_) {
              _controller.reverse();
              widget.onPressed!.call();
            }
          : null,
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (_, child) => Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(colors: [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.15)])
                : null,
            color: enabled ? null : Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.30)),
            boxShadow: enabled ? [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(0, 4))] : null,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(widget.label, style: TextStyle(fontSize: 12, color: color, fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
