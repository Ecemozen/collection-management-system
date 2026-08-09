import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';
import 'package:tahsilat_mobile/features/customer/pages/customer_detail_page.dart';
import 'package:tahsilat_mobile/features/customer/pages/customer_edit_page.dart';
import 'customer_add_page.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  static const Color primary = Color(0xFFE31E24);
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final api = ApiService();
      final response = await api.get("Customers");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          customers = List<Map<String, dynamic>>.from(data);
          filteredCustomers = List.from(customers);
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Cariler alınamadı. Kod: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Bağlantı hatası: $e";
      });
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = List.from(customers);
      } else {
        filteredCustomers = customers.where((c) {
          final company = (c["companyName"] ?? "").toString().toLowerCase();
          final authorized = (c["authorizedPerson"] ?? "").toString().toLowerCase();
          final input = query.toLowerCase();

          return company.contains(input) || authorized.contains(input);
        }).toList();
      }
    });
  }

  Future<void> _navigateAndAddCustomer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerAddPage(),
      ),
    );

    if (result == true) {
      await _loadCustomers();
    }
  }

  Future<void> _deleteCustomer(Map<String, dynamic> customer) async {
    final customerId = customer["id"] ?? customer["customerId"];
    if (customerId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cari Sil"),
        content: Text("${customer["companyName"] ?? "Bu cari"} silinecek. Emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Sil"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final api = ApiService();
        final response = await api.delete("Customers/$customerId");

        if (response.statusCode == 200 || response.statusCode == 204) {
          setState(() {
            customers.removeWhere((c) => (c["id"] ?? c["customerId"]) == customerId);
            _filterCustomers(_searchController.text);
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cari başarıyla silindi.")),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Silme başarısız. Kod: ${response.statusCode}")),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e")),
        );
      }
    }
  }

  String _formatCurrency(dynamic value) {
    final number = double.tryParse(value.toString()) ?? 0;
    return "₺${number.toStringAsFixed(2)}";
  }

  Widget _buildCustomerContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 15,
          ),
        ),
      );
    }

    if (filteredCustomers.isEmpty) {
      return const Center(
        child: Text(
          "Kayıtlı cari bulunamadı.",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            const Color(0xFFF7F7F7),
          ),
          columns: const [
            DataColumn(
              label: Text(
                "Firma",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Yetkili",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Telefon",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Bakiye",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Durum",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "İşlemler",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: filteredCustomers.map((customer) {
            final bool isActive = customer["isActive"] == true;
            final customerId = customer["id"] ?? customer["customerId"];

            return DataRow(
              cells: [
                DataCell(Text(customer["companyName"] ?? "")),
                DataCell(Text(customer["authorizedPerson"] ?? "")),
                DataCell(Text(customer["phone"] ?? "")),
                DataCell(Text(_formatCurrency(customer["balance"]))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive ? "Aktif" : "Pasif",
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (customerId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerDetailPage(
                                  customerId: customerId,
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.visibility,
                          color: Colors.blue,
                        ),
                        tooltip: "Detay",
                      ),
                      IconButton(
                        onPressed: () async {
                          if (customerId != null) {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerEditPage(
                                  customerId: customerId,
                                ),
                              ),
                            );

                            if (result == true) {
                              await _loadCustomers();
                            }
                          }
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.orange,
                        ),
                        tooltip: "Düzenle",
                      ),
                      IconButton(
                        onPressed: () => _deleteCustomer(customer),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        tooltip: "Sil",
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
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
          "Cari Yönetimi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Arama & Buton Alanı
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Tüm cari hesaplarınızı buradan yönetin.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  // Arama Kutusu
                  SizedBox(
                    width: 320,
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterCustomers,
                      decoration: const InputDecoration(
                        hintText: "Cari Ara...",
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Yeni Cari Ekle Butonu
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _navigateAndAddCustomer,
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Yeni Cari",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Cari Tablosu
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _buildCustomerContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}