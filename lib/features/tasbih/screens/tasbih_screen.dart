// lib/features/tasbih/screens/tasbih_screen.dart
import 'package:athkar_app/core/infrastructure/services/storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math' as math;

import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../../../core/infrastructure/services/logging/logger_service.dart';
import '../services/tasbih_service.dart';
import '../models/dhikr_model.dart';
import '../widgets/tasbih_bead_widget.dart';
import '../widgets/tasbih_counter_ring.dart';
import '../widgets/tasbih_pattern_painter.dart';
import '../widgets/dhikr_card.dart';

/// شاشة المسبحة الرقمية المحسنة
class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with TickerProviderStateMixin {
  late TasbihService _service;
  late LoggerService _logger;
  late AnimationController _beadController;
  late AnimationController _rippleController;
  late AnimationController _rotationController;
  late Animation<double> _beadAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _rotationAnimation;

  // للتتبع والتفاعل
  bool _isPressed = false;
  DhikrItem _currentDhikr = DefaultAdhkar.getAll().first; // الذكر الحالي

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupAnimations();
  }

  void _initializeServices() {
    _service = TasbihService(
      storage: getIt<StorageService>(),
      logger: getIt<LoggerService>(),
    );
    _logger = getIt<LoggerService>();
  }

  void _setupAnimations() {
    _beadController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _beadAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _beadController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_rotationController);
  }

  @override
  void dispose() {
    _beadController.dispose();
    _rippleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _service,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: Stack(
          children: [
            // خلفية مزخرفة
            _buildAnimatedBackground(),
            
            // المحتوى الرئيسي
            SafeArea(
              child: Column(
                children: [
                  // شريط التطبيق المخصص
                  _buildCustomAppBar(context),
                  
                  // محدد نوع الذكر
                  _buildDhikrSelector(),
                  
                  // المنطقة الرئيسية للمسبحة
                  Expanded(
                    child: _buildMainTasbihArea(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: TasbihPatternPainter(
              rotation: _rotationAnimation.value,
              color: _currentDhikr.primaryColor.withValues(alpha: 0.05),
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
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
              gradient: LinearGradient(
                colors: _currentDhikr.gradient,
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
            ),
            child: const Icon(
              Icons.radio_button_checked,
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
                  'المسبحة الرقمية',
                  style: context.titleLarge?.copyWith(
                    fontWeight: ThemeConstants.bold,
                  ),
                ),
                Text(
                  'اذكر الله كثيراً',
                  style: context.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // زر تصفير العداد
          Consumer<TasbihService>(
            builder: (context, service, _) {
              return Container(
                margin: const EdgeInsets.only(left: ThemeConstants.space2),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  child: InkWell(
                    onTap: () => _showResetDialog(service),
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
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: ThemeConstants.error,
                        size: ThemeConstants.iconMd,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ThemeConstants.space4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        child: InkWell(
          onTap: _showDhikrSelectionModal,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
          child: Container(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _currentDhikr.gradient),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _currentDhikr.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeConstants.space2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  ),
                  child: Icon(
                    _currentDhikr.category.icon,
                    color: Colors.white,
                    size: ThemeConstants.iconMd,
                  ),
                ),
                
                ThemeConstants.space3.w,
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عرض النص كاملاً مع إمكانية التفاف السطور
                      Text(
                        _currentDhikr.text,
                        style: context.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: ThemeConstants.bold,
                          height: 1.3,
                        ),
                        maxLines: null, // السماح بعدد غير محدود من السطور
                        overflow: TextOverflow.visible, // عدم قطع النص
                      ),
                      ThemeConstants.space1.h,
                      Row(
                        children: [
                          Text(
                            _currentDhikr.category.title,
                            style: context.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          Text(
                            ' • ',
                            style: context.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          Text(
                            '${_currentDhikr.recommendedCount}×',
                            style: context.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: ThemeConstants.iconMd,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainTasbihArea(BuildContext context) {
    return Consumer<TasbihService>(
      builder: (context, service, _) {
        final progress = (service.count % _currentDhikr.recommendedCount) / _currentDhikr.recommendedCount;
        
        return Container(
          padding: const EdgeInsets.all(ThemeConstants.space6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // العداد الدائري الرئيسي
              Stack(
                alignment: Alignment.center,
                children: [
                  // الحلقة الخارجية للتقدم
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: TasbihCounterRing(
                      progress: progress,
                      gradient: _currentDhikr.gradient,
                      strokeWidth: 8,
                    ),
                  ),
                  
                  // الحلقة الداخلية للعد الكامل
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: TasbihCounterRing(
                      progress: service.count / 1000, // تقدم إجمالي لألف
                      gradient: [
                        context.textSecondaryColor.withValues(alpha: 0.2),
                        context.textSecondaryColor.withValues(alpha: 0.1),
                      ],
                      strokeWidth: 4,
                    ),
                  ),
                  
                  // الزر المركزي للتسبيح
                  AnimatedBuilder(
                    animation: _beadAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _beadAnimation.value,
                        child: GestureDetector(
                          onTapDown: (_) {
                            setState(() => _isPressed = true);
                            _beadController.forward();
                            HapticFeedback.lightImpact();
                          },
                          onTapUp: (_) {
                            setState(() => _isPressed = false);
                            _beadController.reverse();
                            _incrementCounter(service);
                          },
                          onTapCancel: () {
                            setState(() => _isPressed = false);
                            _beadController.reverse();
                          },
                          child: TasbihBeadWidget(
                            size: 180,
                            gradient: _currentDhikr.gradient,
                            isPressed: _isPressed,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${service.count}',
                                  style: context.displayMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: ThemeConstants.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                ThemeConstants.space1.h,
                                Text(
                                  'اضغط للتسبيح',
                                  style: context.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // تأثير الموجات عند الضغط
                  if (_isPressed)
                    AnimatedBuilder(
                      animation: _rippleAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 180 + (_rippleAnimation.value * 40),
                          height: 180 + (_rippleAnimation.value * 40),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _currentDhikr.primaryColor.withValues(
                                alpha: (1 - _rippleAnimation.value) * 0.5,
                              ),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              
              ThemeConstants.space6.h,
              
              // معلومات التقدم
              _buildProgressInfo(service, _currentDhikr),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressInfo(TasbihService service, DhikrItem currentDhikr) {
    final currentRound = service.count % currentDhikr.recommendedCount;
    final completedRounds = service.count ~/ currentDhikr.recommendedCount;
    
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        border: Border.all(
          color: context.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoItem(
            'الجولة الحالية',
            '$currentRound / ${currentDhikr.recommendedCount}',
            Icons.radio_button_checked,
            currentDhikr.primaryColor,
          ),
          
          Container(
            width: 1,
            height: 40,
            color: context.dividerColor,
          ),
          
          _buildInfoItem(
            'الجولات المكتملة',
            '$completedRounds',
            Icons.check_circle,
            ThemeConstants.success,
          ),
          
          Container(
            width: 1,
            height: 40,
            color: context.dividerColor,
          ),
          
          _buildInfoItem(
            'الإجمالي اليوم',
            '${service.count}',
            Icons.star,
            ThemeConstants.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: ThemeConstants.iconMd,
        ),
        ThemeConstants.space1.h,
        Text(
          value,
          style: context.titleMedium?.copyWith(
            color: color,
            fontWeight: ThemeConstants.bold,
          ),
        ),
        Text(
          label,
          style: context.labelSmall?.copyWith(
            color: context.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _incrementCounter(TasbihService service) {
    service.increment(dhikrType: _currentDhikr.text);
    
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });
    
    // تأثير اهتزاز خفيف عند الوصول لهدف
    if (service.count % _currentDhikr.recommendedCount == 0) {
      HapticFeedback.mediumImpact();
      _showCompletionCelebration(_currentDhikr);
    }
    
    _logger.debug(
      message: '[TasbihScreen] increment',
      data: {
        'count': service.count,
        'dhikr': _currentDhikr.text,
      },
    );
  }

  void _showCompletionCelebration(DhikrItem dhikr) {
    // إظهار رسالة تهنئة خضراء عند اكتمال الجولة
    context.showSuccessSnackBar(
      'تم إكمال جولة ${dhikr.category.title} 🎉',
    );
  }

  void _showResetDialog(TasbihService service) {
    AppInfoDialog.showConfirmation(
      context: context,
      title: 'تصفير العداد',
      content: 'هل أنت متأكد من أنك تريد تصفير العداد؟ سيتم فقدان العد الحالي.',
      confirmText: 'تصفير',
      cancelText: 'إلغاء',
      icon: Icons.refresh_rounded,
      destructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        service.reset();
        HapticFeedback.mediumImpact();
        context.showSuccessSnackBar(
          'تم تصفير العداد',
        );
      }
    });
  }

  void _showDhikrSelectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مقبض السحب
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // رأس القائمة
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.list_alt_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اختر الذكر',
                          style: context.titleLarge?.copyWith(
                            fontWeight: ThemeConstants.bold,
                          ),
                        ),
                        Text(
                          'اختر الذكر الذي تريد تسبيحه',
                          style: context.bodyMedium?.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // قائمة الأذكار بالتصنيفات
            Flexible(
              child: _buildDhikrCategoriesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDhikrCategoriesList() {
    // تجميع الأذكار حسب التصنيف
    final Map<DhikrCategory, List<DhikrItem>> categorizedAdhkar = {};
    
    for (final dhikr in DefaultAdhkar.getAll()) {
      if (!categorizedAdhkar.containsKey(dhikr.category)) {
        categorizedAdhkar[dhikr.category] = [];
      }
      categorizedAdhkar[dhikr.category]!.add(dhikr);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: categorizedAdhkar.keys.length,
      itemBuilder: (context, index) {
        final category = categorizedAdhkar.keys.elementAt(index);
        final adhkar = categorizedAdhkar[category]!;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان التصنيف
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ThemeConstants.primary.withValues(alpha: 0.1),
                      ThemeConstants.primaryLight.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemeConstants.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      category.icon,
                      color: ThemeConstants.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.title,
                      style: context.titleMedium?.copyWith(
                        color: ThemeConstants.primary,
                        fontWeight: ThemeConstants.semiBold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: ThemeConstants.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${adhkar.length}',
                        style: context.labelSmall?.copyWith(
                          color: ThemeConstants.primary,
                          fontWeight: ThemeConstants.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // قائمة الأذكار في هذا التصنيف
              ...adhkar.map((dhikr) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _currentDhikr = dhikr;
                      });
                      Navigator.pop(context);
                      HapticFeedback.mediumImpact();
        context.showSuccessSnackBar(
          'تم تغيير الذكر إلى: ${dhikr.text}',
        );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _currentDhikr.id == dhikr.id 
                            ? dhikr.primaryColor.withValues(alpha: 0.1)
                            : context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _currentDhikr.id == dhikr.id 
                              ? dhikr.primaryColor.withValues(alpha: 0.3)
                              : context.dividerColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          // أيقونة الذكر
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: dhikr.gradient),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              dhikr.category.icon,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // نص الذكر والفضل - عرض كامل بدون قطع
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dhikr.text, // عرض النص كاملاً
                                  style: context.bodyMedium?.copyWith(
                                    fontWeight: _currentDhikr.id == dhikr.id 
                                        ? ThemeConstants.semiBold 
                                        : ThemeConstants.regular,
                                    color: _currentDhikr.id == dhikr.id 
                                        ? dhikr.primaryColor
                                        : context.textPrimaryColor,
                                    height: 1.4,
                                  ),
                                  maxLines: null, // السماح بعدد غير محدود من السطور
                                  overflow: TextOverflow.visible, // عدم قطع النص
                                ),
                                
                                // عرض الفضل إذا وُجد
                                if (dhikr.virtue != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _currentDhikr.id == dhikr.id 
                                          ? dhikr.primaryColor.withValues(alpha: 0.1)
                                          : ThemeConstants.accent.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: _currentDhikr.id == dhikr.id 
                                            ? dhikr.primaryColor.withValues(alpha: 0.2)
                                            : ThemeConstants.accent.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          size: 12,
                                          color: _currentDhikr.id == dhikr.id 
                                              ? dhikr.primaryColor
                                              : ThemeConstants.accent,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            dhikr.virtue!,
                                            style: context.bodySmall?.copyWith(
                                              color: context.textSecondaryColor,
                                              height: 1.3,
                                              fontSize: 11,
                                            ),
                                            maxLines: 2, // عرض سطرين من الفضل
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // العدد المقترح
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: dhikr.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${dhikr.recommendedCount}×',
                              style: context.labelSmall?.copyWith(
                                color: dhikr.primaryColor,
                                fontWeight: ThemeConstants.semiBold,
                              ),
                            ),
                          ),
                          
                          // مؤشر الاختيار
                          if (_currentDhikr.id == dhikr.id) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle,
                              color: dhikr.primaryColor,
                              size: 20,
                            ),
                          ] else ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.radio_button_unchecked,
                              color: context.textSecondaryColor.withValues(alpha: 0.3),
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ],
          ),
        );
      },
    );
  }
}