/**
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:outdoor_therapy/features/views/auth/sign_in_screen.dart';
import 'package:outdoor_therapy/features/views/menu/profile/profile_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _notificationsEnabled = false;
  String _sleepTimer = 'Off';

  final List<String> _sleepTimerOptions = [
    'Off', '15 min', '30 min', '45 min', '60 min',
  ];

  void _showSleepTimerPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sleep Timer',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ..._sleepTimerOptions.map((opt) => ListTile(
            title: Text(opt, style: const TextStyle(color: Colors.white, fontSize: 15)),
            trailing: _sleepTimer == opt
                ? const Icon(Icons.check, color: Color(0xFF6C5ECF))
                : null,
            onTap: () {
              setState(() => _sleepTimer = opt);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── Header ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your account, preferences, and app features.',
                      style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Profile card ─────────────────────────────────────────────
            SliverToBoxAdapter(child: _ProfileCard()),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── App Settings ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _SectionHeader(title: 'App Settings')),
            SliverToBoxAdapter(
              child: _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.timer_outlined,
                    title: 'Default Sleep Timer',
                    subtitle: 'Set A Timer To Stop Audio Automatically.',
                    trailing: GestureDetector(
                      onTap: _showSleepTimerPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2538),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _sleepTimer,
                              style: const TextStyle(
                                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.check, size: 14, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Get All Kinds Of Notification',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (val) => setState(() => _notificationsEnabled = val),
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF6C5ECF),
                      inactiveThumbColor: Colors.white70,
                      inactiveTrackColor: const Color(0xFF2A3047),
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── General ───────────────────────────────────────────────────
            SliverToBoxAdapter(child: _SectionHeader(title: 'General')),
            SliverToBoxAdapter(
              child: _SettingsGroup(
                children: [
                  _SettingsTile(
                    svgPath: 'assets/icons/subscription.svg',   // ← SVG
                    title: 'Subscription',
                    subtitle: 'View Or Upgrade Your Premium Subscription.',
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 22),
                    onTap: () {},
                  ),
                  const _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.shield_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Learn How We Protect Your Data.',
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 22),
                    onTap: () {},
                  ),
                  const _SettingsDivider(),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Review The App Terms And Conditions.',
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 22),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── Logout ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _LogoutButton(),
              ),
            ),

            // ── Version ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    Text('Version 1.0.0',
                        style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 2),
                    Text('© 2026 DreamScape',
                        style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 160)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Profile card
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(()=>ProfileScreen());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF131929),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 54, height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.5),
                image: const DecorationImage(
                  image: AssetImage('assets/images/demo_user.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('John Doe',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('John@Example.Com',
                      style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      SvgPicture.asset('assets/icons/premium.svg', width: 15, height: 15),
                      const SizedBox(width: 5),
                      Text('Premium Member',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 12, fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Section header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(title,
          style: const TextStyle(
            color: Colors.white, fontSize: 20,
            fontWeight: FontWeight.w700, letterSpacing: -0.3,
          )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Settings group
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF131929),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: Column(children: children),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Settings tile — accepts IconData OR svgPath (both optional, one required)
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData? icon;       // Material icon
  final String? svgPath;      // Path to SVG asset  ← new
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    this.icon,
    this.svgPath,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  }) : assert(icon != null || svgPath != null,
  '_SettingsTile requires either icon or svgPath');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // ── Icon / SVG badge ─────────────────────────────────────
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
              child: Center(
                child: svgPath != null
                    ? SvgPicture.asset(
                  svgPath!,
                  width: 18, height: 18,
                  colorFilter: const ColorFilter.mode(
                    Colors.white70, BlendMode.srcIn,
                  ),
                )
                    : Icon(icon, size: 18, color: Colors.white70),
              ),
            ),
            const SizedBox(width: 14),
            // ── Text ─────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 12, height: 1.3,
                      )),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Divider
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1, thickness: 0.5,
      color: Colors.white.withOpacity(0.07),
      indent: 68, endIndent: 0,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Logout button
// ─────────────────────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.offAll(()=> SignInScreen());
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF131929),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        ),
        child: const Text(
          'Logout',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.redAccent, fontSize: 15,
            fontWeight: FontWeight.w600, letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}*/






///
///
///
/// todo:: integrating api
///
///
///
///




