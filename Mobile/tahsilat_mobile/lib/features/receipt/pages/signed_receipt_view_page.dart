import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:tahsilat_mobile/core/services/api_service.dart';
import 'package:tahsilat_mobile/features/receipt/pages/signed_receipt_upload_page.dart';

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

  final ApiService _apiService = ApiService();

  Map<String, dynamic>? receipt;

  Uint8List? signedFileBytes;
  String? signedContentType;
  String? signedFileName;

  bool isLoading = true;
  bool isFileLoading = true;

  String? errorMessage;
  String? fileErrorMessage;

  @override
  void initState() {
    super.initState();

    _loadReceipt();
    _loadSignedFile();
  }

  // ----------------------------------------------------------
  // MAKBUZ BİLGİLERİNİ GETİR
  // ----------------------------------------------------------

  Future<void> _loadReceipt() async {
    try {
      final response =
          await _apiService.get("Receipts/${widget.receiptId}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          receipt = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Makbuz bilgileri alınamadı.";
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            "Makbuz bilgileri alınırken hata oluştu: $e";
        isLoading = false;
      });
    }
  }

  // ----------------------------------------------------------
  // İMZALI DOSYAYI BACKEND'DEN GETİR
  // ----------------------------------------------------------

  Future<void> _loadSignedFile() async {
    try {
      final response =
          await _apiService.get(
        "Receipts/${widget.receiptId}/signed",
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          signedFileBytes = response.bodyBytes;
          signedContentType =
              response.headers["content-type"];

          signedFileName =
              receipt?["signedFileName"]?.toString() ??
                  "signed_receipt.pdf";

          isFileLoading = false;
        });
      } else {
        setState(() {
          fileErrorMessage =
              "İmzalı makbuz bulunamadı.";
          isFileLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        fileErrorMessage =
            "İmzalı makbuz yüklenirken hata oluştu: $e";
        isFileLoading = false;
      });
    }
  }

  // ----------------------------------------------------------
  // PDF Mİ?
  // ----------------------------------------------------------

  bool get _isPdf {
    if (signedContentType != null) {
      return signedContentType!
          .toLowerCase()
          .contains("pdf");
    }

    return signedFileName
            ?.toLowerCase()
            .endsWith(".pdf") ??
        false;
  }

  // ----------------------------------------------------------
  // IMAGE Mİ?
  // ----------------------------------------------------------

  bool get _isImage {
    if (signedContentType != null) {
      return signedContentType!
              .toLowerCase()
              .contains("image") ||
          signedContentType!
              .toLowerCase()
              .contains("jpeg") ||
          signedContentType!
              .toLowerCase()
              .contains("png");
    }

    final name =
        signedFileName?.toLowerCase() ?? "";

    return name.endsWith(".jpg") ||
        name.endsWith(".jpeg") ||
        name.endsWith(".png");
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
          "İmzalı Makbuz",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: _buildBody(),
    );
  }

  // ----------------------------------------------------------
  // BODY
  // ----------------------------------------------------------

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primary,
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),

              const SizedBox(height: 15),

              Text(
                errorMessage!,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });

                  _loadReceipt();
                },
                child: const Text(
                  "Tekrar Dene",
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data = receipt ?? {};

    final receiptNumber =
        data["receiptNumber"]?.toString() ?? "";

    final companyName =
        data["companyName"]?.toString() ?? "";

    final amount =
        data["amount"]?.toString() ?? "0";

    final paymentType =
        data["feeTypeName"]?.toString() ?? "";

    final hasSignedFile =
        signedFileBytes != null &&
        signedFileBytes!.isNotEmpty;

    return Padding(
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

          // --------------------------------------------------
          // MAKBUZ BİLGİLERİ
          // --------------------------------------------------

          Card(
            elevation: 2,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),

            child: Padding(
              padding: const EdgeInsets.all(25),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  _buildInfoRow(
                    "Makbuz No",
                    receiptNumber,
                  ),

                  _buildInfoRow(
                    "Cari",
                    companyName,
                  ),

                  _buildInfoRow(
                    "Tahsilat Tutarı",
                    "₺$amount",
                  ),

                  _buildInfoRow(
                    "Ödeme Türü",
                    paymentType,
                  ),

                  _buildInfoRow(
                    "Durum",
                    hasSignedFile
                        ? "İmzalı Makbuz Yüklendi"
                        : "İmza Bekliyor",
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // --------------------------------------------------
          // DOSYA
          // --------------------------------------------------

          Card(
            elevation: 2,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),

            child: Padding(
              padding: const EdgeInsets.all(25),

              child: _buildFilePreview(),
            ),
          ),

          const SizedBox(height: 35),

          // --------------------------------------------------
          // BUTONLAR
          // --------------------------------------------------

          Wrap(
            spacing: 20,
            runSpacing: 20,

            children: [
              // İmzalı dosya varsa Tam Ekran
              if (hasSignedFile)
                ElevatedButton.icon(
                  onPressed: () {
                    _openFullScreen();
                  },

                  icon: const Icon(
                    Icons.fullscreen,
                  ),

                  label: const Text(
                    "Tam Ekran",
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                  ),
                ),

              // İmzalı dosya varsa İndir
              if (hasSignedFile)
                ElevatedButton.icon(
                  onPressed: () {
                    _downloadFile();
                  },

                  icon: const Icon(
                    Icons.download,
                  ),

                  label: const Text(
                    "İndir",
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primary,
                    side: const BorderSide(
                      color: primary,
                    ),
                  ),
                ),

              // İmzalı makbuz yükle
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SignedReceiptUploadPage(
                        receiptId: widget.receiptId,
                      ),
                    ),
                  );

                  // Yükleme ekranından dönünce tekrar kontrol et
                  if (mounted) {
                    setState(() {
                      isFileLoading = true;
                      fileErrorMessage = null;
                      signedFileBytes = null;
                    });

                    await _loadReceipt();
                    await _loadSignedFile();
                  }
                },

                icon: const Icon(
                  Icons.upload_file,
                ),

                label: const Text(
                  "İmzalı Makbuz Yükle",
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                ),
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

              icon: const Icon(
                Icons.arrow_back,
              ),

              label: const Text(
                "Geri",
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // DOSYA GÖRÜNTÜLEME
  // ----------------------------------------------------------

  Widget _buildFilePreview() {
    if (isFileLoading) {
      return const SizedBox(
        height: 500,

        child: Center(
          child: CircularProgressIndicator(
            color: primary,
          ),
        ),
      );
    }

    if (fileErrorMessage != null) {
      return SizedBox(
        height: 300,

        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              const Icon(
                Icons.description_outlined,
                size: 80,
                color: Colors.grey,
              ),

              const SizedBox(height: 20),

              Text(
                fileErrorMessage!,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (signedFileBytes == null ||
        signedFileBytes!.isEmpty) {
      return const SizedBox(
        height: 300,

        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              Icon(
                Icons.description_outlined,
                size: 80,
                color: Colors.grey,
              ),

              SizedBox(height: 20),

              Text(
                "Bu makbuza ait imzalı dosya bulunmuyor.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // PDF
    if (_isPdf) {
      return SizedBox(
        height: 600,

        child: SfPdfViewer.memory(
          signedFileBytes!,
        ),
      );
    }

    // IMAGE
    if (_isImage) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(15),

        child: Image.memory(
          signedFileBytes!,

          height: 600,

          width: double.infinity,

          fit: BoxFit.contain,

          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return const SizedBox(
              height: 300,

              child: Center(
                child: Text(
                  "Dosya görüntülenemedi.",
                ),
              ),
            );
          },
        ),
      );
    }

    return SizedBox(
      height: 300,

      child: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.insert_drive_file,
              size: 80,
              color: primary,
            ),

            const SizedBox(height: 20),

            Text(
              signedFileName ??
                  "İmzalı Makbuz",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TAM EKRAN
  // ----------------------------------------------------------

  void _openFullScreen() {
    if (signedFileBytes == null) {
      return;
    }

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) {
          if (_isPdf) {
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  "İmzalı Makbuz",
                ),
              ),

              body: SfPdfViewer.memory(
                signedFileBytes!,
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.black,

            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),

            body: Center(
              child: InteractiveViewer(
                child: Image.memory(
                  signedFileBytes!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // İNDİR
  // ----------------------------------------------------------

  Future<void> _downloadFile() async {
    if (signedFileBytes == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${signedFileName ?? "Dosya"} hazır.",
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ----------------------------------------------------------
  // INFO ROW
  // ----------------------------------------------------------

  Widget _buildInfoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),

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