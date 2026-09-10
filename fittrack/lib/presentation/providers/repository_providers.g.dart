// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends
        $FunctionalProvider<IAuthRepository, IAuthRepository, IAuthRepository>
    with $Provider<IAuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<IAuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IAuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IAuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IAuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'7db7ee78ec52038fe814fbf89049e9f9f1c4469e';

@ProviderFor(userRepository)
final userRepositoryProvider = UserRepositoryProvider._();

final class UserRepositoryProvider
    extends
        $FunctionalProvider<IUserRepository, IUserRepository, IUserRepository>
    with $Provider<IUserRepository> {
  UserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRepositoryHash();

  @$internal
  @override
  $ProviderElement<IUserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IUserRepository create(Ref ref) {
    return userRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IUserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IUserRepository>(value),
    );
  }
}

String _$userRepositoryHash() => r'568d084ff40cfcde34fbcae41bd36cdbba5d1118';

@ProviderFor(scheduleRepository)
final scheduleRepositoryProvider = ScheduleRepositoryProvider._();

final class ScheduleRepositoryProvider
    extends
        $FunctionalProvider<
          IScheduleRepository,
          IScheduleRepository,
          IScheduleRepository
        >
    with $Provider<IScheduleRepository> {
  ScheduleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleRepositoryHash();

  @$internal
  @override
  $ProviderElement<IScheduleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IScheduleRepository create(Ref ref) {
    return scheduleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IScheduleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IScheduleRepository>(value),
    );
  }
}

String _$scheduleRepositoryHash() =>
    r'52bef6fbb736d77a29103b550f485b79709c0363';

@ProviderFor(workoutSessionRepository)
final workoutSessionRepositoryProvider = WorkoutSessionRepositoryProvider._();

final class WorkoutSessionRepositoryProvider
    extends
        $FunctionalProvider<
          IWorkoutSessionRepository,
          IWorkoutSessionRepository,
          IWorkoutSessionRepository
        >
    with $Provider<IWorkoutSessionRepository> {
  WorkoutSessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutSessionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutSessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<IWorkoutSessionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IWorkoutSessionRepository create(Ref ref) {
    return workoutSessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IWorkoutSessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IWorkoutSessionRepository>(value),
    );
  }
}

String _$workoutSessionRepositoryHash() =>
    r'9bd2e78bdc7f5efa09b43ff26e6a52b73ec74a1d';
