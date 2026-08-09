import 'package:flutter/material.dart';

class SignedReceiptViewPage extends StatefulWidget {
  final int receiptId;

  const SignedReceiptViewPage({
    super.key,
    required this.receiptId,
  });

  @override
  State<SignedReceiptViewPage> createState() =>
      _SignedReceiptViewPageState();
}

class _SignedReceiptViewPageState extends State<SignedReceiptViewPage> {
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
          "İmzalı Makbuz",
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
              "İmzalı Makbuz",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Yüklenen imzalı makbuzu görüntüleyebilir ve indirebilirsiniz.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 35),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("Makbuz No", "MKB-2026-000001"),
                    _buildInfoRow("Cari", "XYZ İnşaat"),
                    _buildInfoRow("Tahsilat Tutarı", "₺25.000"),
                    _buildInfoRow("Ödeme Türü", "Havale"),
                    _buildInfoRow("Durum", "✅ İmzalı Makbuz Yüklendi"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Container(
                      height: 500,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description,
                            size: 100,
                            color: Colors.red,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "signed_receipt.pdf",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Backend bağlantısından sonra\nPDF burada görüntülenecek.",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.remove_red_eye),
                  label: const Text("Tam Ekran"),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text("İndir"),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Yeni Dosya Yükle"),
                ),
              ],
            ),
            const SizedBox(height: 35),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Geri"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          SizedBox(
            width: 180,
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}