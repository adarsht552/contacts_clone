import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';
import '../services/contact_provider.dart';
import '../widgets/contact_list_tile.dart';
import 'add_edit_contact_screen.dart';
import 'contact_detail_screen.dart';

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key});

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openComposer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditContactScreen()),
    );
    if (result == true && mounted) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _callContact(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    context.read<ContactProvider>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openComposer,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Create'),
      ),
      body: Consumer<ContactProvider>(
        builder: (context, provider, _) {
          final grouped = provider.groupedContacts;
          final totalContacts = provider.contacts.length;
          final favoriteCount = provider.favorites.length;

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: provider.loadContacts,
            child: CustomScrollView(
              key: const ValueKey('contacts_scroll_view'),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // 1. The Header is ALWAYS rendered so focus is never lost
                SliverToBoxAdapter(
                  child: _Header(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: provider.searchContacts,
                    onClear: _clearSearch,
                    totalContacts: totalContacts,
                    favoriteCount: favoriteCount,
                    isSearching: provider.isSearching,
                  ),
                ),
                // 2. Condition checks if contacts exist
                if (grouped.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      isSearch: provider.isSearching,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final key = grouped.keys.elementAt(index);
                          final contacts = grouped[key]!;
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 320),
                            child: SlideAnimation(
                              verticalOffset: 24,
                              child: FadeInAnimation(
                                child: _ContactSection(
                                  title: key,
                                  contacts: contacts,
                                  onCall: _callContact,
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: grouped.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final int totalContacts;
  final int favoriteCount;
  final bool isSearching;

  const _Header({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
    required this.totalContacts,
    required this.favoriteCount,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contacts',
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? 'Search across names, numbers, and email'
                  : '$totalContacts contacts, $favoriteCount favorites',
              style: textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            SearchBar(
              controller: controller,
              focusNode: focusNode,
              hintText: 'Search contacts',
              leading: const Icon(Icons.search_rounded),
              trailing: [
                if (controller.text.isNotEmpty)
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor:
                  WidgetStatePropertyAll(scheme.surfaceContainerHigh),
              onChanged: onChanged,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _HighlightCard(
                    icon: Icons.people_alt_outlined,
                    label: 'All contacts',
                    value: totalContacts.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HighlightCard(
                    icon: Icons.star_outline_rounded,
                    label: 'Favorites',
                    value: favoriteCount.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HighlightCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  final String title;
  final List<Contact> contacts;
  final ValueChanged<String> onCall;

  const _ContactSection({
    required this.title,
    required this.contacts,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: scheme.primary,
                      letterSpacing: 0.3,
                    ),
              ),
            ),
            ...contacts.asMap().entries.map((entry) {
              final i = entry.key;
              final contact = entry.value;
              return ContactListTile(
                contact: contact,
                showDivider: i < contacts.length - 1,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContactDetailScreen(contact: contact),
                  ),
                ),
                onCallTap: () => onCall(contact.phoneNumber),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isSearch;

  const _EmptyState({super.key, this.isSearch = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Removed the ListView so it integrates perfectly with SliverFillRemaining
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centers it nicely
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearch ? Icons.search_off_rounded : Icons.people_alt_outlined,
              size: 52,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearch ? 'No contacts found' : 'Start building your directory',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            isSearch
                ? 'Try a different name, phone number, or email address.'
                : 'Create your first contact to see them appear here with favorites and quick actions.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}