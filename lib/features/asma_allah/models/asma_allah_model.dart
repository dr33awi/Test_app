// lib/features/asma_allah/models/asma_allah_model.dart

/// نموذج أسماء الله الحسنى - محدث
class AsmaAllahModel {
  final int id;
  final String name;        // الاسم
  final String meaning;     // المعنى
  final String? reference;  // المرجع القرآني
  
  const AsmaAllahModel({
    required this.id,
    required this.name,
    required this.meaning,
    this.reference,
  });
  
  /// تحويل من JSON
  factory AsmaAllahModel.fromJson(Map<String, dynamic> json) {
    return AsmaAllahModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      meaning: json['meaning'] ?? '',
      reference: json['reference'],
    );
  }
  
  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'meaning': meaning,
      'reference': reference,
    };
  }
  
  /// نسخة محدثة من الكائن
  AsmaAllahModel copyWith({
    int? id,
    String? name,
    String? meaning,
    String? reference,
  }) {
    return AsmaAllahModel(
      id: id ?? this.id,
      name: name ?? this.name,
      meaning: meaning ?? this.meaning,
      reference: reference ?? this.reference,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AsmaAllahModel &&
        other.id == id &&
        other.name == name &&
        other.meaning == meaning &&
        other.reference == reference;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        meaning.hashCode ^
        reference.hashCode;
  }
}