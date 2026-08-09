import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';

class CustomerEditPage extends StatefulWidget {
  final int customerId;

  const CustomerEditPage({
    super.key,
    required this.customerId,
  });

  @override
  State<CustomerEditPage> createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends State<CustomerEditPage> {
  static const Color primary = Color(0xFFE31E24);

  final _formKey = GlobalKey<FormState>();

  final companyController = TextEditingController();
  final authorizedController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final taxNumberController = TextEditingController();
  final taxOfficeController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final addressController = TextEditingController();
  final noteController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    try {
      final api = ApiService();

      final response = await api.get(
        "Customers/${widget.customerId}",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          companyController.text = data["companyName"] ?? "";
          authorizedController.text = data["authorizedPerson"] ?? "";
          phoneController.text = data["phone"] ?? "";
          emailController.text = data["email"] ?? "";
          taxNumberController.text = data["taxNumber"] ?? "";
          taxOfficeController.text = data["taxOffice"] ?? "";
          addressController.text = data["address"] ?? "";

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              "Cari bilgileri alınamadı. Kod: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Bağlantı hatası: $e";
      });
    }
  }

  Future<void> _updateCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final api = ApiService();

      final body = {
        "companyName": companyController.text.trim(),
        "authorizedPerson": authorizedController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "address": addressController.text.trim(),
        "taxOffice": taxOfficeController.text.trim(),
        "taxNumber": taxNumberController.text.trim(),
      };

      final response = await api.put(
        "Customers/${widget.customerId}",
        body,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cari başarıyla güncellendi."),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        setState(() {
          isSaving = false;
        });

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
      setState(() {
        isSaving = false;
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
    companyController.dispose();
    authorizedController.dispose();
    phoneController.dispose();
    emailController.dispose();
    taxNumberController.dispose();
    taxOfficeController.dispose();
    cityController.dispose();
    districtController.dispose();
    addressController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Cari Düzenle"),
        ),
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Cari Düzenle",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Cari Bilgileri",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: companyController,
                      decoration: const InputDecoration(
                        labelText: "Firma Adı",
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      controller: authorizedController,
                      decoration: const InputDecoration(
                        labelText: "Yetkili Kişi",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: taxNumberController,
                      decoration: const InputDecoration(
                        labelText: "Vergi No",
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      controller: taxOfficeController,
                      decoration: const InputDecoration(
                        labelText: "Vergi Dairesi",
                        prefixIcon: Icon(Icons.account_balance),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: "Telefon",
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "E-Posta",
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: "İl",
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      controller: districtController,
                      decoration: const InputDecoration(
                        labelText: "İlçe",
                        prefixIcon: Icon(Icons.map),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Adres",
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Açıklama",
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                    onPressed: isSaving ? null : _updateCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 18,
                      ),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text("Güncelle"),
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