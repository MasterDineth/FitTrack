import 'package:flutter/material.dart';

import 'settings/widgets/athlete_profile_hero_card.dart';
import 'settings/widgets/settings_header.dart';
import 'settings/widgets/settings_logout_button.dart';
import 'settings/widgets/settings_search_bar.dart';
import 'settings/widgets/settings_sections_list.dart';

/// Rebuilt FitTrack Settings Screen – Tab Index 3 of the main navigation dock.
///
/// Implemented strictly adhering to Google Stitch design ID 1b6cb97ed1144c0f8365f5ab895964e0:
/// - Luminous frosted glass surfaces with dynamic theme and accent extraction
/// - UI consistency with Dashboard (top right frosted notification bell + athlete avatar)
/// - Athlete Profile Hero Card with verified emerald checkmark and experience badge
/// - 4 grouped sections with real-time quick preview metrics
/// - Full-width secondary rose Log Out button with confirmation dialog
/// - Zero per-card blur overhead for maximum scrolling frame rates
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dock clearance calculation: bottom inset + dock height padding
    final bottomPadding = (MediaQuery.paddingOf(context).bottom > 0)
        ? MediaQuery.paddingOf(context).bottom + 20.0
        : 96.0;

    final isSearching = _searchQuery.trim().isNotEmpty;
    final showProfileHero = !isSearching ||
        'profile'.contains(_searchQuery.trim().toLowerCase()) ||
        'account'.contains(_searchQuery.trim().toLowerCase());
    final showLogout = !isSearching ||
        'log out'.contains(_searchQuery.trim().toLowerCase()) ||
        'logout'.contains(_searchQuery.trim().toLowerCase());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverSafeArea(
                top: true,
                bottom: false,
                sliver: SliverPadding(
                  padding: EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top: 6.0,
                    bottom: bottomPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // 1. Top Header (Settings title + Notification bell + Avatar)
                      const SettingsHeader(),

                      // 2. Search Bar
                      SettingsSearchBar(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        onClear: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),

                      // 3. Athlete Profile Banner Card
                      if (showProfileHero) const AthleteProfileHeroCard(),

                      // 4. 4 Grouped Sections with live previews & search filter
                      SettingsSectionsList(searchQuery: _searchQuery),

                      // 5. Destructive Log Out Action Button
                      if (showLogout) const SettingsLogoutButton(),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
