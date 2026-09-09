import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user.dart';
import 'repository_providers.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<User?> build() async {
    // Artificial delay to let the splash screen animations play out
    await Future.delayed(const Duration(seconds: 3));
    final authRepo = ref.watch(authRepositoryProvider);
    return await authRepo.getCurrentUser();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      return await authRepo.signInWithEmailAndPassword(email, password);
    });
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      return await authRepo.signUpWithEmailAndPassword(email, password);
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signOut();
      return null;
    });
  }
}
