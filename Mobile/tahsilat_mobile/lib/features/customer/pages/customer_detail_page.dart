import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';

class CustomerDetailPage extends StatefulWidget {
  final int customerId;

  const CustomerDetailPage({
    super.key,
    required this.customerId,
  });

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  static const Color primary = Color(0xFFE31E24);

  Map<String, dynamic>? customerData;
  bool isLoading = true;
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
          customerData = Map<String, dynamic>.from(data);
          isLoading = false;
          errorMessage = null;
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
          title: const Text("Cari Detayı"),
        ),
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final customer = customerData!;
    final String company = customer["companyName"] ?? "";
    final String authorized = customer["authorizedPerson"] ?? "";
    final String phone = customer["phone"] ?? "";
    final String email = customer["email"] ?? "";
    final String taxNumber = customer["taxNumber"] ?? "";
    final String taxOffice = customer["taxOffice"] ?? "";
    final String address = customer["address"] ?? "";
    final bool isActive = customer["isActive"] == true;
    final String status = isActive ? "Aktif" : "Pasif";
    final double balance =
        double.tryParse(customer["balance"].toString()) ?? 0;
    final double totalCollected =
        double.tryParse(customer["totalCollected"].toString()) ?? 0;
    final double pendingCollection =
        double.tryParse(customer["pendingCollection"].toString()) ?? 0;
    final List<dynamic> payments = customer["payments"] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Cari Detayı",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Başlık & Aksiyon Butonları
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Cari Hesap Detayları",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text("Düzenle"),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text("Sil"),
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // Firma Bilgileri Kartı
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Firma Bilgileri",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildInfoRow("Firma Adı", company, Icons.business),
                      _buildInfoRow("Yetkili", authorized, Icons.person),
                      _buildInfoRow("Telefon", phone, Icons.phone),
                      _buildInfoRow(
                        "E-Posta",
                        email,
                        Icons.email,
                      ),
                      _buildInfoRow("Vergi No", taxNumber, Icons.badge),
                      _buildInfoRow(
                        "Vergi Dairesi",
                        taxOffice,
                        Icons.account_balance,
                      ),
                      _buildInfoRow(
                        "Adres",
                        address,
                        Icons.home,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Finans Özeti Başlığı
              const Text(
                "Finans Özeti",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Finans Kartları
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: "Cari Bakiyesi",
                      value: _formatCurrency(balance),
                      icon: Icons.account_balance_wallet,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildStatCard(
                      title: "Toplam Tahsilat",
                      value: _formatCurrency(totalCollected),
                      icon: Icons.payments,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildStatCard(
                      title: "Bekleyen Tahsilat",
                      value: _formatCurrency(pendingCollection),
                      icon: Icons.schedule,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // Son Tahsilatlar Tablosu Kartı
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Son Tahsilatlar",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("Tarih")),
                            DataColumn(label: Text("Tutar")),
                            DataColumn(label: Text("Durum")),
                          ],
                          rows: payments.map((payment) {
                            final date = DateTime.tryParse(
                              payment["paymentDate"]?.toString() ?? "",
                            );

                            final amount =
                                double.tryParse(payment["amount"].toString()) ?? 0;

                            final bool paid = payment["isPaid"] == true;

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    date == null
                                        ? "-"
                                        : "${date.day.toString().padLeft(2, '0')}."
                                          "${date.month.toString().padLeft(2, '0')}."
                                          "${date.year}",
                                  ),
                                ),
                                DataCell(
                                  Text(_formatCurrency(amount)),
                                ),
                                DataCell(
                                  Text(
                                    paid ? "Ödendi" : "Bekliyor",
                                    style: TextStyle(
                                      color: paid ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(dynamic value) {
    final number = double.tryParse(value.toString()) ?? 0;

    return "₺${number.toStringAsFixed(2)}";
  }

  // Bilgi Satırı Widget Builder
  Widget _buildInfoRow(
    String title,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Icon(
            icon,
            color: primary,
            size: 22,
          ),
          const SizedBox(width: 15),
          SizedBox(
            width: 160,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // İstatistik Kartı Widget Builder
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 38,
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}