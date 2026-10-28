import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({
    required this.userName,
    required this.userEmail,
    required this.lastLogin,
    super.key,
  });

  final String? userName;
  final String? userEmail;
  final DateTime? lastLogin;

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  String _accountValue(String? value) =>
      value?.trim().isNotEmpty == true ? value!.trim() : 'Not provided';

  String _formatLastLogin(BuildContext context) {
    if (widget.lastLogin == null) return 'Not available';
    final localDate = widget.lastLogin!.toLocal();
    final localTime = TimeOfDay.fromDateTime(localDate);
    final localizations = MaterialLocalizations.of(context);
    return '${localizations.formatFullDate(localDate)} at '
        '${localizations.formatTimeOfDay(localTime)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.card,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Back to Profile',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        titleSpacing: 4,
        title: const Text('Account Security'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 32),
              children: [
                const SizedBox(height: 20),
                _AccountInformationCard(
                  userName: _accountValue(widget.userName),
                  email: _accountValue(widget.userEmail),
                  lastLogin: _formatLastLogin(context),
                ),
                const SizedBox(height: 16),
                const _ChangePasswordCard(),
                const SizedBox(height: 16),
                const _UnavailableSecurityCard(
                  title: 'Recent Login Activity',
                  icon: Icons.devices_outlined,
                  description: 'Review the devices and sessions that have accessed your account.',
                  unavailableMessage: 'Login history and session management are not available yet.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordCard extends StatefulWidget {
  const _ChangePasswordCard();

  @override
  State<_ChangePasswordCard> createState() => _ChangePasswordCardState();
}

class _ChangePasswordCardState extends State<_ChangePasswordCard> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _obscurePassword = [true, true, true];

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _cancel() {
    _formKey.currentState?.reset();
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _obscurePassword.fillRange(0, _obscurePassword.length, true);
    });
  }

  String? _requiredPassword(String? value) =>
      value == null || value.isEmpty ? 'Enter your password.' : null;

  void _updatePassword() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Password updates are unavailable because this service does not '
            'currently support changing passwords.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return _SecurityCard(
      title: 'Change Password',
      icon: Icons.lock_outline_rounded,
      badge: 'Unavailable',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Keep your account secure by updating your password regularly.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.65),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your current password and choose a new one. Your password '
            'is never displayed or stored by this page.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.65),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _passwordField(
                  label: 'Current Password',
                  controller: _currentPasswordController,
                  obscureIndex: 0,
                  validator: _requiredPassword,
                ),
                const SizedBox(height: 12),
                _passwordField(
                  label: 'New Password',
                  controller: _newPasswordController,
                  obscureIndex: 1,
                  validator: _requiredPassword,
                ),
                const SizedBox(height: 12),
                _passwordField(
                  label: 'Confirm New Password',
                  controller: _confirmPasswordController,
                  obscureIndex: 2,
                  validator: (value) {
                    final requiredError = _requiredPassword(value);
                    if (requiredError != null) return requiredError;
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.neutral,
                        size: 19,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Password updates are unavailable because this '
                          'service does not currently support changing passwords.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: 0.72),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: _updatePassword,
                      child: const Text('Update Password'),
                    ),
                    OutlinedButton(
                      onPressed: _cancel,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required int obscureIndex,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: _obscurePassword[obscureIndex],
      enableSuggestions: false,
      autocorrect: false,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          tooltip: _obscurePassword[obscureIndex]
              ? 'Show $label'
              : 'Hide $label',
          onPressed: () {
            setState(() {
              _obscurePassword[obscureIndex] = !_obscurePassword[obscureIndex];
            });
          },
          icon: Icon(
            _obscurePassword[obscureIndex]
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }
}

class _AccountInformationCard extends StatelessWidget {
  const _AccountInformationCard({
    required this.userName,
    required this.email,
    required this.lastLogin,
  });

  final String userName;
  final String email;
  final String lastLogin;

  @override
  Widget build(BuildContext context) {
    return _SecurityCard(
      title: 'Login Information',
      child: Column(
        children: [
          _InformationRow(
            icon: Icons.person_outline_rounded,
            label: 'Username',
            value: userName,
          ),
          const _RowDivider(),
          _InformationRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email Address',
            value: email,
          ),
          const _RowDivider(),
          _InformationRow(
            icon: Icons.schedule_rounded,
            label: 'Last Login',
            value: lastLogin,
          ),
        ],
      ),
    );
  }
}

class _UnavailableSecurityCard extends StatelessWidget {
  const _UnavailableSecurityCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.unavailableMessage,
  });

  final String title;
  final IconData icon;
  final String description;
  final String unavailableMessage;

  @override
  Widget build(BuildContext context) {
    return _SecurityCard(
      title: title,
      icon: icon,
      badge: 'Unavailable',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.65),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.neutral,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    unavailableMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: 0.72),
                      fontSize: 12,
                      height: 1.4,
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

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({
    required this.title,
    required this.child,
    this.icon,
    this.badge,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: AppColors.secondary, size: 20),
                ),
                const SizedBox(width: 11),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: AppColors.neutral,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Icon(icon, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: foreground.withValues(alpha: 0.58),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, indent: 42, color: Theme.of(context).dividerColor);
}
