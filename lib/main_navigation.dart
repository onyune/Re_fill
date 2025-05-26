import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:refill/colors.dart';
import 'home_service/home_screen.dart';
import 'order_service/order_screen.dart';
import 'order_service/stocks_screen.dart';
import 'chat_service/chat_screen.dart';
import 'setting_service/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  int _unreadCount = 0;
  String _role = 'owner';
  List<Widget>? _screens;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadUserRoleAndInit();
    _listenToUnreadMessages();
  }

  Future<void> _loadUserRoleAndInit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final role = userDoc['role'] ?? 'owner';

    setState(() {
      _role = role;
      _screens = [
        const HomeScreen(),
        role == 'owner' ? const OrderScreen() : const StocksScreen(),
        const ChatScreen(),
        const SettingsScreen(),
      ];
      _isInitialized = true;
    });
  }

  Future<void> _listenToUnreadMessages() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc['storeId'];

    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(storeId)
        .collection('messages')
        .snapshots()
        .listen((snapshot) {
      int count = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final readBy = (data['readBy'] is List) ? List<String>.from(data['readBy']) : [];
        if (!readBy.contains(uid)) {
          count++;
        }
      }
      setState(() {
        _unreadCount = count;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _screens == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens![_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.background,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(
            icon: Icon(_role == 'owner' ? Icons.inventory_2 : Icons.list_alt),
            label: _role == 'owner' ? '발주' : '재고',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.chat),
                if (_unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        _unreadCount > 99 ? '99+' : '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: '채팅',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}
