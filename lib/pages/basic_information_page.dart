import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';

class BasicInformationPage extends StatefulWidget {
  const BasicInformationPage({
    required this.userName,
    required this.userEmail,
    this.profilePhotoPath,
    this.onNameChanged,
    super.key,
  });

  final String? userName;
  final String? userEmail;
  final String? profilePhotoPath;
  final Future<void> Function(String)? onNameChanged;

  @override
  State<BasicInformationPage> createState() => _BasicInformationPageState();
}

class _BasicInformationPageState extends State<BasicInformationPage> {
  static const _keys = {
    'name': 'basic_information_name',
    'phone': 'basic_information_phone',
    'dateOfBirth': 'basic_information_date_of_birth',
    'gender': 'basic_information_gender',
    'nationality': 'basic_information_nationality',
    'country': 'basic_information_country',
    'city': 'basic_information_city',
    'address': 'basic_information_address',
  };

  late _BasicInformationData _details;
  bool _isLoading = true;
  bool _isSaving = false;

  String get _email => widget.userEmail?.trim().isNotEmpty == true
      ? widget.userEmail!.trim()
      : 'Email unavailable';

  String _preferenceKey(String field) {
    final email = widget.userEmail!.trim().toLowerCase();
    return '${_keys[field]!}_${Uri.encodeComponent(email)}';
  }

  String get _name {
    final name = _details.name.trim();
    return name.isNotEmpty ? name : 'Name unavailable';
  }

  @override
  void initState() {
    super.initState();
    _details = _BasicInformationData(name: widget.userName?.trim() ?? '');
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      if (widget.userEmail?.trim().isNotEmpty != true) return;
      final preferences = await SharedPreferences.getInstance();
      final loaded = _BasicInformationData(
        name: preferences.getString(_preferenceKey('name')) ?? _details.name,
        phone: preferences.getString(_preferenceKey('phone')) ?? '',
        dateOfBirth: preferences.getString(_preferenceKey('dateOfBirth')) ?? '',
        gender: preferences.getString(_preferenceKey('gender')) ?? '',
        nationality: preferences.getString(_preferenceKey('nationality')) ?? '',
        country: preferences.getString(_preferenceKey('country')) ?? '',
        city: preferences.getString(_preferenceKey('city')) ?? '',
        address: preferences.getString(_preferenceKey('address')) ?? '',
      );
      if (mounted) setState(() => _details = loaded);
    } on Exception {
      if (mounted) _showMessage('Unable to load saved profile details.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editDetails() async {
    final updated = await showModalBottomSheet<_BasicInformationData>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _EditBasicInformationSheet(initial: _details),
    );
    if (updated == null || !mounted) return;

    setState(() => _isSaving = true);
    try {
      if (widget.userEmail?.trim().isNotEmpty != true) {
        _showMessage('Unable to save details without an account email.');
        return;
      }
      final preferences = await SharedPreferences.getInstance();
      final values = <String, String>{
        'name': updated.name,
        'phone': updated.phone,
        'dateOfBirth': updated.dateOfBirth,
        'gender': updated.gender,
        'nationality': updated.nationality,
        'country': updated.country,
        'city': updated.city,
        'address': updated.address,
      };
      for (final entry in values.entries) {
        final saved = await preferences.setString(
          _preferenceKey(entry.key),
          entry.value,
        );
        if (!saved) throw Exception('Unable to save profile details.');
      }
      if (!mounted) return;
      setState(() => _details = updated);
      try {
        await widget.onNameChanged?.call(updated.name);
      } on Exception {
        if (mounted) {
          _showMessage(
            'Profile details were saved, but the account name could not be updated.',
          );
        }
        return;
      }
      _showMessage('Your personal details have been saved on this device.');
    } on Exception {
      if (mounted) _showMessage('Unable to save your profile details.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSecuritySettings({required bool twoFactor}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(twoFactor ? 'Two-factor authentication' : 'Password'),
        content: Text(
          twoFactor
              ? 'Two-factor authentication settings are not available for this account yet.'
              : 'Your password is managed securely by your PMES account. Use the password reset option on the sign-in page to change it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, _) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 32),
                      children: [
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Back to Profile',
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: AppColors.secondary,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Basic Information',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _ProfileSummaryCard(
                          name: _name,
                          email: _email,
                          organization: 'Not provided',
                          department: 'Not provided',
                          photoPath: widget.profilePhotoPath,
                          isSaving: _isSaving,
                          onEdit: _isSaving ? null : _editDetails,
                        ),
                        const SizedBox(height: 16),
                        _InformationCard(
                          title: 'PERSONAL DETAILS',
                          rows: [
                            _InformationRowData(
                              Icons.person_outline_rounded,
                              'Full Name',
                              _name,
                            ),
                            _InformationRowData(
                              Icons.mail_outline_rounded,
                              'Email Address',
                              _email,
                            ),
                            _InformationRowData(
                              Icons.phone_outlined,
                              'Phone Number',
                              _value(_details.phone),
                            ),
                            _InformationRowData(
                              Icons.cake_outlined,
                              'Date of Birth',
                              _value(_details.dateOfBirth),
                            ),
                            _InformationRowData(
                              Icons.wc_rounded,
                              'Gender',
                              _value(_details.gender),
                            ),
                            _InformationRowData(
                              Icons.flag_outlined,
                              'Nationality',
                              _value(_details.nationality),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16)
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  String _value(String value) => value.trim().isEmpty ? 'Not provided' : value;
}

class _BasicInformationData {
  const _BasicInformationData({
    this.name = '',
    this.phone = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.nationality = '',
    this.country = '',
    this.city = '',
    this.address = '',
  });

  final String name;
  final String phone;
  final String dateOfBirth;
  final String gender;
  final String nationality;
  final String country;
  final String city;
  final String address;
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.name,
    required this.email,
    required this.organization,
    required this.department,
    required this.photoPath,
    required this.isSaving,
    required this.onEdit,
  });

  final String name;
  final String email;
  final String organization;
  final String department;
  final String? photoPath;
  final bool isSaving;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: photoPath == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 38,
                      color: AppColors.secondary,
                    )
                  : Image.file(
                      File(photoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person_rounded,
                        size: 38,
                        color: AppColors.secondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PMES Account',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Organization: $organization',
                  style: TextStyle(
                    color: foreground.withValues(alpha: 0.62),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Department / team: $department',
                  style: TextStyle(
                    color: foreground.withValues(alpha: 0.62),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              visualDensity: VisualDensity.compact,
            ),
            child: Text(isSaving ? 'Saving' : 'Edit'),
          ),
        ],
      ),
    );
  }
}

class _InformationRowData {
  const _InformationRowData(this.icon, this.label, this.value, {this.onTap});

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.title, required this.rows});

  final String title;
  final List<_InformationRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 5),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.neutral,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
              ),
            ),
          ),
          for (var index = 0; index < rows.length; index++) ...[
            _InformationRow(data: rows[index]),
            if (index != rows.length - 1)
              Divider(
                height: 1,
                indent: 42,
                color: Theme.of(context).dividerColor,
              ),
          ],
        ],
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({required this.data});

  final _InformationRowData data;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    final child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Icon(data.icon, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.58),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.value,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (data.onTap != null)
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutralLight,
            ),
        ],
      ),
    );
    if (data.onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(10),
        child: child,
      ),
    );
  }
}

