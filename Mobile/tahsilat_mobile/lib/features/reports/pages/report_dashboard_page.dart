import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';

import 'monthly_report_page.dart';
import 'customer_report_page.dart';
import 'report_detail_page.dart';
import 'export_report_page.dart';

class ReportDashboardPage extends StatefulWidget {
  const ReportDashboardPage({super.key});

  @override
  State<ReportDashboardPage> createState() =>
      _ReportDashboardPageState();
}

class _ReportDashboardPageState extends State<ReportDashboardPage> {
  static const Color primary = Color(0xFFE31E24);

  bool isLoading = true;
  String? errorMessage;

  List<dynamic> payments = [];
  List<dynamic> debts = [];
  List<dynamic> customers = [];

  @override
  void initState() {
    super.initState();
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

      final paymentsData = jsonDecode(paymentsResponse.body);
      final debtsData = jsonDecode(debtsResponse.body);
      final customersData = jsonDecode(customersResponse.body);

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

  double get totalCollected {
    double total = 0;

    for (final payment in payments) {
      total += _toDouble(payment["amount"]);
    }

    return total;
  }

  double get todayCollected {
    final now = DateTime.now();

    double total = 0;

    for (final payment in payments) {
      final date = _toDate(payment["paymentDate"]);

      if (date == null) {
        continue;
      }

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        total += _toDouble(payment["amount"]);
      }
    }

    return total;
  }

  double get remainingDebt {
    double total = 0;

    for (final debt in debts) {
      total += _toDouble(debt["remainingAmount"]);
    }

    return total;
  }

  Map<String, double> get companyTotals {
    final Map<String, double> totals = {};

    for (final payment in payments) {
      final company =
          (payment["companyName"] ?? "Bilinmeyen Cari").toString();

      final amount = _toDouble(payment["amount"]);

      totals[company] = (totals[company] ?? 0) + amount;
    }

    return totals;
  }

  List<MapEntry<String, double>> get topCompanies {
    final list = companyTotals.entries.toList();

    list.sort(
      (a, b) => b.value.compareTo(a.value),
    );

    return list.take(5).toList();
  }

  List<dynamic> get lastPayments {
    final list = List<dynamic>.from(payments);

    list.sort((a, b) {
      final dateA = _toDate(a["paymentDate"]);
      final dateB = _toDate(b["paymentDate"]);

      if (dateA == null || dateB == null) {
        return 0;
      }

      return dateB.compareTo(dateA);
    });

    return list.take(5).toList();
  }

  List<dynamic> get pendingDebts {
    final list = debts.where((debt) {
      return _toDouble(debt["remainingAmount"]) > 0;
    }).toList();

    list.sort((a, b) {
      final dateA = _toDate(a["dueDate"]);
      final dateB = _toDate(b["dueDate"]);

      if (dateA == null || dateB == null) {
        return 0;
      }

      return dateA.compareTo(dateB);
    });

    return list.take(5).toList();
  }

  Map<String, double> get monthlyTotals {
    final Map<String, double> totals = {};

    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month - i,
        1,
      );

      final key = "${date.year}-${date.month}";

