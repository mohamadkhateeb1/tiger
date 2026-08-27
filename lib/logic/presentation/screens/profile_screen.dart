import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme.dart';
import '../../../data/models/player_profile_model.dart';
import 'api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  PlayerProfileModel? _profile;

  // --- فورم تغيير كلمة المرور ---
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _apiService.getProfile();

    if (!mounted) return;

    if (result.isUnauthorized) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      return;
    }

    setState(() {
      _isLoading = false;
      if (result.success) {
        _profile = result.profile;
      } else {
        _errorMessage = result.errorMessage;
      }
    });
  }

  Future<void> _handleChangePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showSnack("يرجى تعبئة كل الحقول", isError: true);
      return;
    }

    if (newPass.length < 6) {
      _showSnack("كلمة المرور الجديدة يجب ألا تقل عن 6 أحرف", isError: true);
      return;
    }

    if (newPass != confirm) {
      _showSnack("كلمة المرور الجديدة وتأكيدها غير متطابقين", isError: true);
      return;
    }

    setState(() => _isChangingPassword = true);

    final result = await _apiService.updatePassword(
      currentPassword: current,
      newPassword: newPass,
    );

    if (!mounted) return;

    if (result.isUnauthorized) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      return;
    }

    setState(() => _isChangingPassword = false);

    if (result.success) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _showSnack(result.message ?? "تم تغيير كلمة المرور بنجاح", isError: false);
    } else {
      _showSnack(result.errorMessage ?? "تعذّر تغيير كلمة المرور", isError: true);
    }
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isError ? Colors.redAccent : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('الملف الشخصي',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 60),
              const SizedBox(height: 20),
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 15)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadProfile,
                icon: const Icon(Icons.refresh, color: Colors.black),
                label: const Text("إعادة المحاولة", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _profile!;

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      backgroundColor: AppTheme.cardColor,
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(profile),
            const SizedBox(height: 24),
            _buildInfoSection(profile),
            const SizedBox(height: 24),
            _buildPasswordSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(PlayerProfileModel profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
            child: Text(
              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '؟',
              style: const TextStyle(color: AppTheme.primaryColor, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),
          Text(profile.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          if (profile.level != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(profile.level!, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 10),
          Text("منضم منذ ${profile.joinedAt}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInfoSection(PlayerProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("بياناتي", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildInfoTile(Icons.email_outlined, "البريد الإلكتروني", profile.email),
        if (profile.phone != null) _buildInfoTile(Icons.phone_outlined, "رقم الهاتف", profile.phone!),
        if (profile.coachName != null) _buildInfoTile(Icons.sports_gymnastics, "المدرب المسؤول", profile.coachName!),
        if (profile.height != null) _buildInfoTile(Icons.height, "الطول", "${profile.height!.toStringAsFixed(0)} سم"),
        if (profile.weight != null) _buildInfoTile(Icons.monitor_weight_outlined, "الوزن", "${profile.weight!.toStringAsFixed(1)} كغ"),
        if (profile.dateOfBirth != null) _buildInfoTile(Icons.cake_outlined, "تاريخ الميلاد", profile.dateOfBirth!),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 10),
              Text("تغيير كلمة المرور", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _currentPasswordController,
            obscureText: true,
            enabled: !_isChangingPassword,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'كلمة المرور الحالية',
              prefixIcon: Icon(Icons.lock_person_outlined, color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            enabled: !_isChangingPassword,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'كلمة المرور الجديدة',
              prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            enabled: !_isChangingPassword,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'تأكيد كلمة المرور الجديدة',
              prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isChangingPassword ? null : _handleChangePassword,
              child: _isChangingPassword
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                    )
                  : const Text("تغيير كلمة المرور", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}