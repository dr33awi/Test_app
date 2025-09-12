// lib/features/tasbih/models/dhikr_model.dart
import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';

/// نموذج بيانات الذكر
class DhikrItem {
  final String id;
  final String text;
  final String? virtue; // الفضل
  final int recommendedCount;
  final DhikrCategory category;
  final List<Color> gradient;
  final Color primaryColor;
  final bool isCustom;

  const DhikrItem({
    required this.id,
    required this.text,
    this.virtue,
    required this.recommendedCount,
    required this.category,
    required this.gradient,
    required this.primaryColor,
    this.isCustom = false,
  });

  factory DhikrItem.fromMap(Map<String, dynamic> map) {
    return DhikrItem(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      virtue: map['virtue'],
      recommendedCount: map['recommendedCount'] ?? 33,
      category: DhikrCategory.values.firstWhere(
        (cat) => cat.name == map['category'],
        orElse: () => DhikrCategory.tasbih,
      ),
      gradient: _parseGradient(map['gradient']),
      primaryColor: Color(map['primaryColor'] ?? 0xFF4CAF50),
      isCustom: map['isCustom'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'virtue': virtue,
      'recommendedCount': recommendedCount,
      'category': category.name,
      'gradient': gradient.map((c) => c.value).toList(),
      'primaryColor': primaryColor.value,
      'isCustom': isCustom,
    };
  }

  static List<Color> _parseGradient(dynamic gradientData) {
    if (gradientData is List) {
      return gradientData.map((color) => Color(color as int)).toList();
    }
    return [ThemeConstants.primary, ThemeConstants.primaryLight];
  }

  DhikrItem copyWith({
    String? id,
    String? text,
    String? virtue,
    int? recommendedCount,
    DhikrCategory? category,
    List<Color>? gradient,
    Color? primaryColor,
    bool? isCustom,
  }) {
    return DhikrItem(
      id: id ?? this.id,
      text: text ?? this.text,
      virtue: virtue ?? this.virtue,
      recommendedCount: recommendedCount ?? this.recommendedCount,
      category: category ?? this.category,
      gradient: gradient ?? this.gradient,
      primaryColor: primaryColor ?? this.primaryColor,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

/// تصنيفات الأذكار
enum DhikrCategory {
  tasbih('التسبيح', Icons.radio_button_checked),
  tahmid('التحميد', Icons.favorite),
  takbir('التكبير', Icons.star),
  tahlil('التهليل', Icons.brightness_high),
  istighfar('الاستغفار', Icons.healing),
  salawat('الصلاة على النبي', Icons.mosque);

  const DhikrCategory(this.title, this.icon);
  
  final String title;
  final IconData icon;
}

/// مجموعة الأذكار الافتراضية
class DefaultAdhkar {
  static List<DhikrItem> getAll() {
    return [
      // التسبيح
      const DhikrItem(
        id: 'subhan_allah',
        text: 'سُبْحَانَ اللهِ',
        virtue: 'من قال سبحان الله مائة مرة حطت خطاياه وإن كانت مثل زبد البحر',
        recommendedCount: 33,
        category: DhikrCategory.tasbih,
        gradient: [ThemeConstants.primary, ThemeConstants.primaryLight],
        primaryColor: ThemeConstants.primary,
      ),
      
      DhikrItem(
        id: 'subhan_allah_wa_bihamdihi',
        text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
        virtue: 'من قال سبحان الله وبحمده في يوم مائة مرة حطت خطاياه وإن كانت مثل زبد البحر',
        recommendedCount: 100,
        category: DhikrCategory.tasbih,
        gradient: [ThemeConstants.primary.lighten(0.1), ThemeConstants.primary],
        primaryColor: ThemeConstants.primary,
      ),
      
      DhikrItem(
        id: 'subhan_allah_azeem',
        text: 'سُبْحَانَ اللهِ الْعَظِيمِ',
        virtue: 'كلمة خفيفة على اللسان ثقيلة في الميزان حبيبة إلى الرحمن',
        recommendedCount: 33,
        category: DhikrCategory.tasbih,
        gradient: [ThemeConstants.primary.darken(0.1), ThemeConstants.primary],
        primaryColor: ThemeConstants.primary,
      ),

      DhikrItem(
        id: 'subhan_allah_wa_bihamdihi_subhan_allah_azeem',
        text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ سُبْحَانَ اللهِ الْعَظِيمِ',
        virtue: 'كلمتان خفيفتان على اللسان ثقيلتان في الميزان حبيبتان إلى الرحمن',
        recommendedCount: 10,
        category: DhikrCategory.tasbih,
        gradient: [ThemeConstants.primary.lighten(0.2), ThemeConstants.primary.darken(0.1)],
        primaryColor: ThemeConstants.primary,
      ),

      // التحميد
      const DhikrItem(
        id: 'alhamdulillah',
        text: 'الْحَمْدُ لِلّهِ',
        virtue: 'الحمد لله تملأ الميزان، والتسبيح والتكبير تملآن أو تملأ ما بين السماء والأرض',
        recommendedCount: 33,
        category: DhikrCategory.tahmid,
        gradient: [ThemeConstants.accent, ThemeConstants.accentLight],
        primaryColor: ThemeConstants.accent,
      ),
      
      DhikrItem(
        id: 'alhamdulillah_rabbil_alameen',
        text: 'الْحَمْدُ لِلّهِ رَبِّ الْعَالَمِينَ',
        virtue: 'فاتحة الكتاب وأم القرآن، من أعظم السور في كتاب الله',
        recommendedCount: 25,
        category: DhikrCategory.tahmid,
        gradient: [ThemeConstants.accent.lighten(0.1), ThemeConstants.accent],
        primaryColor: ThemeConstants.accent,
      ),

      DhikrItem(
        id: 'alhamdulillah_kathiran',
        text: 'الْحَمْدُ لِلّهِ كَثِيرًا طَيِّبًا مُبَارَكًا فِيهِ',
        virtue: 'من التحميدات المباركة التي يضاعف الله بها الحسنات',
        recommendedCount: 10,
        category: DhikrCategory.tahmid,
        gradient: [ThemeConstants.accent.darken(0.1), ThemeConstants.accent.lighten(0.1)],
        primaryColor: ThemeConstants.accent,
      ),

      // التكبير
      const DhikrItem(
        id: 'allahu_akbar',
        text: 'اللهُ أَكْبَرُ',
        virtue: 'التكبير يملأ ما بين السماء والأرض، وهو من أحب الكلام إلى الله',
        recommendedCount: 34,
        category: DhikrCategory.takbir,
        gradient: [ThemeConstants.tertiary, ThemeConstants.tertiaryLight],
        primaryColor: ThemeConstants.tertiary,
      ),
      
      DhikrItem(
        id: 'allahu_akbar_kabiran',
        text: 'اللهُ أَكْبَرُ كَبِيرًا',
        virtue: 'من التكبيرات المستحبة في الصلاة وعند الاستفتاح',
        recommendedCount: 10,
        category: DhikrCategory.takbir,
        gradient: [ThemeConstants.tertiary.lighten(0.1), ThemeConstants.tertiary],
        primaryColor: ThemeConstants.tertiary,
      ),

      DhikrItem(
        id: 'allahu_akbar_wa_lillahil_hamd',
        text: 'اللهُ أَكْبَرُ وَلِلّهِ الْحَمْدُ',
        virtue: 'من الأذكار الجامعة للتكبير والتحميد التي تجمع خير الدنيا والآخرة',
        recommendedCount: 25,
        category: DhikrCategory.takbir,
        gradient: [ThemeConstants.tertiary.darken(0.1), ThemeConstants.tertiary.lighten(0.1)],
        primaryColor: ThemeConstants.tertiary,
      ),

      // التهليل
      DhikrItem(
        id: 'la_ilaha_illa_allah',
        text: 'لاَ إِلَهَ إِلاَّ اللهُ',
        virtue: 'أفضل الذكر لا إله إلا الله، وهي كلمة التوحيد وأعظم كلمة',
        recommendedCount: 100,
        category: DhikrCategory.tahlil,
        gradient: [ThemeConstants.success, ThemeConstants.success.lighten(0.2)],
        primaryColor: ThemeConstants.success,
      ),
      
      DhikrItem(
        id: 'la_ilaha_illa_allah_wahdahu',
        text: 'لاَ إِلَهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ',
        virtue: 'من قالها عشر مرات كان كمن أعتق أربعة أنفس من ولد إسماعيل',
        recommendedCount: 10,
        category: DhikrCategory.tahlil,
        gradient: [ThemeConstants.success.darken(0.1), ThemeConstants.success],
        primaryColor: ThemeConstants.success,
      ),

      DhikrItem(
        id: 'la_ilaha_illa_allah_wahdahu_complete',
        text: 'لاَ إِلَهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
        virtue: 'من قالها في يوم مائة مرة كانت له عدل عشر رقاب، وكتبت له مائة حسنة، ومحيت عنه مائة سيئة',
        recommendedCount: 10,
        category: DhikrCategory.tahlil,
        gradient: [ThemeConstants.success.lighten(0.1), ThemeConstants.success.darken(0.1)],
        primaryColor: ThemeConstants.success,
      ),

      // الاستغفار
      const DhikrItem(
        id: 'astaghfirullah',
        text: 'أَسْتَغْفِرُ اللهَ',
        virtue: 'الاستغفار يمحو الذنوب ويجلب الرزق والفرج، ومن لزمه فتحت له أبواب الرحمة',
        recommendedCount: 100,
        category: DhikrCategory.istighfar,
        gradient: [ThemeConstants.primaryDark, ThemeConstants.primary],
        primaryColor: ThemeConstants.primaryDark,
      ),
      
      DhikrItem(
        id: 'astaghfirullah_azeem',
        text: 'أَسْتَغْفِرُ اللهَ الْعَظِيمَ',
        virtue: 'من قالها ثلاثاً غفر الله له وإن كان فارّاً من الزحف',
        recommendedCount: 3,
        category: DhikrCategory.istighfar,
        gradient: [ThemeConstants.primaryDark.lighten(0.1), ThemeConstants.primaryDark],
        primaryColor: ThemeConstants.primaryDark,
      ),

      DhikrItem(
        id: 'astaghfirullah_alladhi_la_ilaha_illa_huwa',
        text: 'أَسْتَغْفِرُ اللهَ الَّذِي لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
        virtue: 'سيد الاستغفار، من قالها من النهار موقناً بها فمات من يومه قبل أن يمسي دخل الجنة',
        recommendedCount: 1,
        category: DhikrCategory.istighfar,
        gradient: [ThemeConstants.primaryDark.darken(0.1), ThemeConstants.primaryDark.lighten(0.1)],
        primaryColor: ThemeConstants.primaryDark,
      ),

      // الصلاة على النبي
      const DhikrItem(
        id: 'salallahu_alayhi_wasallam',
        text: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
        virtue: 'من صلى علي صلاة صلى الله عليه بها عشراً، وحطت عنه عشر خطايا، ورفعت له عشر درجات',
        recommendedCount: 10,
        category: DhikrCategory.salawat,
        gradient: [ThemeConstants.accentDark, ThemeConstants.accent],
        primaryColor: ThemeConstants.accentDark,
      ),

      DhikrItem(
        id: 'salallahu_alayhi_wasallam_complete',
        text: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
        virtue: 'الصلاة الإبراهيمية الكاملة التي علمها النبي صلى الله عليه وسلم لأصحابه',
        recommendedCount: 10,
        category: DhikrCategory.salawat,
        gradient: [ThemeConstants.accentDark.lighten(0.1), ThemeConstants.accentDark],
        primaryColor: ThemeConstants.accentDark,
      ),

      DhikrItem(
        id: 'allahumma_salli_ala_muhammad',
        text: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
        virtue: 'أقصر وأيسر صيغ الصلاة على النبي، وفيها الأجر العظيم',
        recommendedCount: 100,
        category: DhikrCategory.salawat,
        gradient: [ThemeConstants.accentDark.darken(0.1), ThemeConstants.accentDark.lighten(0.1)],
        primaryColor: ThemeConstants.accentDark,
      ),
    ];
  }

  static List<DhikrItem> getByCategory(DhikrCategory category) {
    return getAll().where((dhikr) => dhikr.category == category).toList();
  }

  static List<DhikrItem> getPopular() {
    return [
      getAll().firstWhere((d) => d.id == 'subhan_allah'),
      getAll().firstWhere((d) => d.id == 'alhamdulillah'),
      getAll().firstWhere((d) => d.id == 'allahu_akbar'),
      getAll().firstWhere((d) => d.id == 'la_ilaha_illa_allah'),
      getAll().firstWhere((d) => d.id == 'astaghfirullah'),
    ];
  }
}