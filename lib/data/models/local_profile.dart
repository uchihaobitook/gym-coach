import 'package:equatable/equatable.dart';

/// A local athlete profile sharing one device (A/B).
class LocalProfile extends Equatable {
  const LocalProfile({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.colorSeed = 0,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int colorSeed;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final text = parts.first;
      return text.substring(0, text.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  LocalProfile copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? colorSeed,
  }) {
    return LocalProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      colorSeed: colorSeed ?? this.colorSeed,
    );
  }

  factory LocalProfile.fromJson(Map<String, dynamic> json) {
    return LocalProfile(
      id: json['id'] as String,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String).trim()
          : 'VĐV',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      colorSeed: (json['colorSeed'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'colorSeed': colorSeed,
      };

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt, colorSeed];
}
