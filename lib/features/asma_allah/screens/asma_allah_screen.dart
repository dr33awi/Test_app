// lib/features/asma_allah/screens/asma_allah_screen.dart - مع البحث في الشرح المفصل
import 'package:athkar_app/app/di/service_locator.dart';
import 'package:athkar_app/app/themes/app_theme.dart';
import 'package:athkar_app/core/infrastructure/services/storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/asma_allah_model.dart';
import '../services/asma_allah_service.dart';
import '../widgets/asma_allah_widgets.dart';
import 'asma_detail_screen.dart';

class AsmaAllahScreen extends StatefulWidget {
  const AsmaAllahScreen({super.key});
  @override
  State<AsmaAllahScreen> createState() => _AsmaAllahScreenState();
}

class _AsmaAllahScreenState extends State<AsmaAllahScreen> {
  late AsmaAllahService _service;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  
  // إعدادات العرض
  bool _showDetailedView = false;

  @override
  void initState() {
    super.initState();
    _service = AsmaAllahService(storage: getIt<StorageService>());
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _service.dispose();
    super.dispose();
  }

  List<AsmaAllahModel> _getFilteredList() {
    var list = _service.asmaAllahList;
    if (_searchQuery.isNotEmpty) {
      list = list.where((item) => 
        item.name.contains(_searchQuery) || 
        item.meaning.contains(_searchQuery) ||
        item.explanation.contains(_searchQuery) ||
        (item.reference?.contains(_searchQuery) ?? false)
      ).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _service,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // شريط التطبيق المحسن
              _buildEnhancedAppBar(),
              
              // المحتوى الرئيسي
              Expanded(
                child: _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Column(
        children: [
          // الصف الأول - العنوان والأزرار
          Row(
            children: [
              // زر الرجوع
              AppBackButton(
                onPressed: () => Navigator.of(context).pop(),
              ),
              
              ThemeConstants.space3.w,
              
              // أيقونة مميزة
              Container(
                padding: const EdgeInsets.all(ThemeConstants.space2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ThemeConstants.tertiary, ThemeConstants.tertiaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeConstants.tertiary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.star_outline,
                  color: Colors.white,
                  size: ThemeConstants.iconMd,
                ),
              ),
              
              ThemeConstants.space3.w,
              
              // معلومات العنوان
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أسماء الله الحسنى',
                      style: context.titleLarge?.copyWith(
                        fontWeight: ThemeConstants.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    Text(
                      'تسعة وتسعون اسماً من أحصاها دخل الجنة',
                      style: context.bodySmall?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // زر تبديل طريقة العرض
              _buildViewToggleButton(),
            ],
          ),
          
          ThemeConstants.space4.h,
          
          // شريط البحث المحسن
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton() {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        child: InkWell(
          onTap: () {
            setState(() => _showDetailedView = !_showDetailedView);
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(ThemeConstants.space2),
            child: Icon(
              _showDetailedView ? Icons.view_agenda_rounded : Icons.view_list_rounded,
              color: ThemeConstants.tertiary,
              size: ThemeConstants.iconMd,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        border: Border.all(
          color: context.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: context.bodyMedium,
        decoration: InputDecoration(
          hintText: 'ابحث في الأسماء أو المعاني أو الشرح والتفسير...',
          hintStyle: TextStyle(
            color: context.textSecondaryColor.withValues(alpha: 0.7),
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              color: context.textSecondaryColor,
              size: ThemeConstants.iconMd,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    margin: const EdgeInsetsDirectional.only(end: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.textSecondaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.clear_rounded,
                      color: context.textSecondaryColor,
                      size: 16,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.space4,
            vertical: ThemeConstants.space4,
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Consumer<AsmaAllahService>(
      builder: (_, service, __) {
        if (service.isLoading) {
          return _buildLoadingState();
        }
        
        final list = _getFilteredList();
        if (list.isEmpty) {
          return _buildEmptyState();
        }
        
        return _showDetailedView 
            ? _buildDetailedList(list)
            : _buildCompactList(list);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            decoration: BoxDecoration(
              color: ThemeConstants.tertiary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hourglass_empty_rounded, color: ThemeConstants.tertiary, size: 28),
          ),
          ThemeConstants.space4.h,
          Text(
            'جاري تحميل أسماء الله الحسنى...',
            style: context.titleMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          ThemeConstants.space2.h,
          Text(
            'يرجى الانتظار قليلاً',
            style: context.bodySmall?.copyWith(
              color: context.textSecondaryColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space6),
            decoration: BoxDecoration(
              color: context.textSecondaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 60,
              color: context.textSecondaryColor.withValues(alpha: 0.5),
            ),
          ),
          ThemeConstants.space4.h,
          Text(
            'لا توجد نتائج',
            style: context.titleLarge?.copyWith(
              color: context.textSecondaryColor,
              fontWeight: ThemeConstants.bold,
            ),
          ),
          ThemeConstants.space2.h,
          Text(
            'جرب البحث بكلمات أخرى أو امسح شريط البحث',
            style: context.bodyMedium?.copyWith(
              color: context.textSecondaryColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          ThemeConstants.space6.h,
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              HapticFeedback.lightImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.tertiary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConstants.space6,
                vertical: ThemeConstants.space3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
              ),
            ).copyWith(
              overlayColor: const MaterialStatePropertyAll(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('عرض جميع الأسماء'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactList(List<AsmaAllahModel> list) {
    return Column(
      children: [
        // عداد النتائج ونوع البحث
        if (_searchQuery.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.space4,
              vertical: ThemeConstants.space2,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 16,
                  color: context.textSecondaryColor,
                ),
                ThemeConstants.space1.w,
                Text(
                  'عدد النتائج: ${list.length}',
                  style: context.labelMedium?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConstants.space2,
                    vertical: ThemeConstants.space1,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeConstants.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
                  ),
                  child: Text(
                    'البحث في كامل المحتوى',
                    style: context.labelSmall?.copyWith(
                      color: ThemeConstants.tertiary,
                      fontWeight: ThemeConstants.medium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // القائمة المضغوطة
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(ThemeConstants.space4),
            physics: const ClampingScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Container(
                margin: const EdgeInsets.only(bottom: ThemeConstants.space2),
                child: CompactAsmaAllahCard(
                  item: item,
                  onTap: () => _openDetails(item),
                  showExplanationPreview: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedList(List<AsmaAllahModel> list) {
    return Column(
      children: [
        // عداد النتائج مع معلومات إضافية
        if (_searchQuery.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.space4,
              vertical: ThemeConstants.space2,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      size: 16,
                      color: context.textSecondaryColor,
                    ),
                    ThemeConstants.space1.w,
                    Text(
                      'عدد النتائج: ${list.length}',
                      style: context.labelMedium?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeConstants.space2,
                        vertical: ThemeConstants.space1,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeConstants.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(ThemeConstants.radiusSm),
                      ),
                      child: Text(
                        'العرض التفصيلي',
                        style: context.labelSmall?.copyWith(
                          color: ThemeConstants.primary,
                          fontWeight: ThemeConstants.medium,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        
        // القائمة التفصيلية
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(ThemeConstants.space4),
            physics: const BouncingScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return DetailedAsmaAllahCard(
                item: item,
                onTap: () => _openDetails(item),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openDetails(AsmaAllahModel item) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) => UnifiedAsmaAllahDetailsScreen(
          item: item,
          service: _service,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
      ),
    );
  }
}