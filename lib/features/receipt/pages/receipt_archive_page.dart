import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';
import 'package:tahsilat_mobile/features/receipt/pages/signed_receipt_view_page.dart';

class ReceiptArchivePage extends StatefulWidget {
  const ReceiptArchivePage({super.key});

  @override
  State<ReceiptArchivePage> createState() => _ReceiptArchivePageState();
}

class _ReceiptArchivePageState extends State<ReceiptArchivePage> {
  static const Color primary = Color(0xFFE31E24);

  final ApiService _apiService = ApiService();

  List<dynamic> _receipts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    try {
      final response = await _apiService.get("Receipts");

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _receipts = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Makbuzlar alınamadı.";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = "Makbuzlar yüklenirken hata oluştu: $e";
        _isLoading = false;
      });
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
          "Makbuz Arşivi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: ListView(
          children: [
            const Text(
              "Makbuz Arşivi",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Oluşturulan tüm makbuzları görüntüleyebilirsiniz.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              decoration: InputDecoration(
                hintText: "Makbuz No veya Cari Ara",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              )
            else if (_receipts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    "Henüz makbuz bulunmuyor.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ..._receipts.map((receipt) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _buildReceiptCard(
                    receiptId: receipt["id"],
                    receiptNo: receipt["receiptNumber"] ?? "",
                    customer: receipt["companyName"] ?? "",
                    amount: "₺${receipt["amount"] ?? 0}",
                    status: receipt["signedFilePath"] != null
                        ? "İmzalı"
                        : "İmza Bekliyor",
                  ),
                );
              }),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Dashboard'a Dön"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard({
    required int receiptId,
    required String receiptNo,
    required String customer,
    required String amount,
    required String status,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow("Makbuz No", receiptNo),
            _buildRow("Cari", customer),
            _buildRow("Tutar", amount),
            const SizedBox(height: 20),
            Row(
              children: [
                Chip(
                  backgroundColor: status == "İmzalı"
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  label: Text(status),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignedReceiptViewPage(
                          receiptId: receiptId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.remove_red_eye),
                  label: const Text("Görüntüle"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}