// lib/features/asma_allah/screens/asma_allah_screen.dart
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

  @override
  void initState() {
    super.initState();
    _service = AsmaAllahService(storage: getIt<StorageService>());
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _service.dispose();
    super.dispose();
  }

  List<AsmaAllahModel> _getFilteredList() {
    var list = _service.asmaAllahList;
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
            SliverToBoxAdapter(child: _buildSearchAndFilters()),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildEnhancedSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 260,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF2E7D32), // لون أخضر بدلاً من البنفسجي
      foregroundColor: Colors.white,
      title: null,
      actions: const [],
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
                border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.20)), // لون أخضر
              ),
              child: TextField(
                controller: _searchController,
                style: context.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'ابحث عن اسم أو معنى...',
                  hintStyle: TextStyle(color: context.isDarkMode ? Colors.white54 : Colors.grey[600]),
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
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<AsmaAllahService>(builder: (_, service, __) {
      if (service.isLoading) {
        return const SliverFillRemaining(
          child: Center(child: AppLoading(type: LoadingType.circular, size: LoadingSize.large, color: Color(0xFF2E7D32))), // لون أخضر
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
      return _buildListView(list);
    });
  }

  Widget _buildListView(List<AsmaAllahModel> list) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final item = list[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EnhancedAsmaAllahCard(item: item, onTap: () => _openDetails(item)),
            );
          },
          childCount: list.length,
        ),
      ),
    );
  }

  void _openDetails(AsmaAllahModel item) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AsmaAllahDetailsScreen(item: item, service: _service),
    ));
  }
}