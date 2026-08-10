import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';
import 'package:tahsilat_mobile/features/payment/pages/payment_add_page.dart';
import 'package:tahsilat_mobile/features/payment/pages/payment_detail_page.dart';
import 'package:tahsilat_mobile/features/payment/pages/payment_edit_page.dart';

class PaymentListPage extends StatefulWidget {
  const PaymentListPage({super.key});

  @override
  State<PaymentListPage> createState() => _PaymentListPageState();
}

class _PaymentListPageState extends State<PaymentListPage> {
  static const Color primary = Color(0xFFE31E24);

  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _filteredPayments = [];
  final TextEditingController _searchController = TextEditingController();
  
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _searchController.addListener(_filterPayments);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    try {
      final api = ApiService();
      final response = await api.get("Payments");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _payments = List<Map<String, dynamic>>.from(data);
          _filteredPayments = _payments;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Tahsilatlar alınamadı. Kod: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Bağlantı hatası: $e";
      });
    }
  }

  Future<void> _deletePayment(int paymentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Tahsilatı Sil",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Bu tahsilatı silmek istediğinize emin misiniz?\n\n"
            "Bu işlem geri alınamaz.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Sil"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final api = ApiService();
      final response = await api.delete("Payments/$paymentId");

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tahsilat başarıyla silindi."),
            backgroundColor: Colors.green,
          ),
        );

        await _loadPayments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Tahsilat silinemedi. Kod: ${response.statusCode}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Silme sırasında hata oluştu: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterPayments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPayments = _payments.where((payment) {
        final customer = payment["companyName"]?.toString().toLowerCase() ?? "";
        final paymentType = payment["feeTypeName"]?.toString().toLowerCase() ?? "";
        return customer.contains(query) || paymentType.contains(query);
      }).toList();
    });
  }

  Widget _buildPaymentContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 15,
          ),
        ),
      );
    }

    if (_filteredPayments.isEmpty) {
      return const Center(
        child: Text(
          "Kayıtlı tahsilat bulunamadı.",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            const Color(0xFFF7F7F7),
          ),
          columns: const [
            DataColumn(
              label: Text(
                "Cari",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Tutar",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Tarih",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Ödeme Türü",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Durum",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "İşlemler",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: _filteredPayments.map((payment) {
            final bool isPaid = payment["isPaid"] == true;

            final String customer =
                payment["companyName"]?.toString() ?? "";

            final String amount =
                "₺${payment["amount"]?.toString() ?? "0"}";

            final String date =
                payment["paymentDate"]?.toString().split("T").first ?? "";

            final String paymentType =
                payment["feeTypeName"]?.toString() ?? "";

            final String status = isPaid ? "Ödendi" : "Bekliyor";

            return DataRow(
              cells: [
                DataCell(Text(customer)),
                DataCell(Text(amount)),
                DataCell(Text(date)),
                DataCell(Text(paymentType)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isPaid
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      // GÖRÜNTÜLE
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentDetailPage(
                                paymentId: payment["id"],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.visibility,
                          color: Colors.blue,
                        ),
                        tooltip: "Detay",
                      ),
                      // DÜZENLE
                      IconButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentEditPage(
                                paymentId: payment["id"],
                              ),
                            ),
                          );

                          await _loadPayments();
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.orange,
                        ),
                        tooltip: "Düzenle",
                      ),
                      // SİL
                      IconButton(
                        onPressed: () {
                          _deletePayment(payment["id"]);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        tooltip: "Sil",
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Tahsilat Yönetimi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Arama ve Yeni Tahsilat Ekle Butonu Alanı
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Tüm tahsilatlarınızı buradan yönetin.",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 320,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Tahsilat Ara...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(14),
                          ),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentAddPage(
                              onPaymentAdded: (newPayment) async {
                                await _loadPayments();
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Yeni Tahsilat",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Tahsilat Tablosu
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _buildPaymentContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}