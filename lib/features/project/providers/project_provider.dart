import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/crochet_project.dart';
import '../../../core/storage/project_storage_service.dart';

final projectProvider = FutureProvider.family<CrochetProject?, String>(
  (ref, id) async {
    return ref.read(storageServiceProvider).load(id);
  },
);
