import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/destination_screen.dart';
import 'screens/chat_rooms_screen.dart';
import 'screens/all_chat_rooms_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // AdMob 초기화를 try-catch로 감싸기
  try {
    await MobileAds.instance.initialize();
    AdService.loadInterstitialAd(); // 광고 미리 로드
  } catch (e) {
    print('AdMob 초기화 실패: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '여행 채팅 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'HakgyoansinDungeunmiso',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'HakgyoansinDungeunmiso',
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF4c75e4),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          bodySmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const MainScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DestinationScreen(),
    const AllChatRoomsScreen(),
    const ChatRoomsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    AdService.loadInterstitialAd(); // 광고 미리 로드
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '여행지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '전체 채팅방',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '참여중인 채팅',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4c75e4),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
