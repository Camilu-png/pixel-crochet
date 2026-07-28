import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'pattern_row.dart';

const _uuid = Uuid();

@immutable
class CrochetProject {
  CrochetProject({
    String? id,
    required this.name,
    required this.width,
    required this.height,
    required this.rows,
    this.currentRowIndex = 0,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final int width;
  final int height;
  final List<PatternRow> rows;
  final int currentRowIndex;
  final DateTime createdAt;

  int get totalRows => rows.length;
  int get currentRowNumber => rows.isNotEmpty ? rows[currentRowIndex].rowNumber : 0;
  double get progress => totalRows > 0 ? currentRowIndex / totalRows : 0.0;
  bool get isCompleted => currentRowIndex >= totalRows - 1;

  CrochetProject copyWith({
    String? name,
    int? width,
    int? height,
    List<PatternRow>? rows,
    int? currentRowIndex,
  }) {
    return CrochetProject(
      id: id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      rows: rows ?? this.rows,
      currentRowIndex: currentRowIndex ?? this.currentRowIndex,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'width': width,
        'height': height,
        'rows': rows.map((r) => r.toJson()).toList(),
        'currentRowIndex': currentRowIndex,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CrochetProject.fromJson(Map<String, dynamic> json) {
    return CrochetProject(
      id: json['id'] as String,
      name: json['name'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      rows: (json['rows'] as List)
          .map((r) => PatternRow.fromJson(r as Map<String, dynamic>))
          .toList(),
      currentRowIndex: json['currentRowIndex'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrochetProject &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
