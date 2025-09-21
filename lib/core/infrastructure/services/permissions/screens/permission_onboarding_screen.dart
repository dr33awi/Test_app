// lib/core/infrastructure/services/permissions/screens/permission_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../permission_service.dart';
import '../permission_constants.dart';
import '../widgets/permission_dialogs.dart';

/// نتيجة شاشة Onboarding
class OnboardingResult {
  final bool skipped;
  final List<AppPermissionType> selectedPermissions;
  
  OnboardingResult({
    required this.skipped,
    required this.selectedPermissions,
  });
}

/// شاشة Onboarding الموحدة لطلب الأذونات
class PermissionOnboardingScreen extends StatefulWidget {
  final PermissionService permissionService;
  final List<AppPermissionType>? criticalPermissions;
  final List<AppPermissionType>? optionalPermissions;
  final Function(OnboardingResult)? onComplete;
  
  const PermissionOnboardingScreen({
    super.key,
    required this.permissionService,
    this.criticalPermissions,
    this.optionalPermissions,
    this.onComplete,
  });
  
  @override
  State<PermissionOnboardingScreen> createState() => _PermissionOnboardingScreenState();
}

class _PermissionOnboardingScreenState extends State<PermissionOnboardingScreen>
    with TickerProviderStateMixin {
  
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  int _currentPage = 0;
  final int _totalPages = 4;
  
  // الأذونات المختارة
  final Set<AppPermissionType> _selectedPermissions = {};
  
  // حالة معالجة الأذونات
  bool _isProcessingPermissions = false;
  
  @override
  void initState() {
    super.initState();
    
    _pageController = PageController();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    // إضافة الأذونات الحرجة تلقائياً
    final criticalPermissions = widget.criticalPermissions ?? PermissionConstants.criticalPermissions;
    _selectedPermissions.addAll(criticalPermissions);
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // في الصفحة الأخيرة - معالجة الأذونات
      _processPermissionsAndComplete();
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }
  
  void _skip() {
    HapticFeedback.mediumImpact();
    _showSkipConfirmation();
  }
  
  void _showSkipConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('تخطي إعداد الأذونات؟'),
        content: const Text(
          'قد لا تعمل بعض ميزات التطبيق بشكل صحيح بدون الأذونات المطلوبة.\n\nيمكنك تفعيلها لاحقاً من الإعدادات.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeWithResult(OnboardingResult(
                skipped: true,
                selectedPermissions: [],
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('تخطي'),
          ),
        ],
      ),
    );
  }
  
  /// معالجة الأذونات وإكمال Onboarding
  Future<void> _processPermissionsAndComplete() async {
    if (_isProcessingPermissions) return;
    
    setState(() {
      _isProcessingPermissions = true;
    });
    
    HapticFeedback.heavyImpact();
    
    // إذا لم يتم اختيار أي أذونات
    if (_selectedPermissions.isEmpty) {
      _completeWithResult(OnboardingResult(
        skipped: false,
        selectedPermissions: [],
      ));
      return;
    }
    
    // عرض dialog التقدم
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: _PermissionProcessingDialog(
          totalPermissions: _selectedPermissions.length,
        ),
      ),
    );
    
    try {
      // طلب الأذونات
      final results = await _requestPermissions();
      
      // إغلاق dialog التقدم
      if (mounted) {
        Navigator.pop(context);
      }
      
      // عرض النتائج
      if (mounted) {
        await _showResults(results);
      }
      
      // إكمال العملية
      _completeWithResult(OnboardingResult(
        skipped: false,
        selectedPermissions: _selectedPermissions.toList(),
      ));
      
    } catch (e) {
      debugPrint('Error processing permissions: $e');
      
      // إغلاق dialog في حالة الخطأ
      if (mounted) {
        Navigator.pop(context);
        _showErrorMessage('حدث خطأ في معالجة الأذونات');
      }
      
      setState(() {
        _isProcessingPermissions = false;
      });
    }
  }
  
  /// طلب الأذونات بشكل متسلسل
  Future<Map<AppPermissionType, AppPermissionStatus>> _requestPermissions() async {
    final results = <AppPermissionType, AppPermissionStatus>{};
    final permissions = _selectedPermissions.toList();
    
    for (int i = 0; i < permissions.length; i++) {
      final permission = permissions[i];
      
      // تحديث dialog التقدم
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PopScope(
            canPop: false,
            child: _PermissionProcessingDialog(
              totalPermissions: permissions.length,
              currentIndex: i + 1,
              currentPermission: permission,
            ),
          ),
        );
      }
      
      // طلب الإذن
      try {
        final status = await widget.permissionService.requestPermission(permission);
        results[permission] = status;
        debugPrint('Permission ${permission.toString()}: ${status.toString()}');
      } catch (e) {
        debugPrint('Error requesting permission $permission: $e');
        results[permission] = AppPermissionStatus.unknown;
      }
      
      // تأخير صغير بين الطلبات
      if (i < permissions.length - 1) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }
    
    return results;
  }
  
  /// عرض نتائج طلب الأذونات
  Future<void> _showResults(Map<AppPermissionType, AppPermissionStatus> results) async {
    final granted = results.entries
        .where((e) => e.value == AppPermissionStatus.granted)
        .map((e) => e.key)
        .toList();
    
    final denied = results.entries
        .where((e) => e.value != AppPermissionStatus.granted)
        .map((e) => e.key)
        .toList();
    
    if (mounted) {
      await PermissionDialogs.showResultDialog(
        context: context,
        granted: granted,
        denied: denied,
      );
    }
  }
  
  /// إكمال العملية وإرجاع النتيجة
  void _completeWithResult(OnboardingResult result) {
    if (widget.onComplete != null) {
      widget.onComplete!(result);
    } else {
      Navigator.pop(context, result);
    }
  }
  
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // خلفية متدرجة
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor.withValues(alpha: 0.1),
                    theme.primaryColor.withValues(alpha: 0.05),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
            
            // المحتوى الرئيسي
            SafeArea(
              child: Column(
                children: [
                  // Header مع Progress
                  _buildHeader(),
                  
                  // Pages
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                            HapticFeedback.selectionClick();
                          },
                          children: [
                            _buildWelcomePage(),
                            _buildExplanationPage(),
                            _buildPermissionSelectionPage(),
                            _buildCompletionPage(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Navigation
                  _buildNavigation(),
                ],
              ),
            ),
            
            // Loading overlay
            if (_isProcessingPermissions)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: isActive ? 24 : 8,
                decoration: BoxDecoration(
                  color: isActive 
                      ? Theme.of(context).primaryColor 
                      : Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mosque,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Text(
            'مرحباً بك في\nحصن المسلم',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'رفيقك اليومي للأذكار والعبادات',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExplanationPage() {
    final features = [
      {
        'icon': Icons.notifications_active,
        'title': 'تذكيرات ذكية',
        'description': 'تنبيهات في الأوقات المناسبة',
        'color': Colors.blue,
      },
      {
        'icon': Icons.location_on,
        'title': 'مواقيت دقيقة',
        'description': 'حسب موقعك الجغرافي',
        'color': Colors.green,
      },
      {
        'icon': Icons.explore,
        'title': 'اتجاه القبلة',
        'description': 'بوصلة دقيقة للصلاة',
        'color': Colors.orange,
      },
      {
        'icon': Icons.menu_book,
        'title': 'أذكار شاملة',
        'description': 'جميع الأذكار اليومية',
        'color': Colors.purple,
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ميزات التطبيق',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildFeatureCard(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              description: feature['description'] as String,
              color: feature['color'] as Color,
            ),
          )),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPermissionSelectionPage() {
    final criticalPermissions = widget.criticalPermissions ?? PermissionConstants.criticalPermissions;
    final optionalPermissions = widget.optionalPermissions ?? PermissionConstants.optionalPermissions;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأذونات المطلوبة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'نحتاج بعض الأذونات لتوفير أفضل تجربة',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          
          Text(
            'أذونات أساسية',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          ...criticalPermissions.map((permission) => 
            _buildPermissionItem(permission, isCritical: true),
          ),
          
          if (optionalPermissions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'أذونات اختيارية',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ...optionalPermissions.map((permission) => 
              _buildPermissionItem(permission, isCritical: false),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildPermissionItem(AppPermissionType permission, {required bool isCritical}) {
    final info = PermissionConstants.getInfo(permission);
    final isSelected = _selectedPermissions.contains(permission);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isCritical ? null : () {
          setState(() {
            if (isSelected) {
              _selectedPermissions.remove(permission);
            } else {
              _selectedPermissions.add(permission);
            }
          });
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? info.color.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? info.color.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? info.color.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  info.icon,
                  color: isSelected ? info.color : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          info.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isSelected ? null : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isCritical)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 10,
                                  color: Colors.red[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'مطلوب',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCritical)
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value ?? false) {
                        _selectedPermissions.add(permission);
                      } else {
                        _selectedPermissions.remove(permission);
                      }
                    });
                    HapticFeedback.selectionClick();
                  },
                  activeColor: info.color,
                ),
              if (isCritical)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.lock,
                    size: 18,
                    color: Colors.green[700],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCompletionPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Colors.green,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'كل شيء جاهز!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'سنطلب الأذونات المختارة الآن',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'يمكنك تغيير الأذونات لاحقاً من الإعدادات',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
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
  
  Widget _buildNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isProcessingPermissions ? null : _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('السابق'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isProcessingPermissions ? null : _nextPage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _currentPage == _totalPages - 1 
                    ? Colors.green 
                    : Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessingPermissions
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentPage == _totalPages - 1 ? 'البدء' : 'التالي',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          if (_currentPage < _totalPages - 1) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: _isProcessingPermissions ? null : _skip,
              child: Text(
                'تخطي',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dialog لعرض التقدم أثناء معالجة الأذونات
class _PermissionProcessingDialog extends StatelessWidget {
  final int totalPermissions;
  final int currentIndex;
  final AppPermissionType? currentPermission;
  
  const _PermissionProcessingDialog({
    required this.totalPermissions,
    this.currentIndex = 0,
    this.currentPermission,
  });
  
  @override
  Widget build(BuildContext context) {
    final progress = currentIndex > 0 ? currentIndex / totalPermissions : 0.0;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'جاري طلب الأذونات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (currentIndex > 0) ...[
              Text(
                '$currentIndex من $totalPermissions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              if (currentPermission != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    PermissionConstants.getName(currentPermission!),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}