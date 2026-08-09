import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:tahsilat_mobile/core/services/api_service.dart';
import '../../customer/pages/customer_list_page.dart';
import '../../payment/pages/payment_list_page.dart';
import '../../reports/pages/report_dashboard_page.dart';
import 'package:tahsilat_mobile/features/receipt/pages/receipt_archive_page.dart';
import '../models/dashboard_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color primary = Color(0xFFE31E24);
  int selectedMenuIndex = 0;

  DashboardModel? dashboardData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final api = ApiService();
      final response = await api.get("Dashboard");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          dashboardData = DashboardModel.fromJson(data);
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              "Dashboard verileri alınamadı. Kod: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Bağlantı hatası: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      drawer: MediaQuery.of(context).size.width < 900
          ? Drawer(child: _buildSidebarContent())
          : null,
      appBar: MediaQuery.of(context).size.width < 900
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              title: const Text(
                "Dashboard",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth >= 900;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDesktop)
                  SizedBox(
                    width: 280,
                    child: _buildSidebarContent(),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isDesktop ? 30 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(isDesktop),
                        const SizedBox(height: 30),
                        _buildStatGrid(constraints.maxWidth),
                        const SizedBox(height: 30),
                        _buildMainContent(isDesktop),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.only(bottom: 20),
            alignment: Alignment.centerLeft,
            child: Image.asset(
              "assets/images/logo.png",
              width: double.infinity,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  "TAHSİLAT",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primary,
                    letterSpacing: 1.2,
                  ),
                );
              },
            ),
          ),
          _buildMenuItem(Icons.grid_view_rounded, "Dashboard", 0),
          _buildMenuItem(Icons.account_balance_wallet_rounded, "Tahsilatlar", 1),
          _buildMenuItem(Icons.group_rounded, "Cariler", 2),
          _buildMenuItem(Icons.bar_chart_rounded, "Raporlar", 3),
          _buildMenuItem(Icons.receipt_long_rounded, "Makbuz Arşivi", 4),
          const Spacer(),
          _buildMenuItem(Icons.logout_rounded, "Çıkış Yap", 5, isLogout: true),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Row(
      children: [
        if (isDesktop)
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashboard",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Tahsilat Yönetim Sistemi",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          )
        else
          const Spacer(),
        _buildHeaderIconButton(Icons.search_rounded),
        const SizedBox(width: 12),
        _buildHeaderIconButton(Icons.notifications_none_rounded),
        const SizedBox(width: 16),
        const Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: primary,
              child: Text(
                "E",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ecem Özen",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "Yönetici",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatGrid(double maxWidth) {
    int crossAxisCount = 4;
    if (maxWidth < 600) {
      crossAxisCount = 1;
    } else if (maxWidth < 1100) {
      crossAxisCount = 2;
    }

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Text(
        errorMessage!,
        style: const TextStyle(color: Colors.red),
      );
    }

    final data = dashboardData!;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: crossAxisCount == 1 ? 2.2 : 1.6,
      children: [
        _statCard(
          Icons.people_alt_rounded,
          "Toplam Cari",
          "${data.totalCustomers}",
          const Color(0xFF2196F3),
        ),
        _statCard(
          Icons.account_balance_wallet_rounded,
          "Toplam Borç",
          _formatCurrency(data.totalDebtAmount),
          const Color(0xFFFF9800),
        ),
        _statCard(
          Icons.payments_rounded,
          "Toplam Tahsilat",
          _formatCurrency(data.totalCollectedAmount),
          const Color(0xFF4CAF50),
        ),
        _statCard(
          Icons.money_off_csred_rounded,
          "Kalan Borç",
          _formatCurrency(data.remainingAmount),
          primary,
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    return "₺${value.toStringAsFixed(2)}";
  }

  Widget _buildMainContent(bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 65,
            child: Column(
              children: [
                _buildIncomeChartPanel(),
                const SizedBox(height: 25),
                _buildRecentTransactionsPanel(),
              ],
            ),
          ),
          const SizedBox(width: 25),
          Expanded(
            flex: 35,
            child: _buildUpcomingPaymentsPanel(),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildIncomeChartPanel(),
          const SizedBox(height: 20),
          _buildRecentTransactionsPanel(),
          const SizedBox(height: 20),
          _buildUpcomingPaymentsPanel(),
        ],
      );
    }
  }

  Widget _buildMenuItem(IconData icon, String title, int index, {bool isLogout = false}) {
    final bool isSelected = selectedMenuIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() => selectedMenuIndex = index);

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PaymentListPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CustomerListPage(),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ReportDashboardPage(),
              ),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ReceiptArchivePage(),
              ),
            );
          }
        },
        splashColor: primary.withOpacity(0.05),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? primary.withOpacity(0.08) : Colors.transparent,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 5 : 0,
                height: 50,
                decoration: const BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
              SizedBox(width: isSelected ? 19 : 24),
              Icon(
                icon,
                color: isSelected
                    ? primary
                    : (isLogout ? Colors.redAccent : Colors.grey[600]),
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? primary
                      : (isLogout ? Colors.redAccent : const Color(0xFF444444)),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF555555), size: 20),
    );
  }

  Widget _statCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeChartPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📈 Gelir Grafiği",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar("Pzt", 0.4),
                _buildBar("Sal", 0.65),
                _buildBar("Çar", 0.5),
                _buildBar("Per", 0.85),
                _buildBar("Cum", 0.7),
                _buildBar("Cmt", 0.3),
                _buildBar("Paz", 0.2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double heightFactor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 22,
          height: 100 * heightFactor,
          decoration: BoxDecoration(
            color: primary.withOpacity(heightFactor > 0.7 ? 1.0 : 0.35),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildRecentTransactionsPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Son Tahsilatlar",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 15),
          _transactionRow("Ankara Lojistik A.Ş.", "₺45.000", "Bugün, 14:30"),
          const Divider(height: 20),
          _transactionRow("Zonguldak Madencilik Ltd.", "₺18.500", "Bugün, 11:15"),
          const Divider(height: 20),
          _transactionRow("Bülent Otomotiv", "₺61.500", "Dün, 16:45"),
        ],
      ),
    );
  }

  Widget _transactionRow(String company, String amount, String date) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.arrow_downward, color: Color(0xFF4CAF50), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                company,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingPaymentsPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Yaklaşan Ödemeler",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 15),
          _paymentRow("Sigma Teknoloji", "₺32.000", "Son 2 Gün"),
          const SizedBox(height: 12),
          _paymentRow("NovaStore Mağazacılık", "₺14.200", "Son 5 Gün"),
          const SizedBox(height: 12),
          _paymentRow("Kamil Koç Taşımacılık", "₺8.750", "Haftaya"),
        ],
      ),
    );
  }

  Widget _paymentRow(String title, String amount, String status) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}