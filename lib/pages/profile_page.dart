import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/dashboard_overview.dart';
import '../core/theme/app_colors.dart';
import 'basic_information_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    required this.userName,
    required this.userEmail,
    required this.overview,
    required this.onLogout,
    this.onAppearance,
    this.onProfileNameChanged,
    super.key,
  });

  final String? userName;
  final String? userEmail;
  final DashboardOverviewData? overview;
  final VoidCallback onLogout;
  final VoidCallback? onAppearance;
  final Future<void> Function(String)? onProfileNameChanged;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _profilePhotoKey = 'profile_photo_path';
  final ImagePicker _imagePicker = ImagePicker();
  String? _profilePhotoPath;
  bool _isPickingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedPath = preferences.getString(_profilePhotoKey);
      if (savedPath == null) return;
      if (!await File(savedPath).exists()) {
        await preferences.remove(_profilePhotoKey);
        return;
      }
      if (mounted) setState(() => _profilePhotoPath = savedPath);
    } on Exception {
      if (mounted) {
        _showPhotoMessage('Unable to load your saved profile photo.');
      }
    }
  }

  Future<void> _chooseProfilePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    setState(() => _isPickingPhoto = true);
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (image == null) return;

      final appDirectory = await getApplicationDocumentsDirectory();
      final extension = _imageExtension(image.name);
      final destination = File(
        '${appDirectory.path}${Platform.pathSeparator}profile_photo.$extension',
      );
      await File(image.path).copy(destination.path);

      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(
        _profilePhotoKey,
        destination.path,
      );
      if (!saved) {
        throw const FileSystemException('Could not save profile photo path.');
      }
      if (mounted) {
        setState(() => _profilePhotoPath = destination.path);
      }
    } on PlatformException {
      if (mounted) {
        _showPhotoMessage('Unable to access the selected photo.');
      }
    } on FileSystemException {
      if (mounted) _showPhotoMessage('Unable to save the profile photo.');
    } on Exception {
      if (mounted) _showPhotoMessage('Unable to update the profile photo.');
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  String _imageExtension(String name) {
    final separator = name.lastIndexOf('.');
    if (separator == -1 || separator == name.length - 1) return 'jpg';
    final extension = name.substring(separator + 1).toLowerCase();
    return RegExp(r'^[a-z0-9]+$').hasMatch(extension) ? extension : 'jpg';
  }

  void _showPhotoMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.userName?.trim().isNotEmpty == true
        ? widget.userName!.trim()
        : 'Name unavailable';
    final email = widget.userEmail?.trim().isNotEmpty == true
        ? widget.userEmail!.trim()
        : 'Email unavailable';
    final projects = widget.overview?.projects;
    final completedProjects = projects?.where((project) {
      final progress = project.status.progress.trim().toLowerCase();
      return progress == 'complete' || progress == 'completed';
    }).length;
    final allocation = widget.overview?.summary.fiscalAllocation;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileIdentityCard(
            name: name,
            email: email,
            profilePhotoPath: _profilePhotoPath,
            onEdit: () => _showUnavailableFeature(
              context,
              'Profile editing is not available yet.',
            ),
            onChangePhoto: _isPickingPhoto ? null : _chooseProfilePhoto,
          ),
          const SizedBox(height: 24),
          _ProfileSectionCard(
            title: 'PERSONAL INFORMATION',
            tiles: [
              _ProfileMenuTileData(
                icon: Icons.person_outline_rounded,
                title: 'Basic Information',
                description: 'Name, email, phone, location',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BasicInformationPage(
                      userName: widget.userName,
                      userEmail: widget.userEmail,
                      profilePhotoPath: _profilePhotoPath,
                      onNameChanged: widget.onProfileNameChanged,
                    ),
                  ),
                ),
              ),
              _ProfileMenuTileData(
                icon: Icons.shield_outlined,
                title: 'Account Security',
                description: 'Password, 2FA, login activity',
                onTap: () => _showUnavailableFeature(
                  context,
                  'Security settings are not available yet.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProfileSectionCard(
            title: 'ORGANIZATION',
            tiles: [
              _ProfileMenuTileData(
                icon: Icons.business_outlined,
                title: 'My Organization',
                description: 'Role, department, team',
                onTap: () => _showUnavailableFeature(
                  context,
                  'Organization details are not available yet.',
                ),
              ),
              _ProfileMenuTileData(
                icon: Icons.groups_outlined,
                title: 'Team Members',
                description: 'View and manage your team',
                onTap: () => _showUnavailableFeature(
                  context,
                  'Team management is not available in this app yet.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProfileSectionCard(
            title: 'PREFERENCES',
            tiles: [
              _ProfileMenuTileData(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                description: 'Theme, language, display',
                onTap:
                    widget.onAppearance ??
                    () => _showUnavailableFeature(
                      context,
                      'Appearance settings are not available yet.',
                    ),
              ),
              _ProfileMenuTileData(
                icon: Icons.logout_rounded,
                title: 'Log Out',
                description: 'Sign out of your account',
                showChevron: false,
                onTap: widget.onLogout,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUnavailableFeature(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProfileIdentityCard extends StatelessWidget {
  const _ProfileIdentityCard({
    required this.name,
    required this.email,
    required this.profilePhotoPath,
    required this.onEdit,
    required this.onChangePhoto,
  });

  final String name;
  final String email;
  final String? profilePhotoPath;
  final VoidCallback onEdit;
  final VoidCallback? onChangePhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ProfileAvatar(
            profilePhotoPath: profilePhotoPath,
            onChangePhoto: onChangePhoto,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.card,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: onEdit,
                      tooltip: 'Edit profile',
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.card,
                        size: 19,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: AppColors.card.withValues(alpha: 0.78),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PMES Account',
                    style: TextStyle(
                      color: AppColors.card,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.profilePhotoPath,
    required this.onChangePhoto,
  });

  final String? profilePhotoPath;
  final VoidCallback? onChangePhoto;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 82,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF0FF),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: profilePhotoPath == null
                  ? const Icon(
                      Icons.person_rounded,
                      color: AppColors.secondary,
                      size: 54,
                    )
                  : Image.file(
                      File(profilePhotoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person_rounded,
                        color: AppColors.secondary,
                        size: 54,
                      ),
                    ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Material(
              color: AppColors.secondary,
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: onChangePhoto,
                tooltip: 'Change profile photo',
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.card,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({required this.title, required this.tiles});

  final String title;
  final List<_ProfileMenuTileData> tiles;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                color: isDark
                    ? colorScheme.onSurface.withValues(alpha: 0.68)
                    : AppColors.neutral,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          for (var index = 0; index < tiles.length; index++) ...[
            _ProfileMenuTile(data: tiles[index]),
            if (index < tiles.length - 1)
              Divider(
                height: 1,
                indent: 54,
                color: Theme.of(context).dividerColor,
              ),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuTileData {
  const _ProfileMenuTileData({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool showChevron;
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({required this.data});

  final _ProfileMenuTileData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: '${data.title}, ${data.description}',
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: AppColors.secondary, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: TextStyle(
                        color: isDark
                            ? colorScheme.onSurface
                            : AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.description,
                      style: TextStyle(
                        color: isDark
                            ? colorScheme.onSurface.withValues(alpha: 0.68)
                            : AppColors.neutral,
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              if (data.showChevron) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.neutralLight,
                  size: 22,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
