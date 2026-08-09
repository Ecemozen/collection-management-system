import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';
import 'package:tahsilat_mobile/features/receipt/pages/receipt_preview_page.dart';

class PaymentModel {
  final int id;
  final String customer;
  final String amount;
  final String date;
  final String paymentType;
  final String status;

  PaymentModel({
    required this.id,
    required this.customer,
    required this.amount,
    required this.date,
    required this.paymentType,
    this.status = 'Ödendi',
  });
}

class PaymentAddPage extends StatefulWidget {
  final Function(PaymentModel) onPaymentAdded;

  const PaymentAddPage({super.key, required this.onPaymentAdded});

  @override
  State<PaymentAddPage> createState() => _PaymentAddPageState();
}

class _PaymentAddPageState extends State<PaymentAddPage> {
  static const Color primary = Color(0xFFE31E24);
  
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  
  List<Map<String, dynamic>> _feeTypes = [];
  bool _isLoadingFeeTypes = true;
  String? _selectedPaymentType;

  List<String> _customerList = [];
  bool _isLoadingCustomers = true;

  int? _selectedDebtId;
  double? _remainingAmount;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadFeeTypes();
  }

  Future<void> _loadCustomers() async {
    try {
      final api = ApiService();
      final response = await api.get("Customers");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _customerList = data
              .map((customer) =>
                  customer["companyName"]?.toString() ?? "")
              .where((name) => name.isNotEmpty)
              .toList();

          _isLoadingCustomers = false;
        });
      } else {
        setState(() {
          _isLoadingCustomers = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingCustomers = false;
      });
    }
  }

  Future<void> _loadFeeTypes() async {
    try {
      final api = ApiService();
      final response = await api.get("FeeTypes");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _feeTypes = data
              .map((item) => {
                    "id": item["id"],
                    "name": item["name"]?.toString() ?? "",
                  })
              .where((item) =>
                  item["name"].toString().isNotEmpty &&
                  item["name"].toString() != "string" &&
                  item["name"].toString() != "Havale")
              .toList();

          if (_feeTypes.isNotEmpty) {
            _selectedPaymentType = _feeTypes.first["name"].toString();
          }

          _isLoadingFeeTypes = false;
        });
      } else {
        setState(() {
          _isLoadingFeeTypes = false;
        });
      }
    } catch (e) {
      print("FeeTypes yükleme hatası: $e");

      setState(() {
        _isLoadingFeeTypes = false;
      });
    }
  }

  Future<void> _loadDebtForCustomer(String customerName) async {
    try {
      final api = ApiService();

      final response = await api.get(
        "Debts/search?customerName=${Uri.encodeComponent(customerName)}",
      );

      if (response.statusCode == 200) {
        final List<dynamic> debts = jsonDecode(response.body);

        if (debts.isNotEmpty) {
          final debt = debts.first;

          setState(() {
            _selectedDebtId = debt["id"];
            _remainingAmount =
                (debt["remainingAmount"] as num?)?.toDouble();
          });
        } else {
          setState(() {
            _selectedDebtId = null;
            _remainingAmount = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _selectedDebtId = null;
        _remainingAmount = null;
      });
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getSelectedFeeTypeName() {
    return _selectedPaymentType ?? "Nakit";
  }

  int? _getSelectedFeeTypeId() {
    final selected = _feeTypes.firstWhere(
      (element) => element["name"] == _selectedPaymentType,
      orElse: () => {},
    );
    return selected["id"];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String formattedDate = "${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}";
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptPreviewPage(
            customerName: _customerController.text.trim(),
            amount: _amountController.text.trim(),
            paymentType: _getSelectedFeeTypeName(),
            date: formattedDate,
            note: _noteController.text.trim(),
          ),
        ),
      );
    }
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDebtId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen bir cari/müşteri seçiniz."),
        ),
      );
      return;
    }

    final selectedFeeTypeId = _getSelectedFeeTypeId();
    if (selectedFeeTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen bir ödeme türü seçiniz."),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Geçerli bir tutar giriniz."),
        ),
      );
      return;
    }

    final api = ApiService();

    final body = {
      "debtId": _selectedDebtId,
      "amount": amount,
      "paymentDate": _selectedDate.toIso8601String(),
      "feeTypeId": selectedFeeTypeId,
      "description": _noteController.text.trim(),
    };

    try {
      final response = await api.post(
        "Payments",
        body,
      );

      print("Payment Status Code: ${response.statusCode}");
      print("Payment Response: ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        final paymentData = jsonDecode(response.body);
        final int paymentId = paymentData["id"];

        // Makbuz oluştur
        final receiptResponse = await api.post(
          "Receipts",
          {
            "paymentId": paymentId,
          },
        );

        if (receiptResponse.statusCode != 200 &&
            receiptResponse.statusCode != 201) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Tahsilat kaydedildi fakat makbuz oluşturulamadı. "
                "Kod: ${receiptResponse.statusCode}",
              ),
            ),
          );

          return;
        }

        final receiptData = jsonDecode(receiptResponse.body);

        final formattedDate =
            "${_selectedDate.day.toString().padLeft(2, '0')}."
            "${_selectedDate.month.toString().padLeft(2, '0')}."
            "${_selectedDate.year}";

        final newPayment = PaymentModel(
          id: paymentId,
          customer: _customerController.text.trim(),
          amount: "₺${amount.toStringAsFixed(0)}",
          date: formattedDate,
          paymentType: _getSelectedFeeTypeName(),
          status: "Ödendi",
        );

        widget.onPaymentAdded(newPayment);

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptPreviewPage(
              paymentId: paymentId,
              customerName:
                  receiptData["companyName"]?.toString() ?? "",
              amount:
                  receiptData["amount"]?.toString() ?? "0",
              paymentType:
                  receiptData["feeTypeName"]?.toString() ?? "",
              date:
                  receiptData["paymentDate"]
                      ?.toString()
                      .split("T")
                      .first ??
                  formattedDate,
              note:
                  receiptData["description"]?.toString() ?? "",
            ),
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Tahsilat kaydedilemedi. Kod: ${response.statusCode}",
            ),
          ),
        );
      }
    } catch (e) {
      print("Payment Error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hata oluştu: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Yeni Tahsilat Ekle",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(35),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const Text(
                        "Tahsilat Bilgileri",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Lütfen tahsilat detaylarını eksiksiz giriniz.",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const Divider(height: 40, thickness: 1.2),
                      
                      // Cari / Müşteri Seçimi ve Özelleştirilmiş Autocomplete
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return _customerList.where((String customer) {
                            return customer.toLowerCase().contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String selection) {
                          setState(() {
                            _customerController.text = selection;
                          });

                          _loadDebtForCustomer(selection);
                        },
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                          if (_customerController.text.isNotEmpty && controller.text.isEmpty) {
                            controller.text = _customerController.text;
                          }
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            onChanged: (value) {
                              _customerController.text = value;
                            },
                            decoration: InputDecoration(
                              labelText: _isLoadingCustomers ? "Müşteriler Yükleniyor..." : "Cari / Müşteri Ara veya Seç",
                              prefixIcon: const Icon(Icons.person_search, color: primary),
                              suffixIcon: _isLoadingCustomers
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Lütfen cari adı seçiniz veya yazınız.";
                              }
                              return null;
                            },
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 220,
                                  maxWidth: 580,
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final String option = options.elementAt(index);
                                    return InkWell(
                                      onTap: () {
                                        onSelected(option);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          border: index < options.length - 1
                                              ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                                              : null,
                                        ),
                                        child: Text(
                                          option,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Tahsilat Tutarı
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: "Tahsilat Tutarı (₺)",
                          prefixIcon: const Icon(Icons.currency_lira, color: primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Lütfen tutar giriniz.";
                          }
                          if (double.tryParse(value) == null) {
                            return "Geçerli bir sayı giriniz.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Ödeme Türü Dropdown
                      DropdownButtonFormField<String>(
                        value: _feeTypes.any(
                          (fee) => fee["name"] == _selectedPaymentType,
                        )
                            ? _selectedPaymentType
                            : null,
                        decoration: InputDecoration(
                          labelText: _isLoadingFeeTypes ? "Ödeme Türleri Yükleniyor..." : "Ödeme Türü",
                          prefixIcon: const Icon(Icons.payment, color: primary),
                          suffixIcon: _isLoadingFeeTypes
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _feeTypes.map((fee) {
                          return DropdownMenuItem<String>(
                            value: fee["name"].toString(),
                            child: Text(fee["name"].toString()),
                          );
                        }).toList(),
                        onChanged: _isLoadingFeeTypes
                            ? null
                            : (String? newValue) {
                                if (newValue == null) return;

                                setState(() {
                                  _selectedPaymentType = newValue;
                                });
                              },
                        validator: (value) {
                          if (value == null) {
                            return "Lütfen ödeme türü seçiniz.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Tarih Seçici
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: "İşlem Tarihi",
                            prefixIcon: const Icon(Icons.calendar_today, color: primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Açıklama / Not
                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Açıklama / Not (Opsiyonel)",
                          prefixIcon: const Icon(Icons.note, color: primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Makbuzu Önizle Butonu
                      SizedBox(
                        height: 45,
                        child: OutlinedButton.icon(
                          onPressed: _submitForm,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: const BorderSide(color: primary, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.visibility, size: 20),
                          label: const Text(
                            "Makbuzu Önizle",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tahsilatı Kaydet Butonu
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _savePayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.save),
                          label: const Text(
                            "Tahsilatı Kaydet",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}