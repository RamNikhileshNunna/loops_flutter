import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:loops_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<UserModel?> build() async {
    return _fetchProfile();
  }

  Future<UserModel?> _fetchProfile() async {
    final authRepo = ref.read(authRepositoryProvider);
    return authRepo.getCurrentUser();
  }
}
