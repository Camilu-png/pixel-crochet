import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/sync_providers.dart';
import '../../../core/sync/sync_state.dart';
import '../../../core/supabase/supabase_client_provider.dart';
import '../../../generated/app_localizations.dart';
import '../providers/account_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final client = ref.watch(supabaseClientProvider);
    final userAsync = ref.watch(supabaseUserProvider);
    final syncState = ref.watch(syncStateProvider);

    if (client == null) {
      return _AccountMessage(
        icon: Icons.cloud_off_outlined,
        title: l10n.accountCloudUnavailableTitle,
        message: l10n.accountCloudUnavailableBody,
      );
    }

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _AccountMessage(
        icon: Icons.cloud_off_outlined,
        title: l10n.accountCloudUnavailableTitle,
        message: l10n.accountCloudUnavailableBody,
      ),
      data: (user) => user == null
          ? _GuestAccountView(onSignIn: () => _signIn(context, ref))
          : _SignedInAccountView(
              email: user.email ?? '',
              state: syncState,
              onSync: () => _sync(context, ref),
              onSignOut: () => _signOut(context, ref),
            ),
    );
  }

  Future<void> _signIn(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(supabaseAccountServiceProvider);
    if (service == null) return;
    try {
      await service.signInWithGoogle(redirectTo: Uri.base.origin);
    } catch (_) {
      if (context.mounted) _showMessage(context, l10n.accountSignInError);
    }
  }

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.read(syncRepositoryProvider);
    if (repository == null) return;
    var state = ref.read(syncStateProvider);
    if (state == SyncState.migrationRequired) {
      final count = await repository.pendingMigrationCount();
      if (!context.mounted) return;
      final approved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.migrationDialogTitle),
          content: Text(l10n.migrationDialogBody(count)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.migrationCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.migrationApprove),
            ),
          ],
        ),
      );
      if (approved != true) return;
      await repository.approveLocalMigration();
    }
    state = await repository.syncPending();
    if (!context.mounted) return;
    final message = switch (state) {
      SyncState.synced => l10n.syncComplete,
      SyncState.conflict => l10n.syncConflict,
      SyncState.unavailable => l10n.syncUnavailable,
      SyncState.pending => l10n.syncPending,
      SyncState.migrationRequired => l10n.migrationStillRequired,
      SyncState.localOnly => l10n.accountGuestDescription,
    };
    _showMessage(context, message);
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final service = ref.read(supabaseAccountServiceProvider);
    if (service == null) return;
    try {
      await service.signOut();
    } catch (_) {
      if (context.mounted) {
        _showMessage(
          context,
          AppLocalizations.of(context)!.accountSignOutError,
        );
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _GuestAccountView extends StatelessWidget {
  const _GuestAccountView({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _AccountMessage(
      icon: Icons.cloud_queue_outlined,
      title: l10n.accountGuestTitle,
      message: l10n.accountGuestDescription,
      action: FilledButton.icon(
        onPressed: onSignIn,
        icon: const Icon(Icons.login),
        label: Text(l10n.accountSignInGoogle),
      ),
    );
  }
}

class _SignedInAccountView extends StatelessWidget {
  const _SignedInAccountView({
    required this.email,
    required this.state,
    required this.onSync,
    required this.onSignOut,
  });

  final String email;
  final SyncState state;
  final VoidCallback onSync;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSyncing = state == SyncState.pending;
    return _AccountMessage(
      icon: Icons.account_circle_outlined,
      title: l10n.accountSignedInTitle,
      message: l10n.accountSignedInAs(email),
      details: Text(_syncLabel(l10n, state)),
      action: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: isSyncing ? null : onSync,
            icon: isSyncing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_sync_outlined),
            label: Text(
              state == SyncState.migrationRequired
                  ? l10n.migrationApprove
                  : l10n.syncNow,
            ),
          ),
          OutlinedButton.icon(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
            label: Text(l10n.accountSignOut),
          ),
        ],
      ),
    );
  }

  String _syncLabel(AppLocalizations l10n, SyncState state) => switch (state) {
    SyncState.localOnly => l10n.syncLocalOnly,
    SyncState.pending => l10n.syncPending,
    SyncState.migrationRequired => l10n.migrationRequiredLabel,
    SyncState.synced => l10n.syncComplete,
    SyncState.conflict => l10n.syncConflict,
    SyncState.unavailable => l10n.syncUnavailable,
  };
}

class _AccountMessage extends StatelessWidget {
  const _AccountMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.details,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? details;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 44),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center),
                  if (details != null) ...[
                    const SizedBox(height: 16),
                    details!,
                  ],
                  if (action != null) ...[const SizedBox(height: 20), action!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
