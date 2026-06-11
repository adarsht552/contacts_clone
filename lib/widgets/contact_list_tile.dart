import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../utils/app_theme.dart';
import 'contact_avatar.dart';

class ContactListTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final bool showDivider;
  final VoidCallback? onCallTap;

  const ContactListTile({
    super.key,
    required this.contact,
    required this.onTap,
    this.showDivider = true,
    this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final secondaryText = contact.company?.isNotEmpty == true
        ? contact.company!
        : contact.phoneNumber;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ContactAvatar(
                  contact: contact,
                  radius: 24,
                  fontSize: 16,
                  heroTag: 'contact-avatar-${contact.id}',
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.fullName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        secondaryText,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onCallTap != null)
                  IconButton.filledTonal(
                    onPressed: onCallTap,
                    icon: const Icon(Icons.call_outlined, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: scheme.secondaryContainer,
                      foregroundColor: scheme.onSecondaryContainer,
                    ),
                  ),
                if (contact.isFavorite)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.star_rounded,
                      color: AppTheme.warning,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 72),
            child: Divider(height: 1),
          ),
      ],
    );
  }
}
