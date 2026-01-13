import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_editor/core/theme/theme_cubit.dart';
import 'package:photo_editor/features/pro/presentation/pages/pro_screen.dart';
import 'package:photo_editor/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Pro Banner
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF006E), Color(0xFF8338EC)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 32),
                  const Gap(16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Go Pro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Unlock all features & remove ads',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const Gap(32),

          const Text(
            "Appearance",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              // color: Colors.white, // Remove hardcoded white
            ),
          ),
          const Gap(16),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return SwitchListTile(
                title: const Text("Dark Mode"),
                value: themeMode == ThemeMode.dark,
                onChanged: (isDark) {
                  context.read<ThemeCubit>().toggleTheme(isDark);
                },
                secondary: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
              );
            },
          ),
          const Gap(32),
          const Text(
            "General",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              // color: Colors.white,
            ),
          ),
          const Gap(16),
          _SettingTile(
            icon: Icons.restore,
            title: 'Restore Purchase',
            onTap: () {
              // TODO: Implement restore
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Restore purchase implementation pending'),
                ),
              );
            },
          ),
          _SettingTile(
            icon: Icons.shield_outlined,
            title: 'Privacy Policy',
            onTap: () {
              _launchUrl('https://example.com/privacy');
            },
          ),
          _SettingTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              _launchUrl('https://example.com/terms');
            },
          ),
          const Gap(32),
          const Text(
            "About",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Gap(16),
          _SettingTile(
            icon: Icons.share_outlined,
            title: 'Share App',
            onTap: () {
              // TODO: Implement share
            },
          ),
          _SettingTile(
            icon: Icons.thumb_up_alt_outlined,
            title: 'Rate Us',
            onTap: () {
              // TODO: Implement rating
            },
          ),
          const Gap(32),

          _SettingTile(
            icon: Icons.logout,
            title: 'Log Out',
            onTap: () {
              context.read<AuthCubit>().signOut();
              context.go('/login');
            },
          ),

          const Gap(32),

          Center(
            child: Text(
              'Version $_version',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDark ? Colors.white : Colors.black;
    final containerColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.05);

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: contentColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: contentColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: contentColor.withOpacity(0.3),
        size: 16,
      ),
    );
  }
}
