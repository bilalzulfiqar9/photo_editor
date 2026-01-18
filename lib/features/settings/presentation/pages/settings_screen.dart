import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
           GestureDetector(
            onTap: () {
              context.push('/pro');
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withAlpha(200),
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withAlpha(200),
                  ],
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
            child: Text('Version $_version', style: TextStyle(fontSize: 14)),
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
    final containerColor = Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.only(left: 8, right: 8),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).primaryColor),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
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
          color: Theme.of(context).primaryColor,
          size: 16,
        ),
      ),
    );
  }
}
