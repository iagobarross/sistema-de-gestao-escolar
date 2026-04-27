import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:gestao_escolar_app/screens/login_screen.dart';

class NavItem {
  final String label;
  final IconData icon;
  final Widget page;

  const NavItem({required this.label, required this.icon, required this.page});
}

class MainShell extends StatefulWidget {
  final String titulo;
  final String? role;
  final List<NavItem> items;

  const MainShell({
    required this.titulo,
    required this.role,
    required this.items,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  String _nome = '';

  @override
  void initState() {
    super.initState();
    AuthService().getNome().then((n) {
      if (mounted) setState(() => _nome = n ?? '');
    });
  }

  void _selecionar(int index) {
    setState(() => _selectedIndex = index);
    Navigator.of(context).pop();
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = AppTheme.roleColor(widget.role);
    final roleLabel = AppTheme.roleLabel(widget.role);
    final currentItem = widget.items[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: roleColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentItem.label),
            Text(
              widget.titulo,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      drawer: _buildDrawer(roleColor, roleLabel),
      body: IndexedStack(
        index: _selectedIndex,
        children: widget.items.map((item) => item.page).toList(),
      ),
    );
  }

  Widget _buildDrawer(Color roleColor, String roleLabel) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(color: roleColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  child: Text(
                    _nome.isNotEmpty ? _nome[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    roleLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (_, i) {
                final item = widget.items[i];
                final isSelected = i == _selectedIndex;
                return ListTile(
                  selected: isSelected,
                  selectedTileColor: roleColor.withOpacity(0.1),
                  selectedColor: roleColor,
                  iconColor: isSelected ? roleColor : AppTheme.textSecondary,
                  leading: Icon(item.icon),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 2,
                  ),
                  onTap: () => _selecionar(i),
                );
              },
            ),
          ),

          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
