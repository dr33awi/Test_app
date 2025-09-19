// lib/features/athkar/screens/notification_settings_screen.dart (ألوان الأيقونات فقط)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/di/service_locator.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/infrastructure/services/permissions/permission_service.dart';
import '../../../core/infrastructure/services/storage/storage_service.dart';
import '../services/athkar_service.dart';
import '../models/athkar_model.dart';
import '../constants/athkar_constants.dart';
import '../utils/category_utils.dart';
import '../../../core/infrastructure/services/notifications/notification_manager.dart';
import '../../../core/infrastructure/services/notifications/models/notification_models.dart';

class AthkarNotificationSettingsScreen extends StatefulWidget {
  const AthkarNotificationSettingsScreen({super.key});

  @override
  State<AthkarNotificationSettingsScreen> createState() => 
      _AthkarNotificationSettingsScreenState();
}

class _AthkarNotificationSettingsScreenState 
    extends State<AthkarNotificationSettingsScreen> {
  late final AthkarService _service;
  late final PermissionService _permissionService;
  late final StorageService _storage;
  
  List<AthkarCategory>? _categories;
  final Map<String, bool> _enabled = {};
  final Map<String, TimeOfDay> _customTimes = {};
  final Map<String, TimeOfDay> _originalTimes = {};
  
  bool _saving = false;
  bool _hasPermission = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _service = getIt<AthkarService>();
    _permissionService = getIt<PermissionService>();
    _storage = getIt<StorageService>();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // التحقق من إصدار الإعدادات
      await _checkSettingsVersion();
      
      // التحقق من الإذن
      _hasPermission = await _permissionService.checkNotificationPermission();
      
      // تحميل الفئات
      final allCategories = await _service.loadCategories();
      
      // تحميل الإعدادات المحفوظة
      final enabledIds = _service.getEnabledReminderCategories();
      final savedCustomTimes = _service.getCustomTimes();
      
      // التحقق من أول تشغيل
      final isFirstLaunch = enabledIds.isEmpty && savedCustomTimes.isEmpty;
      
      // تهيئة البيانات
      _enabled.clear();
      _customTimes.clear();
      _originalTimes.clear();
      
      final autoEnabledIds = <String>[];
      
      for (final category in allCategories) {
        // تحديد حالة التفعيل
        bool shouldEnable = enabledIds.contains(category.id);
        
        // في أول تشغيل، تفعيل الفئات الأساسية
        if (isFirstLaunch && AthkarConstants.shouldAutoEnable(category.id)) {
          shouldEnable = true;
          autoEnabledIds.add(category.id);
        }
        
        _enabled[category.id] = shouldEnable;
        
        // تعيين الوقت
        final customTime = savedCustomTimes[category.id];
        final time = customTime ?? 
                    category.notifyTime ?? 
                    AthkarConstants.getDefaultTimeForCategory(category.id);
        
        _customTimes[category.id] = time;
        _originalTimes[category.id] = time;
      }
      
      setState(() {
        _categories = allCategories;
        _isLoading = false;
      });
      
      // حفظ الإعدادات الأولية في أول تشغيل
      if (isFirstLaunch && autoEnabledIds.isNotEmpty) {
        await _saveInitialSettings(autoEnabledIds);
      }
      
      // التحقق من صحة الإشعارات المجدولة
      if (_hasPermission) {
        await _validateScheduledNotifications();
      }
      
    } catch (e) {
      debugPrint('خطأ في تحميل البيانات: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل في تحميل البيانات. يرجى المحاولة مرة أخرى.';
      });
    }
  }

  Future<void> _checkSettingsVersion() async {
    final currentVersion = _storage.getInt(AthkarConstants.settingsVersionKey) ?? 1;
    
    if (currentVersion < AthkarConstants.currentSettingsVersion) {
      // ترقية الإعدادات إذا لزم الأمر
      await _migrateSettings(currentVersion);
      await _storage.setInt(
        AthkarConstants.settingsVersionKey,
        AthkarConstants.currentSettingsVersion,
      );
    }
  }

  Future<void> _migrateSettings(int fromVersion) async {
    debugPrint('ترقية إعدادات الأذكار من الإصدار $fromVersion');
  }

  Future<void> _saveInitialSettings(List<String> autoEnabledIds) async {
    await _service.setEnabledReminderCategories(autoEnabledIds);
    await _service.saveCustomTimes(_customTimes);
    
    if (_hasPermission) {
      await _service.scheduleCategoryReminders();
    }
    
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.showSuccessSnackBar(
            'تم تفعيل الأذكار الأساسية تلقائياً (${autoEnabledIds.length} فئات)'
          );
        }
      });
    }
  }

  Future<void> _validateScheduledNotifications() async {
    try {
      final enabledIds = _service.getEnabledReminderCategories();
      final scheduledNotifications = await NotificationManager.instance
          .getScheduledNotifications();
      
      final scheduledAthkarIds = scheduledNotifications
          .where((n) => n.category == NotificationCategory.athkar)
          .map((n) => n.payload?['categoryId'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet();
      
      final enabledSet = enabledIds.toSet();
      final missingNotifications = enabledSet.difference(scheduledAthkarIds);
      
      if (missingNotifications.isNotEmpty) {
        debugPrint('إعادة جدولة الإشعارات المفقودة: $missingNotifications');
        await _service.scheduleCategoryReminders();
      }
    } catch (e) {
      debugPrint('خطأ في التحقق من الإشعارات: $e');
    }
  }

  Future<void> _requestPermission() async {
    try {
      final granted = await _permissionService.requestNotificationPermission();
      setState(() => _hasPermission = granted);
      
      if (granted) {
        context.showSuccessSnackBar('تم منح إذن الإشعارات');
        
        // جدولة الإشعارات للفئات المفعلة
        final enabledIds = _enabled.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
            
        if (enabledIds.isNotEmpty) {
          await _service.scheduleCategoryReminders();
        }
      } else {
        context.showErrorSnackBar('تم رفض إذن الإشعارات');
      }
    } catch (e) {
      context.showErrorSnackBar('حدث خطأ أثناء طلب الإذن');
    }
  }

  Future<void> _toggleCategory(String categoryId, bool value) async {
    final oldValue = _enabled[categoryId];
    
    setState(() {
      _enabled[categoryId] = value;
    });
    
    try {
      await _saveChanges();
    } catch (e) {
      // إعادة القيمة السابقة في حالة الخطأ
      setState(() {
        _enabled[categoryId] = oldValue ?? false;
      });
      rethrow;
    }
  }

  Future<void> _updateTime(String categoryId, TimeOfDay time) async {
    final oldTime = _customTimes[categoryId];
    
    setState(() {
      _customTimes[categoryId] = time;
    });
    
    try {
      // حفظ الوقت الجديد
      await _service.saveCustomTimes(_customTimes);
      
      // إعادة جدولة فقط إذا كانت الفئة مفعلة
      if (_enabled[categoryId] == true && _hasPermission) {
        final category = _categories!.firstWhere((c) => c.id == categoryId);
        
        await NotificationManager.instance.cancelAthkarReminder(categoryId);
        await NotificationManager.instance.scheduleAthkarReminder(
          categoryId: categoryId,
          categoryName: category.title,
          time: time,
        );
      }
      
      // تفعيل الفئة تلقائياً عند تغيير الوقت
      if (!(_enabled[categoryId] ?? false)) {
        await _toggleCategory(categoryId, true);
      }
      
      if (mounted) {
        context.showSuccessSnackBar('تم تحديث الوقت بنجاح');
      }
    } catch (e) {
      // إعادة الوقت السابق في حالة الخطأ
      setState(() {
        _customTimes[categoryId] = oldTime ?? 
            AthkarConstants.getDefaultTimeForCategory(categoryId);
      });
      
      if (mounted) {
        context.showErrorSnackBar('حدث خطأ في تحديث الوقت');
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_saving) return;
    
    setState(() => _saving = true);
    
    try {
      // التحقق من الأذونات
      if (!_hasPermission) {
        final enabledCount = _enabled.values.where((e) => e).length;
        if (enabledCount > 0) {
          if (mounted) {
            context.showWarningSnackBar('يجب تفعيل أذونات الإشعارات أولاً');
          }
          return;
        }
      }

      // تحديث الإعدادات
      await _service.updateReminderSettings(
        enabledMap: _enabled,
        customTimes: _customTimes,
      );
      
      // تحديث الأوقات الأصلية
      _originalTimes.clear();
      _originalTimes.addAll(_customTimes);
      
      if (mounted) {
        context.showSuccessSnackBar('تم حفظ الإعدادات بنجاح');
      }
    } catch (e) {
      debugPrint('خطأ في حفظ الإعدادات: $e');
      if (mounted) {
        context.showErrorSnackBar('حدث خطأ في حفظ الإعدادات');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _selectTime(String categoryId, TimeOfDay currentTime) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
      helpText: 'اختر وقت التذكير',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: context.surfaceColor,
              hourMinuteTextColor: context.textPrimaryColor,
              dialHandColor: ThemeConstants.primary,
              dialBackgroundColor: context.cardColor,
              helpTextStyle: context.titleMedium?.copyWith(
                color: context.textPrimaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      await _updateTime(categoryId, selectedTime);
    }
  }

  Future<void> _enableAllReminders() async {
    HapticFeedback.mediumImpact();
    
    final shouldEnable = await AppInfoDialog.showConfirmation(
      context: context,
      title: 'تفعيل جميع التذكيرات',
      content: 'هل تريد تفعيل تذكيرات جميع فئات الأذكار؟',
      confirmText: 'تفعيل الكل',
      cancelText: 'إلغاء',
      icon: Icons.notifications_active,
    );
    
    if (shouldEnable == true) {
      setState(() {
        for (final category in _categories ?? <AthkarCategory>[]) {
          _enabled[category.id] = true;
        }
      });
      await _saveChanges();
    }
  }

  Future<void> _disableAllReminders() async {
    HapticFeedback.mediumImpact();
    
    final shouldDisable = await AppInfoDialog.showConfirmation(
      context: context,
      title: 'إيقاف جميع التذكيرات',
      content: 'هل تريد إيقاف جميع تذكيرات الأذكار؟',
      confirmText: 'إيقاف الكل',
      cancelText: 'إلغاء',
      icon: Icons.notifications_off,
      destructive: true,
    );
    
    if (shouldDisable == true) {
      setState(() {
        for (final category in _categories ?? <AthkarCategory>[]) {
          _enabled[category.id] = false;
        }
      });
      await _saveChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    const gradient = LinearGradient(
      colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    
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
              gradient: gradient,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: ThemeConstants.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_active,
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
                  'إشعارات الأذكار',
                  style: context.titleLarge?.copyWith(
                    fontWeight: ThemeConstants.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                Text(
                  'تخصيص تذكيرات الأذكار اليومية',
                  style: context.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          if (_hasPermission && (_categories?.isNotEmpty ?? false))
            _buildActionsMenu(),
          
          if (_saving)
            Container(
              margin: const EdgeInsets.only(left: ThemeConstants.space2),
              child: const SizedBox(
                width: ThemeConstants.iconMd,
                height: ThemeConstants.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionsMenu() {
    return Container(
      margin: const EdgeInsets.only(left: ThemeConstants.space2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        child: PopupMenuButton<String>(
          icon: Container(
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
              Icons.more_vert,
              color: context.textPrimaryColor,
              size: ThemeConstants.iconMd,
            ),
          ),
          onSelected: (value) {
            switch (value) {
              case 'enable_all':
                _enableAllReminders();
                break;
              case 'disable_all':
                _disableAllReminders();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'enable_all',
              child: Row(
                children: [
                  Icon(Icons.notifications_active),
                  SizedBox(width: 8),
                  Text('تفعيل الكل'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'disable_all',
              child: Row(
                children: [
                  Icon(Icons.notifications_off),
                  SizedBox(width: 8),
                  Text('إيقاف الكل'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: AppLoading.page(
          message: 'جاري تحميل الإعدادات...',
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: AppEmptyState.error(
          message: _errorMessage!,
          onRetry: _loadData,
        ),
      );
    }

    final categories = _categories ?? [];

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(ThemeConstants.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPermissionSection(),
            
            const SizedBox(height: ThemeConstants.space6),
            
            if (_hasPermission) ...[
              if (categories.isEmpty)
                _buildNoCategoriesMessage()
              else ...[
                _buildQuickStats(categories),
                
                const SizedBox(height: ThemeConstants.space4),
                
                Text(
                  'جميع فئات الأذكار (${categories.length})',
                  style: context.titleMedium?.copyWith(
                    fontWeight: ThemeConstants.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                
                const SizedBox(height: ThemeConstants.space2),
                
                Text(
                  'يمكنك تفعيل التذكيرات لأي فئة وتخصيص أوقاتها',
                  style: context.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                
                const SizedBox(height: ThemeConstants.space4),
                
                ...categories.map((category) => 
                  _buildCategoryTile(category)
                ),
              ],
            ] else
              _buildPermissionRequiredMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(List<AthkarCategory> categories) {
    final enabledCount = _enabled.values.where((e) => e).length;
    final disabledCount = categories.length - enabledCount;
    
    return AppCard(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.notifications_active,
              count: enabledCount,
              label: 'مفعلة',
              color: ThemeConstants.success,
            ),
          ),
          
          Container(
            width: 1,
            height: 40,
            color: context.dividerColor,
          ),
          
          Expanded(
            child: _StatItem(
              icon: Icons.notifications_off,
              count: disabledCount,
              label: 'معطلة',
              color: context.textSecondaryColor,
            ),
          ),
          
          Container(
            width: 1,
            height: 40,
            color: context.dividerColor,
          ),
          
          Expanded(
            child: _StatItem(
              icon: Icons.format_list_numbered,
              count: categories.length,
              label: 'الكل',
              color: context.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionSection() {
    return AppCard(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _hasPermission ? Icons.notifications_active : Icons.notifications_off,
                color: _hasPermission ? ThemeConstants.success : ThemeConstants.warning,
                size: 24,
              ),
              const SizedBox(width: ThemeConstants.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasPermission ? 'الإشعارات مفعلة' : 'الإشعارات معطلة',
                      style: context.titleSmall?.copyWith(
                        fontWeight: ThemeConstants.semiBold,
                        color: _hasPermission ? ThemeConstants.success : ThemeConstants.warning,
                      ),
                    ),
                    Text(
                      _hasPermission 
                          ? 'يمكنك الآن تخصيص تذكيرات الأذكار'
                          : 'قم بتفعيل الإشعارات لتلقي التذكيرات',
                      style: context.bodySmall?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_hasPermission) ...[
            const SizedBox(height: ThemeConstants.space3),
            SizedBox(
              width: double.infinity,
              child: AppButton.primary(
                text: 'تفعيل الإشعارات',
                onPressed: _requestPermission,
                icon: Icons.notifications,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoCategoriesMessage() {
    return AppCard(
      padding: const EdgeInsets.all(ThemeConstants.space5),
      child: Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 48,
            color: context.textSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: ThemeConstants.space3),
          Text(
            'لا توجد فئات أذكار',
            style: context.titleMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: ThemeConstants.space2),
          Text(
            'لم يتم العثور على أي فئات للأذكار',
            style: context.bodyMedium?.copyWith(
              color: context.textSecondaryColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequiredMessage() {
    return AppCard(
      padding: const EdgeInsets.all(ThemeConstants.space5),
      child: Column(
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            size: 48,
            color: ThemeConstants.warning,
          ),
          const SizedBox(height: ThemeConstants.space3),
          Text(
            'الإشعارات مطلوبة',
            style: context.titleMedium?.copyWith(
              color: ThemeConstants.warning,
              fontWeight: ThemeConstants.bold,
            ),
          ),
          const SizedBox(height: ThemeConstants.space2),
          Text(
            'يجب تفعيل الإشعارات أولاً لتتمكن من إعداد تذكيرات الأذكار',
            style: context.bodyMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeConstants.space4),
          AppButton.primary(
            text: 'تفعيل الإشعارات الآن',
            onPressed: _requestPermission,
            icon: Icons.notifications_active,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(AthkarCategory category) {
    final isEnabled = _enabled[category.id] ?? false;
    final currentTime = _customTimes[category.id] ?? 
        AthkarConstants.getDefaultTimeForCategory(category.id);
    final isAutoEnabled = AthkarConstants.shouldAutoEnable(category.id);
    final isEssential = AthkarConstants.isEssentialCategory(category.id);
    
    // الحصول على اللون والأيقونة المطابقة من CategoryUtils (فقط للأيقونات)
    final categoryColor = CategoryUtils.getCategoryThemeColor(category.id);
    final categoryIcon = CategoryUtils.getCategoryIcon(category.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeConstants.space3),
      child: AppCard(
        padding: const EdgeInsets.all(ThemeConstants.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // أيقونة الفئة بلون مطابق فقط
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  ),
                  child: Icon(
                    categoryIcon,
                    color: categoryColor,
                    size: ThemeConstants.iconMd,
                  ),
                ),
                
                const SizedBox(width: ThemeConstants.space3),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.title,
                              style: context.titleSmall?.copyWith(
                                fontWeight: ThemeConstants.semiBold,
                              ),
                            ),
                          ),
                          if (isEssential)
                            _buildBadge(
                              'أساسي',
                              ThemeConstants.success,
                            ),
                          if (isAutoEnabled && !isEssential)
                            _buildBadge(
                              'مفضل',
                              ThemeConstants.info,
                            ),
                        ],
                      ),
                      if (category.description?.isNotEmpty == true)
                        Text(
                          category.description!,
                          style: context.bodySmall?.copyWith(
                            color: context.textSecondaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                      // عدد الأذكار
                      Text(
                        '${category.athkar.length} ذكر',
                        style: context.labelSmall?.copyWith(
                          color: context.textSecondaryColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Switch(
                  value: isEnabled,
                  onChanged: _hasPermission 
                      ? (value) => _toggleCategory(category.id, value)
                      : null,
                  activeColor: isEssential 
                      ? ThemeConstants.success 
                      : ThemeConstants.primary,
                ),
              ],
            ),
            
            if (isEnabled) ...[
              const SizedBox(height: ThemeConstants.space3),
              _buildTimeSelector(
                category: category,
                currentTime: currentTime,
                isEssential: isEssential,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: ThemeConstants.space2),
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.space2,
        vertical: ThemeConstants.space1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXs),
      ),
      child: Text(
        label,
        style: context.labelSmall?.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: ThemeConstants.bold,
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required AthkarCategory category,
    required TimeOfDay currentTime,
    required bool isEssential,
  }) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space3),
      decoration: BoxDecoration(
        color: (isEssential ? ThemeConstants.success : ThemeConstants.primary)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        border: Border.all(
          color: (isEssential ? ThemeConstants.success : ThemeConstants.primary)
              .withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: ThemeConstants.iconSm,
            color: isEssential ? ThemeConstants.success : ThemeConstants.primary,
          ),
          const SizedBox(width: ThemeConstants.space2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'وقت التذكير: ${currentTime.format(context)}',
                  style: context.bodyMedium?.copyWith(
                    color: isEssential ? ThemeConstants.success : ThemeConstants.primary,
                    fontWeight: ThemeConstants.medium,
                  ),
                ),
                if (category.notifyTime == null)
                  Text(
                    'وقت افتراضي - يمكنك تغييره',
                    style: context.labelSmall?.copyWith(
                      color: (isEssential ? ThemeConstants.success : ThemeConstants.primary)
                          .withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _selectTime(category.id, currentTime),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConstants.space3,
              ),
            ),
            child: const Text('تغيير'),
          ),
        ],
      ),
    );
  }
}

/// ويدجت إحصائية صغيرة
class _StatItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: ThemeConstants.iconSm,
        ),
        const SizedBox(height: ThemeConstants.space1),
        Text(
          '$count',
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
        ),
      ],
    );
  }
}