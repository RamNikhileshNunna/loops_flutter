import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'features/feed/presentation/screens/feed_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/explore/presentation/screens/explore_screen.dart';
import 'features/activity/presentation/screens/activity_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/feed/data/repositories/video_upload_repository_impl.dart';
import 'package:dio/dio.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final List<int> _history = [];
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndexIsolate();
  }

  void _updateIndexIsolate() {
    final location = GoRouterState.of(context).uri.toString();
    int newIndex = 0;
    if (location.startsWith('/explore')) {
      newIndex = 1;
    } else if (location.startsWith('/activity')) {
      newIndex = 3;
    } else if (location.startsWith('/profile')) {
      newIndex = 4;
    }

    // Create history entry if it's a new visit (not just a rebuild)
    // We check if the newIndex is different from the last history item.
    if (_history.isEmpty || _history.last != newIndex) {
      _history.add(newIndex);
    }

    // Keep history manageable
    if (_history.length > 10) {
      _history.removeAt(0);
    }

    _currentIndex = newIndex;
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        _pickAndUpload(context, ref);
        return;
      case 3:
        context.go('/activity');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final messenger = ScaffoldMessenger.of(context);

    final XFile? picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    String? caption;
    if (context.mounted) {
      caption = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('Add a caption'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Optional caption'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Skip'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
                child: const Text('Upload'),
              ),
            ],
          );
        },
      );
    }

    if (!context.mounted) return;
    final repo = ref.read(videoUploadRepositoryProvider);

    final progress = ValueNotifier<double?>(0);
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => ValueListenableBuilder<double?>(
          valueListenable: progress,
          builder: (ctx, value, child) {
            final display = value != null
                ? (value * 100).clamp(0, 100).toStringAsFixed(0)
                : '--';
            return AlertDialog(
              backgroundColor: Colors.black87,
              title: const Text(
                'Uploading...',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: value,
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$display%',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    try {
      await repo.uploadVideo(
        file: picked,
        caption: caption,
        onProgress: (sent, total) {
          if (total > 0) {
            progress.value = sent / total;
          }
        },
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // close progress dialog
        messenger.showSnackBar(
          const SnackBar(content: Text('Upload complete')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // close progress dialog
        String message = 'Upload failed';
        if (e is DioException) {
          message += ': ${e.response?.statusMessage ?? e.message}';
          if (e.response?.data != null) {
            message += ' ${e.response?.data}';
          }
        } else {
          message += ': $e';
        }
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPopInternal = _history.length > 1;

    return PopScope(
      canPop: !canPopInternal,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        setState(() {
          _history.removeLast();
        });

        final prevIndex = _history.last;

        switch (prevIndex) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/explore');
            break;
          case 3:
            context.go('/activity');
            break;
          case 4:
            context.go('/profile');
            break;
        }
      },
      child: Scaffold(
        body: widget.child,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          onPressed: () => _pickAndUpload(context, ref),
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Upload',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Activity',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(StorageService(prefs)),
      ],
      child: const LoopsApp(),
    ),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final authRepo = ref.read(authRepositoryProvider);
      final isAuthenticated = await authRepo.isAuthenticated();
      final isLoginPage = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoginPage) {
        return '/login';
      }

      if (isAuthenticated && isLoginPage) {
        return '/';
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const FeedScreen()),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/activity',
            builder: (context, state) => const ActivityScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ],
  );
});

class LoopsApp extends ConsumerWidget {
  const LoopsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Loops Expo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Force dark for now
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
