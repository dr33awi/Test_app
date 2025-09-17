// lib/features/asma_allah/widgets/asma_search_delegate.dart

import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';
import '../models/asma_allah_model.dart';

class AsmaSearchDelegate extends SearchDelegate<AsmaAllahModel?> {
  final List<AsmaAllahModel> allNames;
  final Function(AsmaAllahModel) onNameSelected;

  AsmaSearchDelegate({
    required this.allNames,
    required this.onNameSelected,
  }) : super(
    searchFieldLabel: 'ابحث عن اسم...',
    keyboardType: TextInputType.text,
    textInputAction: TextInputAction.search,
  );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _searchNames();
    
    if (results.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return _buildResultsList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildPopularNames(context);
    }
    
    final suggestions = _searchNames();
    
    if (suggestions.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return _buildResultsList(context, suggestions);
  }

  List<AsmaAllahModel> _searchNames() {
    if (query.isEmpty) return allNames;
    
    final searchQuery = query.toLowerCase();
    
    return allNames.where((name) {
      return name.name.toLowerCase().contains(searchQuery) ||
             name.transliteration.toLowerCase().contains(searchQuery) ||
             name.meaning.toLowerCase().contains(searchQuery) ||
             name.id.toString() == searchQuery;
    }).toList();
  }

  Widget _buildResultsList(BuildContext context, List<AsmaAllahModel> names) {
    return ListView.builder(
      padding: const EdgeInsets.all(ThemeConstants.space4),
      itemCount: names.length,
      itemBuilder: (context, index) {
        final name = names[index];
        return _buildSearchItem(context, name);
      },
    );
  }

  Widget _buildSearchItem(BuildContext context, AsmaAllahModel name) {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConstants.space3),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusLg),
        border: Border.all(
          color: context.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        onTap: () {
          close(context, name);
          onNameSelected(name);
        },
        leading: Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6B46C1),
                Color(0xFF9F7AEA),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              name.id.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: RichText(
          text: TextSpan(
            children: _highlightSearchQuery(name.name, context),
            style: context.titleMedium?.copyWith(
              fontWeight: ThemeConstants.bold,
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: _highlightSearchQuery(name.transliteration, context, isSubtitle: true),
                style: context.labelSmall?.copyWith(
                  color: const Color(0xFF6B46C1),
                ),
              ),
            ),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                children: _highlightSearchQuery(name.meaning, context, isSubtitle: true),
                style: context.bodySmall?.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: context.textSecondaryColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  List<TextSpan> _highlightSearchQuery(String text, BuildContext context, {bool isSubtitle = false}) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }
    
    final matches = RegExp(query, caseSensitive: false).allMatches(text);
    
    if (matches.isEmpty) {
      return [TextSpan(text: text)];
    }
    
    final spans = <TextSpan>[];
    int start = 0;
    
    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: TextStyle(
          backgroundColor: const Color(0xFF6B46C1).withValues(alpha: 0.2),
          fontWeight: FontWeight.bold,
          color: isSubtitle ? const Color(0xFF6B46C1) : null,
        ),
      ));
      
      start = match.end;
    }
    
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    
    return spans;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: context.textSecondaryColor.withValues(alpha: 0.3),
          ),
          ThemeConstants.space3.h,
          Text(
            'لم يتم العثور على نتائج',
            style: context.titleLarge?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          ThemeConstants.space2.h,
          Text(
            'جرب البحث بكلمة أخرى',
            style: context.bodyMedium?.copyWith(
              color: context.textSecondaryColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularNames(BuildContext context) {
    // أشهر الأسماء للعرض كاقتراحات
    final popularNames = [
      allNames.firstWhere((n) => n.id == 1),  // الله
      allNames.firstWhere((n) => n.id == 2),  // الرحمن
      allNames.firstWhere((n) => n.id == 3),  // الرحيم
      allNames.firstWhere((n) => n.id == 15), // الغفار
      allNames.firstWhere((n) => n.id == 18), // الرزاق
    ];
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ThemeConstants.space4),
          color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
          child: Text(
            'الأسماء الأكثر بحثاً',
            style: context.titleMedium?.copyWith(
              color: const Color(0xFF6B46C1),
              fontWeight: ThemeConstants.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(ThemeConstants.space4),
            itemCount: popularNames.length,
            itemBuilder: (context, index) {
              return _buildSearchItem(context, popularNames[index]);
            },
          ),
        ),
      ],
    );
  }
}