import 'package:flutter/cupertino.dart';
import '../../../models/contacts_model.dart';
import '../../../services/contacts.dart';
import '../../../utils/constants/my_sharePrefs.dart';

class ContactsProvider with ChangeNotifier {
  final ContactsService _contactService = ContactsService();
  final MySharedPrefs _prefs = MySharedPrefs();

  List<ContactsModel> _allContacts = [];
  List<ContactsModel> _filteredContacts = [];
  bool _isLoading = false;
  Map<String, bool> _expandedContacts = {};

  List<ContactsModel> get contacts => _filteredContacts;
  bool get isLoading => _isLoading;
  bool isExpanded(String contactId) => _expandedContacts[contactId] ?? false;

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  /// ✅ Fetch contacts — from cache first, then API if expired
  Future<void> fetchContacts() async {
    _setLoading(true);
    try {
      final isExpired = await _prefs.isContactsCacheExpired();
      if (!isExpired) {
        print("📦 Loading contacts from cache...");
        final cachedContacts = await _prefs.getContacts();
        _allContacts = cachedContacts;
        _filteredContacts = cachedContacts;
        _setLoading(false);
        return;
      }

      print("🌐 Fetching contacts from API...");
      final fetchedContacts = await _contactService.getAllContacts();
      _allContacts = fetchedContacts;
      _filteredContacts = fetchedContacts;

      /// ✅ Cache the contacts
      await _prefs.setContacts(fetchedContacts);
    } catch (e) {
      print("❌ Failed to fetch contacts: $e");
    }
    _setLoading(false);
  }

  void searchContacts(String query) {
    if (query.isEmpty) {
      _filteredContacts = _allContacts;
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredContacts = _allContacts.where((contact) {
        try {
          final name = contact.name?.toLowerCase() ?? '';
          final email = contact.email?.toLowerCase() ?? '';
          return name.contains(lowerQuery) || email.contains(lowerQuery);
        } catch (e) {
          print("⚠️ Error filtering contact: $e");
          return false;
        }
      }).toList();
    }
    notifyListeners();
  }

  void toggleExpansion(String contactId) {
    if (_expandedContacts.containsKey(contactId)) {
      _expandedContacts[contactId] = !_expandedContacts[contactId]!;
    } else {
      _expandedContacts[contactId] = true;
    }
    notifyListeners();
  }


  /// ✅ Create New Contact
  Future<bool> createNewContact({
    required String name,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String phoneAreaCode,
    required String phoneCountryCode,
    required String addressLine1,
    required String city,
    required String region,
    required String postalCode,
    required String country,
    required String taxNumber,
    required String companyNumber,
    required String defaultCurrency,
  }) async {
    _setLoading(true);

    try {
      final isCreated = await _contactService.createContact(
        name: name,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        phoneAreaCode: phoneAreaCode,
        phoneCountryCode: phoneCountryCode,
        addressLine1: addressLine1,
        city: city,
        region: region,
        postalCode: postalCode,
        country: country,
        taxNumber: taxNumber,
        companyNumber: companyNumber,
        defaultCurrency: defaultCurrency,
      );

      if (isCreated) {
        // Refresh the contact list after successful creation
        await fetchContacts();
        print("✅ New contact created and list updated!");
        return true;
      } else {
        print("📛 Failed to create contact");
        return false;
      }
    } catch (e) {
      print("❌ Exception during creating new contact: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

}