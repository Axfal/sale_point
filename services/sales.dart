import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:point_of_sales/models/invoice_model.dart';
import 'package:point_of_sales/utils/helpers/show_toast_dialouge.dart';
import 'client/api_client.dart';

class SalesService {
  final ApiClient _apiClient = ApiClient();
  final String _postInvoice = "/add_sale.php";
  final String _getInvoices = "/get_sale.php";
  final String _invoicePayment = "/invoice_payment.php";
  final String _updateSaleInvoice = "/update_invoice.php";
  final String _deleteSaleInvoice = "/xero_invoice_void.php";

  Future<Map<String, dynamic>?> addSale({required InvoiceModel invoice}) async {
    final List<Map<String, dynamic>> productList = invoice.products
        .map((p) => {
              "product_id": p.itemId,
              "sales_price": double.parse(p.salesPrice.toStringAsFixed(2)),
              "quantity": p.quantity,
            })
        .toList();

    final String taxType = invoice.taxStatus!;

    Map<String, dynamic> data = {
      "user_id": invoice.userId,
      "account_id": invoice.accountId ?? "null",
      "contact_id": invoice.contactId,
      "customer_name": invoice.customerName,
      "dated_today": DateFormat('yyyy-MM-dd').format(invoice.datedToday),
      "due_today": DateFormat('yyyy-MM-dd').format(invoice.dueToday),
      "invoice_number": invoice.invoiceNumber,
      "tax_type": taxType,
      "products": productList,
    };

    try {
      final response = await _apiClient.post(_postInvoice, data);

      if (response!['success'] == true) {
        print("Success: ${response["message"]}");
        ShowToastDialog.showToast(response['message']);
        return response;
      } else {
        print("Failed: error: ${response['error']}");
        return response;
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  /// 📌 Fetch Invoices by User ID (with optional pagination)
  Future<List<Map<String, dynamic>>> getInvoices(int userId) async {
    // Construct the URL with just the user_id query parameter
    String url = '$_getInvoices?user_id=$userId';

    final response = await _apiClient.get(url);
    debugPrint("📄 Fetched from $url => $response");

    // Check if the response is valid and contains the 'invoices' data
    if (response != null &&
        response['success'] == true &&
        response.containsKey('invoices')) {
      return List<Map<String, dynamic>>.from(response['invoices']);
    }

    return [];
  }

  /// update sale invoice section
  Future<dynamic> updateSaleInvoice(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(_updateSaleInvoice, data);
      if (response != null &&
          response['success'] == true &&
          response['message'] != null) {
        print('success is: ===> ${response['success']}');
        print('message ===> ${response['message']}');
        return response;
      }
    } catch (e) {
      print('error at service side');
    }
  }

  /// Deletes a sale invoice on the server.
  Future<dynamic> deleteSaleInvoice(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(_deleteSaleInvoice, data);

      if (response is Map<String, dynamic>) {
        print("response ======>>>>>123.>>>>> ${response}");
        if (response['success'] == true && response['message'] != null) {
          return response;
        } else if (response['success'] == false && response['error'] != null) {
          ShowToastDialog.showToast(response['error'].toString());
        } else {
          print("response ===>>> ${response['error'].toString()}");
          ShowToastDialog.showToast('Unexpected response from server.');
        }
      } else {
        ShowToastDialog.showToast('Invalid response format from server.');
      }
    } catch (e) {
      debugPrint("deleteSaleInvoice error: $e");
      ShowToastDialog.showToast('Failed to delete invoice. Try again.');
    }
    return null;
  }

  /// Posts payment details to the invoice_payment API
  Future<Map<String, dynamic>> invoicePayment({
    required String invoiceNumber,
    required double amount,
    required String paymentDate,
    required String accountCode,
  }) async {
    final Map<String, dynamic> data = {
      "invoice_number": invoiceNumber,
      "amount": amount,
      "payment_date": paymentDate,
      "account_code": accountCode,
    };

    debugPrint("[invoicePayment] Posting payload to /invoice_payment.php: \n");
    debugPrint(data.toString());

    final response = await _apiClient.post(_invoicePayment, data);

    debugPrint("[invoicePayment] Response from /invoice_payment.php: \n");
    debugPrint(response?.toString() ?? 'null');

    if (response == null) {
      return {
        "success": false,
        "message": "API response was null.",
      };
    }

    if (response['success'] == false) {
      return {
        "success": false,
        "message": response['error'] ??
            response['message'] ??
            "An error occurred while processing the payment.",
      };
    }

    return response;
  }
}
