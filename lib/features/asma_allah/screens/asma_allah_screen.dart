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
      expandedHeight: 260,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF6B46C1),
      foregroundColor: Colors.white,
      title: AnimatedOpacity(
        opacity: _searchQuery.isEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: const Text('أسماء الله الحسنى', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.20), borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            const Icon(Icons.format_list_numbered, size: 18),
            const SizedBox(width: 4),
            Consumer<AsmaAllahService>(builder: (_, __, ___) {
              final filteredCount = _getFilteredList().length;
              return Text('$filteredCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
            }),
          ]),
        ),
      ],
      flexibleSpace: const FlexibleSpaceBar(background: EnhancedAsmaAllahHeader()),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: context.isDarkMode ? Colors.white.withOpacity(0.10) : Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFF6B46C1).withOpacity(0.20)),
              ),
              child: TextField(
                controller: _searchController,
                style: context.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'ابحث عن اسم أو معنى...',
                  hintStyle: TextStyle(color: context.isDarkMode ? Colors.white54 : Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: const Color(0xFF6B46C1).withOpacity(0.70)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: () {
                            _searchController.clear();
                            HapticFeedback.lightImpact();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)]),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: const Color(0xFF6B46C1).withOpacity(0.30), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  setState(() => _isGridView = !_isGridView);
                  HapticFeedback.lightImpact();
                },
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.grid_view, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final category = _categories[i];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF6B46C1),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedCategory = category);
                HapticFeedback.lightImpact();
              },
              backgroundColor: Colors.transparent,
              selectedColor: const Color(0xFF6B46C1),
              side: BorderSide(
                color: isSelected ? const Color(0xFF6B46C1) : const Color(0xFF6B46C1).withOpacity(0.30),
                width: isSelected ? 2 : 1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              duration: Duration(milliseconds: 300 + (i * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (_, v, child) => Transform.translate(offset: Offset(0, 20 * (1 - v)), child: Opacity(opacity: v, child: child)),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: EnhancedAsmaAllahCard(item: item, onTap: () => _openDetails(item)),
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
          childAspectRatio: 1.0,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final item = list[i];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (i * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (_, v, child) => Transform.scale(scale: v, child: Opacity(opacity: v, child: child)),
              child: AsmaAllahGridCard(item: item, onTap: () => _openDetails(item)),
            );
          },
          childCount: list.length,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _scrollToRandom,
      backgroundColor: const Color(0xFF6B46C1),
      child: const Icon(Icons.casino, color: Colors.white),
      tooltip: 'اسم عشوائي',
    );
  }

  void _scrollToRandom() {
    final list = _getFilteredList();
    if (list.isEmpty) return;
    final randomIndex = DateTime.now().millisecondsSinceEpoch % list.length;
    _openDetails(list[randomIndex]);
  }

  void _openDetails(AsmaAllahModel item) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, animation, __) => AsmaAllahDetailsScreen(item: item, service: _service),
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    ));
  }
}
