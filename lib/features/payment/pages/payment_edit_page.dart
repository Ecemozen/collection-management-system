import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';

class PaymentEditPage extends StatefulWidget {
  final int paymentId;

  const PaymentEditPage({
    super.key,
    required this.paymentId,
  });

  @override
  State<PaymentEditPage> createState() => _PaymentEditPageState();
}

class _PaymentEditPageState extends State<PaymentEditPage> {
  static const Color primary = Color(0xFFE31E24);
  final ApiService _apiService = ApiService();
  bool isLoading = true;
  bool isSaving = false;

  final _formKey = GlobalKey<FormState>();

  String? selectedCustomer = "ABC Otomotiv";
  String? selectedPaymentType;
  int? selectedFeeTypeId;
  List<Map<String, dynamic>> feeTypes = [];
  bool isLoadingFeeTypes = true;

  final amountController = TextEditingController();
  final receiptNoController = TextEditingController();
  final bankController = TextEditingController();
  final noteController = TextEditingController();
  final dateController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _updateDateText();
    _loadFeeTypes();
    _loadPayment();
  }

  void _updateDateText() {
    dateController.text =
        "${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}";
  }

  Future<void> _loadFeeTypes() async {
    try {
      final response = await _apiService.get("FeeTypes");

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          feeTypes = data
              .map((item) => {
                    "id": item["id"],
                    "name": item["name"]?.toString() ?? "",
                  })
              .where((item) =>
                  item["name"].toString().isNotEmpty &&
                  item["name"].toString() != "string" &&
                  item["name"].toString() != "Havale")
              .toList();

          isLoadingFeeTypes = false;
        });
      } else {
        setState(() {
          isLoadingFeeTypes = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingFeeTypes = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ödeme türleri alınamadı: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadPayment() async {
    try {
      final response = await _apiService.get(
        "Payments/${widget.paymentId}",
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          selectedCustomer = data["companyName"]?.toString();
          selectedPaymentType = data["feeTypeName"]?.toString();
          selectedFeeTypeId = data["feeTypeId"];
          amountController.text = data["amount"]?.toString() ?? "";
          receiptNoController.text = data["receiptNo"]?.toString() ?? "";
          bankController.text = data["bankName"]?.toString() ?? "";
          noteController.text = data["description"]?.toString() ?? "";

          if (data["paymentDate"] != null) {
            selectedDate = DateTime.parse(data["paymentDate"].toString());
            _updateDateText();
          }

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tahsilat alınamadı. Kod: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bağlantı hatası: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    receiptNoController.dispose();
    bankController.dispose();
    noteController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _updateDateText();
      });
    }
  }

  Future<void> _updatePayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedFeeTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ödeme türü bilgisi alınamadı."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final body = {
        "amount": double.tryParse(
              amountController.text.trim(),
            ) ??
            0.0,
        "paymentDate": selectedDate.toIso8601String(),
        "feeTypeId": selectedFeeTypeId,
        "description": noteController.text.trim(),
      };

      final response = await _apiService.put(
        "Payments/${widget.paymentId}",
        body,
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tahsilat başarıyla güncellendi."),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Güncelleme başarısız. Kod: ${response.statusCode}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bağlantı hatası: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
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
          "Tahsilatı Düzenle",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primary),
            )
          : Padding(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text(
                      "Tahsilat Düzenle",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Cari Seçimi
                    DropdownButtonFormField<String>(
                      value: selectedCustomer,
                      decoration: const InputDecoration(
                        labelText: "Cari",
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        if (selectedCustomer != null &&
                            ![
                              "ABC Otomotiv",
                              "XYZ İnşaat",
                              "Yiğit Akü Bayi",
                            ].contains(selectedCustomer))
                          DropdownMenuItem(
                            value: selectedCustomer,
                            child: Text(selectedCustomer!),
                          ),
                        const DropdownMenuItem(
                          value: "ABC Otomotiv",
                          child: Text("ABC Otomotiv"),
                        ),
                        const DropdownMenuItem(
                          value: "XYZ İnşaat",
                          child: Text("XYZ İnşaat"),
                        ),
                        const DropdownMenuItem(
                          value: "Yiğit Akü Bayi",
                          child: Text("Yiğit Akü Bayi"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCustomer = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? "Lütfen bir cari seçin" : null,
                    ),
                    const SizedBox(height: 20),

                    // Tahsilat Tutarı
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Tahsilat Tutarı",
                        prefixIcon: Icon(Icons.payments),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Lütfen tutar girin";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Ödeme Türü
                    DropdownButtonFormField<int>(
                      value: feeTypes.any(
                        (fee) => fee["id"] == selectedFeeTypeId,
                      )
                          ? selectedFeeTypeId
                          : null,
                      decoration: InputDecoration(
                        labelText: isLoadingFeeTypes
                            ? "Ödeme Türleri Yükleniyor..."
                            : "Ödeme Türü",
                        prefixIcon: const Icon(Icons.account_balance_wallet),
                        suffixIcon: isLoadingFeeTypes
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              )
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                      items: feeTypes.map((fee) {
                        return DropdownMenuItem<int>(
                          value: fee["id"] as int,
                          child: Text(fee["name"].toString()),
                        );
                      }).toList(),
                      onChanged: isLoadingFeeTypes
                          ? null
                          : (value) {
                              setState(() {
                                selectedFeeTypeId = value;

                                final selected = feeTypes.firstWhere(
                                  (fee) => fee["id"] == value,
                                );

                                selectedPaymentType =
                                    selected["name"].toString();
                              });
                            },
                      validator: (value) =>
                          value == null ? "Lütfen ödeme türü seçin" : null,
                    ),
                    const SizedBox(height: 20),

                    // Banka
                    TextFormField(
                      controller: bankController,
                      decoration: const InputDecoration(
                        labelText: "Banka",
                        prefixIcon: Icon(Icons.account_balance),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Makbuz No
                    TextFormField(
                      controller: receiptNoController,
                      decoration: const InputDecoration(
                        labelText: "Makbuz No",
                        prefixIcon: Icon(Icons.receipt_long),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tarih Seçimi
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: const InputDecoration(
                        labelText: "Tarih",
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Açıklama
                    TextFormField(
                      controller: noteController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Açıklama",
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 35),

                    // İptal ve Güncelle Butonları
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: isSaving ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 18,
                            ),
                          ),
                          child: const Text("İptal"),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton.icon(
                          onPressed: isSaving ? null : _updatePayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 18,
                            ),
                          ),
                          icon: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                              isSaving ? "Güncelleniyor..." : "Güncelle"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}