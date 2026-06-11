import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';
import '../services/contact_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/contact_avatar.dart';
import 'add_edit_contact_screen.dart';

class ContactDetailScreen extends StatefulWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late Contact _contact;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  Future<void> _launchUri(Uri uri, {String? errorText}) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    if (!mounted || errorText == null) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorText)));
  }

  Future<void> _makeCall(String number) => _launchUri(
        Uri(scheme: 'tel', path: number),
        errorText: 'Could not start the call action on this device.',
      );

  Future<void> _sendSms(String number) =>
      _launchUri(Uri(scheme: 'sms', path: number));

  Future<void> _sendEmail(String email) =>
      _launchUri(Uri(scheme: 'mailto', path: email));

  Future<void> _toggleFavorite() async {
    final provider = context.read<ContactProvider>();
    await provider.toggleFavorite(_contact);
    setState(() {
      _contact = _contact.copyWith(isFavorite: !_contact.isFavorite);
    });
  }

  Future<void> _deleteContact() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete contact'),
        content: Text(
          'Are you sure you want to delete ${_contact.fullName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ContactProvider>().deleteContact(_contact.id);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_contact.fullName} deleted')),
      );
    }
  }

  Future<void> _editContact() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => AddEditContactScreen(contact: _contact)),
    );
    if (result == true && mounted) {
      final provider = context.read<ContactProvider>();
      final updated = provider.contacts.firstWhere(
        (c) => c.id == _contact.id,
        orElse: () => _contact,
      );
      setState(() => _contact = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: scheme.surface,
            foregroundColor: scheme.onSurface,
            actions: [
              IconButton(
                icon: Icon(
                  _contact.isFavorite
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: _contact.isFavorite
                      ? AppTheme.warning
                      : scheme.onSurfaceVariant,
                ),
                onPressed: _toggleFavorite,
                tooltip: _contact.isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  if (value == 'edit') _editContact();
                  if (value == 'delete') _deleteContact();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppTheme.error),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: AppTheme.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primaryContainer,
                      scheme.tertiaryContainer,
                      scheme.surface,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ContactAvatar(
                        contact: _contact,
                        radius: 52,
                        fontSize: 38,
                        heroTag: 'contact-avatar-${_contact.id}',
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _contact.fullName,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: scheme.onSurface,
                                ),
                      ),
                      if (_contact.company?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _contact.company!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.call_rounded,
                    label: 'Call',
                    color: scheme.primary,
                    onTap: () => _makeCall(_contact.phoneNumber),
                  ),
                  _ActionButton(
                    icon: Icons.message_rounded,
                    label: 'Message',
                    color: scheme.secondary,
                    onTap: () => _sendSms(_contact.phoneNumber),
                  ),
                  if (_contact.email?.isNotEmpty == true)
                    _ActionButton(
                      icon: Icons.email_rounded,
                      label: 'Email',
                      color: scheme.tertiary,
                      onTap: () => _sendEmail(_contact.email!),
                    ),
                  _ActionButton(
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    color: scheme.onSurfaceVariant,
                    onTap: _editContact,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.phone_rounded,
                        label: 'Mobile',
                        value: _contact.phoneNumber,
                        onTap: () => _makeCall(_contact.phoneNumber),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.message_outlined, size: 20),
                              color: scheme.primary,
                              onPressed: () => _sendSms(_contact.phoneNumber),
                            ),
                            IconButton(
                              icon: const Icon(Icons.call_outlined, size: 20),
                              color: scheme.primary,
                              onPressed: () => _makeCall(_contact.phoneNumber),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_contact.email?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    _InfoCard(
                      children: [
                        _InfoRow(
                          icon: Icons.email_rounded,
                          label: 'Email',
                          value: _contact.email!,
                          onTap: () => _sendEmail(_contact.email!),
                        ),
                      ],
                    ),
                  ],
                  if (_contact.company?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    _InfoCard(
                      children: [
                        _InfoRow(
                          icon: Icons.business_rounded,
                          label: 'Company',
                          value: _contact.company!,
                        ),
                      ],
                    ),
                  ],
                  if (_contact.address?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    _InfoCard(
                      children: [
                        _InfoRow(
                          icon: Icons.location_on_rounded,
                          label: 'Address',
                          value: _contact.address!,
                        ),
                      ],
                    ),
                  ],
                  if (_contact.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    _InfoCard(
                      children: [
                        _InfoRow(
                          icon: Icons.notes_rounded,
                          label: 'Notes',
                          value: _contact.notes!,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
