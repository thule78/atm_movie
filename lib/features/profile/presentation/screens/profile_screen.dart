import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../router/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../user_data/domain/models/app_profile.dart';
import '../../../user_data/presentation/providers/user_data_provider.dart';
import 'my_comments_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final userDataProvider = context.watch<UserDataProvider>();
    final profile = userDataProvider.profile;
    final displayName =
        profile?.displayName ?? currentUser?.resolvedName ?? 'Guest User';
    final email =
        profile?.email ?? currentUser?.resolvedEmail ?? 'guest@atmmovie.app';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 38,
            backgroundColor: AppTheme.softRed,
            backgroundImage: profile?.photoUrl != null
                ? NetworkImage(profile!.photoUrl!)
                : null,
            child: profile?.photoUrl == null
                ? const Icon(
                    Icons.person_rounded,
                    color: AppTheme.primaryRed,
                    size: 40,
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(displayName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(email, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 28),
          Card(
            child: Column(
              children: [
                _ProfileTile(
                  icon: Icons.edit_outlined,
                  title: 'Edit profile',
                  onTap: () => _showEditProfileDialog(
                    context,
                    initialName: displayName,
                    profile: profile,
                  ),
                ),
                const Divider(height: 1),
                _ProfileTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'My comments',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MyCommentsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (userDataProvider.profileError != null) ...[
            const SizedBox(height: 16),
            Text(
              userDataProvider.profileError!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: authProvider.isBusy
                ? null
                : () async {
                    await context.read<AuthProvider>().signOut();
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      RouteNames.welcome,
                      (route) => false,
                    );
                  },
            child: Text(authProvider.isBusy ? 'Logging out...' : 'Log out'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProfileDialog(
    BuildContext context,
    {
    required String initialName,
    required AppProfile? profile,
    }
  ) async {
    final controller = TextEditingController(text: initialName);
    final imagePicker = ImagePicker();
    XFile? selectedPhoto;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final photoProvider = context.watch<UserDataProvider>();

            Future<void> pickPhoto() async {
              final photo = await imagePicker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 1200,
                imageQuality: 85,
              );
              if (photo == null) {
                return;
              }
              setDialogState(() {
                selectedPhoto = photo;
              });
            }

            return AlertDialog(
              title: const Text('Edit profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppTheme.softRed,
                      backgroundImage: selectedPhoto != null
                          ? FileImage(
                              // `XFile.path` is the simplest preview source here.
                              File(selectedPhoto!.path),
                            )
                          : profile?.photoUrl != null
                          ? NetworkImage(profile!.photoUrl!)
                          : null,
                      child: selectedPhoto == null && profile?.photoUrl == null
                          ? const Icon(
                              Icons.person_rounded,
                              color: AppTheme.primaryRed,
                              size: 40,
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: photoProvider.isUpdatingProfile
                          ? null
                          : pickPhoto,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Upload profile photo'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: photoProvider.isUpdatingProfile
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: photoProvider.isUpdatingProfile
                      ? null
                      : () async {
                          final userDataProvider =
                              context.read<UserDataProvider>();
                          final trimmedName = controller.text.trim();
                          if (trimmedName.isEmpty) {
                            return;
                          }

                          List<int>? photoBytes;
                          String? photoExtension;
                          if (selectedPhoto != null) {
                            photoBytes = await selectedPhoto!.readAsBytes();
                            final nameParts = selectedPhoto!.name.split('.');
                            photoExtension = nameParts.length > 1
                                ? nameParts.last.toLowerCase()
                                : 'jpg';
                          }

                          await userDataProvider.updateProfile(
                            displayName: trimmedName,
                            photoBytes: photoBytes,
                            photoExtension: photoExtension,
                          );
                          if (!dialogContext.mounted ||
                              userDataProvider.profileError != null) {
                            return;
                          }
                          Navigator.of(dialogContext).pop();
                        },
                  child: Text(
                    photoProvider.isUpdatingProfile ? 'Saving...' : 'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.title, this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
