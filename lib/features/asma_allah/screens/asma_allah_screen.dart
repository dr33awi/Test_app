// ============================================
import 'package:athkar_app/app/di/service_locator.dart';
import 'package:athkar_app/app/themes/app_theme.dart';
import 'package:athkar_app/core/infrastructure/services/storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/asma_allah_model.dart';
import '../services/asma_allah_service.dart';
import '../widgets/asma_allah_widgets.dart';
import '../extensions/asma_allah_extensions.dart';
import 'asma_detail_screen.dart';

class AsmaAllahScreen extends StatefulWidget {
  const AsmaAllahScreen({super.key});
  @override
  State<AsmaAllahScreen> createState() => _AsmaAllahScreenState();
}

class _AsmaAllahScreenState extends State<AsmaAllahScreen> with SingleTickerProviderStateMixin {
  late AsmaAllahService _service;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isGridView = false;

  late final AnimationController _animationController =
      AnimationController(duration: const Duration(milliseconds: 800), vsync: this)..forward();
  late final Animation<double> _fadeAnimation =
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

  final List<String> _categories = const ['الكل', 'الرحمة', 'القوة والعزة', 'العلم والحكمة', 'الخلق والرزق', 'المغفرة'];
  String _selectedCategory = 'الكل';

  @override
  void initState() {
    super.initState();
    _service = AsmaAllahService(storage: getIt<StorageService>());
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _service.dispose();
    super.dispose();
  }

