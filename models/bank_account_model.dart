class BankAccountModel {
  final String accountId;
  final String? code;
  final String name;
  final String status;
  final String type;
  final String taxType;
  final String accountClass;
  final bool enablePaymentsToAccount;
  final bool showInExpenseClaims;
  final String bankAccountNumber;
  final String bankAccountType;
  final String currencyCode;
  final String reportingCode;
  final String reportingCodeName;
  final bool hasAttachments;
  final DateTime updatedDateUTC;
  final bool addToWatchlist;

  BankAccountModel({
    required this.accountId,
    required this.code,
    required this.name,
    required this.status,
    required this.type,
    required this.taxType,
    required this.accountClass,
    required this.enablePaymentsToAccount,
    required this.showInExpenseClaims,
    required this.bankAccountNumber,
    required this.bankAccountType,
    required this.currencyCode,
    required this.reportingCode,
    required this.reportingCodeName,
    required this.hasAttachments,
    required this.updatedDateUTC,
    required this.addToWatchlist,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    // Parse the UTC date string which comes in format "/Date(timestamp+0000)/"
    String dateStr = json['UpdatedDateUTC'] as String;
    int timestamp = int.parse(
      dateStr.replaceAll('/Date(', '').replaceAll('+0000)/', ''),
    );
    DateTime updatedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);

    return BankAccountModel(
      accountId: json['AccountID'] ?? '',
      code: json['Code'] ?? '',
      name: json['Name'] ?? '',
      status: json['Status'] ?? '',
      type: json['Type'] ?? '',
      taxType: json['TaxType'] ?? '',
      accountClass: json['Class'] ?? '',
      enablePaymentsToAccount: json['EnablePaymentsToAccount'] ?? false,
      showInExpenseClaims: json['ShowInExpenseClaims'] ?? false,
      bankAccountNumber: json['BankAccountNumber'] ?? '',
      bankAccountType: json['BankAccountType'] ?? '',
      currencyCode: json['CurrencyCode'] ?? '',
      reportingCode: json['ReportingCode'] ?? '',
      reportingCodeName: json['ReportingCodeName'] ?? '',
      hasAttachments: json['HasAttachments'] ?? false,
      updatedDateUTC: updatedDate,
      addToWatchlist: json['AddToWatchlist'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AccountID': accountId,
      'Code': code,
      'Name': name,
      'Status': status,
      'Type': type,
      'TaxType': taxType,
      'Class': accountClass,
      'EnablePaymentsToAccount': enablePaymentsToAccount,
      'ShowInExpenseClaims': showInExpenseClaims,
      'BankAccountNumber': bankAccountNumber,
      'BankAccountType': bankAccountType,
      'CurrencyCode': currencyCode,
      'ReportingCode': reportingCode,
      'ReportingCodeName': reportingCodeName,
      'HasAttachments': hasAttachments,
      'UpdatedDateUTC': '/Date(${updatedDateUTC.millisecondsSinceEpoch}+0000)/',
      'AddToWatchlist': addToWatchlist,
    };
  }
}
