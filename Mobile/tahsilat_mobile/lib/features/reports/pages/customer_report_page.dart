import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';
import 'package:tahsilat_mobile/features/reports/pages/report_detail_page.dart';

class CustomerReportPage extends StatefulWidget {
  const CustomerReportPage({super.key});

  @override
  State<CustomerReportPage> createState() =>
      _CustomerReportPageState();
}

class _CustomerReportPageState extends State<CustomerReportPage> {
  static const Color primary = Color(0xFFE31E24);

  final TextEditingController searchController =
      TextEditingController();

  String selectedCustomer = "Tümü";

  bool isLoading = true;
  String? errorMessage;

  List<dynamic> payments = [];
  List<dynamic> debts = [];
  List<dynamic> customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomerReport();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomerReport() async {
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
        errorMessage =
            "Bağlantı hatası: $e";
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
    final date = _toDate(value);

    if (date == null) {
      return "-";
    }

    return "${date.day.toString().padLeft(2, '0')}."
        "${date.month.toString().padLeft(2, '0')}."
        "${date.year}";
  }

  Map<String, double> get customerPaymentTotals {
    final Map<String, double> result = {};

    for (final payment in payments) {
      final company =
          (payment["companyName"] ??
                  "Bilinmeyen Cari")
              .toString();

      final amount =
          _toDouble(payment["amount"]);

      result[company] =
          (result[company] ?? 0) +
              amount;
    }

    return result;
  }

  Map<String, int> get customerPaymentCounts {
    final Map<String, int> result = {};

    for (final payment in payments) {
      final company =
          (payment["companyName"] ??
                  "Bilinmeyen Cari")
              .toString();

      result[company] =
          (result[company] ?? 0) + 1;
    }

    return result;
  }

  List<MapEntry<String, double>>
      get sortedCustomers {
    final list =
        customerPaymentTotals.entries
            .toList();

    list.sort(
      (a, b) =>
          b.value.compareTo(a.value),
    );

    return list;
  }

  List<MapEntry<String, double>>
      get filteredCustomers {
    final query =
        searchController.text
            .trim()
            .toLowerCase();

    var list =
        sortedCustomers;

    if (selectedCustomer !=
        "Tümü") {
      list = list.where(
        (item) =>
            item.key ==
            selectedCustomer,
      ).toList();
    }

    if (query.isNotEmpty) {
      list = list.where(
        (item) =>
            item.key
                .toLowerCase()
                .contains(query),
      ).toList();
    }

    return list;
  }

  double get totalCollected {
    double total = 0;

    for (final payment in payments) {
      total +=
          _toDouble(payment["amount"]);
    }

    return total;
  }

