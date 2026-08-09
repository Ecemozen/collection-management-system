import 'package:flutter/material.dart';

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  static const Color primary = Color(0xFFE31E24);

  String selectedMonth = "Ağustos 2026";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Aylık Tahsilat Raporu",
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
              "Aylık Tahsilat Raporu",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Seçilen aya ait tahsilat performansını görüntüleyin.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              value: selectedMonth,
              decoration: const InputDecoration(
                labelText: "Ay Seçiniz",
                prefixIcon: Icon(Icons.calendar_month),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Haziran 2026",
                  child: Text("Haziran 2026"),
                ),
                DropdownMenuItem(
                  value: "Temmuz 2026",
                  child: Text("Temmuz 2026"),
                ),
                DropdownMenuItem(
                  value: "Ağustos 2026",
                  child: Text("Ağustos 2026"),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedMonth = value;
                  });
                }
              },
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    "Toplam Tahsilat",
                    "₺1.245.000",
                    Icons.payments,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildSummaryCard(
                    "Tahsilat Sayısı",
                    "184",
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildSummaryCard(
                    "Toplam Cari",
                    "148",
                    Icons.groups,
                    primary,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildSummaryCard(
                    "Başarı Oranı",
                    "%94",
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
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
                            "Aylık Tahsilat Grafiği",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Container(
                            height: 320,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.show_chart,
                                    size: 90,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "Aylık Grafik",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Backend bağlantısından sonra\nburada gerçek grafik gösterilecek.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
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
                ),
                const SizedBox(width: 25),
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
                            "Aylık Özet",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 25),
                          _buildInfoRow(
                            "En Yüksek Gün",
                            "14 Ağustos",
                          ),
                          _buildInfoRow(
                            "En Yüksek Tahsilat",
                            "₺186.000",
                          ),
                          _buildInfoRow(
                            "Ortalama Günlük",
                            "₺41.500",
                          ),
                          _buildInfoRow(
                            "Tahsilat Başarısı",
                            "%94",
                          ),
                          _buildInfoRow(
                            "Bekleyen",
                            "₺72.000",
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
                      "Aylık Tahsilat Tablosu",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),
                    DataTable(
                      columns: const [
                        DataColumn(label: Text("Tarih")),
                        DataColumn(label: Text("Cari")),
                        DataColumn(label: Text("Tutar")),
                        DataColumn(label: Text("Durum")),
                      ],
                      rows: const [
                        DataRow(cells: [
                          DataCell(Text("01.08.2026")),
                          DataCell(Text("ABC Otomotiv")),
                          DataCell(Text("₺25.000")),
                          DataCell(Text("Ödendi")),
                        ]),
                        DataRow(cells: [
                          DataCell(Text("05.08.2026")),
                          DataCell(Text("XYZ İnşaat")),
                          DataCell(Text("₺48.500")),
                          DataCell(Text("Ödendi")),
                        ]),
                        DataRow(cells: [
                          DataCell(Text("11.08.2026")),
                          DataCell(Text("Yiğit Market")),
                          DataCell(Text("₺18.000")),
                          DataCell(Text("Bekliyor")),
                        ]),
                        DataRow(cells: [
                          DataCell(Text("18.08.2026")),
                          DataCell(Text("Delta Lojistik")),
                          DataCell(Text("₺32.500")),
                          DataCell(Text("Ödendi")),
                        ]),
                      ],
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("PDF raporu hazırlanıyor..."),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 18,
                            ),
                          ),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("PDF Oluştur"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Excel dosyası hazırlanıyor..."),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 18,
                            ),
                          ),
                          icon: const Icon(Icons.table_chart),
                          label: const Text("Excel Aktar"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Rapor yazdırılıyor..."),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 18,
                            ),
                          ),
                          icon: const Icon(Icons.print),
                          label: const Text("Yazdır"),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
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
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}