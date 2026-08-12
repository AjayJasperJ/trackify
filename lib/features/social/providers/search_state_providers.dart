import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'social_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  
  return ref.watch(publicProfileRepositoryProvider).searchUsers(query);
});