  double get averageCollection {
    if (payments.isEmpty) {
      return 0;
    }

    return totalCollected /
        payments.length;
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

  int get activeCustomers {
    return customers.length;
  }

  double get successfulPaymentRate {
    if (payments.isEmpty) {
      return 0;
    }

    int successful = 0;

    for (final payment in payments) {
      if (payment["isPaid"] == true) {
        successful++;
      }
    }

    return successful /
        payments.length *
        100;
  }

  String get mostActiveCustomer {
    final list =
        customerPaymentCounts.entries
            .toList();

    if (list.isEmpty) {
      return "-";
    }

    list.sort(
      (a, b) =>
          b.value.compareTo(a.value),
    );

    return list.first.key;
  }

  int get mostActiveCustomerCount {
    final list =
        customerPaymentCounts.entries
            .toList();

    if (list.isEmpty) {
      return 0;
    }

    list.sort(
      (a, b) =>
          b.value.compareTo(a.value),
    );

    return list.first.value;
  }

  String get highestCollectionCustomer {
    final list =
        sortedCustomers;

    if (list.isEmpty) {
      return "-";
    }

    return list.first.key;
  }

  double get highestCollection {
    final list =
        sortedCustomers;

    if (list.isEmpty) {
      return 0;
    }

    return list.first.value;
  }

  List<MapEntry<String, double>>
      get topCustomers {
    return sortedCustomers
        .take(5)
        .toList();
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
          "Cari Raporları",
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

                    _loadCustomerReport();
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
                      _loadCustomerReport,
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                            30),
                    child: ListView(
                      children: [
                        const Text(
                          "Cari Raporları",
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
                          "Cari bazlı tahsilat ve işlem performansını gerçek verilerle inceleyin.",
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Colors.grey,
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        _buildFilters(),

                        const SizedBox(
                          height: 30,
                        ),

                        _buildSummaryCards(),

                        const SizedBox(
                          height: 35,
                        ),

                        _buildCustomerTable(),

                        const SizedBox(
                          height: 35,
                        ),

                        _buildAnalysisArea(),

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

                _loadCustomerReport();
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

  Widget _buildFilters() {
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
            const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder:
              (context, constraints) {
            if (constraints.maxWidth <
                700) {
              return Column(
                children: [
                  _buildSearchField(),

                  const SizedBox(
                    height: 15,
                  ),

                  _buildCustomerDropdown(),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child:
                      _buildSearchField(),
                ),

                const SizedBox(
                  width: 20,
                ),

                Expanded(
                  child:
                      _buildCustomerDropdown(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller:
          searchController,

      decoration:
          const InputDecoration(
        labelText:
            "Cari ara",
        hintText:
            "Cari adı yazın...",
        prefixIcon:
            Icon(Icons.search),
        border:
            OutlineInputBorder(),
      ),

      onChanged: (_) {
        setState(() {});
      },
    );
  }

  Widget _buildCustomerDropdown() {
    final names =
        customerPaymentTotals.keys
            .toList();

    names.sort();

    return DropdownButtonFormField<
        String>(
      value: selectedCustomer,

      decoration:
          const InputDecoration(
        labelText:
            "Cari seçiniz",
        prefixIcon:
            Icon(Icons.business),
        border:
            OutlineInputBorder(),
      ),

      items: [
        const DropdownMenuItem(
          value: "Tümü",
          child: Text("Tümü"),
        ),

        ...names.map(
          (name) =>
              DropdownMenuItem(
            value: name,
            child: Text(name),
          ),
        ),
      ],

      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          selectedCustomer =
              value;
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
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio:
              count == 1
                  ? 3
                  : 1.5,
          children: [
            _buildSummaryCard(
              "Toplam Cari",
              customers.length
                  .toString(),
              Icons.groups,
              primary,
            ),

            _buildSummaryCard(
              "Aktif Cariler",
              activeCustomers
                  .toString(),
              Icons.check_circle_outline,
              Colors.green,
            ),

            _buildSummaryCard(
              "Bekleyen İşlem",
              pendingTransactions
                  .toString(),
              Icons.pending_actions,
              Colors.orange,
            ),

            _buildSummaryCard(
              "Ort. Tahsilat",
              _formatCurrency(
                averageCollection,
              ),
              Icons.analytics,
              Colors.blue,
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
              color: color,
              size: 40,
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
                  color: color,
                  fontSize: 24,
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

  Widget _buildCustomerTable() {
    final list =
        filteredCustomers;

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
              "Cari Tahsilat Listesi",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            if (list.isEmpty)
              const Padding(
                padding:
                    EdgeInsets.all(30),
                child: Center(
                  child: Text(
                    "Cari tahsilat verisi bulunmuyor.",
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
                          Text("Cari"),
                    ),
                    DataColumn(
                      label:
                          Text("Tahsilat"),
                    ),
                    DataColumn(
                      label:
                          Text("İşlem"),
                    ),
                    DataColumn(
                      label:
                          Text("Durum"),
                    ),
                  ],

                  rows: list.map(
                    (item) {
                      final company =
                          item.key;

                      final amount =
                          item.value;

                      final count =
                          customerPaymentCounts[
                                  company] ??
                              0;

                      final pending =
                          _customerHasPendingDebt(
                        company,
                      );

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              company,
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
                            Text(
                              count
                                  .toString(),
                            ),
                          ),

                          DataCell(
                            _statusWidget(
                              pending
                                  ? "Bekliyor"
                                  : "Başarılı",
                              pending
                                  ? Colors.orange
                                  : Colors.green,
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

  bool _customerHasPendingDebt(
    String company,
  ) {
    // DebtDto içinde CompanyName bulunmadığı
    // için cari ile borcu doğrudan eşleştiremiyoruz.
    //
    // Bu nedenle burada sadece IsPaid durumuna
    // göre ödeme tarafındaki bilgiyi kullanıyoruz.

    for (final payment in payments) {
      final paymentCompany =
          (payment["companyName"] ??
                  "Bilinmeyen Cari")
              .toString();

      if (paymentCompany == company &&
          payment["isPaid"] != true) {
        return true;
      }
    }

    return false;
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
        final isSmall =
            constraints.maxWidth <
                900;

        if (isSmall) {
          return Column(
            children: [
              _buildTopCustomers(),

              const SizedBox(
                height: 25,
              ),

              _buildCustomerAnalysis(),
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child:
                  _buildTopCustomers(),
            ),

            const SizedBox(
              width: 25,
            ),

            Expanded(
              child:
                  _buildCustomerAnalysis(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopCustomers() {
    final list =
        topCustomers;

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
              "En Başarılı Cariler",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            if (list.isEmpty)
              const Text(
                "Henüz tahsilat verisi bulunmuyor.",
                style: TextStyle(
                  color: Colors.grey,
                ),
              )
            else
              for (final item in list)
                _buildCustomerTile(
                  item.key,
                  _formatCurrency(
                    item.value,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerTile(
    String name,
    String amount,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor:
                      primary,
                  child: Icon(
                    Icons.business,
                    color:
                        Colors.white,
                    size: 20,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Text(
                    name,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Text(
            amount,
            style:
                const TextStyle(
              color: Colors.green,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAnalysis() {
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
              "Cari Analizi",
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
              "En Aktif Cari",
              mostActiveCustomer,
            ),

            _buildAnalysisRow(
              "En Büyük Tahsilat",
              _formatCurrency(
                highestCollection,
              ),
            ),

            _buildAnalysisRow(
              "En Fazla İşlem",
              mostActiveCustomerCount
                  .toString(),
            ),

            _buildAnalysisRow(
              "Başarı Oranı",
              "%${successfulPaymentRate.toStringAsFixed(0)}",
            ),

            _buildAnalysisRow(
              "Toplam Tahsilat",
              _formatCurrency(
                totalCollected,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  const TextStyle(
                color: Colors.grey,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
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
                          "Cari raporu PDF olarak hazırlanıyor...",
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
                  label:
                      const Text("Excel"),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ReportDetailPage(),
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
                    Icons.analytics,
                  ),
                  label:
                      const Text(
                    "Detaylı Rapor",
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
                        Colors.deepPurple,
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
                  label:
                      const Text(
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