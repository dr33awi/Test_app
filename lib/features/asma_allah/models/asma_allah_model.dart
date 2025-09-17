// lib/features/asma_allah/models/asma_allah_model.dart

class AsmaAllahModel {
  final int id;
  final String name;          // الاسم بالعربية
  final String transliteration; // النطق بالإنجليزية
  final String meaning;       // المعنى
  final String explanation;   // الشرح المفصل
  final String benefits;      // الفوائد والآثار
  final String dhikrCount;    // عدد مرات الذكر المستحب
  final String reference;     // المرجع من القرآن أو السنة
  final bool isFavorite;      // هل مضاف للمفضلة

  const AsmaAllahModel({
    required this.id,
    required this.name,
    required this.transliteration,
    required this.meaning,
    required this.explanation,
    required this.benefits,
    required this.dhikrCount,
    required this.reference,
    this.isFavorite = false,
  });

  AsmaAllahModel copyWith({
    int? id,
    String? name,
    String? transliteration,
    String? meaning,
    String? explanation,
    String? benefits,
    String? dhikrCount,
    String? reference,
    bool? isFavorite,
  }) {
    return AsmaAllahModel(
      id: id ?? this.id,
      name: name ?? this.name,
      transliteration: transliteration ?? this.transliteration,
      meaning: meaning ?? this.meaning,
      explanation: explanation ?? this.explanation,
      benefits: benefits ?? this.benefits,
      dhikrCount: dhikrCount ?? this.dhikrCount,
      reference: reference ?? this.reference,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'transliteration': transliteration,
      'meaning': meaning,
      'explanation': explanation,
      'benefits': benefits,
      'dhikrCount': dhikrCount,
      'reference': reference,
      'isFavorite': isFavorite,
    };
  }

  factory AsmaAllahModel.fromJson(Map<String, dynamic> json) {
    return AsmaAllahModel(
      id: json['id'] as int,
      name: json['name'] as String,
      transliteration: json['transliteration'] as String,
      meaning: json['meaning'] as String,
      explanation: json['explanation'] as String,
      benefits: json['benefits'] as String,
      dhikrCount: json['dhikrCount'] as String,
      reference: json['reference'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}