  List<AsmaAllahModel> _getFilteredList() {
    var list = _service.asmaAllahList;
    if (_selectedCategory != 'الكل') {
      list = list.where((item) {
        final n = item.name;
        switch (_selectedCategory) {
          case 'الرحمة':
            return n.contains('رحم') || n.contains('رحيم') || n.contains('رؤوف') || n.contains('ودود');
          case 'القوة والعزة':
            return n.contains('عزيز') || n.contains('قوي') || n.contains('جبار') || n.contains('قهار') || n.contains('متين') || n.contains('قادر');
          case 'العلم والحكمة':
            return n.contains('عليم') || n.contains('حكيم') || n.contains('خبير') || n.contains('سميع') || n.contains('بصير');
          case 'الخلق والرزق':
            return n.contains('خالق') || n.contains('بارئ') || n.contains('مصور') || n.contains('رزاق') || n.contains('وهاب');
          case 'المغفرة':
            return n.contains('غفور') || n.contains('غفار') || n.contains('تواب') || n.contains('عفو');
          default:
            return true;
        }
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((item) => item.name.contains(_searchQuery) || item.meaning.contains(_searchQuery)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _service,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: CustomScrollView(
          slivers: [
            _buildEnhancedSliverAppBar(),
            SliverToBoxAdapter(child: FadeTransition(opacity: _fadeAnimation, child: _buildSearchAndFilters())),
            SliverToBoxAdapter(child: FadeTransition(opacity: _fadeAnimation, child: _buildCategoryChips())),
            _buildContent(),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  SliverAppBar _buildEnhancedSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF6B46C1),
      foregroundColor: Colors.white,
      title: AnimatedOpacity(
        opacity: _searchQuery.isEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFFFC107), Colors.white],
          ).createShader(bounds),
          child: const Text(
            'أسماء الله الحسنى',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.25),
                Colors.white.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.format_list_numbered,
                size: 20,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Consumer<AsmaAllahService>(
                builder: (_, __, ___) {
                  final filteredCount = _getFilteredList().length;
                  return TweenAnimationBuilder<int>(
                    duration: const Duration(milliseconds: 300),
                    tween: IntTween(begin: 0, end: filteredCount),
                    builder: (context, value, child) {
                      return Text(
                        '$value',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            const EnhancedAsmaAllahHeader(),
            // Additional overlay for smooth transition
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xFF6B46C1).withValues(alpha: 0.1),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.isDarkMode 
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey[50]!,
                    context.isDarkMode 
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.grey[100]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _searchQuery.isNotEmpty
                      ? const Color(0xFF6B46C1).withValues(alpha: 0.6)
                      : const Color(0xFF6B46C1).withValues(alpha: 0.2),
                  width: _searchQuery.isNotEmpty ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: context.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث في الأسماء أو المعاني...',
                  hintStyle: TextStyle(
                    color: context.isDarkMode ? Colors.white54 : Colors.grey[600],
                    fontSize: 15,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search,
                      color: _searchQuery.isNotEmpty
                          ? const Color(0xFF6B46C1)
                          : const Color(0xFF6B46C1).withValues(alpha: 0.7),
                      size: 22,
                    ),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[600]?.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              HapticFeedback.lightImpact();
                            },
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Enhanced toggle button with better animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6B46C1),
                        const Color(0xFF9F7AEA),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B46C1).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() => _isGridView = !_isGridView);
                        HapticFeedback.mediumImpact();
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _isGridView ? Icons.view_list : Icons.grid_view,
                          key: ValueKey(_isGridView),
                          color: Colors.white,
                          size: 24,
                        ),
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

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final category = _categories[i];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(left: 10),
            child: TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 200 + (i * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                context.isDarkMode 
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.grey[100]!,
                                context.isDarkMode 
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.grey[50]!,
                              ],
                            ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? Colors.transparent
                            : const Color(0xFF6B46C1).withValues(alpha: 0.3),
                        width: isSelected ? 0 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF6B46C1).withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          setState(() => _selectedCategory = category);
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                category,
                                style: TextStyle(
                                  color: isSelected 
                                      ? Colors.white 
                                      : const Color(0xFF6B46C1),
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  fontSize: 14,
                                  shadows: isSelected 
                                      ? [
                                          Shadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<AsmaAllahService>(builder: (_, service, __) {
      if (service.isLoading) {
        return const SliverFillRemaining(
          child: Center(child: AppLoading(type: LoadingType.circular, size: LoadingSize.large, color: Color(0xFF6B46C1))),
        );
      }
      final list = _getFilteredList();
      if (list.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('لا توجد نتائج', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('جرب البحث بكلمات أخرى', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            ]),
          ),
        );
      }
      return _isGridView ? _buildGridView(list) : _buildListView(list);
    });
  }

  Widget _buildListView(List<AsmaAllahModel> list) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final item = list[i];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (i * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (_, v, child) => Transform.translate(
                offset: Offset(0, 30 * (1 - v)),
                child: Transform.scale(
                  scale: 0.8 + (0.2 * v),
                  child: Opacity(
                    opacity: v,
                    child: child,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EnhancedAsmaAllahCard(
                  item: item,
                  onTap: () => _openDetails(item),
                ),
              ),
            );
          },
          childCount: list.length,
        ),
      ),
    );
  }

  Widget _buildGridView(List<AsmaAllahModel> list) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final item = list[i];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (i * 80)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (_, v, child) => Transform.scale(
                scale: 0.6 + (0.4 * v),
                child: Transform.rotate(
                  angle: (1 - v) * 0.2,
                  child: Opacity(
                    opacity: v,
                    child: child,
                  ),
                ),
              ),
              child: AsmaAllahGridCard(
                item: item,
                onTap: () => _openDetails(item),
              ),
            );
          },
          childCount: list.length,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Transform.rotate(
            angle: (1 - value) * math.pi * 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B46C1).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _scrollToRandom,
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background glow effect
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Icon with animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(seconds: 2),
                      tween: Tween(begin: 0.0, end: 2 * math.pi),
                      builder: (context, rotationValue, child) {
                        return Transform.rotate(
                          angle: rotationValue,
                          child: const Icon(
                            Icons.casino,
                            color: Colors.white,
                            size: 28,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                tooltip: 'اسم عشوائي',
              ),
            ),
          ),
        );
      },
    );
  }

  void _scrollToRandom() {
    final list = _getFilteredList();
    if (list.isEmpty) return;
    final randomIndex = DateTime.now().millisecondsSinceEpoch % list.length;
    _openDetails(list[randomIndex]);
  }

  void _openDetails(AsmaAllahModel item) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            AsmaAllahDetailsScreen(item: item, service: _service),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Enhanced page transition with multiple effects
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          final slideAnimation = animation.drive(
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve)),
          );

          final scaleAnimation = animation.drive(
            Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve)),
          );

          final fadeAnimation = animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)),
          );

          return SlideTransition(
            position: slideAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}
