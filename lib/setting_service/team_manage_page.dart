import 'package:flutter/material.dart';

class TeamManagePage extends StatelessWidget {
  const TeamManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('팀 관리',
          style: TextStyle(color: Color(0xFF2563EB),
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildMemberTile('A', '매니저'),
          _buildMemberTile('B', '직원'),
        ],
      ),
    );
  }

  Widget _buildMemberTile(String name, String role) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(name),
      subtitle: Text(role),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          // TODO: 역할 변경, 삭제 등 처리
        },
      ),
    );
  }
}
