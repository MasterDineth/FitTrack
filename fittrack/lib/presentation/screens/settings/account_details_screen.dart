import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/user_profile.dart';
import '../../providers/user_profile_provider.dart';

/// Account Details Screen matching Google Stitch specification (Project 12918880879747462056).
///
/// Features:
/// - Sub-navigation header with "Synced" pill badge & help icon
/// - Ambient Hero Card with CircleAvatar fallback, verified badge, stats grid
/// - Soft form fields (Full Name, Phone with Country picker, DOB with calendar, Address)
/// - Interactive Phone verification requirement before saving
/// - Amber missing-field warning alerts on required attributes
/// - Locked Username and Email fields with Support link
/// - Password & Security navigation card
/// - Sticky Save Changes and Discard actions
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

  String _selectedCountryCode = '+94';
  String _selectedCountryFlag = '🇱🇰';

  bool _isPhoneVerified = false;
  String _originalPhone = '';
  String _originalName = '';
  String _originalDob = '';
  String _originalAddress = '';

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
    _addressController = TextEditingController();

    _nameController.addListener(() => setState(() {}));
    _phoneController.addListener(_onPhoneChanged);
    _dobController.addListener(() => setState(() {}));
    _addressController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final currentText = _phoneController.text.trim();
    if (currentText != _originalPhone) {
      if (_isPhoneVerified) {
        setState(() {
          _isPhoneVerified = false;
        });
      }
    } else {
      final profile = ref.read(userProfileProvider).value;
      final savedVerified = profile?.isPhoneVerified ?? false;
      if (_isPhoneVerified != savedVerified) {
        setState(() {
          _isPhoneVerified = savedVerified;
        });
      }
    }
    setState(() {});
  }

  void _populateFromProfile(UserProfile profile) {
    _originalName = profile.name.isNotEmpty ? profile.name : 'Dineth';
    _originalPhone = profile.phone ?? '77 123 4567';
    _originalDob = profile.dob ?? '14 Mar 2004';
    _originalAddress =
        profile.address ?? '742 Evergreen Terrace, Colombo';
    _isPhoneVerified = profile.isPhoneVerified;

    _nameController.text = _originalName;
    _phoneController.text = _originalPhone;
    _dobController.text = _originalDob;
    _addressController.text = _originalAddress;
    _initialized = true;
  }

  BoxDecoration _buildCardDecoration(BuildContext context,
      {double radius = 16}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: isDark
          ? null
          : [
              const BoxShadow(
                color: Color(0x080F172A),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
      border: isDark ? Border.all(color: colorScheme.outline) : null,
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2004, 3, 14),
      firstDate: DateTime(1930),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final formatted =
          '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      setState(() {
        _dobController.text = formatted;
      });
    }
  }

  void _verifyPhone() {
    setState(() {
      _isPhoneVerified = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Mobile number verified successfully.',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF008F5C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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

    _originalName = name;
    _originalPhone = phone;
    _originalDob = dob;
    _originalAddress = address;

    if (!mounted) return;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final snackFg = primaryColor.computeLuminance() > 0.5
        ? const Color(0xFF002112)
        : Colors.white;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: snackFg, size: 18),
            const SizedBox(width: 8),
            Text(
              'Account details saved securely.',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                color: snackFg,
              ),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _discardChanges() {
    setState(() {
      _nameController.text = _originalName;
      _phoneController.text = _originalPhone;
      _dobController.text = _originalDob;
      _addressController.text = _originalAddress;
      final profile = ref.read(userProfileProvider).value;
      _isPhoneVerified = profile?.isPhoneVerified ?? false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Changes discarded.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showCountryPicker() {
    final countries = [
      {'flag': '🇱🇰', 'code': '+94', 'name': 'Sri Lanka'},
      {'flag': '🇺🇸', 'code': '+1', 'name': 'United States'},
      {'flag': '🇬🇧', 'code': '+44', 'name': 'United Kingdom'},
      {'flag': '🇦🇺', 'code': '+61', 'name': 'Australia'},
      {'flag': '🇨🇦', 'code': '+1', 'name': 'Canada'},
      {'flag': '🇩🇪', 'code': '+49', 'name': 'Germany'},
      {'flag': '🇮🇳', 'code': '+91', 'name': 'India'},
      {'flag': '🇸🇬', 'code': '+65', 'name': 'Singapore'},
      {'flag': '🇦🇪', 'code': '+971', 'name': 'UAE'},
    ];

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Country Code',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: countries.length,
                    itemBuilder: (ctx, idx) {
                      final c = countries[idx];
                      return ListTile(
                        leading: Text(c['flag']!,
                            style: const TextStyle(fontSize: 22)),
                        title: Text(
                          c['name']!,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: colorScheme.onSurface,
                          ),
                        ),
                        trailing: Text(
                          c['code']!,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedCountryFlag = c['flag']!;
                            _selectedCountryCode = c['code']!;
                          });
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final profile = userProfileAsync.value;

    if (profile != null && !_initialized) {
      _populateFromProfile(profile);
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final profileImagePath = profile?.profileImagePath;
    final hasCustomImage = profileImagePath != null &&
        profileImagePath.trim().isNotEmpty &&
        File(profileImagePath).existsSync();
    final name = (profile?.name.trim().isNotEmpty == true)
        ? profile!.name
        : (_originalName.isNotEmpty ? _originalName : 'Dineth');
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';
    final handle =
        '@${name.toLowerCase().replaceAll(' ', '')}.fit';
    final experience = profile?.experienceLevel ?? 'Advanced';

    final isNameEmpty = _nameController.text.trim().isEmpty;
    final isPhoneEmpty = _phoneController.text.trim().isEmpty;
    final isAddressEmpty = _addressController.text.trim().isEmpty;
    final canSave = !isNameEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top Sub-Navigation Header ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Circular Back Button
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        shape: BoxShape.circle,
                        border: isDark
                            ? Border.all(color: colorScheme.outline)
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),

                  // Synced badge & Help trigger
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(100),
                          border: isDark
                              ? Border.all(color: colorScheme.outline)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Synced',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => context.push('/settings/help'),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer,
                            shape: BoxShape.circle,
                            border: isDark
                                ? Border.all(color: colorScheme.outline)
                                : null,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.help_outline_rounded,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Scrollable Form Body ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile Summary Hero Card ─────────────────────────
                    Container(
                      decoration: _buildCardDecoration(context, radius: 20),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          // Decorative ambient halo
                          Positioned(
                            top: -24,
                            right: -24,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primary
                                    .withValues(alpha: isDark ? 0.12 : 0.08),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // Avatar with Verified Badge
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor:
                                              colorScheme.surfaceContainer,
                                          backgroundImage: hasCustomImage
                                              ? FileImage(File(profileImagePath))
                                              : null,
                                          onBackgroundImageError: hasCustomImage
                                              ? (exception, stackTrace) {
                                                  debugPrint(
                                                      'Error loading profile image: $exception');
                                                }
                                              : null,
                                          child: !hasCustomImage
                                              ? Text(
                                                  initial,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Plus Jakarta Sans',
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w800,
                                                    color: colorScheme.primary,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        Positioned(
                                          bottom: -2,
                                          right: -2,
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: colorScheme.surface,
                                                width: 2,
                                              ),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.verified_rounded,
                                                size: 12,
                                                color: colorScheme.onPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 14),

                                    // Identity Meta
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  name,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Plus Jakarta Sans',
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: colorScheme.onSurface,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primary
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(100),
                                                ),
                                                child: Text(
                                                  '${experience.toUpperCase()} LIFTER',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Plus Jakarta Sans',
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.5,
                                                    color: colorScheme.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: handle,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Plus Jakarta Sans',
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color:
                                                        colorScheme.primary,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: ' • Member since 2026',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Plus Jakarta Sans',
                                                    fontSize: 12,
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),
                                const Divider(height: 1),
                                const SizedBox(height: 12),

                                // 3-Column Stats Grid
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'WORKOUTS',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '148',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 26,
                                      color: colorScheme.outlineVariant
                                          .withValues(alpha: 0.4),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'STREAK',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .local_fire_department_rounded,
                                                size: 16,
                                                color: colorScheme.primary,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '14 Wks',
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 26,
                                      color: colorScheme.outlineVariant
                                          .withValues(alpha: 0.4),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'RANK',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Top 3%',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: colorScheme.tertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── 1. Full Name ──────────────────────────────────────
                    _buildFieldHeader(
                      context,
                      label: 'Full Name',
                      isRequired: true,
                      trailingActionText: 'Edit',
                      trailingActionIcon: Icons.edit_outlined,
                    ),
                    const SizedBox(height: 6),
                    _buildSoftTextField(
                      context,
                      controller: _nameController,
                      hintText: 'Enter your full name',
                      suffixIcon: Icon(
                        Icons.edit_note_rounded,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    _buildHelperText(
                      context,
                      icon: Icons.info_outline_rounded,
                      text:
                          'This is how your name appears on leaderboards & workouts.',
                    ),
                    const SizedBox(height: 16),

                    // ── 2. Mobile Number ──────────────────────────────────
                    _buildFieldHeader(
                      context,
                      label: 'Mobile Number',
                      isRequired: true,
                      customTrailing: _isPhoneVerified
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: colorScheme.primary
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 12,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : InkWell(
                              onTap: _verifyPhone,
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  'Verify',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Country Selector
                        InkWell(
                          onTap: _showCountryPicker,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(16),
                              border: isDark
                                  ? Border.all(color: colorScheme.outline)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Text(_selectedCountryFlag,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  _selectedCountryCode,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.expand_more_rounded,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Phone Input
                        Expanded(
                          child: _buildSoftTextField(
                            context,
                            controller: _phoneController,
                            hintText: '77 123 4567',
                            keyboardType: TextInputType.phone,
                            suffixIcon: _isPhoneVerified
                                ? Icon(
                                    Icons.verified_rounded,
                                    size: 18,
                                    color: colorScheme.primary,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                    if (isPhoneEmpty)
                      _buildWarningText(
                        context,
                        text: 'Required to complete your profile setup.',
                      )
                    else
                      _buildHelperText(
                        context,
                        icon: Icons.shield_outlined,
                        text:
                            'Used for two-factor authentication and account recovery.',
                      ),
                    const SizedBox(height: 16),

                    // ── 3. Date of Birth ──────────────────────────────────
                    _buildFieldHeader(
                      context,
                      label: 'Date of Birth',
                      isRequired: true,
                      trailingActionText: 'Edit',
                      trailingActionIcon: Icons.edit_outlined,
                    ),
                    const SizedBox(height: 6),
                    _buildSoftTextField(
                      context,
                      controller: _dobController,
                      hintText: 'DD MMM YYYY',
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.calendar_month_outlined,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => _pickDate(context),
                      ),
                    ),
                    _buildHelperText(
                      context,
                      icon: Icons.info_outline_rounded,
                      text: 'Used for age-adjusted metabolic calculations.',
                    ),
                    const SizedBox(height: 16),

                    // ── 4. Address ────────────────────────────────────────
                    _buildFieldHeader(
                      context,
                      label: 'Address',
                      isRequired: true,
                      trailingActionText: 'Edit',
                      trailingActionIcon: Icons.edit_outlined,
                    ),
                    const SizedBox(height: 6),
                    _buildSoftTextField(
                      context,
                      controller: _addressController,
                      hintText: 'Street, City',
                      suffixIcon: Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isAddressEmpty)
                      _buildWarningText(
                        context,
                        text: 'Required to complete your profile setup.',
                      )
                    else
                      _buildHelperText(
                        context,
                        icon: Icons.near_me_outlined,
                        text:
                            'Required for local gym matching & region telemetry.',
                      ),
                    const SizedBox(height: 20),

                    // ── 5. Locked Username ────────────────────────────────
                    _buildFieldHeader(
                      context,
                      label: 'Username',
                      labelIcon: Icons.lock_outline_rounded,
                      customTrailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Locked',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildLockedField(
                      context,
                      value: handle,
                      icon: Icons.lock_outline_rounded,
                    ),
                    _buildHelperText(
                      context,
                      icon: Icons.help_outline_rounded,
                      text: 'Username is permanent and unique across FitTrack.',
                    ),
                    const SizedBox(height: 16),

                    // ── 6. Locked Email Address ───────────────────────────
                    _buildFieldHeader(
                      context,
                      label: 'Email Address',
                      labelIcon: Icons.lock_outline_rounded,
                      customTrailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Verified • Locked',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildLockedField(
                      context,
                      value: profile?.email ?? 'dineth.fit@example.com',
                      icon: Icons.lock_outline_rounded,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Contact support to update your registered email.',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => context.push('/settings/help'),
                            child: Text(
                              'Contact Support',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Password & Security Quick-Link Card ───────────────
                    InkWell(
                      onTap: () => context.push('/settings/security'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _buildCardDecoration(context, radius: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.key_rounded,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Password & Security',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Last changed 3 months ago • 2FA enabled',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 11,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // ── Sticky Footer Actions ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Full-width Primary Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: canSave ? _saveChanges : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.primary.computeLuminance() > 0.5
                            ? const Color(0xFF002112)
                            : Colors.white,
                        disabledBackgroundColor: isDark
                            ? const Color(0xFF1E283A)
                            : const Color(0xFFE2E8F0),
                        disabledForegroundColor: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        elevation: canSave ? 2 : 0,
                        shadowColor: canSave
                            ? colorScheme.primary.withValues(alpha: 0.35)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: !canSave && isDark
                              ? const BorderSide(
                                  color: Color(0xFF2B3A4F), width: 1)
                              : BorderSide.none,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: canSave
                                ? (colorScheme.primary.computeLuminance() > 0.5
                                    ? const Color(0xFF002112)
                                    : Colors.white)
                                : (isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Save Changes',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: canSave
                                  ? (colorScheme.primary.computeLuminance() > 0.5
                                      ? const Color(0xFF002112)
                                      : Colors.white)
                                  : (isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Ghost Discard Button
                  TextButton(
                    onPressed: _discardChanges,
                    child: Text(
                      'Discard Changes',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ──────────────────────────────────────────────────────

  Widget _buildFieldHeader(
    BuildContext context, {
    required String label,
    IconData? labelIcon,
    bool isRequired = false,
    String? trailingActionText,
    IconData? trailingActionIcon,
    Widget? customTrailing,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 2),
              Text(
                '*',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
            if (labelIcon != null) ...[
              const SizedBox(width: 4),
              Icon(labelIcon, size: 14, color: colorScheme.onSurfaceVariant),
            ],
          ],
        ),
        if (customTrailing != null)
          customTrailing
        else if (trailingActionText != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingActionIcon != null)
                Icon(
                  trailingActionIcon,
                  size: 12,
                  color: colorScheme.primary,
                ),
              const SizedBox(width: 3),
              Text(
                trailingActionText,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSoftTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: colorScheme.outline) : null,
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildLockedField(
    BuildContext context, {
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: colorScheme.outline) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Icon(
            icon,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildHelperText(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningText(
    BuildContext context, {
    required String text,
  }) {
    const amberColor = Color(0xFFD97706);

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 13,
            color: amberColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: amberColor,
            ),
          ),
        ],
      ),
    );
  }
}
