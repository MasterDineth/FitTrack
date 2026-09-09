import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../data/repositories/mock/mock_auth_repository.dart';
import '../../data/repositories/mock/mock_user_repository.dart';

part 'repository_providers.g.dart';

@riverpod
IAuthRepository authRepository(Ref ref) {
  return MockAuthRepository();
}

@riverpod
IUserRepository userRepository(Ref ref) {
  return MockUserRepository();
}
