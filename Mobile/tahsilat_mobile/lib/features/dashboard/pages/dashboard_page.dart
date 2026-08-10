import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
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

      if (!mounted) return;

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
      if (!mounted) return;
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
              foregroundColor: Colors.black,
              elevation: 0,
              title: const Text(
                "Dashboard",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDesktop)
                  SizedBox(width: 280, child: _buildSidebarContent()),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: 2.5,
                            sigmaY: 2.5,
                          ),
                          child: Image.asset(
                            "assets/images/yigit_aku_bina.jpg",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(
                                  color: const Color(0xFFF5F6FA),
                                ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          color: Colors.white.withOpacity(0.48),
                        ),
                      ),
                      SingleChildScrollView(
                        padding: EdgeInsets.all(isDesktop ? 30 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(isDesktop),
                            const SizedBox(height: 28),
                            _buildStatGrid(constraints.maxWidth),
                            const SizedBox(height: 34),
                            _buildBatterySection(constraints.maxWidth),
                          ],
                        ),
                      ),
                    ],
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
              errorBuilder: (_, __, ___) => const Text(
                "TAHSİLAT",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop)
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashboard",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Tahsilat Yönetim Sistemi",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
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
        if (isDesktop)
          const Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primary,
                child: Text(
                  "E",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ecem Özen",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text("Yönetici",
                      style: TextStyle(color: Colors.black54, fontSize: 12)),
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
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final data = dashboardData!;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
      childAspectRatio: crossAxisCount == 1 ? 2.7 : 1.55,
      children: [
        _statCard(Icons.people_alt_rounded, "Toplam Cari",
            "${data.totalCustomers}", const Color(0xFF2196F3)),
        _statCard(Icons.account_balance_wallet_rounded, "Toplam Borç",
            _formatCurrency(data.totalDebtAmount), const Color(0xFFFF9800)),
        _statCard(Icons.payments_rounded, "Toplam Tahsilat",
            _formatCurrency(data.totalCollectedAmount), const Color(0xFF4CAF50)),
        _statCard(Icons.money_off_csred_rounded, "Kalan Borç",
            _formatCurrency(data.remainingAmount), primary),
      ],
    );
  }

  String _formatCurrency(double value) => "₺${value.toStringAsFixed(2)}";

  Widget _statCard(
      IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 9),
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
                    color: Color(0xFF777777),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
            ],
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF171717),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatterySection(double maxWidth) {
    int columns = 4;
    if (maxWidth < 650) {
      columns = 1;
    } else if (maxWidth < 1000) {
      columns = 2;
    }

    final batteries = [
      "assets/images/battery_premium.jpg",
      "assets/images/battery_silver.jpg",
      "assets/images/battery_efb.jpg",
      "assets/images/battery_asia.jpg",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Yiğit Akü Ürünleri",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF171717),
          ),
        ),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: batteries.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: columns == 1 ? 2.0 : 1.35,
          ),
          itemBuilder: (context, index) {
            return _buildBatteryCard(
              image: batteries[index],
              title: "",
              subtitle: "",
            );
          },
        ),
      ],
    );
  }

  Widget _buildBatteryCard({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Image.asset(
          image,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return const Center(
              child: Icon(
                Icons.battery_full_rounded,
                size: 60,
                color: primary,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index,
      {bool isLogout = false}) {
    final bool isSelected = selectedMenuIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() => selectedMenuIndex = index);

          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PaymentListPage()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CustomerListPage()));
          } else if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReportDashboardPage()));
          } else if (index == 4) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReceiptArchivePage()));
          }
        },
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
                      : (isLogout
                          ? Colors.redAccent
                          : const Color(0xFF444444)),
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
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
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF555555), size: 20),
    );
  }
}