import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/contact_provider.dart';
import 'contacts_tab.dart';
import 'favorites_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    ContactsTab(),
    FavoritesTab(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactProvider>().loadContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Material(
          color: scheme.surfaceContainer,
          elevation: 8,
          shadowColor: Colors.black12,
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) =>
                setState(() => _currentIndex = index),
            height: 72,
            backgroundColor: Colors.transparent,
            indicatorColor: scheme.secondaryContainer,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.people_outline_rounded),
                selectedIcon: Icon(Icons.people_rounded),
                label: 'Contacts',
              ),
              NavigationDestination(
                icon: Icon(Icons.star_outline_rounded),
                selectedIcon: Icon(Icons.star_rounded),
                label: 'Favorites',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
