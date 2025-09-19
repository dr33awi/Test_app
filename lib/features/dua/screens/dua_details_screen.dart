// lib/features/dua/screens/dua_details_screen.dart - محسن ومتناسق
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/di/service_locator.dart';
import '../services/dua_service.dart';
import '../models/dua_model.dart';
import '../widgets/dua_card_widget.dart';

class DuaDetailsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const DuaDetailsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<DuaDetailsScreen> createState() => _DuaDetailsScreenState();
}

class _DuaDetailsScreenState extends State<DuaDetailsScreen> {
  late final DuaService _duaService;
  
  List<Dua> _duas = [];
  bool _isLoading = true;
  double _fontSize = 18.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _duaService = getService<DuaService>();
    _loadDuas();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDuas() async {
    try {
      setState(() => _isLoading = true);
      
      _duas = await _duaService.getDuasByCategory(widget.categoryId);
      
      // تحميل حجم الخط المحفوظ
      _fontSize = await _duaService.getSavedFontSize();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showErrorSnackBar('حدث خطأ في تحميل الأدعية');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // شريط التطبيق المحسن (متناسق مع أسماء الله الحسنى)
            _buildEnhancedAppBar(),
            
            // المحتوى الرئيسي
            Expanded(
              child: _isLoading ? _buildLoading() : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar() {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      child: Row(
        children: [
          // زر الرجوع (متناسق مع أسماء الله الحسنى)
          AppBackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          ThemeConstants.space3.w,
          
          // أيقونة مميزة (نفس ستايل أسماء الله الحسنى)
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ThemeConstants.primary, ThemeConstants.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: ThemeConstants.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: ThemeConstants.iconMd,
            ),
          ),
          
          ThemeConstants.space3.w,
          
          // معلومات الفئة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryName,
                  style: context.titleLarge?.copyWith(
                    fontWeight: ThemeConstants.bold,
                    color: context.textPrimaryColor,
                  ),
                ),
                Text(
                  '${_duas.length} دعاء',
                  style: context.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // أزرار الإجراءات (نفس ستايل أسماء الله الحسنى)
          _buildActionButton(
            icon: Icons.text_fields_rounded,
            onTap: _showFontSizeDialog,
          ),
          
          _buildActionButton(
            icon: Icons.refresh_rounded,
            onTap: _loadDuas,
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
              color: isSecondary ? context.textSecondaryColor : ThemeConstants.primary,
              size: ThemeConstants.iconMd,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            decoration: BoxDecoration(
              color: ThemeConstants.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: ThemeConstants.primary,
              strokeWidth: 3,
            ),
          ),
          ThemeConstants.space4.h,
          Text(
            'جاري تحميل ${widget.categoryName}...',
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

  Widget _buildContent() {
    if (_duas.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // إحصائيات الأدعية
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.space4,
            vertical: ThemeConstants.space2,
          ),
          child: Row(
            children: [
              Icon(
                Icons.format_list_numbered_rounded,
                size: 16,
                color: context.textSecondaryColor,
              ),
              ThemeConstants.space1.w,
              Text(
                'عدد الأدعية: ${_duas.length}',
                style: context.labelMedium?.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
              
              const Spacer(),
              
              // عدد الأدعية المقروءة
              if (_duas.any((d) => d.readCount > 0)) ...[
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: ThemeConstants.accent,
                ),
                ThemeConstants.space1.w,
                Text(
                  'مقروءة: ${_duas.where((d) => d.readCount > 0).length}',
                  style: context.labelMedium?.copyWith(
                    color: ThemeConstants.accent,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // قائمة الأدعية
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(ThemeConstants.space4),
            physics: const BouncingScrollPhysics(),
            itemCount: _duas.length,
            itemBuilder: (context, index) {
              final dua = _duas[index];
              
              return Container(
                margin: const EdgeInsets.only(bottom: ThemeConstants.space3),
                child: DuaCardWidget(
                  dua: dua,
                  index: index,
                  fontSize: _fontSize,
                  onTap: () => _onDuaTap(dua),
                  onShare: () => _shareDua(dua),
                  onCopy: () => _copyDua(dua),
                ),
              );
            },
          ),
        ),
      ],
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
              Icons.menu_book_outlined,
              size: 60,
              color: context.textSecondaryColor.withValues(alpha: 0.5),
            ),
          ),
          ThemeConstants.space4.h,
          Text(
            'لا توجد أدعية',
            style: context.titleLarge?.copyWith(
              color: context.textSecondaryColor,
              fontWeight: ThemeConstants.bold,
            ),
          ),
          ThemeConstants.space2.h,
          Text(
            'لا توجد أدعية في هذه الفئة حالياً',
            style: context.bodyMedium?.copyWith(
              color: context.textSecondaryColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          ThemeConstants.space6.h,
          ElevatedButton.icon(
            onPressed: _loadDuas,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConstants.space6,
                vertical: ThemeConstants.space3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusXl),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ThemeConstants.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              ),
              child: const Icon(
                Icons.text_fields_rounded,
                color: ThemeConstants.primary,
                size: 20,
              ),
            ),
            ThemeConstants.space2.w,
            const Text('حجم الخط'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFontSizeOption('صغير', 16.0),
            _buildFontSizeOption('متوسط', 18.0),
            _buildFontSizeOption('كبير', 22.0),
            _buildFontSizeOption('كبير جداً', 26.0),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeOption(String label, double size) {
    final isSelected = _fontSize == size;
    
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConstants.space2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
        child: InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();
            setState(() => _fontSize = size);
            
            // حفظ حجم الخط المختار
            await _duaService.saveFontSize(size);
            
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(ThemeConstants.space3),
            decoration: BoxDecoration(
              color: isSelected 
                  ? ThemeConstants.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusMd),
              border: Border.all(
                color: isSelected 
                    ? ThemeConstants.primary.withValues(alpha: 0.3)
                    : context.dividerColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected ? ThemeConstants.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? ThemeConstants.primary : context.textSecondaryColor,
                    ),
                  ),
                  child: isSelected 
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
                ThemeConstants.space3.w,
                Expanded(
                  child: Text(
                    label,
                    style: context.bodyLarge?.copyWith(
                      fontSize: size,
                      fontWeight: isSelected ? ThemeConstants.semiBold : ThemeConstants.regular,
                      color: isSelected ? ThemeConstants.primary : context.textPrimaryColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.textSecondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusFull),
                  ),
                  child: Text(
                    '${size.toInt()}',
                    style: context.labelSmall?.copyWith(
                      color: context.textSecondaryColor,
                      fontWeight: ThemeConstants.medium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDuaTap(Dua dua) {
    HapticFeedback.lightImpact();
    // تسجيل قراءة الدعاء
    _duaService.markDuaAsRead(dua.id);
    
    // تحديث حالة الدعاء في القائمة
    setState(() {
      final index = _duas.indexWhere((d) => d.id == dua.id);
      if (index != -1) {
        _duas[index] = dua.copyWith(
          readCount: dua.readCount + 1,
          lastRead: DateTime.now(),
        );
      }
    });
  }

  void _shareDua(Dua dua) {
    HapticFeedback.lightImpact();
    
    final text = '''${dua.title}

${dua.arabicText}

${dua.source != null ? 'المصدر: ${dua.source}' : ''}
${dua.reference != null ? 'المرجع: ${dua.reference}' : ''}

من تطبيق أذكاري - الأدعية المأثورة''';
    
    Clipboard.setData(ClipboardData(text: text));
    context.showSuccessSnackBar('تم نسخ الدعاء للمشاركة');
  }

  void _copyDua(Dua dua) {
    HapticFeedback.lightImpact();
    
    Clipboard.setData(ClipboardData(text: dua.arabicText));
    context.showSuccessSnackBar('تم نسخ الدعاء');
  }
}