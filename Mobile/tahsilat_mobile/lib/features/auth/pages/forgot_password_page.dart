import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const Color primaryColor = Color(0xFFE31E24);
  static const Color primaryHoverColor = Color(0xFFC8181D);
  static const Color backgroundColor = Color(0xFFEEF1F6);
  static const Color inputFillColor = Color(0xFFF8FAFC);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      // API Şifre Sıfırlama İsteği Simülasyonu
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Şifre sıfırlama bağlantısı e-posta adresinize gönderildi."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 460),
              padding: const EdgeInsets.symmetric(
                horizontal: 36,
                vertical: 36,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 35,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: 0.7,
                        child: Image.asset(
                          "assets/images/logo.png",
                          width: 170,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Başlıklar
                    const Text(
                      "Şifrenizi mi Unuttunuz?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "E-posta adresinizi girin. Size şifre sıfırlama bağlantısı göndereceğiz.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // E-Posta Input
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleResetPassword(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "E-posta adresi boş bırakılamaz";
                        }
                        final emailRegExp = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegExp.hasMatch(value.trim())) {
                          return "Geçerli bir e-posta adresi giriniz";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "E-Posta",
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        filled: true,
                        fillColor: inputFillColor,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Şifre Sıfırlama Butonu
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.hovered)
                                ? primaryHoverColor
                                : primaryColor,
                          ),
                          foregroundColor: WidgetStateProperty.all(Colors.white),
                          elevation: WidgetStateProperty.all(0),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        onPressed: isLoading ? null : _handleResetPassword,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "ŞİFRE SIFIRLAMA BAĞLANTISI GÖNDER",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Giriş Yap'a Dön
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: primaryColor,
                      ),
                      label: const Text(
                        "Giriş Yap'a Dön",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Versiyon Bilgisi
                    const Text(
                      "Sürüm 1.0.0",
                      style: TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}