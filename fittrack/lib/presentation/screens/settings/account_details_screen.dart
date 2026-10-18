import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fittrack/domain/entities/user_profile.dart';
import 'package:fittrack/presentation/providers/notifications_provider.dart';
import 'package:fittrack/presentation/providers/user_profile_provider.dart';
import 'package:fittrack/presentation/widgets/ambient_mesh_background.dart';
import 'package:fittrack/presentation/widgets/modals/discard_changes_dialog.dart';
import 'account_details/widgets/account_contact_section.dart';
import 'account_details/widgets/account_credentials_section.dart';
import 'account_details/widgets/account_floating_dock.dart';
import 'account_details/widgets/account_header.dart';
import 'account_details/widgets/account_hero_card.dart';
import 'account_details/widgets/account_personal_section.dart';
import 'account_details/widgets/account_profile_shortcut.dart';
import 'account_details/widgets/account_security_card.dart';

/// Redesigned FitTrack Account Details Screen.
///
/// Built strictly following the FitTrack Frosted Glass Design System.
/// Features:
/// - In-header dynamic island notifications & back navigation
/// - Profile identity hero card linking directly to Profile screen
/// - Personal section: Full Name & custom Date of Birth cylinder roller picker
/// - Contact section: Mobile number (+94) with 2FA verification & Address
/// - Locked section: Immutable username & verified email
/// - Password & Security navigation card
/// - Bottom shortcut linking to Athlete Profile
/// - Floating save and discard actions (strictly visible only when dirty)
/// - Discard confirmation dialog matching Create Schedule modal
/// - Real-time push to Notification Feed and in-header Dynamic Island
class AccountDetailsScreen extends ConsumerStatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  ConsumerState<AccountDetailsScreen> createState() =>
      _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends ConsumerState<AccountDetailsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;
  late final TextEditingController _addressController;

  bool _isPhoneVerified = false;
  String _initialName = '';
  String _initialPhone = '';
  String _initialDob = '';
  String _initialAddress = '';
  bool _initialPhoneVerified = false;

  bool _initialized = false;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
    _addressController = TextEditingController();

    _nameController.addListener(_checkDirtyState);
    _phoneController.addListener(_checkDirtyState);
    _dobController.addListener(_checkDirtyState);
    _addressController.addListener(_checkDirtyState);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _populateFromProfile(UserProfile profile) {
    if (_initialized) return;

    _initialName = profile.name.isNotEmpty ? profile.name : 'Dineth';
    _initialPhone = profile.phone ?? '77 123 4567';
    _initialDob = profile.dob ?? '14 Oct 2003';
    _initialAddress = profile.address ?? '742 Evergreen Terrace, Colombo';
    _initialPhoneVerified = profile.isPhoneVerified;

    _nameController.text = _initialName;
    _phoneController.text = _initialPhone;
    _dobController.text = _initialDob;
    _addressController.text = _initialAddress;
    _isPhoneVerified = _initialPhoneVerified;

    _initialized = true;
  }

  void _checkDirtyState() {
    final nameChanged = _nameController.text.trim() != _initialName.trim();
    final phoneChanged = _phoneController.text.trim() != _initialPhone.trim();
    final dobChanged = _dobController.text.trim() != _initialDob.trim();
    final addressChanged =
        _addressController.text.trim() != _initialAddress.trim();
    final phoneVerifiedChanged = _isPhoneVerified != _initialPhoneVerified;

    final dirty = nameChanged ||
        phoneChanged ||
        dobChanged ||
        addressChanged ||
        phoneVerifiedChanged;

    if (dirty != _isDirty) {
      setState(() {
        _isDirty = dirty;
      });
    }
  }

  void _verifyPhone() {
    setState(() {
      _isPhoneVerified = true;
      _checkDirtyState();
    });

    ref.read(notificationFeedProvider.notifier).pushNotification(
          type: FtNotificationType.habit,
          title: 'Mobile Verified:',
          body: '+94 ${_phoneController.text.trim()} linked to 2FA security.',
        );
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final dob = _dobController.text.trim();
    final address = _addressController.text.trim();

    await ref.read(userProfileProvider.notifier).updateProfileInfo(
          name: name.isNotEmpty ? name : null,
          phone: phone.isNotEmpty ? phone : null,
          dob: dob.isNotEmpty ? dob : null,
          address: address.isNotEmpty ? address : null,
          isPhoneVerified: _isPhoneVerified,
        );

    ref.read(notificationFeedProvider.notifier).pushNotification(
          type: FtNotificationType.habit,
          title: 'Account Synced:',
          body: 'Your personal information has been saved.',
        );

    if (!mounted) return;
    setState(() {
      _initialName = name;
      _initialPhone = phone;
      _initialDob = dob;
      _initialAddress = address;
      _initialPhoneVerified = _isPhoneVerified;
      _isDirty = false;
    });
  }

  Future<bool> _confirmDiscard() async {
    if (!_isDirty) return true;

    final confirmed = await DiscardChangesDialog.show(
      context,
      title: 'Discard personal edits?',
      message:
          'You have unsaved changes in your account details. Discarding will revert to your last saved state.',
    );

    if (confirmed) {
      setState(() {
        _nameController.text = _initialName;
        _phoneController.text = _initialPhone;
        _dobController.text = _initialDob;
        _addressController.text = _initialAddress;
        _isPhoneVerified = _initialPhoneVerified;
        _isDirty = false;
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
    final profile = userProfileAsync.value ??
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

    _populateFromProfile(profile);

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
                              AccountHeader(
                                onBackTap: _handleBackTap,
                              ),
                              const SizedBox(height: 10),

                              // 2. Profile Identity Hero Card (Navigates to Profile on tap)
                              AccountHeroCard(
                                profile: profile,
                                isDirty: _isDirty,
                                onEditPhoto: () {
                                  ref
                                      .read(userProfileProvider.notifier)
                                      .updateProfileImage();
                                },
                              ),
                              const SizedBox(height: 18),

                              // 3. Personal Section (Full Name, Date of Birth with Cylinder Picker)
                              AccountPersonalSection(
                                nameController: _nameController,
                                dobController: _dobController,
                                onNameChanged: (_) => _checkDirtyState(),
                                onDobChanged: (_) => _checkDirtyState(),
                              ),
                              const SizedBox(height: 18),

                              // 4. Contact Section (Phone +94 with Verification & Address)
                              AccountContactSection(
                                phoneController: _phoneController,
                                addressController: _addressController,
                                isPhoneVerified: _isPhoneVerified,
                                onVerifyPhone: _verifyPhone,
                                onPhoneChanged: (_) => _checkDirtyState(),
                                onAddressChanged: (_) => _checkDirtyState(),
                              ),
                              const SizedBox(height: 18),

                              // 5. Locked Credentials (Username & Email)
                              AccountCredentialsSection(
                                profile: profile,
                              ),
                              const SizedBox(height: 18),

                              // 6. Password & Security Navigation Tile
                              const AccountSecurityCard(),
                              const SizedBox(height: 14),

                              // 7. Athlete Profile Shortcut Tile
                              const AccountProfileShortcut(),
                              const SizedBox(height: 16),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 8. Sticky Floating Action Dock (Strictly visible only when dirty)
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.paddingOf(context).bottom + 12,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 393),
                    child: AccountFloatingDock(
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
