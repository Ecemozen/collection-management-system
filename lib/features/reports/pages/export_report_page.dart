import 'package:flutter/material.dart';

class ExportReportPage extends StatefulWidget {
  const ExportReportPage({super.key});

  @override
  State<ExportReportPage> createState() => _ExportReportPageState();
}

class _ExportReportPageState extends State<ExportReportPage> {
  static const Color primary = Color(0xFFE31E24);

  String selectedFormat = "PDF";
  String selectedReport = "Aylık Tahsilat";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Rapor Dışa Aktar",
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
              "Raporu Dışa Aktar",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Raporları PDF, Excel veya CSV olarak oluşturabilirsiniz.",
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
                    const Text(
                      "Rapor Türü",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedReport,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Aylık Tahsilat",
                          child: Text("Aylık Tahsilat"),
                        ),
                        DropdownMenuItem(
                          value: "Cari Tahsilat",
                          child: Text("Cari Tahsilat"),
                        ),
                        DropdownMenuItem(
                          value: "Genel Rapor",
                          child: Text("Genel Rapor"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedReport = value!;
                        });
                      },
                    ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dosya Formatı",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    RadioListTile<String>(
                      value: "PDF",
                      groupValue: selectedFormat,
                      onChanged: (value) {
                        setState(() {
                          selectedFormat = value.toString();
                        });
                      },
                      title: const Text("PDF"),
                    ),
                    RadioListTile<String>(
                      value: "Excel",
                      groupValue: selectedFormat,
                      onChanged: (value) {
                        setState(() {
                          selectedFormat = value.toString();
                        });
                      },
                      title: const Text("Excel"),
                    ),
                    RadioListTile<String>(
                      value: "CSV",
                      groupValue: selectedFormat,
                      onChanged: (value) {
                        setState(() {
                          selectedFormat = value.toString();
                        });
                      },
                      title: const Text("CSV"),
                    ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tarih Aralığı",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Başlangıç Tarihi",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Bitiş Tarihi",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Rapor Önizleme",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description,
                              size: 70,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Rapor Önizleme",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Backend bağlantısından sonra\nönizleme burada gösterilecek.",
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
                      "Dışa Aktarma İşlemleri",
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
                          label: const Text("PDF Oluştur"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.table_chart),
                          label: const Text("Excel Oluştur"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.file_copy),
                          label: const Text("CSV Oluştur"),
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
            const SizedBox(height: 35),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Raporlara Dön"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}