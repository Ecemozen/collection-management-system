import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';

class CustomerAddPage extends StatefulWidget {
  const CustomerAddPage({super.key});

  @override
  State<CustomerAddPage> createState() => _CustomerAddPageState();
}

class _CustomerAddPageState extends State<CustomerAddPage> {
  static const Color primary = Color(0xFFE31E24);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController companyController = TextEditingController();
  final TextEditingController authorizedController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController taxNumberController = TextEditingController();
  final TextEditingController taxOfficeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

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

  Future<void> _saveCustomer() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      final api = ApiService();

      final response = await api.post(
        "Customers",
        {
          "companyName": companyController.text.trim(),
          "authorizedPerson": authorizedController.text.trim(),
          "phone": phoneController.text.trim(),
          "email": emailController.text.trim(),
          "address":
              "${addressController.text.trim()}${districtController.text.trim().isNotEmpty ? ", ${districtController.text.trim()}" : ""}${cityController.text.trim().isNotEmpty ? ", ${cityController.text.trim()}" : ""}",
          "taxOffice": taxOfficeController.text.trim(),
          "taxNumber": taxNumberController.text.trim(),
        },
      );

      if (response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cari başarıyla kaydedildi."),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Cari kaydedilemedi. Kod: ${response.statusCode}",
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Yeni Cari Ekle",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 768;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 30 : 16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  padding: EdgeInsets.all(isDesktop ? 30 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Firma Bilgileri",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Firma Adı & Yetkili Kişi
                        _buildResponsiveRow(
                          isDesktop: isDesktop,
                          children: [
                            TextFormField(
                              controller: companyController,
                              validator: (val) => val == null || val.isEmpty
                                  ? "Firma adı gereklidir"
                                  : null,
                              decoration: const InputDecoration(
                                labelText: "Firma Adı",
                                prefixIcon: Icon(Icons.business),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextFormField(
                              controller: authorizedController,
                              decoration: const InputDecoration(
                                labelText: "Yetkili Kişi",
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Vergi No & Vergi Dairesi
                        _buildResponsiveRow(
                          isDesktop: isDesktop,
                          children: [
                            TextFormField(
                              controller: taxNumberController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Vergi No / T.C.",
                                prefixIcon: Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextFormField(
                              controller: taxOfficeController,
                              decoration: const InputDecoration(
                                labelText: "Vergi Dairesi",
                                prefixIcon: Icon(Icons.account_balance_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Telefon & E-Posta
                        _buildResponsiveRow(
                          isDesktop: isDesktop,
                          children: [
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: "Telefon",
                                prefixIcon: Icon(Icons.phone_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: "E-Posta",
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // İl & İlçe
                        _buildResponsiveRow(
                          isDesktop: isDesktop,
                          children: [
                            TextFormField(
                              controller: cityController,
                              decoration: const InputDecoration(
                                labelText: "İl",
                                prefixIcon: Icon(Icons.location_city),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            TextFormField(
                              controller: districtController,
                              decoration: const InputDecoration(
                                labelText: "İlçe",
                                prefixIcon: Icon(Icons.map_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Adres
                        TextFormField(
                          controller: addressController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: "Adres",
                            prefixIcon: Icon(Icons.home_outlined),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Açıklama
                        TextFormField(
                          controller: noteController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: "Açıklama / Notlar",
                            prefixIcon: Icon(Icons.note_alt_outlined),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 35),

                        // Aksiyon Butonları
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("İptal"),
                            ),
                            const SizedBox(width: 15),
                            ElevatedButton.icon(
                              onPressed: _saveCustomer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.save_rounded),
                              label: const Text(
                                "Kaydet",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveRow({
    required bool isDesktop,
    required List<Widget> children,
  }) {
    if (isDesktop) {
      return Row(
        children: children
            .map((widget) => Expanded(child: widget))
            .expand((widget) => [widget, const SizedBox(width: 20)])
            .toList()
          ..removeLast(),
      );
    } else {
      return Column(
        children: children
            .expand((widget) => [widget, const SizedBox(height: 20)])
            .toList()
          ..removeLast(),
      );
    }
  }
}