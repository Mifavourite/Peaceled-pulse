import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'detection_screen.dart';
import 'values_screen.dart';
import 'victory_log_screen.dart';
import 'chat_screen.dart';
import 'security_test_screen.dart';
import 'feedback_screen.dart';
import 'settings_screen.dart';
import 'emergency_support_screen.dart';
import 'daily_checkin_screen.dart';
import 'schedule_screen.dart';
import 'journal_screen.dart';
import 'goals_screen.dart';
import 'prayer_timer_screen.dart';
import 'progress_analytics_screen.dart';
import 'resources_screen.dart';

/// Home Screen with navigation to main features
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ScheduleScreen(),
    const DetectionScreen(),
    const ValuesScreen(),
    const VictoryLogScreen(),
    const ChatScreen(),
  ];
  
  // Additional screens accessible from menu
  void _navigateToScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Peaceled Pulse',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          // Emergency button (always visible)
          IconButton(
            icon: const Icon(Icons.phone_in_talk, color: Colors.red),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EmergencySupportScreen(),
                ),
              );
            },
            tooltip: 'Emergency Support',
          ),
          // More menu
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'journal',
                child: ListTile(
                  leading: Icon(Icons.book),
                  title: Text('Journal'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'goals',
                child: ListTile(
                  leading: Icon(Icons.flag),
                  title: Text('Goals'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'prayer',
                child: ListTile(
                  leading: Icon(Icons.self_improvement),
                  title: Text('Prayer Timer'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'analytics',
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('Progress Analytics'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'resources',
                child: ListTile(
                  leading: Icon(Icons.library_books),
                  title: Text('Resources'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'journal':
                  _navigateToScreen(const JournalScreen());
                  break;
                case 'goals':
                  _navigateToScreen(const GoalsScreen());
                  break;
                case 'prayer':
                  _navigateToScreen(const PrayerTimerScreen());
                  break;
                case 'analytics':
                  _navigateToScreen(const ProgressAnalyticsScreen());
                  break;
                case 'resources':
                  _navigateToScreen(const ResourcesScreen());
                  break;
                case 'settings':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                  break;
              }
            },
          ),
          // Beta feedback button
          IconButton(
            icon: const Icon(Icons.feedback),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FeedbackScreen(),
                ),
              );
            },
            tooltip: 'Beta Feedback',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Detection',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Values',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.celebration),
            label: 'Victory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