      totals[key] = 0;
    }

    for (final payment in payments) {
      final date = _toDate(payment["paymentDate"]);

      if (date == null) {
        continue;
      }

      final key = "${date.year}-${date.month}";

      if (totals.containsKey(key)) {
        totals[key] =
            totals[key]! + _toDouble(payment["amount"]);
      }
    }

    return totals;
  }

  String _formatCurrency(double value) {
    final fixed = value.toStringAsFixed(2);

    final parts = fixed.split(".");

    String integerPart = parts[0];

    String result = "";

    while (integerPart.length > 3) {
      result =
          ".${integerPart.substring(integerPart.length - 3)}$result";
      integerPart =
          integerPart.substring(0, integerPart.length - 3);
    }

    result = integerPart + result;

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

  String _monthName(int month) {
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

    if (month < 1 || month > 12) {
      return "";
    }

    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Raporlar",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            tooltip: "Yenile",
            icon: const Icon(Icons.refresh),
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
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadReportData,
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: ListView(
                      children: [
                        const Text(
                          "Finansal Raporlar",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Şirketinizin finansal durumunu gerçek verilerle takip edin.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 35),

                        _buildNavigationCards(context),

                        const SizedBox(height: 35),

                        _buildSummaryCards(),

                        const SizedBox(height: 35),

                        _buildMainReportArea(),

                        const SizedBox(height: 35),

                        _buildPaymentArea(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 70,
              color: Colors.red,
            ),

            const SizedBox(height: 20),

            Text(
              errorMessage ?? "Bir hata oluştu.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                _loadReportData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Tekrar Dene"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 900;

        final cards = [
          _NavigationCardData(
            title: "Aylık Rapor",
            subtitle: "Aylık tahsilat performansı",
            icon: Icons.calendar_month,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const MonthlyReportPage(),
                ),
              );
            },
          ),

          _NavigationCardData(
            title: "Cari Raporları",
            subtitle: "Müşteri bazlı analizler",
            icon: Icons.groups,
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CustomerReportPage(),
                ),
              );
            },
          ),

          _NavigationCardData(
            title: "Rapor Detayları",
            subtitle: "Detaylı işlem dökümleri",
            icon: Icons.assignment,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ReportDetailPage(),
                ),
              );
            },
          ),

          _NavigationCardData(
            title: "Dışa Aktar",
            subtitle: "PDF / Excel indir",
            icon: Icons.file_download,
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ExportReportPage(),
                ),
              );
            },
          ),
        ];

        if (isSmall) {
          return Column(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                _buildNavigationCard(cards[i]),
                if (i != cards.length - 1)
                  const SizedBox(height: 15),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(
                child: _buildNavigationCard(cards[i]),
              ),
              if (i != cards.length - 1)
                const SizedBox(width: 20),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNavigationCard(
    _NavigationCardData data,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor:
                    data.color.withOpacity(0.12),
                radius: 26,
                child: Icon(
                  data.icon,
                  color: data.color,
                  size: 28,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                data.subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int count = 4;

        if (constraints.maxWidth < 1000) {
          count = 2;
        }

        if (constraints.maxWidth < 600) {
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
              count == 1 ? 3.0 : 1.5,
          children: [
            _buildSummaryCard(
              "Toplam Tahsilat",
              _formatCurrency(totalCollected),
              Icons.payments,
              Colors.green,
            ),

            _buildSummaryCard(
              "Bugünkü Tahsilat",
              _formatCurrency(todayCollected),
              Icons.today,
              Colors.blue,
            ),

            _buildSummaryCard(
              "Bekleyen",
              _formatCurrency(remainingDebt),
              Icons.pending_actions,
              Colors.orange,
            ),

            _buildSummaryCard(
              "Toplam Cari",
              customers.length.toString(),
              Icons.groups,
              primary,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 42,
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

            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainReportArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall =
            constraints.maxWidth < 900;

        if (isSmall) {
          return Column(
            children: [
              _buildMonthlyChart(),
              const SizedBox(height: 25),
              _buildTopCustomers(),
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildMonthlyChart(),
            ),

            const SizedBox(width: 25),

            Expanded(
              child: _buildTopCustomers(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyChart() {
    final monthly = monthlyTotals;

    final values = monthly.values.toList();

    double maxValue = 0;

    for (final value in values) {
      if (value > maxValue) {
        maxValue = value;
      }
    }

    if (maxValue == 0) {
      maxValue = 1;
    }

    return Card(
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
            const Text(
              "Aylık Tahsilat Performansı",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Son 6 ay",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 280,
              child: values.every(
                (value) => value == 0,
              )
                  ? const Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 70,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Henüz grafik verisi bulunmuyor.",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        for (int i = 0;
                            i < values.length;
                            i++)
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.end,
                                children: [
                                  Text(
                                    _shortCurrency(
                                      values[i],
                                    ),
                                    style:
                                        const TextStyle(
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  SizedBox(
                                    height: 190 *
                                        (values[i] /
                                            maxValue),
                                    child: Container(
                                      decoration:
                                          BoxDecoration(
                                        color: primary,
                                        borderRadius:
                                            BorderRadius
                                                .circular(8),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    _monthName(
                                      int.parse(
                                        monthly.keys
                                            .elementAt(i)
                                            .split("-")[1],
                                      ),
                                    ),
                                    style:
                                        const TextStyle(
                                      fontSize: 11,
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
          ],
        ),
      ),
    );
  }

  String _shortCurrency(double value) {
    if (value >= 1000000) {
      return "₺${(value / 1000000).toStringAsFixed(1)}M";
    }

    if (value >= 1000) {
      return "₺${(value / 1000).toStringAsFixed(0)}K";
    }

    return "₺${value.toStringAsFixed(0)}";
  }

  Widget _buildTopCustomers() {
    final list = topCompanies;

    return Card(
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
            const Text(
              "En Çok Tahsilat",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    "Henüz tahsilat verisi bulunmuyor.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              for (final item in list)
                _buildTopCustomer(
                  item.key,
                  item.value,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCustomer(
    String company,
    double amount,
  ) {
    return ListTile(
      contentPadding:
          EdgeInsets.zero,

      leading: const CircleAvatar(
        backgroundColor: primary,
        child: Icon(
          Icons.business,
          color: Colors.white,
        ),
      ),

      title: Text(
        company,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: const Text(
        "Toplam Tahsilat",
      ),

      trailing: Text(
        _formatCurrency(amount),
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPaymentArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall =
            constraints.maxWidth < 900;

        if (isSmall) {
          return Column(
            children: [
              _buildLastPayments(),
              const SizedBox(height: 25),
              _buildPendingPayments(),
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildLastPayments(),
            ),

            const SizedBox(width: 25),

            Expanded(
              child: _buildPendingPayments(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLastPayments() {
    return Card(
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
            const Text(
              "Son Tahsilatlar",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            if (lastPayments.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    "Henüz tahsilat bulunmuyor.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              for (final payment in lastPayments)
                _buildLastPayment(
                  (payment["companyName"] ??
                          "Bilinmeyen Cari")
                      .toString(),
                  _toDouble(
                    payment["amount"],
                  ),
                  _formatDate(
                    payment["paymentDate"],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastPayment(
    String company,
    double amount,
    String date,
  ) {
    return ListTile(
      contentPadding:
          EdgeInsets.zero,

      leading: const CircleAvatar(
        backgroundColor:
            Color(0xFFE8F5E9),
        child: Icon(
          Icons.check,
          color: Colors.green,
        ),
      ),

      title: Text(
        company,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Text(
        date,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),

      trailing: Text(
        _formatCurrency(amount),
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPendingPayments() {
    return Card(
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
            const Text(
              "Bekleyen Tahsilatlar",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            if (pendingDebts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    "Bekleyen tahsilat bulunmuyor.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              for (final debt in pendingDebts)
                _buildPendingPayment(
                  (debt["invoiceNumber"] ??
                          "Fatura")
                      .toString(),
                  _toDouble(
                    debt["remainingAmount"],
                  ),
                  _formatDate(
                    debt["dueDate"],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingPayment(
    String invoice,
    double amount,
    String dueDate,
  ) {
    return ListTile(
      contentPadding:
          EdgeInsets.zero,

      leading: const CircleAvatar(
        backgroundColor:
            Color(0xFFFFF3E0),
        child: Icon(
          Icons.schedule,
          color: Colors.orange,
        ),
      ),

      title: Text(
        invoice,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Text(
        "Vade: $dueDate",
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),

      trailing: Text(
        _formatCurrency(amount),
        style: const TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _NavigationCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _NavigationCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}