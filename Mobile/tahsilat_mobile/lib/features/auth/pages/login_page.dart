import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tahsilat_mobile/core/services/api_service.dart';
import 'package:tahsilat_mobile/features/dashboard/pages/dashboard_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color primary = Color(0xFFE31E24);

  final _formKey = GlobalKey<FormState>();
  bool rememberMe = false;
  bool obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final api = ApiService();

      final response = await api.post(
        "Auth/login",
        {
          "email": emailController.text.trim(),
          "password": passwordController.text,
        },
      );

      print("Email = '${emailController.text}'");
      print("Password = '${passwordController.text}'");
      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Giriş başarılı."),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("E-posta veya şifre hatalı."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bir hata oluştu: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEF1F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1150),
              decoration: BoxDecoration(
                color: const Color(0xffF8FAFC),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isDesktop = constraints.maxWidth > 850;

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 5, child: _buildLeftPanel()),
                          Expanded(flex: 5, child: _buildRightPanel(isDesktop)),
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRightPanel(isDesktop),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 50,
        vertical: 45,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRect(
                child: Align(
                  alignment: Alignment.topLeft,
                  heightFactor: 0.7,
                  child: Image.asset(
                    "assets/images/logo2.jpeg",
                    width: 320,
                  ),
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                "TAHSİLAT\nYÖNETİM SİSTEMİ",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff1A1A1A),
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Tahsilat süreçlerinizi tek platformdan yönetin, müşteri ödemelerini takip edin ve finansal operasyonlarınızı güvenle yönetin.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xff666666),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(bool isDesktop) {
    return Container(
      color: const Color(0xffF8FAFC),
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 36 : 24,
            vertical: isDesktop ? 32 : 24,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 0.7,
                    child: Image.asset(
                      "assets/images/logo2.jpeg",
                      width: 180,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Hoş Geldiniz",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Lütfen hesabınıza giriş yapın",
                  style: TextStyle(
                    color: Color(0xff888888),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),

                // E-Posta Alanı
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "E-posta alanı boş bırakılamaz";
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return "Geçerli bir e-posta adresi giriniz";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "E-Posta",
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: const Color(0xffF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Şifre Alanı
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Şifre alanı boş bırakılamaz";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Şifre",
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xffF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Beni Hatırla / Şifremi Unuttum
                Row(
                  children: [
                    Transform.scale(
                      scale: 1.1,
                      child: Checkbox(
                        value: rememberMe,
                        activeColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Beni Hatırla",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xff555555),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Şifremi Unuttum",
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Giriş Yap Butonu
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.hovered)
                            ? const Color(0xFFC8181D)
                            : primary,
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "GİRİŞ YAP",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),

                // Hesap Oluştur
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Hesabınız yok mu?",
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 13,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Hesap Oluştur",
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}