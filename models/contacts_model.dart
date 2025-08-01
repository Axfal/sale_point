class ContactsModel {
  final String contactId;
  final String? contactStatus;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? phoneAreaCode;
  final String? phoneCountryCode;
  final String? addressLine1;
  final String? city;
  final String? region;
  final String? postalCode;
  final String? country;
  final String? taxNumber;
  final String? companyNumber;
  final String? defaultCurrency;

  ContactsModel({
    required this.contactId,
    this.contactStatus,
    this.name,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.phoneAreaCode,
    this.phoneCountryCode,
    this.addressLine1,
    this.city,
    this.region,
    this.postalCode,
    this.country,
    this.taxNumber,
    this.companyNumber,
    this.defaultCurrency,
  });

  /// Factory method to create ContactsModel from JSON response
  factory ContactsModel.fromJson(Map<String, dynamic> json) {
    return ContactsModel(
      contactId: json['contact_id'] ?? '',
      contactStatus: json['contact_status'],
      name: json['name'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      phoneAreaCode: json['phone_area_code'],
      phoneCountryCode: json['phone_country_code'],
      addressLine1: json['address_line1'],
      city: json['city'],
      region: json['region'],
      postalCode: json['postal_code'],
      country: json['country'],
      taxNumber: json['tax_number'],
      companyNumber: json['company_number'],
      defaultCurrency: json['default_currency'],
    );
  }

  // Convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'contact_id': contactId,
      'contact_status': contactStatus,
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
    };
  }
}
