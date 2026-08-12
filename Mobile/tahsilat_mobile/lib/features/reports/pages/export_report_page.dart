import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';

class ExportReportPage extends StatefulWidget {
  const ExportReportPage({super.key});

  @override
  State<ExportReportPage> createState() =>
      _ExportReportPageState();
}

class _ExportReportPageState
    extends State<ExportReportPage> {
  static const Color primary =
      Color(0xFFE31E24);

  String selectedFormat = "PDF";
  String selectedReport =
      "Aylık Tahsilat";

  DateTime? startDate;
  DateTime? endDate;

  bool isLoading = true;
  bool isExporting = false;

  String? errorMessage;

  List<dynamic> payments = [];
  List<dynamic> debts = [];
  List<dynamic> customers = [];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    startDate = DateTime(
      now.year,
      now.month,
      1,
    );

    endDate = now;

    _loadReportData();
  }

  Future<void> _loadReportData() async {
    try {
      final api = ApiService();

      final paymentsResponse =
          await api.get("Payments");

      final debtsResponse =
          await api.get("Debts");

      final customersResponse =
          await api.get("Customers");

      if (!mounted) return;

      if (paymentsResponse.statusCode != 200) {
        setState(() {
          isLoading = false;
          errorMessage =
              "Tahsilat verileri alınamadı. Kod: ${paymentsResponse.statusCode}";
        });
        return;
      }

      if (debtsResponse.statusCode != 200) {
        setState(() {
          isLoading = false;
          errorMessage =
              "Borç verileri alınamadı. Kod: ${debtsResponse.statusCode}";
        });
        return;
      }

      if (customersResponse.statusCode != 200) {
        setState(() {
          isLoading = false;
          errorMessage =
              "Cari verileri alınamadı. Kod: ${customersResponse.statusCode}";
        });
        return;
      }

      final paymentsData =
          jsonDecode(
        paymentsResponse.body,
      );

      final debtsData =
          jsonDecode(
        debtsResponse.body,
      );

      final customersData =
          jsonDecode(
        customersResponse.body,
      );

      setState(() {
        payments =
            _toList(paymentsData);

        debts =
            _toList(debtsData);

        customers =
            _toList(customersData);

        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            "Bağlantı hatası: $e";
      });
    }
  }

  List<dynamic> _toList(
    dynamic data,
  ) {
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      if (data["items"] is List) {
        return data["items"];
      }

      if (data["data"] is List) {
        return data["data"];
      }
    }

    return [];
  }

  double _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  DateTime? _toDate(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  String _formatDate(
    DateTime? date,
  ) {
    if (date == null) {
      return "-";
    }

    return "${date.day.toString().padLeft(2, '0')}."
        "${date.month.toString().padLeft(2, '0')}."
        "${date.year}";
  }

  String _formatCurrency(
    double value,
  ) {
    final fixed =
        value.toStringAsFixed(2);

    final parts =
        fixed.split(".");

    String integerPart =
        parts[0];

    String result = "";

    while (integerPart.length > 3) {
      result =
          ".${integerPart.substring(integerPart.length - 3)}$result";

      integerPart =
          integerPart.substring(
        0,
        integerPart.length - 3,
      );
    }

    result =
        integerPart + result;

    return "₺$result,${parts[1]}";
  }

  bool _isDateInRange(
    DateTime date,
  ) {
    if (startDate == null ||
        endDate == null) {
      return true;
    }

    final start = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
    );

    final end = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      23,
      59,
      59,
    );

    return !date.isBefore(start) &&
        !date.isAfter(end);
  }

  List<dynamic>
      get filteredPayments {
    return payments.where(
      (payment) {
        final date =
            _toDate(
          payment["paymentDate"],
        );

        if (date == null) {
          return false;
        }

        return _isDateInRange(
          date,
        );
      },
    ).toList();
  }

  double get totalAmount {
    double total = 0;

    for (final payment
        in filteredPayments) {
      total += _toDouble(
        payment["amount"],
      );
    }

    return total;
  }

  int get transactionCount {
    return filteredPayments.length;
  }

  int get successfulCount {
    return filteredPayments
        .where(
          (payment) =>
              payment["isPaid"] == true,
        )
        .length;
  }

  int get pendingCount {
    return filteredPayments
        .where(
          (payment) =>
              payment["isPaid"] != true,
        )
        .length;
  }

  double get successRate {
    if (transactionCount == 0) {
      return 0;
    }

    return successfulCount /
        transactionCount *
        100;
  }

  String get reportDescription {
    switch (selectedReport) {
      case "Cari Tahsilat":
        return "Cari bazlı tahsilat raporu";

      case "Genel Rapor":
        return "Genel tahsilat ve borç raporu";

      default:
        return "Seçilen tarih aralığındaki aylık tahsilat raporu";
    }
  }

  Future<void> _selectStartDate()
      async {
    final selected =
        await showDatePicker(
      context: context,
      initialDate:
          startDate ?? DateTime.now(),
      firstDate:
          DateTime(2020),
      lastDate:
          DateTime.now(),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      startDate = selected;
    });
  }

  Future<void> _selectEndDate()
      async {
    final selected =
        await showDatePicker(
      context: context,
      initialDate:
          endDate ?? DateTime.now(),
      firstDate:
          DateTime(2020),
      lastDate:
          DateTime.now(),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      endDate = selected;
    });
  }

  Future<void> _exportReport()
      async {
    if (isExporting) {
      return;
    }

    setState(() {
      isExporting = true;
    });

    try {
      final api = ApiService();

      if (selectedFormat == "PDF") {
        final response =
            await api.get(
          "Debts/report",
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          _showMessage(
            "PDF raporu başarıyla oluşturuldu.",
            Colors.green,
          );
        } else {
          _showMessage(
            "PDF oluşturulamadı. Kod: ${response.statusCode}",
            Colors.red,
          );
        }
      } else if (selectedFormat ==
          "Excel") {
        final response =
            await api.get(
          "Debts/excel",
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          _showMessage(
            "Excel raporu başarıyla oluşturuldu.",
            Colors.green,
          );
        } else {
          _showMessage(
            "Excel oluşturulamadı. Kod: ${response.statusCode}",
            Colors.red,
          );
        }
      } else if (selectedFormat ==
          "CSV") {
        final csv =
            _createCsv();

        if (!mounted) return;

        if (csv.isNotEmpty) {
          _showMessage(
            "CSV raporu hazırlandı. ${filteredPayments.length} kayıt içeriyor.",
            Colors.green,
          );
        } else {
          _showMessage(
            "CSV için veri bulunamadı.",
            Colors.orange,
          );
        }
      } else {
        _showMessage(
          "Rapor formatı seçiniz.",
          Colors.orange,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        "Rapor oluşturulurken hata oluştu: $e",
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          isExporting = false;
        });
      }
    }
  }

  String _createCsv() {
    final buffer =
        StringBuffer();

    buffer.writeln(
      "Tarih,Cari,Ödeme Türü,Tutar,Durum",
    );

    for (final payment
        in filteredPayments) {
      final date =
          _formatDate(
        _toDate(
          payment["paymentDate"],
        ),
      );

      final company =
          _csvValue(
        payment["companyName"] ??
            "Bilinmeyen Cari",
      );

      final feeType =
          _csvValue(
        payment["feeTypeName"] ??
            "-",
      );

      final amount =
          _toDouble(
        payment["amount"],
      ).toStringAsFixed(2);

      final status =
          payment["isPaid"] == true
              ? "Ödendi"
              : "Bekliyor";

      buffer.writeln(
        "$date,$company,$feeType,$amount,$status",
      );
    }

    return buffer.toString();
  }

  String _csvValue(
    dynamic value,
  ) {
    final text =
        value.toString();

    if (text.contains(",") ||
        text.contains("\"") ||
        text.contains("\n")) {
      return '"${text.replaceAll('"', '""')}"';
    }

    return text;
  }

  void _showMessage(
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        backgroundColor:
            color,
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor:
            Colors.white,
        foregroundColor:
            Colors.black,
        elevation: 0,

        title: const Text(
          "Rapor Dışa Aktar",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: isLoading
                ? null
                : () {
                    setState(() {
                      isLoading = true;
                      errorMessage =
                          null;
                    });

                    _loadReportData();
                  },
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : errorMessage != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh:
                      _loadReportData,
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                            30),
                    child: ListView(
                      children: [
                        const Text(
                          "Raporu Dışa Aktar",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        const Text(
                          "Gerçek tahsilat verilerinizi PDF, Excel veya CSV formatında hazırlayın.",
                          style: TextStyle(
                            color:
                                Colors.grey,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(
                          height: 35,
                        ),

                        _buildReportType(),

                        const SizedBox(
                          height: 30,
                        ),

                        _buildFormat(),

                        const SizedBox(
                          height: 30,
                        ),

                        _buildDateRange(),

                        const SizedBox(
                          height: 30,
                        ),

                        _buildPreview(),

                        const SizedBox(
                          height: 35,
                        ),

                        _buildExportActions(),

                        const SizedBox(
                          height: 35,
                        ),

                        Align(
                          alignment:
                              Alignment
                                  .centerRight,
                          child:
                              OutlinedButton
                                  .icon(
                            onPressed: () {
                              Navigator.pop(
                                context,
                              );
                            },
                            icon: const Icon(
                              Icons
                                  .arrow_back,
                            ),
                            label:
                                const Text(
                              "Raporlara Dön",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          30,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 70,
              color: Colors.red,
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              errorMessage ??
                  "Bir hata oluştu.",
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage =
                      null;
                });

                _loadReportData();
              },
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                "Tekrar Dene",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportType() {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          25,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            const Text(
              "Rapor Türü",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 20,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            DropdownButtonFormField<
                String>(
              value:
                  selectedReport,

              decoration:
                  const InputDecoration(
                border:
                    OutlineInputBorder(),
                prefixIcon:
                    Icon(
                  Icons
                      .description,
                ),
              ),

              items: const [
                DropdownMenuItem(
                  value:
                      "Aylık Tahsilat",
                  child: Text(
                    "Aylık Tahsilat",
                  ),
                ),
                DropdownMenuItem(
                  value:
                      "Cari Tahsilat",
                  child: Text(
                    "Cari Tahsilat",
                  ),
                ),
                DropdownMenuItem(
                  value:
                      "Genel Rapor",
                  child: Text(
                    "Genel Rapor",
                  ),
                ),
              ],

              onChanged:
                  (value) {
                if (value ==
                    null) {
                  return;
                }

                setState(() {
                  selectedReport =
                      value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormat() {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          25,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            const Text(
              "Dosya Formatı",
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 20,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            RadioListTile<String>(
              value: "PDF",
              groupValue:
                  selectedFormat,
              onChanged:
                  (value) {
                setState(() {
                  selectedFormat =
                      value!;
                });
              },
              title:
                  const Text("PDF"),
              secondary:
                  const Icon(
                Icons
                    .picture_as_pdf,
                color:
                    Colors.red,
              ),
            ),

            RadioListTile<String>(
              value: "Excel",
              groupValue:
                  selectedFormat,
              onChanged:
                  (value) {
                setState(() {
                  selectedFormat =
                      value!;
                });
              },
              title:
                  const Text("Excel"),
              secondary:
                  const Icon(
                Icons
                    .table_chart,
                color:
                    Colors.green,
              ),
            ),

            RadioListTile<String>(
              value: "CSV",
              groupValue:
                  selectedFormat,
              onChanged:
                  (value) {
                setState(() {
                  selectedFormat =
                      value!;
                });
              },
              title:
                  const Text("CSV"),
              secondary:
                  const Icon(
                Icons
                    .file_copy,
                color:
                    Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRange() {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          25,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            const Text(
              "Tarih Aralığı",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            LayoutBuilder(
              builder:
                  (
                context,
                constraints,
              ) {
                if (constraints
                        .maxWidth <
                    650) {
                  return Column(
                    children: [
                      _buildDateButton(
                        "Başlangıç Tarihi",
                        startDate,
                        _selectStartDate,
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      _buildDateButton(
                        "Bitiş Tarihi",
                        endDate,
                        _selectEndDate,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child:
                          _buildDateButton(
                        "Başlangıç Tarihi",
                        startDate,
                        _selectStartDate,
                      ),
                    ),

                    const SizedBox(
                      width: 20,
                    ),

                    Expanded(
                      child:
                          _buildDateButton(
                        "Bitiş Tarihi",
                        endDate,
                        _selectEndDate,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton(
    String title,
    DateTime? date,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
        8,
      ),
      child: InputDecorator(
        decoration:
            InputDecoration(
          labelText: title,
          border:
              const OutlineInputBorder(),
          prefixIcon:
              const Icon(
            Icons.calendar_today,
          ),
        ),
        child: Text(
          _formatDate(date),
          style:
              const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          25,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            const Text(
              "Rapor Önizleme",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Container(
              padding:
                  const EdgeInsets.all(
                25,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons
                        .description,
                    size: 70,
                    color:
                        primary,
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  Text(
                    selectedReport,
                    style:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    reportDescription,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  Wrap(
                    alignment:
                        WrapAlignment
                            .center,
                    spacing: 30,
                    runSpacing: 15,
                    children: [
                      _previewItem(
                        "Tahsilat",
                        _formatCurrency(
                          totalAmount,
                        ),
                      ),

                      _previewItem(
                        "İşlem",
                        transactionCount
                            .toString(),
                      ),

                      _previewItem(
                        "Başarılı",
                        successfulCount
                            .toString(),
                      ),

                      _previewItem(
                        "Bekleyen",
                        pendingCount
                            .toString(),
                      ),

                      _previewItem(
                        "Başarı",
                        "%${successRate.toStringAsFixed(0)}",
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    "${_formatDate(startDate)} - ${_formatDate(endDate)}",
                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewItem(
    String title,
    String value,
  ) {
    return Column(
      children: [
        Text(
          title,
          style:
              const TextStyle(
            color:
                Colors.grey,
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        Text(
          value,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildExportActions() {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          25,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            const Text(
              "Dışa Aktarma İşlemleri",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      isExporting
                          ? null
                          : () {
                              setState(() {
                                selectedFormat =
                                    "PDF";
                              });

                              _exportReport();
                            },
                  icon: const Icon(
                    Icons
                        .picture_as_pdf,
                  ),
                  label: const Text(
                    "PDF Oluştur",
                  ),
                ),

                ElevatedButton.icon(
                  onPressed:
                      isExporting
                          ? null
                          : () {
                              setState(() {
                                selectedFormat =
                                    "Excel";
                              });

                              _exportReport();
                            },
                  icon: const Icon(
                    Icons
                        .table_chart,
                  ),
                  label: const Text(
                    "Excel Oluştur",
                  ),
                ),

                ElevatedButton.icon(
                  onPressed:
                      isExporting
                          ? null
                          : () {
                              setState(() {
                                selectedFormat =
                                    "CSV";
                              });

                              _exportReport();
                            },
                  icon: const Icon(
                    Icons.file_copy,
                  ),
                  label: const Text(
                    "CSV Oluştur",
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    _showMessage(
                      "Yazdırma işlemi için raporu önce PDF olarak oluşturabilirsiniz.",
                      Colors.blue,
                    );
                  },
                  icon: const Icon(
                    Icons.print,
                  ),
                  label: const Text(
                    "Yazdır",
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    _showMessage(
                      "Paylaşmak için oluşturduğunuz PDF veya Excel dosyasını kullanabilirsiniz.",
                      Colors.blue,
                    );
                  },
                  icon: const Icon(
                    Icons.share,
                  ),
                  label: const Text(
                    "Paylaş",
                  ),
                ),
              ],
            ),

            if (isExporting) ...[
              const SizedBox(
                height: 25,
              ),

              const LinearProgressIndicator(),

              const SizedBox(
                height: 10,
              ),

              const Text(
                "Rapor hazırlanıyor...",
                style:
                    TextStyle(
                  color:
                      Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}