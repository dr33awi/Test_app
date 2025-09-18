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
  late AnimationController _rotationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
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
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_rotationController);

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
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
  right: positions[i]['right'],
  left: positions[i]['left'],
  top: positions[i]['top'],
  bottom: positions[i]['bottom'],
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
        children: [
          _simpleIconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.30)),
                ),
                child: Text(
                  'الاسم ${_currentItem.id}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(height: 4),
              Text('من $total', style: TextStyle(color: Colors.white.withOpacity(0.70), fontSize: 12)),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // أزيلت الأزرار الزجاجية والأيقونات

  Widget _buildContent(AsmaAllahModel item) {
    final accent = item.getColor();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const SizedBox(height: 50),
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
                Text('معنى الاسم',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accent, fontFamily: 'Cairo')),
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
                child: Column(children: [
                  Text('من القرآن الكريم',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accent, fontFamily: 'Cairo')),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: accent.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: Text('﴿${item.reference}﴾',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, color: ThemeConstants.lightTextPrimary, fontFamily: 'Amiri', height: 1.8)),
                  )
                ])),
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
    Color disabled = Colors.white.withOpacity(0.30);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(25, 0, 0, 0), Colors.transparent],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleIcon(
            icon: Icons.copy,
            onTap: () {
              HapticFeedback.lightImpact();
              _copyToClipboard();
            },
            tooltip: 'نسخ',
          ),
          _circleIcon(
            icon: Icons.share,
            onTap: () {
              HapticFeedback.lightImpact();
              _share();
            },
            tooltip: 'مشاركة',
          ),
          _circleIcon(
            icon: Icons.chevron_right,
            onTap: canPrev
                ? () {
                    HapticFeedback.lightImpact();
                    _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic);
                  }
                : null,
            color: canPrev ? Colors.white : disabled,
            tooltip: 'السابق',
          ),
          _circleIcon(
            icon: Icons.chevron_left,
            onTap: canNext
                ? () {
                    HapticFeedback.lightImpact();
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic);
                  }
                : null,
            color: canNext ? Colors.white : disabled,
            tooltip: 'التالي',
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
        content: const Text('تم النسخ بنجاح', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
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

// ---------- Helpers (Buttons) ----------
Widget _simpleIconButton({required IconData icon, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.30)),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}

Widget _circleIcon({
  required IconData icon,
  required VoidCallback? onTap,
  String? tooltip,
  Color color = Colors.white,
}) {
  final enabled = onTap != null;
  return GestureDetector(
    onTap: onTap,
    child: Tooltip(
      message: tooltip ?? '',
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.5,
        child: Container(
          width: 48,
          height: 48,
            decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.30)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    ),
  );
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