import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:outdoor_therapy/features/views/auth/sign_in_screen.dart';
import 'package:outdoor_therapy/features/views/menu/profile/profile_screen.dart';
import 'controller/menu_screen_controller.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final MenuScreenController controller = Get.put(MenuScreenController());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshProfile,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ───────────────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage your account, preferences, and app features.',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ── Profile card (with real data) ─────────────────────────────
              // Wrap only the dynamic part in Obx, not the entire card
              SliverToBoxAdapter(
                child: Obx(() => _buildProfileCard(controller)),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── App Settings ──────────────────────────────────────────────
              const SliverToBoxAdapter(child: _SectionHeader(title: 'App Settings')),
              SliverToBoxAdapter(
                child: _SettingsGroup(
                  children: [
                    // Sleep Timer - Only wrap the trailing text in Obx
                    _SettingsTile(
                      icon: Icons.timer_outlined,
                      title: 'Default Sleep Timer',
                      subtitle: 'Set A Timer To Stop Audio Automatically.',
                      trailing: Obx(() => GestureDetector(
                        onTap: () => controller.showSleepTimerPicker(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2538),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12, width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                controller.sleepTimer.value,
                                style: const TextStyle(
                                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right, size: 14, color: Colors.white70),
                            ],
                          ),
                        ),
                      )),
                    ),
                    const _SettingsDivider(),
                    // Notifications - Only wrap the Switch in Obx
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Get All Kinds Of Notification',
                      trailing: Obx(() => Switch(
                        value: controller.notificationsEnabled.value,
                        onChanged: controller.toggleNotifications,
                        activeColor: Colors.white,
                        activeTrackColor: const Color(0xFF6C5ECF),
                        inactiveThumbColor: Colors.white70,
                        inactiveTrackColor: const Color(0xFF2A3047),
                      )),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── General ───────────────────────────────────────────────────
              const SliverToBoxAdapter(child: _SectionHeader(title: 'General')),
              SliverToBoxAdapter(
                child: _SettingsGroup(
                  children: [
                    // Subscription - Wrap only the dynamic subtitle in Obx
                    Obx(() => _SettingsTile(
                      svgPath: controller.isPremium()
                          ? 'assets/icons/premium.svg'
                          : 'assets/icons/subscription.svg',
                      title: 'Subscription',
                      subtitle: controller.isPremium()
                          ? 'You are a premium member'
                          : 'Upgrade to premium for more features',
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 22),
                      onTap: () {
                        Get.snackbar(
                          'Coming Soon',
                          'Subscription feature coming soon',
                          backgroundColor: const Color(0xFF6C5ECF),
                          colorText: Colors.white,
                        );
                      },
                    )),
                    const _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'Learn How We Protect Your Data.',
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 22),
                      onTap: () {
                        Get.snackbar(
                          'Coming Soon',
                          'Privacy Policy feature coming soon',
                          backgroundColor: const Color(0xFF6C5ECF),
                          colorText: Colors.white,
                        );
                      },
                    ),
                    const _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'Review The App Terms And Conditions.',
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 22),
                      onTap: () {
                        Get.snackbar(
                          'Coming Soon',
                          'Terms of Service feature coming soon',
                          backgroundColor: const Color(0xFF6C5ECF),
                          colorText: Colors.white,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── Logout ────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _LogoutButton(controller: controller),
                ),
              ),

              // ── Version ───────────────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: [
                      Text('Version 1.0.0',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                          textAlign: TextAlign.center),
                      SizedBox(height: 2),
                      Text('© 2026 DreamScape',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 160)),
            ],
          ),
        ),
      ),
    );
  }

  // Separate method to build profile card to avoid nested Obx
  Widget _buildProfileCard(MenuScreenController controller) {
    // Loading state
    if (controller.isLoading.value && controller.userData.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF131929),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 54, height: 54,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6C5ECF)),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loading...', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Error state
    if (controller.errorMessage.isNotEmpty && controller.userData.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF131929),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(controller.errorMessage.value, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => controller.refreshProfile(),
                    child: const Text('Tap to retry', style: TextStyle(color: Color(0xFF6C5ECF))),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Profile data loaded
    return GestureDetector(
      onTap: () {
        Get.to(() => const ProfileScreen());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF131929),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        ),
        child: Row(
          children: [
            // Profile image
            Container(
              width: 54, height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(27),
                child: controller.getProfileImage().isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: controller.getProfileImage(),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.white10,
                    child: const Icon(Icons.person, color: Colors.white54, size: 30),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.white10,
                    child: const Icon(Icons.person, color: Colors.white54, size: 30),
                  ),
                )
                    : Container(
                  color: Colors.white10,
                  child: const Icon(Icons.person, color: Colors.white54, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.getFullName(),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.getEmail(),
                    style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      SvgPicture.asset(
                        controller.isPremium() ? 'assets/icons/premium.svg' : 'assets/icons/free.svg',
                        width: 15, height: 15,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        controller.getUserType(),
                        style: TextStyle(
                          color: controller.isPremium()
                              ? Colors.amber.withOpacity(0.8)
                              : Colors.white.withOpacity(0.65),
                          fontSize: 12, fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // if (controller.getMemberSince().isNotEmpty) ...[
                  //   const SizedBox(height: 4),
                  //   Text(
                  //     controller.getMemberSince(),
                  //     style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 10),
                  //   ),
                  // ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Logout button with controller ────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final MenuScreenController controller;

  const _LogoutButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Show confirmation dialog
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF131929),
            title: const Text('Logout', style: TextStyle(color: Colors.white)),
            content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Get.offAll(()=>SignInScreen()),
                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await controller.logout();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF131929),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        ),
        child: const Text(
          'Logout',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.redAccent, fontSize: 15,
            fontWeight: FontWeight.w600, letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

// ── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(title,
          style: const TextStyle(
            color: Colors.white, fontSize: 20,
            fontWeight: FontWeight.w700, letterSpacing: -0.3,
          )),
    );
  }
}

// ── Settings group ───────────────────────────────────────────────────────────
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF131929),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: Column(children: children),
    );
  }
}

// ── Settings tile ────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    this.icon,
    this.svgPath,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  }) : assert(icon != null || svgPath != null,
  '_SettingsTile requires either icon or svgPath');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon / SVG badge
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
              child: Center(
                child: svgPath != null
                    ? SvgPicture.asset(
                  svgPath!,
                  width: 18, height: 18,
                  colorFilter: const ColorFilter.mode(
                    Colors.white70, BlendMode.srcIn,
                  ),
                )
                    : Icon(icon, size: 18, color: Colors.white70),
              ),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 12, height: 1.3,
                      )),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      ),
    );
  }
}

// ── Settings divider ──────────────────────────────────────────────────────────
class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1, thickness: 0.5,
      color: Colors.white.withOpacity(0.07),
      indent: 68, endIndent: 0,
    );
  }
}