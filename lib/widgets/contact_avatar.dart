import 'dart:io';
import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../utils/app_theme.dart';

class ContactAvatar extends StatelessWidget {
  final Contact contact;
  final double radius;
  final double fontSize;
  final String? heroTag;

  const ContactAvatar({
    super.key,
    required this.contact,
    this.radius = 24,
    this.fontSize = 18,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final avatar = _buildAvatar(scheme);
    if (heroTag == null) return avatar;
    return Hero(tag: heroTag!, child: avatar);
  }

  Widget _buildAvatar(ColorScheme scheme) {
    if (contact.photoPath != null && contact.photoPath!.isNotEmpty) {
      final file = File(contact.photoPath!);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: FileImage(file),
        );
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.avatarColorForName(
        contact.firstName.isNotEmpty ? contact.firstName : contact.lastName,
        scheme,
      ),
      child: Text(
        contact.initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
