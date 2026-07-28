import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/crochet_project.dart';
import '../../../core/storage/project_storage_service.dart';
import '../../home/providers/home_provider.dart';

const _storageService = ProjectStorageService();

final projectProvider = FutureProvider.family<CrochetProject?, String>(
  (ref, id) async {
    ref.watch(projectsProvider);
    return _storageService.load(id);
  },
);

final stitchCounterProvider =
    StateNotifierProvider.family<StitchCounterNotifier, int, String>(
  (ref, projectId) => StitchCounterNotifier(),
);

class StitchCounterNotifier extends StateNotifier<int> {
  StitchCounterNotifier() : super(0);

  void increment() => state++;
  void decrement() => state = state > 0 ? state - 1 : 0;
  void reset() => state = 0;
}
