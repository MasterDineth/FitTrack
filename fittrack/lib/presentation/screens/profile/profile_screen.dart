import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fittrack/domain/entities/user_profile.dart';
import 'package:fittrack/presentation/providers/notifications_provider.dart';
import 'package:fittrack/presentation/providers/repository_providers.dart';
import 'package:fittrack/presentation/providers/user_profile_provider.dart';
import 'package:fittrack/presentation/providers/workout_logic_providers.dart';
import 'package:fittrack/presentation/widgets/ambient_mesh_background.dart';
import 'package:fittrack/presentation/widgets/modals/discard_changes_dialog.dart';
import 'widgets/profile_action_dock.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_hero_section.dart';
import 'widgets/profile_logout_section.dart';
import 'widgets/profile_personal_info_section.dart';
import 'widgets/profile_settings_links.dart';
import 'widgets/profile_stats_bento.dart';

/// Redesigned FitTrack Athlete Profile Screen.
///
/// Built strictly following the FitTrack Frosted Glass Design System.
/// Features:
/// - In-header dynamic island notifications & back navigation
/// - Athlete Hero Section with avatar upload & dynamic tier badge
/// - Bento Grid of 4 Key Monthly Metrics + dynamic BMI
/// - Editable Personal Info (Weight, Height, Experience, Goal, Weekly Target)
///   without Name and DOB (moved to Account Details)
/// - Sticky frosted save & discard dock that appears upon editing
/// - Discard confirmation dialog matching Create Schedule modal
/// - Real-time push to Notification Feed and in-header Dynamic Island
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  UserProfile? _draftProfile;
  bool _isDirty = false;

  void _onProfileFieldChanged(UserProfile updated) {
    setState(() {
      _draftProfile = updated;
      _isDirty = true;
    });
  }

  Future<void> _saveChanges() async {
    if (_draftProfile == null) return;

    await ref.read(userProfileProvider.notifier).updateField(
          weightKg: _draftProfile!.weightKg,
          heightCm: _draftProfile!.heightCm,
          experienceLevel: _draftProfile!.experienceLevel,
          primaryGoal: _draftProfile!.primaryGoal,
          weeklyTargetDays: _draftProfile!.weeklyTargetDays,
        );

    ref.read(notificationFeedProvider.notifier).pushNotification(
          type: FtNotificationType.habit,
          title: 'Profile Updated:',
          body: 'Your athlete preferences have been saved.',
        );

    if (!mounted) return;
    setState(() {
      _isDirty = false;
      _draftProfile = null;
    });
  }

  Future<bool> _confirmDiscard() async {
    if (!_isDirty) return true;

    final confirmed = await DiscardChangesDialog.show(
      context,
      title: 'Discard profile edits?',
      message:
          'You have unsaved changes in your profile. Discarding will revert to your last saved state.',
    );

    if (confirmed) {
      setState(() {
        _isDirty = false;
        _draftProfile = null;
      });
      return true;
    }
    return false;
  }

  void _handleBackTap() async {
    if (_isDirty) {
      final shouldPop = await _confirmDiscard();
      if (shouldPop && mounted) {
        context.pop();
      }
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final sessionRepo = ref.watch(workoutSessionRepositoryProvider);
    final metricsAsync = ref.watch(dashboardMetricsProvider(sessionRepo));

    final baseProfile = userProfileAsync.value ??
        const UserProfile(
          id: '1',
          name: 'Dineth',
          age: 22,
          weightKg: 76.5,
          heightCm: 178.0,
          experienceLevel: 'Advanced',
          primaryGoal: 'Pure strength (powerlifting)',
          weeklyTargetDays: 3,
        );

    final activeProfile = _draftProfile ?? baseProfile;
    final metrics = metricsAsync.value;
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 32.0;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _confirmDiscard();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AmbientMeshBackground(
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 393),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverSafeArea(
                        top: true,
                        bottom: false,
                        sliver: SliverPadding(
                          padding: EdgeInsets.only(
                            left: 18.0,
                            right: 18.0,
                            top: 4.0,
                            bottom: _isDirty ? 110.0 : bottomPadding,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate.fixed([
                              // 1. Top Header with Back button & Dynamic Island Bell
                              ProfileHeader(
                                onBackTap: _handleBackTap,
                              ),
                              const SizedBox(height: 8),

                              // 2. Athlete Hero Portrait & Badges
                              ProfileHeroSection(
                                profile: activeProfile,
                                onEditPhoto: () {
                                  ref
                                      .read(userProfileProvider.notifier)
                                      .updateProfileImage();
                                },
                              ),
                              const SizedBox(height: 20),

                              // 3. Bento Grid of 4 Key Metrics + BMI
                              ProfileStatsBento(
                                profile: activeProfile,
                                metrics: metrics,
                              ),
                              const SizedBox(height: 20),

                              // 4. Personal Info Section (Weight, Height, Exp, Goal, Target)
                              ProfilePersonalInfoSection(
                                profile: activeProfile,
                                onProfileChanged: _onProfileFieldChanged,
                              ),
                              const SizedBox(height: 20),

                              // 5. Settings & Preferences (3 Curated Links)
                              const ProfileSettingsLinks(),
                              const SizedBox(height: 24),

                              // 6. Sign Out Button & Version Footer
                              const ProfileLogoutSection(),
                              const SizedBox(height: 12),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 7. Sticky Floating Action Dock (Visible only when modified)
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.paddingOf(context).bottom + 12,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 393),
                    child: ProfileActionDock(
                      isVisible: _isDirty,
                      onSave: _saveChanges,
                      onDiscard: () async {
                        await _confirmDiscard();
                      },
                    ),
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
