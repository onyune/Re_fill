import 'package:flutter/material.dart';
import 'package:refill/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  List<Map<String, dynamic>> teamMembers = [];
  bool isLoading = true;
  String currentUserRole = '';
  String? currentUserUid;

  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
  }

  Future<void> _loadTeamMembers() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    currentUserUid = uid;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final storeId = userDoc.data()?['storeId'];
    currentUserRole = userDoc.data()?['role'] ?? 'staff';

    if (storeId == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('storeId', isEqualTo: storeId)
        .get();

    final List<Map<String, dynamic>> members = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      if (doc.id == uid) continue; // 자기 자신 제외
      members.add({
        'uid': doc.id,
        'name': data['name'] ?? '이름 없음',
        'role': data['role'] ?? 'staff',
      });
    }

    setState(() {
      teamMembers = members;
      isLoading = false;
    });
  }

  Future<void> _toggleManagerRole(String uid, String currentRole) async {
    final newRole = currentRole == 'manager' ? 'staff' : 'manager';
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'role': newRole});

    setState(() {
      final index = teamMembers.indexWhere((m) => m['uid'] == uid);
      if (index != -1) {
        teamMembers[index]['role'] = newRole;
      }
    });
  }

  Future<void> _removeMember(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("직원 삭제"),
        content: const Text("정말 이 직원을 삭제하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("취소")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("삭제")),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      setState(() {
        teamMembers.removeWhere((m) => m['uid'] == uid);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('직원이 삭제되었습니다.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제 중 오류가 발생했습니다.')));
    }
  }

  Icon _getStarIcon(String role) {
    return Icon(
      Icons.star,
      color: role == 'manager' ? Colors.amber : Colors.grey,
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'owner':
        return '점주';
      case 'manager':
        return '매니저';
      default:
        return '직원';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("팀원 목록"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          final member = teamMembers[index];
          final isOwner = member['role'] == 'owner';

          return ListTile(
            leading: const Icon(Icons.person, color: AppColors.primary),
            title: Text(member['name']),
            subtitle: Text(_getRoleLabel(member['role'])),
            trailing: currentUserRole == 'owner' && !isOwner
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: _getStarIcon(member['role']),
                  onPressed: () => _toggleManagerRole(member['uid'], member['role']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () => _removeMember(member['uid']),
                ),
              ],
            )
                : null,
          );
        },
      ),
    );
  }
}
