import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/standards_repository.dart';
import '../models/standard.dart';
import '../models/topic.dart';
import '../models/comparison.dart';

// Repository provider
final standardsRepositoryProvider = Provider<StandardsRepository>((ref) {
  return StandardsRepository();
});

// Standards providers
final standardsProvider = FutureProvider<List<Standard>>((ref) async {
  final repository = ref.read(standardsRepositoryProvider);
  return repository.getStandards();
});

final topicsProvider = FutureProvider<List<Topic>>((ref) async {
  final repository = ref.read(standardsRepositoryProvider);
  return repository.getTopics();
});

final insightsProvider = FutureProvider<List<ComparisonInsight>>((ref) async {
  final repository = ref.read(standardsRepositoryProvider);
  return repository.getInsights();
});

// Topic by ID provider
final topicByIdProvider = FutureProvider.family<Topic?, String>((
    ref,
    id,
    ) async {
  final repository = ref.read(standardsRepositoryProvider);
  return repository.getTopicById(id);
});

// Search provider
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Topic>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final repository = ref.read(standardsRepositoryProvider);
  return repository.searchTopics(query);
});

// Selected topic provider for comparison
final selectedTopicProvider = StateProvider<String?>((ref) => null);

// Bookmarks provider
final bookmarksProvider =
StateNotifierProvider<BookmarksNotifier, List<String>>((ref) {
  return BookmarksNotifier();
});

class BookmarksNotifier extends StateNotifier<List<String>> {
  BookmarksNotifier() : super([]);

  void addBookmark(String topicId) {
    if (!state.contains(topicId)) {
      state = [...state, topicId];
    }
  }

  void removeBookmark(String topicId) {
    state = state.where((id) => id != topicId).toList();
  }

  void toggleBookmark(String topicId) {
    if (state.contains(topicId)) {
      removeBookmark(topicId);
    } else {
      addBookmark(topicId);
    }
  }

  bool isBookmarked(String topicId) {
    return state.contains(topicId);
  }
}
