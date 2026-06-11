import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../services/contact_provider.dart';
import '../widgets/contact_avatar.dart';
import '../widgets/contact_list_tile.dart';
import 'contact_detail_screen.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ContactProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final favorites = provider.favorites;
          if (favorites.isEmpty) {
            return const _EmptyFavorites();
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _FavoritesHeader(favorites: favorites)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final contact = favorites[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 320),
                        child: SlideAnimation(
                          verticalOffset: 24,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                child: ContactListTile(
                                  contact: contact,
                                  showDivider: false,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ContactDetailScreen(contact: contact),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: favorites.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  final List<Contact> favorites;

  const _FavoritesHeader({required this.favorites});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final headlineStyle = Theme.of(context).textTheme.headlineMedium;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Favorites', style: headlineStyle),
            const SizedBox(height: 6),
            Text(
              'Pinned people for quick access',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primaryContainer,
                    scheme.tertiaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: scheme.onPrimaryContainer),
                      const SizedBox(width: 10),
                      Text(
                        '${favorites.length} favorite contacts',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 98,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: favorites.length > 8 ? 8 : favorites.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final contact = favorites[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ContactDetailScreen(contact: contact),
                            ),
                          ),
                          child: Column(
                            children: [
                              ContactAvatar(
                                contact: contact,
                                radius: 28,
                                fontSize: 18,
                                heroTag: 'contact-avatar-${contact.id}',
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 68,
                                child: Text(
                                  contact.firstName.isNotEmpty
                                      ? contact.firstName
                                      : contact.lastName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: scheme.onPrimaryContainer,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'All starred contacts',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
            child: Column(
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star_outline_rounded,
                    size: 54,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No favorites yet',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Mark important contacts with a star and they will appear here for faster calling and access.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