class _EditBasicInformationSheet extends StatefulWidget {
  const _EditBasicInformationSheet({required this.initial});

  final _BasicInformationData initial;

  @override
  State<_EditBasicInformationSheet> createState() =>
      _EditBasicInformationSheetState();
}

class _EditBasicInformationSheetState
    extends State<_EditBasicInformationSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.initial.name);
  late final _phoneController = TextEditingController(
    text: widget.initial.phone,
  );
  late final _dobController = TextEditingController(
    text: widget.initial.dateOfBirth,
  );
  late final _nationalityController = TextEditingController(
    text: widget.initial.nationality,
  );
  late final _countryController = TextEditingController(
    text: widget.initial.country,
  );
  late final _cityController = TextEditingController(text: widget.initial.city);
  late final _addressController = TextEditingController(
    text: widget.initial.address,
  );
  late String _gender = widget.initial.gender;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final initial = DateTime.tryParse(_dobController.text) ?? DateTime(1990);
    final date = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(DateTime.now()) ? DateTime.now() : initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _dobController.text =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _BasicInformationData(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfBirth: _dobController.text.trim(),
        gender: _gender,
        nationality: _nationalityController.text.trim(),
        country: _countryController.text.trim(),
        city: _cityController.text.trim(),
        address: _addressController.text.trim(),
      ),
    );
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Edit personal details',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _decoration('Full name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter your full name.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9+() -]'),
                        ),
                      ],
                      decoration: _decoration('Phone number'),
                      validator: (value) {
                        final phone = value?.trim() ?? '';
                        if (phone.isNotEmpty &&
                            phone.replaceAll(RegExp(r'\D'), '').length < 7) {
                          return 'Enter a valid phone number.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      onTap: _selectDateOfBirth,
                      decoration: _decoration('Date of birth').copyWith(
                        suffixIcon: const Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _gender.isEmpty ? null : _gender,
                      decoration: _decoration('Gender'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text('Female'),
                        ),
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(
                          value: 'Non-binary',
                          child: Text('Non-binary'),
                        ),
                        DropdownMenuItem(
                          value: 'Prefer not to say',
                          child: Text('Prefer not to say'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _gender = value ?? ''),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nationalityController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _decoration('Nationality'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _countryController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _decoration('Country'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _cityController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _decoration('City / Town'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _decoration('Physical address'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
