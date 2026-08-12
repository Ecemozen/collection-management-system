import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';

class ReportDetailPage extends StatefulWidget {
  const ReportDetailPage({super.key});

  @override
  State<ReportDetailPage> createState() =>
      _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  static const Color primary = Color(0xFFE31E24);

  bool isLoading = true;
  String? errorMessage;

  List<dynamic> payments = [];
  List<dynamic> debts = [];

  @override
  void initState() {
    super.initState();
    _loadReportDetail();
  }

  Future<void> _loadReportDetail() async {
    try {
      final api = ApiService();

      final paymentsResponse = await api.get("Payments");
      final debtsResponse = await api.get("Debts");

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

      final paymentsData =
          jsonDecode(paymentsResponse.body);

      final debtsData =
          jsonDecode(debtsResponse.body);

      setState(() {
        payments = _toList(paymentsData);
        debts = _toList(debtsData);
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = "Bağlantı hatası: $e";
      });
    }
  }

  List<dynamic> _toList(dynamic data) {
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

  double _toDouble(dynamic value) {
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

  DateTime? _toDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  String _formatCurrency(double value) {
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

  String _formatDate(dynamic value) {
    final date =
        _toDate(value);

    if (date == null) {
      return "-";
    }

    return "${date.day.toString().padLeft(2, '0')}."
        "${date.month.toString().padLeft(2, '0')}."
        "${date.year}";
  }

  double get totalCollected {
    double total = 0;

    for (final payment in payments) {
      total +=
          _toDouble(payment["amount"]);
    }

    return total;
  }

  int get totalTransactions {
    return payments.length;
  }

  int get successfulTransactions {
    int count = 0;

    for (final payment in payments) {
      if (payment["isPaid"] == true) {
        count++;
      }
    }

    return count;
  }

  double get successRate {
    if (payments.isEmpty) {
      return 0;
    }

    return successfulTransactions /
        payments.length *
        100;
  }

  int get pendingTransactions {
    int count = 0;

    for (final debt in debts) {
      if (_toDouble(
            debt["remainingAmount"],
          ) >
          0) {
        count++;
      }
    }

    return count;
  }

  double get largestPayment {
    if (payments.isEmpty) {
      return 0;
    }

    double largest = 0;

    for (final payment in payments) {
      final amount =
          _toDouble(
        payment["amount"],
      );

      if (amount > largest) {
        largest = amount;
      }
    }

    return largest;
  }

  double get smallestPayment {
    if (payments.isEmpty) {
      return 0;
    }

    double smallest =
        _toDouble(
      payments.first["amount"],
    );

    for (final payment in payments) {
      final amount =
          _toDouble(
        payment["amount"],
      );

      if (amount < smallest) {
        smallest = amount;
      }
    }

    return smallest;
  }

  double get averagePayment {
    if (payments.isEmpty) {
      return 0;
    }

    return totalCollected /
        payments.length;
  }

  List<dynamic> get sortedPayments {
    final list =
        List<dynamic>.from(
      payments,
    );

    list.sort((a, b) {
      final dateA =
          _toDate(
        a["paymentDate"],
      );

      final dateB =
          _toDate(
        b["paymentDate"],
      );

      if (dateA == null ||
          dateB == null) {
        return 0;
      }

      return dateB.compareTo(dateA);
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        title: const Text(
          "Rapor Detayı",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            tooltip: "Yenile",
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

                    _loadReportDetail();
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
                      _loadReportDetail,
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                            30),
                    child: ListView(
                      children: [
                        const Text(
                          "Rapor Detayı",
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
                          "Tahsilat hareketlerinin ayrıntılı analizini gerçek verilerle görüntüleyin.",
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Colors.grey,
                          ),
                        ),

                        const SizedBox(
                          height: 35,
                        ),

                        _buildSummaryCards(),

                        const SizedBox(
                          height: 35,
                        ),

                        _buildReportInfo(),

                        const SizedBox(
                          height: 35,
                        ),

                        _buildPaymentMovements(),

                        const SizedBox(
                          height: 35,
                        ),

                        _buildAnalysisArea(),

                        const SizedBox(
                          height: 35,
                        ),

                        _buildEvaluation(),

                        const SizedBox(
                          height: 35,
                        ),

                        _buildPerformanceChart(),

                        const SizedBox(
                          height: 35,
                        ),

                        _buildReportActions(),
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
            const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
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

                _loadReportDetail();
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

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder:
          (context, constraints) {
        int count = 4;

        if (constraints.maxWidth <
            1000) {
          count = 2;
        }

        if (constraints.maxWidth <
            600) {
          count = 1;
        }

        return GridView.count(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisCount: count,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio:
              count == 1
                  ? 3
                  : 1.5,
          children: [
            _buildSummaryCard(
              "Toplam Tahsilat",
              _formatCurrency(
                totalCollected,
              ),
              Icons.payments,
              Colors.green,
            ),

            _buildSummaryCard(
              "Toplam İşlem",
              totalTransactions
                  .toString(),
              Icons.receipt_long,
              Colors.blue,
            ),

            _buildSummaryCard(
              "Başarı",
              "%${successRate.toStringAsFixed(0)}",
              Icons.trending_up,
              primary,
            ),

            _buildSummaryCard(
              "Bekleyen",
              pendingTransactions
                  .toString(),
              Icons.schedule,
              Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportInfo() {
    final now =
        DateTime.now();

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
            const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Rapor Bilgileri",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            _buildInfoRow(
              "Rapor Türü",
              "Tahsilat Detay Raporu",
            ),

            _buildInfoRow(
              "Oluşturulma",
              _formatDate(now),
            ),

            _buildInfoRow(
              "Cari",
              "Tüm Cariler",
            ),

            _buildInfoRow(
              "Toplam İşlem",
              totalTransactions
                  .toString(),
            ),

            _buildInfoRow(
              "Durum",
              "Güncel",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMovements() {
    final list =
        sortedPayments;

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
            const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Tahsilat Hareketleri",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            if (list.isEmpty)
              const Padding(
                padding:
                    EdgeInsets.all(30),
                child: Center(
                  child: Text(
                    "Henüz tahsilat hareketi bulunmuyor.",
                    style:
                        TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(
                      label:
                          Text("Tarih"),
                    ),
                    DataColumn(
                      label:
                          Text("Cari"),
                    ),
                    DataColumn(
                      label:
                          Text("Ödeme"),
                    ),
                    DataColumn(
                      label:
                          Text("Tutar"),
                    ),
                    DataColumn(
                      label:
                          Text("Durum"),
                    ),
                  ],
                  rows: list
                      .map(
                    (payment) {
                      final company =
                          (payment[
                                      "companyName"] ??
                                  "Bilinmeyen Cari")
                              .toString();

                      final feeType =
                          (payment[
                                      "feeTypeName"] ??
                                  "-")
                              .toString();

                      final amount =
                          _toDouble(
                        payment[
                            "amount"],
                      );

                      final paid =
                          payment[
                                  "isPaid"] ==
                              true;

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              _formatDate(
                                payment[
                                    "paymentDate"],
                              ),
                            ),
                          ),

                          DataCell(
                            Text(
                              company,
                            ),
                          ),

                          DataCell(
                            Text(
                              feeType,
                            ),
                          ),

                          DataCell(
                            Text(
                              _formatCurrency(
                                amount,
                              ),
                            ),
                          ),

                          DataCell(
                            _statusWidget(
                              paid
                                  ? "Ödendi"
                                  : "Bekliyor",
                              paid
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusWidget(
    String text,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withOpacity(
          0.1,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAnalysisArea() {
    return LayoutBuilder(
      builder:
          (context, constraints) {
        if (constraints.maxWidth <
            900) {
          return Column(
            children: [
              _buildCollectionAnalysis(),

              const SizedBox(
                height: 20,
              ),

              _buildGeneralEvaluation(),
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child:
                  _buildCollectionAnalysis(),
            ),

            const SizedBox(
              width: 20,
            ),

            Expanded(
              child:
                  _buildGeneralEvaluation(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCollectionAnalysis() {
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
            const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Tahsilat Analizi",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            _buildAnalysisRow(
              "En Büyük Tahsilat",
              _formatCurrency(
                largestPayment,
              ),
            ),

            _buildAnalysisRow(
              "En Küçük Tahsilat",
              _formatCurrency(
                smallestPayment,
              ),
            ),

            _buildAnalysisRow(
              "Ortalama Tahsilat",
              _formatCurrency(
                averagePayment,
              ),
            ),

            _buildAnalysisRow(
              "Başarı Oranı",
              "%${successRate.toStringAsFixed(0)}",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralEvaluation() {
    String message;

    if (payments.isEmpty) {
      message =
          "Henüz tahsilat verisi bulunmamaktadır.";
    } else if (successRate >= 80 &&
        pendingTransactions == 0) {
      message =
          "Tahsilat performansı başarılı görünüyor. Bekleyen işlem bulunmuyor.";
    } else if (successRate >= 80) {
      message =
          "Tahsilat performansı iyi seviyededir. Bekleyen işlemlerin takip edilmesi önerilir.";
    } else {
      message =
          "Tahsilat performansının artırılması ve bekleyen işlemlerin takip edilmesi önerilir.";
    }

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
            const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Genel Değerlendirme",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              message,
              style: TextStyle(
                height: 1.6,
                color:
                    Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    final monthlyTotals =
        _getMonthlyTotals();

    double maxValue = 0;

    for (final value
        in monthlyTotals.values) {
      if (value > maxValue) {
        maxValue = value;
      }
    }

    if (maxValue == 0) {
      maxValue = 1;
    }

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
            const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Rapor Performans Grafiği",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            SizedBox(
              height: 300,
              child: payments.isEmpty
                  ? const Center(
                      child: Text(
                        "Grafik için tahsilat verisi bulunmuyor.",
                        style: TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),
                    )
                  : Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        for (final entry
                            in monthlyTotals.entries)
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 5,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .end,
                                children: [
                                  Text(
                                    _shortCurrency(
                                      entry.value,
                                    ),
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          9,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                        5,
                                  ),

                                  Container(
                                    height:
                                        200 *
                                            (entry.value /
                                                maxValue),
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          primary,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        7,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                        8,
                                  ),

                                  Text(
                                    entry.key,
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          10,
                                      color:
                                          Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
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

  Map<String, double> _getMonthlyTotals() {
    final Map<String, double> result =
        {};

    final now =
        DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final date =
          DateTime(
        now.year,
        now.month - i,
        1,
      );

      final key =
          _shortMonth(date.month);

      result[key] = 0;
    }

    for (final payment in payments) {
      final date =
          _toDate(
        payment["paymentDate"],
      );

      if (date == null) {
        continue;
      }

      final current =
          DateTime(
        now.year,
        now.month,
        1,
      );

      final difference =
          (current.year - date.year) *
                  12 +
              current.month -
                  date.month;

      if (difference >= 0 &&
          difference <= 5) {
        final key =
            _shortMonth(
          date.month,
        );

        result[key] =
            (result[key] ?? 0) +
                _toDouble(
                  payment[
                      "amount"],
                );
      }
    }

    return result;
  }

  String _shortMonth(int month) {
    const months = [
      "Oca",
      "Şub",
      "Mar",
      "Nis",
      "May",
      "Haz",
      "Tem",
      "Ağu",
      "Eyl",
      "Eki",
      "Kas",
      "Ara",
    ];

    return months[month - 1];
  }

  String _shortCurrency(
    double value,
  ) {
    if (value >= 1000000) {
      return "₺${(value / 1000000).toStringAsFixed(1)}M";
    }

    if (value >= 1000) {
      return "₺${(value / 1000).toStringAsFixed(0)}K";
    }

    return "₺${value.toStringAsFixed(0)}";
  }

  Widget _buildEvaluation() {
    return const SizedBox.shrink();
  }

  Widget _buildReportActions() {
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
            const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Rapor İşlemleri",
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
                  onPressed: () {
                    ScaffoldMessenger
                            .of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "PDF raporu hazırlanıyor...",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.picture_as_pdf,
                  ),
                  label:
                      const Text("PDF"),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger
                            .of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Excel raporu hazırlanıyor...",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.table_chart,
                  ),
                  label:
                      const Text("Excel"),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger
                            .of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Rapor yazdırılıyor...",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.print,
                  ),
                  label:
                      const Text("Yazdır"),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger
                            .of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Paylaşım hazırlanıyor...",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.share,
                  ),
                  label:
                      const Text("Paylaş"),
                ),
              ],
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
      padding:
          const EdgeInsets.only(
        bottom: 18,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 220,
            child: Text(
              title,
              style:
                  const TextStyle(
                color: Colors.grey,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 15,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          Text(
            value,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
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
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 38,
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              title,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: Colors.grey,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}