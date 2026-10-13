import 'package:flutter/foundation.dart';

/// Controls whether debug sample telemetry data is provided when real health tracker is not connected.
const bool kUseTemplateSampleData = !kReleaseMode;

/// Staggered section entrance animations (fade + 12px slide up, once per app launch).
const bool kDashboardEntranceMotion = true;
