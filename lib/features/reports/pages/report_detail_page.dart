import 'package:flutter/material.dart';

class ReportDetailPage extends StatefulWidget {
  const ReportDetailPage({super.key});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
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
          "Rapor Detayı",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: ListView(
          children: [
            const Text(
              "Rapor Detayı",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Seçilen raporun ayrıntılı analizini görüntüleyin.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 35),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    "Toplam Tahsilat",
                    "₺1.250.000",
                    Icons.payments,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildSummaryCard(
                    "Toplam İşlem",
                    "186",
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildSummaryCard(
                    "Başarı",
                    "%94",
                    Icons.trending_up,
                    primary,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildSummaryCard(
                    "Bekleyen",
                    "12",
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
              ],
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
                    const Text(
                      "Rapor Bilgileri",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow("Rapor Türü", "Aylık Tahsilat"),
                    _buildInfoRow("Oluşturulma", "06.08.2026"),
                    _buildInfoRow("Hazırlayan", "Admin"),
                    _buildInfoRow("Cari", "ABC Otomotiv"),
                    _buildInfoRow("Durum", "Tamamlandı"),
                  ],
                ),
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
                    const Text(
                      "Tahsilat Hareketleri",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DataTable(
                      columns: const [
                        DataColumn(label: Text("Tarih")),
                        DataColumn(label: Text("Cari")),
                        DataColumn(label: Text("Ödeme")),
                        DataColumn(label: Text("Tutar")),
                        DataColumn(label: Text("Durum")),
                      ],
                      rows: const [
                        DataRow(cells: [
                          DataCell(Text("05.08.2026")),
                          DataCell(Text("ABC Otomotiv")),
                          DataCell(Text("Havale")),
                          DataCell(Text("₺25.000")),
                          DataCell(Text("Ödendi")),
                        ]),
                        DataRow(cells: [
                          DataCell(Text("04.08.2026")),
                          DataCell(Text("XYZ Ltd.")),
                          DataCell(Text("EFT")),
                          DataCell(Text("₺14.000")),
                          DataCell(Text("Bekliyor")),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tahsilat Analizi",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 25),
                          _buildAnalysisRow(
                            "En Büyük Tahsilat",
                            "₺48.500",
                          ),
                          _buildAnalysisRow(
                            "En Küçük Tahsilat",
                            "₺5.000",
                          ),
                          _buildAnalysisRow(
                            "Ortalama Tahsilat",
                            "₺18.250",
                          ),
                          _buildAnalysisRow(
                            "Başarı Oranı",
                            "%94",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Genel Değerlendirme",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Bu dönemde tahsilat performansı oldukça başarılıdır. "
                            "Bekleyen tahsilatlar düşük seviyededir ve ödeme oranı yüksektir.",
                            style: TextStyle(
                              height: 1.6,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
                    const Text(
                      "Rapor Performans Grafiği",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 90,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Grafik Alanı",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Backend bağlandıktan sonra\nburada gerçek grafik gösterilecek.",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                    const Text(
                      "Rapor İşlemleri",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("PDF"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.table_chart),
                          label: const Text("Excel"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.print),
                          label: const Text("Yazdır"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share),
                          label: const Text("Paylaş"),
                        ),
                      ],
                    ),
                  ],
                ),
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
            width: 220,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
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

  Widget _buildAnalysisRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
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
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}