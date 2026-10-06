import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/project_storage_service.dart';
import '../supabase/supabase_client_provider.dart';
import '../supabase/supabase_project_sync_remote.dart';
import 'project_sync_metadata_store.dart';
import 'sync_repository.dart';
import 'sync_state.dart';

final projectSyncMetadataStoreProvider = Provider<ProjectSyncMetadataStore>(
  (ref) => ProjectSyncMetadataStore(),
);

final syncStateProvider = StateProvider<SyncState>(
  (ref) => SyncState.localOnly,
);

final syncRepositoryProvider = Provider<SyncRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;

  final storage = ref.watch(storageServiceProvider);
  return SyncRepository(
    remote: SupabaseProjectSyncRemote(client),
    metadata: ref.watch(projectSyncMetadataStoreProvider),
    loadLocalProjects: storage.loadAll,
    saveLocalProject: storage.save,
    onStateChanged: (state) =>
        ref.read(syncStateProvider.notifier).state = state,
  );
});
