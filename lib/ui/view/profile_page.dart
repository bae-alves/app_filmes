import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/repositories/onboarding_repository.dart';
import '../../l10n/app_localizations.dart';
import '../view_model/auth_view_model.dart';
import '../view_model/onboarding_view_model.dart';
import 'login_page.dart';
import 'onboarding_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.authViewModel,
    this.onboardingRepository,
    this.onUserChanged,
  });

  final AuthViewModel authViewModel;
  final OnboardingRepository? onboardingRepository;
  final VoidCallback? onUserChanged;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initName();
  }

  void _initName() {
    final user = widget.authViewModel.currentUser;
    if (user != null) {
      _nameController.text = user.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    final l10n = AppLocalizations.of(context);
    final success = await widget.authViewModel.updateProfile(
      name: _nameController.text,
    );
    if (success && mounted) {
      setState(() => _isEditing = false);
      widget.onUserChanged?.call();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileUpdatedSuccess)));
    }
  }

  Future<void> _openEditTastePreferences(String userId) async {
    final repo = widget.onboardingRepository;
    if (repo == null) return;

    final vm = OnboardingViewModel(onboardingRepository: repo, userId: userId);

    await vm.loadPreferences();

    if (!mounted) return;

    final l10n = AppLocalizations.of(context);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => OnboardingPage(
          viewModel: vm,
          onCompleted: () {
            if (Navigator.of(routeContext).canPop()) {
              Navigator.of(routeContext).pop();
            }
            widget.onUserChanged?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.tastePreferencesUpdatedSuccess)),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.authViewModel,
      builder: (context, _) {
        final user = widget.authViewModel.currentUser;
        final isLoading = widget.authViewModel.isLoading;

        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.profileTitle), centerTitle: true),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.userCircle2,
                      size: 80,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.profileLoginPrompt,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LoginPage(
                              authViewModel: widget.authViewModel,
                              onSuccess: () {
                                widget.onUserChanged?.call();
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.logIn),
                      label: Text(l10n.loginTitle),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.profileTitle),
            centerTitle: true,
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: const Icon(LucideIcons.pencil),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                      _nameController.text = user.name;
                    });
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name.substring(0, 1).toUpperCase()
                              : 'U',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user.authProvider == 'google'
                            ? LucideIcons.globe
                            : user.authProvider == 'apple'
                            ? LucideIcons.apple
                            : LucideIcons.mail,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.authProvider.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                if (_isEditing) ...[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.nameLabel,
                      prefixIcon: const Icon(LucideIcons.user),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _isEditing = false),
                          child: Text(l10n.btnCancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: isLoading ? null : _handleSaveProfile,
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.saveProfile),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(LucideIcons.user),
                    title: Text(l10n.nameLabel),
                    subtitle: Text(
                      user.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(LucideIcons.mail),
                    title: Text(l10n.emailLabel),
                    subtitle: Text(
                      user.email,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      LucideIcons.sparkles,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      l10n.tastePreferencesTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(l10n.tastePreferencesSubtitle),
                    trailing: const Icon(LucideIcons.chevronRight),
                    onTap: () => _openEditTastePreferences(user.id),
                  ),
                  const Divider(),
                ],

                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            await widget.authViewModel.signOut();
                            widget.onUserChanged?.call();
                          },
                    icon: const Icon(LucideIcons.logOut),
                    label: Text(l10n.logoutAction),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
