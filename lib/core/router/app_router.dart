import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/pdf_viewer/presentation/pages/pdf_viewer_page.dart';
import '../../features/comparison/presentation/pages/comparison_page.dart';
import '../../features/insights/presentation/pages/insights_page.dart';
import '../../features/search/presentation/pages/search_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/pdf/:standardType',
        builder: (context, state) {
          final standardType = state.pathParameters['standardType']!;
          final page =
              int.tryParse(state.uri.queryParameters['page'] ?? '1') ?? 1;
          return PdfViewerPage(standardType: standardType, initialPage: page);
        },
      ),
      GoRoute(
        path: '/comparison',
        builder: (context, state) => const ComparisonPage(),
      ),
      GoRoute(
        path: '/comparison/:topicId',
        builder: (context, state) {
          final topicId = state.pathParameters['topicId']!;
          return ComparisonPage(selectedTopicId: topicId);
        },
      ),
      GoRoute(
        path: '/insights',
        builder: (context, state) => const InsightsPage(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          return SearchPage(initialQuery: query);
        },
      ),
    ],
  );
}
