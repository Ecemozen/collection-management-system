import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';
import 'package:tahsilat_mobile/features/payment/pages/payment_edit_page.dart';

class PaymentDetailPage extends StatefulWidget {
  final int paymentId;

  const PaymentDetailPage({
    super.key,
    required this.paymentId,
  });

  static const Color primary = Color(0xFFE31E24);

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? payment;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPayment();
  }

  Future<void> _loadPayment() async {
    try {
      final response = await _apiService.get(
        "Payments/${widget.paymentId}",
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          setState(() {
            payment = data;
            isLoading = false;
            errorMessage = null;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = "Geçersiz tahsilat verisi alındı.";
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          isLoading = false;
          errorMessage = "Tahsilat bulunamadı.";
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              "Tahsilat bilgileri alınamadı. "
              "Kod: ${response.statusCode}";
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = "Bağlantı hatası: $e";
      });
    }
  }

  String _formatAmount(dynamic value) {
    final amount = double.tryParse(value?.toString() ?? "");

    if (amount == null) {
      return "₺0.00";
    }

    return "₺${amount.toStringAsFixed(2)}";
  }

  String _formatDate(dynamic value) {
    if (value == null) {
      return "-";
    }

    try {
      final date = DateTime.parse(value.toString());

      return "${date.day.toString().padLeft(2, '0')}."
          "${date.month.toString().padLeft(2, '0')}."
          "${date.year}";
    } catch (_) {
      return value.toString();
    }
  }

  String _getStatus() {
    final isPaid = payment?["isPaid"] == true;

    return isPaid ? "Ödendi" : "Bekliyor";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            "Tahsilat Detayı",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: PaymentDetailPage.primary,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            "Tahsilat Detayı",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: PaymentDetailPage.primary,
                  size: 60,
                ),
                const SizedBox(height: 20),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });

                    _loadPayment();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Tekrar Dene"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PaymentDetailPage.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (payment == null) {
      return const Scaffold(
        body: Center(
          child: Text("Tahsilat bilgisi bulunamadı."),
        ),
      );
    }

    final companyName =
        payment!["companyName"]?.toString() ?? "-";

    final feeTypeName =
        payment!["feeTypeName"]?.toString() ?? "-";

    final amount =
        payment!["amount"];

    final paymentDate =
        payment!["paymentDate"];

    final description =
        payment!["description"]?.toString() ?? "";

    final status = _getStatus();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Tahsilat Detayı",
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
              "Tahsilat Bilgileri",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // DETAY BİLGİLERİ
            // =========================

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    _InfoRow(
                      title: "Cari",
                      value: companyName,
                      icon: Icons.business,
                    ),

                    _InfoRow(
                      title: "Tahsilat Tutarı",
                      value: _formatAmount(amount),
                      icon: Icons.payments,
                    ),

                    _InfoRow(
                      title: "Ödeme Türü",
                      value: feeTypeName,
                      icon: Icons.account_balance,
                    ),

                    _InfoRow(
                      title: "Tarih",
                      value: _formatDate(paymentDate),
                      icon: Icons.calendar_month,
                    ),

                    _InfoRow(
                      title: "Durum",
                      value: status,
                      icon: Icons.check_circle,
                    ),

                    _InfoRow(
                      title: "Açıklama",
                      value:
                          description.isEmpty ? "-" : description,
                      icon: Icons.notes,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // ÖZET KARTLARI
            // =========================

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: "Tahsilat",
                    value: _formatAmount(amount),
                    icon: Icons.payments,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: _StatCard(
                    title: "Durum",
                    value: status,
                    icon: Icons.check_circle,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: _StatCard(
                    title: "Tarih",
                    value: _formatDate(paymentDate),
                    icon: Icons.calendar_today,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            // =========================
            // İŞLEM BUTONLARI
            // =========================

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentEditPage(
                          paymentId: widget.paymentId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Düzenle"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// INFO ROW
// =====================================================

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: PaymentDetailPage.primary,
            size: 22,
          ),

          const SizedBox(width: 15),

          SizedBox(
            width: 170,
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
}

// =====================================================
// STAT CARD
// =====================================================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
              textAlign: TextAlign.center,
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