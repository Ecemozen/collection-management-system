import 'package:flutter/material.dart';

class PaymentReceiptPage extends StatelessWidget {
  const PaymentReceiptPage({super.key});

  static const Color primary = Color(0xFFE31E24);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Tahsilat Makbuzu",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: ListView(
          children: [
            // Makbuz Şablon Kartı
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 60,
                      color: primary,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "YİĞİT AKÜ",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "TAHSİLAT MAKBUZU",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    Divider(height: 40),
                    _InfoRow(
                      title: "Makbuz No",
                      value: "MKB-2026-001",
                    ),
                    _InfoRow(
                      title: "Tarih",
                      value: "05.08.2026",
                    ),
                    _InfoRow(
                      title: "Cari",
                      value: "ABC Otomotiv",
                    ),
                    _InfoRow(
                      title: "Yetkili",
                      value: "Ahmet Yılmaz",
                    ),
                    _InfoRow(
                      title: "Telefon",
                      value: "0532 111 22 33",
                    ),
                    Divider(height: 40),
                    _InfoRow(
                      title: "Tahsilat",
                      value: "₺25.000",
                    ),
                    _InfoRow(
                      title: "Ödeme Türü",
                      value: "Havale",
                    ),
                    _InfoRow(
                      title: "Banka",
                      value: "Ziraat Bankası",
                    ),
                    _InfoRow(
                      title: "Durum",
                      value: "Ödendi",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),

            // İşlem Butonları (Yazdır, PDF, Paylaş)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Makbuz yazdırılıyor..."),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 18,
                    ),
                  ),
                  icon: const Icon(Icons.print),
                  label: const Text("Yazdır"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("PDF indirme başlatıldı."),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 18,
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("PDF"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Makbuz paylaşma menüsü açılıyor..."),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 18,
                    ),
                  ),
                  icon: const Icon(Icons.share),
                  label: const Text("Paylaş"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        children: [
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}