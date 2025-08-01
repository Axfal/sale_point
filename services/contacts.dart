import '../models/contacts_model.dart';
import 'client/api_client.dart';

class ContactsService {
  final ApiClient _apiClient = ApiClient();
  final String _getContacts = "/get_contacts.php";
  final String _postContact = "/add_customers.php";

  /// 🔹 Fetch All Contacts
  Future<List<ContactsModel>> getAllContacts() async {
    try {
      final response = await _apiClient.get(_getContacts);

      if (response != null &&
          response['success'] == true &&
          response['data'] is List) {
        final List<dynamic> contactList = response['data'];
        return contactList
            .map((json) => ContactsModel.fromJson(json))
            .toList();
      }

      print("📛 API responded with failure: ${response?['message'] ?? 'Unknown error'}");
    } catch (e) {
      print("❌ Exception during fetching contacts: $e");
    }

    return [];
  }

  /// 🔹 Create New Contact
  Future<bool> createContact({
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
    try {
      final response = await _apiClient.post(_postContact,
         {
          'name': name,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'phone_area_code': phoneAreaCode,
          'phone_country_code': phoneCountryCode,
          'address_line1': addressLine1,
          'city': city,
          'region': region,
          'postal_code': postalCode,
          'country': country,
          'tax_number': taxNumber,
          'company_number': companyNumber,
          'default_currency': defaultCurrency,
        },
      );

      if (response != null && response['success'] == true) {
        print("✅ Customer created successfully!");
        return true;
      } else {
        print("📛 API responded with failure: ${response?['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("❌ Exception during creating customer: $e");
    }

    return false;
  }
}