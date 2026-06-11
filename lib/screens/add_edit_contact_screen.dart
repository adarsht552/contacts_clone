import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../services/contact_provider.dart';
import '../utils/app_theme.dart';

class AddEditContactScreen extends StatefulWidget {
  final Contact? contact;

  const AddEditContactScreen({super.key, this.contact});

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String? _photoPath;
  bool _isSaving = false;

  bool get isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _firstNameController.text = widget.contact!.firstName;
      _lastNameController.text = widget.contact!.lastName;
      _phoneController.text = widget.contact!.phoneNumber;
      _emailController.text = widget.contact?.email ?? '';
      _companyController.text = widget.contact?.company ?? '';
      _addressController.text = widget.contact?.address ?? '';
      _notesController.text = widget.contact?.notes ?? '';
      _photoPath = widget.contact?.photoPath;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: scheme.primary),
              title: const Text('Take photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final image = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 85,
                );
                if (image != null && mounted) {
                  setState(() => _photoPath = image.path);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: scheme.primary),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 85,
                );
                if (image != null && mounted) {
                  setState(() => _photoPath = image.path);
                }
              },
            ),
            if (_photoPath != null)
              ListTile(
                leading:
                    const Icon(Icons.delete_rounded, color: AppTheme.error),
                title: const Text('Remove photo',
                    style: TextStyle(color: AppTheme.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _photoPath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<ContactProvider>();

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim().isEmpty
        ? null
        : _emailController.text.trim();
    final company = _companyController.text.trim().isEmpty
        ? null
        : _companyController.text.trim();
    final address = _addressController.text.trim().isEmpty
        ? null
        : _addressController.text.trim();
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    final success = isEditing
        ? await provider.updateContact(
            widget.contact!.copyWith(
              firstName: firstName,
              lastName: lastName,
              phoneNumber: phone,
              email: email,
              company: company,
              address: address,
              notes: notes,
              photoPath: _photoPath,
              updatedAt: DateTime.now(),
            ),
          )
        : await provider.addContact(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phone,
            email: email,
            company: company,
            address: address,
            notes: notes,
            photoPath: _photoPath,
          );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isEditing ? 'Contact updated' : 'Contact added')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditing ? 'Edit contact' : 'New contact'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveContact,
            child: _isSaving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.primary,
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _TopProfileCard(
              photoPath: _photoPath,
              onTap: _pickImage,
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Basic info',
              children: [
                _FormField(
                  controller: _firstNameController,
                  label: 'First name',
                  icon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if ((value == null || value.trim().isEmpty) &&
                        _lastNameController.text.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _FormField(
                  controller: _lastNameController,
                  label: 'Last name',
                  icon: Icons.badge_outlined,
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Contact details',
              children: [
                _FormField(
                  controller: _phoneController,
                  label: 'Phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[\d\+\-\(\)\s]')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    if (value.trim().length < 6) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _FormField(
                  controller: _emailController,
                  label: 'Email address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !value.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'More info',
              children: [
                _FormField(
                  controller: _companyController,
                  label: 'Company',
                  icon: Icons.business_outlined,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                _FormField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.location_on_outlined,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _FormField(
                  controller: _notesController,
                  label: 'Notes',
                  icon: Icons.notes_rounded,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopProfileCard extends StatelessWidget {
  final String? photoPath;
  final VoidCallback onTap;

  const _TopProfileCard({
    required this.photoPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer,
            scheme.tertiaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: onTap,
                child: photoPath != null
                    ? CircleAvatar(
                        radius: 52,
                        backgroundImage: FileImage(File(photoPath!)),
                      )
                    : CircleAvatar(
                        radius: 52,
                        backgroundColor: scheme.surface.withValues(alpha: 0.72),
                        child: Icon(
                          Icons.person_rounded,
                          size: 52,
                          color: scheme.primary,
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: scheme.onPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Add photo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Use the camera or gallery to personalize this contact.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onPrimaryContainer.withValues(alpha: 0.84),
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Icon(icon, size: 20, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            validator: validator,
            maxLines: maxLines,
            decoration: InputDecoration(
              labelText: label,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: scheme.outlineVariant),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: scheme.primary, width: 2),
              ),
              errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.error),
              ),
              focusedErrorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.error, width: 2),
              ),
              labelStyle: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }
}
