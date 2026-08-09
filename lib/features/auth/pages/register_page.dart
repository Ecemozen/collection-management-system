import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const Color primaryColor = Color(0xFFE31E24);
  static const Color backgroundColor = Color(0xFFEEF1F6);
  static const Color cardColor = Color(0xFFF8FAFC);

  final _formKey = GlobalKey<FormState>();

  bool acceptTerms = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (!acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lütfen kullanım koşullarını kabul edin."),
          ),
        );
        return;
      }
      // Kayıt işlemini başlat
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1150),
              decoration: BoxDecoration(
                color: cardColor,
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
                    final bool isDesktop = constraints.maxWidth > 850;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isDesktop)
                            Expanded(
                              flex: 5,
                              child: _buildLeftBrandPanel(),
                            ),
                          Expanded(
                            flex: 5,
                            child: _buildRightFormPanel(isDesktop),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Sol Marka Paneli
  Widget _buildLeftBrandPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRect(
                child: Align(
                  alignment: Alignment.topLeft,
                  heightFactor: 0.7,
                  child: Image.asset(
                    "assets/images/logo.png",
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
                  color: Color(0xFF1A1A1A),
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Aramıza katılın! Yeni hesap oluşturarak tahsilat operasyonlarınızı ve finansal süreçlerinizi hemen yönetmeye başlayın.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Yiğit Akü İleriye Götürür",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              "© 2026 Yiğit Akü",
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sağ Form Paneli
  Widget _buildRightFormPanel(bool isDesktop) {
    return Container(
      color: cardColor,
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
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
                      "assets/images/logo.png",
                      width: 170,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Hesap Oluştur",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Yeni bir kullanıcı hesabı oluşturun",
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 25),

                // Input Alanları
                _buildCustomFormField(
                  controller: fullNameController,
                  hintText: "Ad Soyad",
                  icon: Icons.person_outline,
                  validator: (v) => (v == null || v.isEmpty) ? "Ad soyad gereklidir" : null,
                ),
                const SizedBox(height: 14),

                _buildCustomFormField(
                  controller: emailController,
                  hintText: "E-Posta",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "E-posta gereklidir";
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                      return "Geçerli bir e-posta adresi giriniz";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                _buildCustomFormField(
                  controller: phoneController,
                  hintText: "Telefon",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),

                _buildCustomFormField(
                  controller: companyController,
                  hintText: "Şirket Adı",
                  icon: Icons.business_outlined,
                ),
                const SizedBox(height: 14),

                _buildCustomFormField(
                  controller: passwordController,
                  hintText: "Şifre",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: obscurePassword,
                  onTogglePassword: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Şifre gereklidir";
                    if (v.length < 6) return "Şifre en az 6 karakter olmalıdır";
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                _buildCustomFormField(
                  controller: confirmPasswordController,
                  hintText: "Şifre Tekrar",
                  icon: Icons.lock_reset_outlined,
                  isPassword: true,
                  obscureText: obscureConfirmPassword,
                  onTogglePassword: () {
                    setState(() => obscureConfirmPassword = !obscureConfirmPassword);
                  },
                  validator: (v) {
                    if (v != passwordController.text) return "Şifreler eşleşmiyor";
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Kullanım Koşulları
                Row(
                  children: [
                    Checkbox(
                      value: acceptTerms,
                      activeColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (value) {
                        setState(() => acceptTerms = value ?? false);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "Kullanım Koşullarını ve Gizlilik Politikasını kabul ediyorum.",
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Buton
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _submitForm,
                    child: const Text(
                      "HESAP OLUŞTUR",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Giriş Yönlendirmesi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Zaten hesabın var mı?",
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 13,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Giriş Yap",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
    );
  }

  // Yeniden Kullanılabilir TextFormField Yardımcısı
  Widget _buildCustomFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: cardColor,
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
      ),
    );
  }
}