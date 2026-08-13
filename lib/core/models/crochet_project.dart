import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'pattern_row.dart';

const _uuid = Uuid();

@immutable
class CrochetProject {
  static const int schemaVersion = 1;

  CrochetProject({
    String? id,
    required this.name,
    required this.width,
    required this.height,
    required this.rows,
    this.currentRowIndex = 0,
    Map<int, Set<int>>? completedBlocks,
    DateTime? createdAt,
  }) : id = id ?? _uuid.v4(),
       createdAt = createdAt ?? DateTime.now(),
       completedBlocks = completedBlocks ?? {};

  final String id;
  final String name;
  final int width;
  final int height;
  final List<PatternRow> rows;
  final int currentRowIndex;
  final Map<int, Set<int>> completedBlocks;
  final DateTime createdAt;

  int get totalRows => rows.length;
  int get currentRowNumber {
    if (rows.isEmpty) return 0;
    return rows[currentRowIndex.clamp(0, rows.length - 1).toInt()].rowNumber;
  }

  double get rowProgress => totalRows > 0 ? currentRowIndex / totalRows : 0.0;

  int get totalCompletedBlocks =>
      completedBlocks.values.fold(0, (sum, blocks) => sum + blocks.length);

  int get totalBlocks =>
      rows.fold(0, (sum, row) => sum + row.colorBlocks.length);

  double get progress =>
      totalBlocks > 0 ? totalCompletedBlocks / totalBlocks : 0.0;

  bool get isCompleted => progress >= 1.0;

  bool isBlockCompleted(int rowIndex, int blockIndex) =>
      completedBlocks[rowIndex]?.contains(blockIndex) ?? false;

  CrochetProject copyWith({
    String? name,
    int? width,
    int? height,
    List<PatternRow>? rows,
    int? currentRowIndex,
    Map<int, Set<int>>? completedBlocks,
  }) {
    return CrochetProject(
      id: id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      rows: (rows ?? this.rows).map((r) => r).toList(),
      currentRowIndex: currentRowIndex ?? this.currentRowIndex,
      completedBlocks: (completedBlocks ?? this.completedBlocks).map(
        (k, v) => MapEntry(k, Set<int>.from(v)),
      ),
      createdAt: createdAt,
    );
  }

  CrochetProject toggleBlock(int rowIndex, int blockIndex) {
    final updated = Map<int, Set<int>>.from(
      completedBlocks.map((k, v) => MapEntry(k, Set<int>.from(v))),
    );
    final rowBlocks = updated[rowIndex] ?? <int>{};
    if (rowBlocks.contains(blockIndex)) {
      rowBlocks.remove(blockIndex);
    } else {
      rowBlocks.add(blockIndex);
    }
    if (rowBlocks.isEmpty) {
      updated.remove(rowIndex);
    } else {
      updated[rowIndex] = rowBlocks;
    }
    return copyWith(completedBlocks: updated);
  }

  Map<String, dynamic> toJson() => {
    'version': schemaVersion,
    'id': id,
    'name': name,
    'width': width,
    'height': height,
    'rows': rows.map((r) => r.toJson()).toList(),
    'currentRowIndex': currentRowIndex,
    'completedBlocks': completedBlocks.map(
      (k, v) => MapEntry(k.toString(), v.toList()),
    ),
    'createdAt': createdAt.toIso8601String(),
  };

  factory CrochetProject.fromJson(Map<String, dynamic> json) {
    final rawCompleted = json['completedBlocks'] as Map<String, dynamic>?;
    final completedBlocks = <int, Set<int>>{};
    if (rawCompleted != null) {
      for (final entry in rawCompleted.entries) {
        final rowIndex = int.tryParse(entry.key) ?? -1;
        final blockIndices = (entry.value as List? ?? const [])
            .cast<int>()
            .toSet();
        if (rowIndex >= 0) {
          completedBlocks[rowIndex] = blockIndices;
        }
      }
    }

    final rows = (json['rows'] as List)
        .map((r) => PatternRow.fromJson(r as Map<String, dynamic>))
        .toList();

    // Clamp the persisted index so corrupted or legacy data can never produce
    // a RangeError when reading the current row.
    final rawRowIndex = json['currentRowIndex'] as int? ?? 0;
    final currentRowIndex = rows.isEmpty
        ? 0
        : rawRowIndex.clamp(0, rows.length - 1).toInt();

    final rawCreatedAt = json['createdAt'];
    final createdAt = rawCreatedAt is String
        ? DateTime.tryParse(rawCreatedAt) ?? DateTime.now()
        : DateTime.now();

    return CrochetProject(
      id: json['id'] as String,
      name: json['name'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      rows: rows,
      currentRowIndex: currentRowIndex,
      completedBlocks: completedBlocks,
      createdAt: createdAt,
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
