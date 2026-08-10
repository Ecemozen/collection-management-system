import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tahsilat_mobile/features/receipt/pages/signed_receipt_upload_page.dart';
import 'package:tahsilat_mobile/features/receipt/pages/signed_receipt_view_page.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';

class ReceiptPreviewPage extends StatefulWidget {
  final int? paymentId;
  final String customerName;
  final String amount;
  final String paymentType;
  final String date;
  final String note;

  const ReceiptPreviewPage({
    super.key,
    this.paymentId,
    required this.customerName,
    required this.amount,
    required this.paymentType,
    required this.date,
    required this.note,
  });

  @override
  State<ReceiptPreviewPage> createState() => _ReceiptPreviewPageState();
}

class _ReceiptPreviewPageState extends State<ReceiptPreviewPage> {
  static const Color primary = Color(0xFFE31E24);
  Map<String, dynamic>? _receipt;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.paymentId != null) {
      _createReceipt();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createReceipt() async {
    try {
      final api = ApiService();

      final response = await api.post(
        "Receipts",
        {
          "paymentId": widget.paymentId,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          setState(() {
            _error = "Makbuz verisi beklenen formatta gelmedi.";
            _isLoading = false;
          });
          return;
        }

        final receiptId = decoded["id"] ?? decoded["Id"];

        if (receiptId == null) {
          setState(() {
            _error = "Makbuz oluşturuldu ancak makbuz ID alınamadı.";
            _isLoading = false;
          });
          return;
        }

        setState(() {
          _receipt = decoded;
          _isLoading = false;
        });

        debugPrint("RECEIPT RESPONSE: ${response.body}");
        debugPrint("RECEIPT ID: $receiptId");
      } else {
        debugPrint("RECEIPT ERROR STATUS: ${response.statusCode}");
        debugPrint("RECEIPT ERROR BODY: ${response.body}");

        setState(() {
          _error =
              "Makbuz oluşturulamadı. Kod: ${response.statusCode}\n${response.body}";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("RECEIPT EXCEPTION: $e");

      if (!mounted) return;

      setState(() {
        _error = "Makbuz oluşturulurken hata oluştu: $e";
        _isLoading = false;
      });
    }
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    final receiptNumber =
        _receipt?["receiptNumber"]?.toString() ?? "-";

    final companyName =
        _receipt?["companyName"]?.toString() ??
        widget.customerName;

    final amount =
        _receipt?["amount"]?.toString() ??
        widget.amount;

    final paymentType =
        _receipt?["feeTypeName"]?.toString() ??
        widget.paymentType;

    final description =
        _receipt?["description"]?.toString() ??
        widget.note;

    final paymentDate =
        _receipt?["paymentDate"]?.toString().split("T").first ??
        widget.date;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Text(
                  "YİĞİT AKÜ",
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  "TAHSİLAT YÖNETİM SİSTEMİ",
                  style: pw.TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  "TAHSİLAT MAKBUZU",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 25),
              pw.Divider(),
              pw.SizedBox(height: 20),
              _pdfRow("Makbuz No", receiptNumber),
              _pdfRow("Tarih", paymentDate),
              _pdfRow("Cari", companyName),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              _pdfRow("Tahsilat Tutarı", "₺$amount"),
              _pdfRow("Ödeme Türü", paymentType),
              _pdfRow(
                "Açıklama",
                description.isEmpty ? "-" : description,
              ),
              pw.Spacer(),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        pw.Divider(),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          "Tahsilatı Teslim Eden",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 40),
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        pw.Divider(),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          "Tahsilatı Teslim Alan",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 35),
              pw.Center(
                child: pw.Text(
                  "Bu belge sistem tarafından elektronik olarak oluşturulmuştur.",
                  style: pw.TextStyle(
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfRow(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  void _handleUploadSignedReceipt() {
    final rawReceiptId = _receipt?["id"] ?? _receipt?["Id"];

    if (rawReceiptId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Makbuz ID bulunamadı."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int? receiptId = int.tryParse(rawReceiptId.toString());

    if (receiptId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Geçersiz makbuz ID."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignedReceiptUploadPage(
          receiptId: receiptId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Tahsilat Makbuzu Önizleme"),
        ),
        body: Center(
          child: Text(_error!),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Tahsilat Makbuzu Önizleme",
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
              "Tahsilat Makbuzu",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Makbuz başarıyla oluşturuldu.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 35),

            // Kurumsal Makbuz Kartı (A4 Tasarım Uyumlu)
            Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(35),
                child: Column(
                  children: [
                    const Text(
                      "YİĞİT AKÜ",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "TAHSİLAT YÖNETİM SİSTEMİ",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "TAHSİLAT MAKBUZU",
                      style: TextStyle(
                        fontSize: 18,
                        color: primary,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(
                      height: 45,
                      thickness: 1.2,
                    ),
                    _buildReceiptRow(
                      "Makbuz No",
                      _receipt?["receiptNumber"]?.toString() ?? "-",
                    ),
                    _buildReceiptRow(
                      "Tarih",
                      _receipt?["paymentDate"]?.toString() ?? widget.date,
                    ),
                    _buildReceiptRow(
                      "Cari",
                      _receipt?["companyName"]?.toString() ?? widget.customerName,
                    ),
                    const Divider(height: 45),
                    _buildReceiptRow(
                      "Tahsilat Tutarı",
                      "₺${_receipt?["amount"] ?? widget.amount}",
                    ),
                    _buildReceiptRow(
                      "Ödeme Türü",
                      _receipt?["feeTypeName"]?.toString() ?? widget.paymentType,
                    ),
                    _buildReceiptRow(
                      "Açıklama",
                      (_receipt?["description"]?.toString().isNotEmpty ?? false)
                          ? _receipt!["description"].toString()
                          : widget.note.isNotEmpty ? widget.note : "-",
                    ),
                    const SizedBox(height: 60),
                    const Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Divider(),
                              SizedBox(height: 8),
                              Text(
                                "Tahsilatı Teslim Eden",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 50),
                        Expanded(
                          child: Column(
                            children: [
                              Divider(),
                              SizedBox(height: 8),
                              Text(
                                "Tahsilatı Teslim Alan",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    const Text(
                      "Bu belge sistem tarafından elektronik olarak oluşturulmuştur.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),

            // Makbuz İşlemleri Kartı
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
                      "Makbuz İşlemleri",
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
                          onPressed: () async {
                            try {
                              final bytes = await _generatePdf(PdfPageFormat.a4);

                              await Printing.sharePdf(
                                bytes: bytes,
                                filename: 'tahsilat_makbuzu.pdf',
                              );
                            } catch (e) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("PDF oluşturulamadı: $e"),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("PDF İndir"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await Printing.layoutPdf(
                                onLayout: (format) => _generatePdf(format),
                              );
                            } catch (e) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Yazdırma başlatılamadı: $e"),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          icon: const Icon(Icons.print),
                          label: const Text("Yazdır"),
                        ),
                        ElevatedButton.icon(
                          onPressed: _handleUploadSignedReceipt,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          icon: const Icon(Icons.upload_file),
                          label: const Text("İmzalı Makbuz Yükle"),
                        ),
                        if (_receipt?["signedFilePath"]?.toString().isNotEmpty ?? false)
                          ElevatedButton.icon(
                            onPressed: () {
                              final rawReceiptId =
                                  _receipt?["id"] ?? _receipt?["Id"];

                              final receiptId =
                                  int.tryParse(rawReceiptId.toString());

                              if (receiptId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Makbuz ID bulunamadı."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SignedReceiptViewPage(
                                    receiptId: receiptId,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            icon: const Icon(Icons.remove_red_eye),
                            label: const Text("İmzalı Makbuzu Görüntüle"),
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
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 18,
                  ),
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Tahsilata Dön"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}