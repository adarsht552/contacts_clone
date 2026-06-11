import 'package:flutter/foundation.dart';
import '../models/contact.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class ContactProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<Contact> _contacts = [];
  List<Contact> _favorites = [];
  List<Contact> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';

  List<Contact> get contacts => _contacts;
  List<Contact> get favorites => _favorites;
  List<Contact> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  // Grouped contacts by first letter
  Map<String, List<Contact>> get groupedContacts {
    final Map<String, List<Contact>> grouped = {};
    final list = _isSearching ? _searchResults : _contacts;
    for (var contact in list) {
      final key = contact.firstName.isNotEmpty
          ? contact.firstName[0].toUpperCase()
          : contact.lastName.isNotEmpty
              ? contact.lastName[0].toUpperCase()
              : '#';
      grouped.putIfAbsent(key, () => []).add(contact);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _contacts = await _db.getAllContacts();
      _favorites = await _db.getFavoriteContacts();
    } catch (e) {
      debugPrint('Error loading contacts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addContact({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? email,
    String? company,
    String? address,
    String? notes,
    String? photoPath,
  }) async {
    try {
      final contact = Contact(
        id: const Uuid().v4(),
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        email: email,
        company: company,
        address: address,
        notes: notes,
        photoPath: photoPath,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _db.insertContact(contact);
      await loadContacts();
      return true;
    } catch (e) {
      debugPrint('Error adding contact: $e');
      return false;
    }
  }

  Future<bool> updateContact(Contact contact) async {
    try {
      final updated = contact.copyWith(updatedAt: DateTime.now());
      await _db.updateContact(updated);
      await loadContacts();
      return true;
    } catch (e) {
      debugPrint('Error updating contact: $e');
      return false;
    }
  }

  Future<bool> deleteContact(String id) async {
    try {
      await _db.deleteContact(id);
      await loadContacts();
      return true;
    } catch (e) {
      debugPrint('Error deleting contact: $e');
      return false;
    }
  }

  Future<bool> toggleFavorite(Contact contact) async {
    try {
      await _db.toggleFavorite(contact.id, !contact.isFavorite);
      await loadContacts();
      return true;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  Future<void> searchContacts(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _isSearching = false;
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isSearching = true;
    _searchResults = await _db.searchContacts(query);
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    _searchResults = [];
    notifyListeners();
  }
}
