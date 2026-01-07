import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:loops_flutter/features/profile/domain/models/user_model.dart';
import 'package:loops_flutter/features/profile/data/repositories/profile_repository_impl.dart';

part 'relationship_controller.g.dart';

@riverpod
Future<List<UserModel>> followers(Ref ref, String userId) {
  return ref.watch(profileRepositoryProvider).getFollowers(userId);
}

@riverpod
Future<List<UserModel>> following(Ref ref, String userId) {
  return ref.watch(profileRepositoryProvider).getFollowing(userId);
}
