
import 'package:athkar_app/app/themes/widgets/core/islamic_pattern_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_theme.dart';
import '../models/asma_allah_model.dart';
import '../data/asma_allah_data.dart';
import '../widgets/asma_card.dart';
import '../widgets/asma_search_delegate.dart';
import 'asma_detail_screen.dart';

class AsmaAllahScreen extends StatefulWidget {
  const AsmaAllahScreen({super.key});

  @override
  State<AsmaAllahScreen> createState() => _AsmaAllahScreenState();
}

class _AsmaAllahScreenState extends State<AsmaAllahScreen> 
    with SingleTickerProviderStateMixin {
  
  // Controllers
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  // Data
  List<AsmaAllahModel> allNames = AsmaAllahData.allNames;
  List<AsmaAllahModel> favoriteNames = [];
  List<AsmaAllahModel> displayedNames = [];
  
  // UI State
  bool _showScrollToTop = false;
  bool _isGridView = false;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    displayedNames = allNames;
    _loadFavorites();
    
    // Listen to scroll
    _scrollController.addListener(() {
      setState(() {
        _showScrollToTop = _scrollController.offset > 200;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _loadFavorites() {
    // Load favorites from storage
    setState(() {
      favoriteNames = allNames.where((name) => name.isFavorite).toList();
    });
  }
  
  void _toggleFavorite(AsmaAllahModel name) {
    setState(() {
      final index = allNames.indexWhere((n) => n.id == name.id);
      if (index != -1) {
        allNames[index] = allNames[index].copyWith(
          isFavorite: !allNames[index].isFavorite
        );
        _loadFavorites();
      }
    });
    
    HapticFeedback.lightImpact();
    
    // Show feedback
    context.showSuccessSnackBar(
      name.isFavorite 
        ? 'تمت الإزالة من المفضلة' 
        : 'تمت الإضافة إلى المفضلة'
    );
  }
  
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: ThemeConstants.durationSlow,
      curve: ThemeConstants.curveDefault,
    );
  }
  
  void _openSearch() {
    showSearch(
      context: context,
      delegate: AsmaSearchDelegate(
        allNames: allNames,
        onNameSelected: (name) => _openDetail(name),
      ),
    );
  }
  
  void _openDetail(AsmaAllahModel name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AsmaDetailScreen(
          asmaAllah: name,
          onFavoriteToggle: () => _toggleFavorite(name),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // AppBar مخصص
            SliverAppBar(
              expandedHeight: 200,
              floating: true,
              pinned: true,
              backgroundColor: const Color(0xFF6B46C1),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'أسماء الله الحسنى',
                  style: context.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: ThemeConstants.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // خلفية متدرجة
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF6B46C1),
                            const Color(0xFF9F7AEA).withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                    
                    // نمط زخرفي
                    CustomPaint(
                      painter: IslamicPatternPainter(
                        color: Colors.white.withValues(alpha: 0.1),
                        patternType: PatternType.geometric,
                        rotation: 0,
                        opacity: 0.1,
                      ),
                    ),
                    
                    // نص الآية
                    Positioned(
                      bottom: 60,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeConstants.space6,
                            vertical: ThemeConstants.space2,
                          ),
                          child: Text(
                            'وَلِلَّهِ الْأَسْمَاءُ الْحُسْنَىٰ فَادْعُوهُ بِهَا',
                            style: context.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 18,
                              fontFamily: ThemeConstants.fontFamilyQuran,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // أزرار الإجراءات
              actions: [
                // زر البحث
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _openSearch,
                  tooltip: 'بحث',
                ),
                
                // تبديل العرض
                IconButton(
                  icon: Icon(
                    _isGridView ? Icons.view_list : Icons.grid_view,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                    HapticFeedback.lightImpact();
                  },
                  tooltip: _isGridView ? 'عرض كقائمة' : 'عرض كشبكة',
                ),
              ],
              
              // TabBar
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.list),
                    text: 'جميع الأسماء (${allNames.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.favorite),
                    text: 'المفضلة (${favoriteNames.length})',
                  ),
                ],
              ),
            ),
          ];
        },
        
        // المحتوى الرئيسي
        body: TabBarView(
          controller: _tabController,
          children: [
            // تبويب جميع الأسماء
            _buildNamesList(allNames),
            
            // تبويب المفضلة
            _buildFavoritesList(),
          ],
        ),
      ),
      
      // زر العودة للأعلى
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: const Color(0xFF6B46C1),
              mini: true,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
    );
  }
  
  Widget _buildNamesList(List<AsmaAllahModel> names) {
    if (names.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: context.textSecondaryColor.withValues(alpha: 0.5),
            ),
            ThemeConstants.space3.h,
            Text(
              'لا توجد نتائج',
              style: context.titleLarge?.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }
    
    // عرض شبكي
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(ThemeConstants.space4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: ThemeConstants.space3,
          mainAxisSpacing: ThemeConstants.space3,
        ),
        itemCount: names.length,
        itemBuilder: (context, index) {
          final name = names[index];
          return AsmaCard(
            asmaAllah: name,
            isGridView: true,
            onTap: () => _openDetail(name),
            onFavoriteToggle: () => _toggleFavorite(name),
          );
        },
      );
    }
    
    // عرض كقائمة
    return ListView.builder(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      itemCount: names.length,
      itemBuilder: (context, index) {
        final name = names[index];
        return AsmaCard(
          asmaAllah: name,
          isGridView: false,
          onTap: () => _openDetail(name),
          onFavoriteToggle: () => _toggleFavorite(name),
        );
      },
    );
  }
  
  Widget _buildFavoritesList() {
    if (favoriteNames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 60,
                color: const Color(0xFF6B46C1).withValues(alpha: 0.5),
              ),
            ),
            ThemeConstants.space4.h,
            Text(
              'لا توجد أسماء في المفضلة',
              style: context.titleLarge?.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            ThemeConstants.space2.h,
            Text(
              'اضغط على أيقونة القلب لإضافة الأسماء',
              style: context.bodyMedium?.copyWith(
                color: context.textSecondaryColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }
    
    return _buildNamesList(favoriteNames);
  }
}