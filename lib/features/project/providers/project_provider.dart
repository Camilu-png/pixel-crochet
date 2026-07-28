import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/crochet_project.dart';
import '../../../core/storage/project_storage_service.dart';
import '../../home/providers/home_provider.dart';

final projectProvider = FutureProvider.family<CrochetProject?, String>(
  (ref, id) async {
    ref.watch(projectsProvider);
    return ref.read(storageServiceProvider).load(id);
  },
);
