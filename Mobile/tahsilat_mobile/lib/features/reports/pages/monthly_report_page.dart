import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() =>
      _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  static const Color primary = Color(0xFFE31E24);

  bool isLoading = true;
  String? errorMessage;

  List<dynamic> payments = [];
  List<dynamic> debts = [];
  List<dynamic> customers = [];

  late List<DateTime> availableMonths;
  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    availableMonths = List.generate(
      12,
      (index) => DateTime(
        now.year,
        now.month - index,
        1,
      ),
    );

    selectedMonth = availableMonths.first;

    _loadReportData();
  }

  Future<void> _loadReportData() async {
    try {
      final api = ApiService();

      final paymentsResponse = await api.get("Payments");
      final debtsResponse = await api.get("Debts");
      final customersResponse = await api.get("Customers");

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
          jsonDecode(paymentsResponse.body);

      final debtsData =
          jsonDecode(debtsResponse.body);

      final customersData =
          jsonDecode(customersResponse.body);

      setState(() {
        payments = _toList(paymentsData);
        debts = _toList(debtsData);
        customers = _toList(customersData);

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

    return double.tryParse(value.toString()) ?? 0;
  }

  DateTime? _toDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  bool _isSameMonth(
    DateTime date,
    DateTime month,
  ) {
    return date.year == month.year &&
        date.month == month.month;
  }

  List<dynamic> get selectedMonthPayments {
    return payments.where((payment) {
      final date =
          _toDate(payment["paymentDate"]);

      if (date == null) {
        return false;
      }

      return _isSameMonth(
        date,
        selectedMonth,
      );
    }).toList();
  }

  double get monthlyTotal {
    double total = 0;

    for (final payment in selectedMonthPayments) {
      total += _toDouble(
        payment["amount"],
      );
    }

    return total;
  }

  int get monthlyPaymentCount {
    return selectedMonthPayments.length;
  }

  double get monthlyAverage {
    if (monthlyPaymentCount == 0) {
      return 0;
    }

    return monthlyTotal /
        monthlyPaymentCount;
  }

  int get monthlyPaidCount {
    int count = 0;

    for (final payment in selectedMonthPayments) {
      if (payment["isPaid"] == true) {
        count++;
      }
    }

    return count;
  }

  double get successRate {
    if (monthlyPaymentCount == 0) {
      return 0;
    }

    return
        (monthlyPaidCount /
                monthlyPaymentCount) *
            100;
  }

  double get pendingAmount {
    double total = 0;

    for (final debt in debts) {
      total += _toDouble(
        debt["remainingAmount"],
      );
    }

    return total;
  }

  List<dynamic> get sortedMonthlyPayments {
    final list =
        List<dynamic>.from(
      selectedMonthPayments,
    );

    list.sort((a, b) {
      final dateA =
          _toDate(a["paymentDate"]);

      final dateB =
          _toDate(b["paymentDate"]);

      if (dateA == null ||
          dateB == null) {
        return 0;
      }

      return dateA.compareTo(dateB);
    });

    return list;
  }

  double get highestDailyAmount {
    final Map<String, double> dailyTotals =
        {};

    for (final payment
        in selectedMonthPayments) {
      final date =
          _toDate(payment["paymentDate"]);

      if (date == null) {
        continue;
      }

      final key =
          "${date.year}-${date.month}-${date.day}";

      dailyTotals[key] =
          (dailyTotals[key] ?? 0) +
              _toDouble(
                payment["amount"],
              );
    }

    if (dailyTotals.isEmpty) {
      return 0;
    }

    return dailyTotals.values.reduce(
      (a, b) => a > b ? a : b,
    );
  }

  String get highestDay {
    final Map<String, double> dailyTotals =
        {};

    final Map<String, DateTime> dates = {};

    for (final payment
        in selectedMonthPayments) {
      final date =
          _toDate(payment["paymentDate"]);

      if (date == null) {
        continue;
      }

      final key =
          "${date.year}-${date.month}-${date.day}";

      dailyTotals[key] =
          (dailyTotals[key] ?? 0) +
              _toDouble(
                payment["amount"],
              );

      dates[key] = date;
    }

    if (dailyTotals.isEmpty) {
      return "-";
    }

    final highest =
        dailyTotals.entries.reduce(
      (a, b) =>
          a.value > b.value ? a : b,
    );

    final date = dates[highest.key]!;

    return "${date.day.toString().padLeft(2, '0')}."
        "${date.month.toString().padLeft(2, '0')}."
        "${date.year}";
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

  String _monthName(int month) {
    const months = [
      "Ocak",
      "Şubat",
      "Mart",
      "Nisan",
      "Mayıs",
      "Haziran",
      "Temmuz",
      "Ağustos",
      "Eylül",
      "Ekim",
      "Kasım",
      "Aralık",
    ];

    return months[month - 1];
  }

  String _shortMonthName(int month) {
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

  String _formatMonth(DateTime date) {
    return "${_monthName(date.month)} ${date.year}";
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
          "Aylık Tahsilat Raporu",
          style: TextStyle(
            fontWeight: FontWeight.bold,
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
                      errorMessage = null;
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
                          "Aylık Tahsilat Raporu",
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
                          "Seçilen aya ait tahsilat performansını gerçek verilerle görüntüleyin.",
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Colors.grey,
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        _buildMonthSelector(),

                        const SizedBox(
                          height: 30,
                        ),

                        _buildSummaryCards(),

                        const SizedBox(
                          height: 35,
                        ),

                        _buildMainArea(),

                        const SizedBox(
                          height: 35,
                        ),

                        _buildPaymentTable(),

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
                  errorMessage = null;
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

  Widget _buildMonthSelector() {
    return DropdownButtonFormField<DateTime>(
      value: selectedMonth,

      decoration:
          const InputDecoration(
        labelText: "Ay Seçiniz",
        prefixIcon:
            Icon(Icons.calendar_month),
        border:
            OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),

      items: availableMonths.map(
        (month) {
          return DropdownMenuItem<
              DateTime>(
            value: month,
            child: Text(
              _formatMonth(month),
            ),
          );
        },
      ).toList(),

      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          selectedMonth = value;
        });
      },
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
                monthlyTotal,
              ),
              Icons.payments,
              Colors.green,
            ),

            _buildSummaryCard(
              "Tahsilat Sayısı",
              monthlyPaymentCount
                  .toString(),
              Icons.receipt_long,
              Colors.blue,
            ),

            _buildSummaryCard(
              "Toplam Cari",
              customers.length
                  .toString(),
              Icons.groups,
              primary,
            ),

            _buildSummaryCard(
              "Başarı Oranı",
              "%${successRate.toStringAsFixed(0)}",
              Icons.trending_up,
              Colors.orange,
            ),
          ],
        );
      },
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
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
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
              height: 10,
            ),

            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  color: color,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainArea() {
    return LayoutBuilder(
      builder:
          (context, constraints) {
        final isSmall =
            constraints.maxWidth <
                900;

        if (isSmall) {
          return Column(
            children: [
              _buildMonthlyChart(),

              const SizedBox(
                height: 25,
              ),

              _buildMonthlySummary(),
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child:
                  _buildMonthlyChart(),
            ),

            const SizedBox(
              width: 25,
            ),

            Expanded(
              child:
                  _buildMonthlySummary(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyChart() {
    final dailyTotals =
        <int, double>{};

    for (final payment
        in selectedMonthPayments) {
      final date =
          _toDate(
        payment["paymentDate"],
      );

      if (date == null) {
        continue;
      }

      dailyTotals[date.day] =
          (dailyTotals[date.day] ??
                  0) +
              _toDouble(
                payment["amount"],
              );
    }

    double maxValue = 0;

    for (final value
        in dailyTotals.values) {
      if (value > maxValue) {
        maxValue = value;
      }
    }

    if (maxValue == 0) {
      maxValue = 1;
    }

    final daysInMonth =
        DateTime(
              selectedMonth.year,
              selectedMonth.month + 1,
              0,
            ).day;

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
              "Aylık Tahsilat Grafiği",
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
              height: 320,
              child: dailyTotals.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Icon(
                            Icons.show_chart,
                            size: 70,
                            color:
                                Colors.grey,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Bu ay için tahsilat bulunmuyor.",
                            style: TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal,
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .end,
                        children: List.generate(
                          daysInMonth,
                          (index) {
                            final day =
                                index + 1;

                            final value =
                                dailyTotals[
                                        day] ??
                                    0;

                            return Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    4,
                              ),
                              child: SizedBox(
                                width: 24,
                                child:
                                    Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .end,
                                  children: [
                                    if (value >
                                        0)
                                      RotatedBox(
                                        quarterTurns:
                                            3,
                                        child:
                                            Text(
                                          _shortCurrency(
                                              value),
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                8,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                    const SizedBox(
                                      height:
                                          5,
                                    ),

                                    Container(
                                      width:
                                          18,
                                      height:
                                          210 *
                                              (value /
                                                  maxValue),
                                      decoration:
                                          BoxDecoration(
                                        color:
                                            primary,
                                        borderRadius:
                                            BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height:
                                          6,
                                    ),

                                    Text(
                                      "$day",
                                      style:
                                          const TextStyle(
                                        fontSize:
                                            9,
                                        color:
                                            Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildMonthlySummary() {
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
              "Aylık Özet",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            _buildInfoRow(
              "En Yüksek Gün",
              highestDay,
            ),

            _buildInfoRow(
              "En Yüksek Tahsilat",
              _formatCurrency(
                highestDailyAmount,
              ),
            ),

            _buildInfoRow(
              "Ortalama Tahsilat",
              _formatCurrency(
                monthlyAverage,
              ),
            ),

            _buildInfoRow(
              "Tahsilat Başarısı",
              "%${successRate.toStringAsFixed(0)}",
            ),

            _buildInfoRow(
              "Bekleyen",
              _formatCurrency(
                pendingAmount,
              ),
            ),

            _buildInfoRow(
              "Tahsilat Adedi",
              monthlyPaymentCount
                  .toString(),
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
          Expanded(
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

          Text(
            value,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTable() {
    final data =
        sortedMonthlyPayments;

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
            Text(
              "${_formatMonth(selectedMonth)} Tahsilatları",
              style: const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            if (data.isEmpty)
              const Padding(
                padding:
                    EdgeInsets.all(30),
                child: Center(
                  child: Text(
                    "Seçilen ayda tahsilat bulunmuyor.",
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
                          Text("Tutar"),
                    ),
                    DataColumn(
                      label:
                          Text("Durum"),
                    ),
                  ],
                  rows: data.map(
                    (payment) {
                      final isPaid =
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
                              (payment[
                                          "companyName"] ??
                                      "Bilinmeyen Cari")
                                  .toString(),
                            ),
                          ),

                          DataCell(
                            Text(
                              _formatCurrency(
                                _toDouble(
                                  payment[
                                      "amount"],
                                ),
                              ),
                            ),
                          ),

                          DataCell(
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    10,
                                vertical:
                                    6,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: isPaid
                                    ? Colors
                                        .green
                                        .withOpacity(
                                            0.1)
                                    : Colors
                                        .orange
                                        .withOpacity(
                                            0.1),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  20,
                                ),
                              ),
                              child: Text(
                                isPaid
                                    ? "Ödendi"
                                    : "Bekliyor",
                                style:
                                    TextStyle(
                                  color: isPaid
                                      ? Colors
                                          .green
                                      : Colors
                                          .orange,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
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
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.red,
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                  ),
                  icon: const Icon(
                    Icons.picture_as_pdf,
                  ),
                  label: const Text(
                    "PDF Oluştur",
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger
                            .of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Excel dosyası hazırlanıyor...",
                        ),
                      ),
                    );
                  },
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.green,
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                  ),
                  icon: const Icon(
                    Icons.table_chart,
                  ),
                  label: const Text(
                    "Excel Aktar",
                  ),
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
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        primary,
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 28,
                      vertical: 18,
                    ),
                  ),
                  icon: const Icon(
                    Icons.print,
                  ),
                  label: const Text(
                    "Yazdır",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}