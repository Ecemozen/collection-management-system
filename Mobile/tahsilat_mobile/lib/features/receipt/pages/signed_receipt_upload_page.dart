import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'package:tahsilat_mobile/core/services/api_service.dart';
import 'package:tahsilat_mobile/features/receipt/pages/signed_receipt_view_page.dart';

class SignedReceiptUploadPage extends StatefulWidget {
  final int receiptId;

  const SignedReceiptUploadPage({
    super.key,
    required this.receiptId,
  });

  @override
  State<SignedReceiptUploadPage> createState() =>
      _SignedReceiptUploadPageState();
}

class _SignedReceiptUploadPageState
    extends State<SignedReceiptUploadPage> {
  static const Color primary = Color(0xFFE31E24);

  String? selectedFile;
  String? selectedFilePath;

  bool isUploading = false;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    setState(() {
      selectedFile = result.files.single.name;
      selectedFilePath = result.files.single.path;
    });
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) {
      return;
    }

    setState(() {
      selectedFile = image.name;
      selectedFilePath = image.path;
    });
  }

  Future<void> _uploadSignedReceipt() async {
    if (selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen önce bir dosya seçin."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final api = ApiService();

      final response = await api.uploadFile(
        "Receipts/${widget.receiptId}/signed",
        selectedFilePath!,
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("İmzalı makbuz başarıyla yüklendi."),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SignedReceiptViewPage(
              receiptId: widget.receiptId,
            ),
          ),
        );
      } else {
        if (!mounted) return;

        String message = "İmzalı makbuz yüklenemedi.";

        try {
          final body = jsonDecode(response.body);

          if (body is Map && body["message"] != null) {
            message = body["message"].toString();
          }
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Yükleme sırasında hata oluştu: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
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
          "İmzalı Makbuz Yükle",
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
            const SizedBox(height: 10),
            const Text(
              "Müşteri tarafından imzalanmış makbuzu sisteme yükleyin.",
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
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 90,
                            color: primary,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "İmzalı makbuzu yükleyin",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "PDF veya Fotoğraf",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              isUploading ? null : _pickPdf,
                          icon: const Icon(
                            Icons.picture_as_pdf,
                          ),
                          label: const Text("PDF Seç"),
                        ),
                        ElevatedButton.icon(
                          onPressed:
                              isUploading ? null : _takePhoto,
                          icon: const Icon(
                            Icons.photo_camera,
                          ),
                          label: const Text("Fotoğraf Çek"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    if (selectedFile != null) ...[
                      Card(
                        color: Colors.green.shade50,
                        child: ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: Text(selectedFile!),
                          subtitle: const Text(
                            "Dosya seçildi.",
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                    SizedBox(
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed:
                            selectedFilePath == null ||
                                    isUploading
                                ? null
                                : _uploadSignedReceipt,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                        ),
                        icon: isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.cloud_upload,
                              ),
                        label: Text(
                          isUploading
                              ? "Yükleniyor..."
                              : "İmzalı Makbuzu Yükle",
                        ),
                      ),
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
}