import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';

/// Admin: danh sách member có tìm kiếm + phân trang (cuộn tới cuối thì tải trang tiếp),
/// đổi role Admin/Member, khóa/mở khóa. Không cho thao tác trên chính mình (API cũng chặn).
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _userService = UserService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  final List<UserListItem> _users = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  String? _error;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _reload();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Cuộn gần cuối danh sách (còn 200px) thì tải trang tiếp theo.
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadNextPage();
    }
  }

  /// Tải lại từ trang 1 (khi mở màn, tìm kiếm, kéo để làm mới, hoặc sau khi sửa).
  Future<void> _reload() async {
    setState(() {
      _users.clear();
      _page = 0;
      _hasMore = true;
      _error = null;
    });
    await _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      final result = await _userService.getUsers(
        keyword: _searchController.text,
        page: _page + 1,
        pageSize: 10,
      );
      setState(() {
        _users.addAll(result.items);
        _page = result.page;
        _hasMore = result.hasMore;
        _totalItems = result.totalItems;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _runAction(Future<String> Function() action) async {
    try {
      final message = await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _toggleLock(UserListItem user) async {
    final lock = !user.isLocked;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lock ? 'Khóa tài khoản' : 'Mở khóa tài khoản'),
        content: Text(lock
            ? 'Khóa ${user.email}? Người này sẽ không đăng nhập được nữa.'
            : 'Mở khóa ${user.email}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true), child: Text(lock ? 'Khóa' : 'Mở khóa')),
        ],
      ),
    );
    if (confirm == true) await _runAction(() => _userService.updateLock(user.id, lock));
  }

  Future<void> _toggleRole(UserListItem user) async {
    final newRole = user.isAdmin ? 'Member' : 'Admin';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi role'),
        content: Text('Đổi ${user.email} thành $newRole?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Đồng ý')),
        ],
      ),
    );
    if (confirm == true) await _runAction(() => _userService.updateRole(user.id, newRole));
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthProvider>().session?.userId;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý member')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _reload(),
              decoration: InputDecoration(
                hintText: 'Tìm theo email hoặc họ tên',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _reload();
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Tổng: $_totalItems tài khoản',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reload,
              child: _buildList(currentUserId, dateFormat),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(int? currentUserId, DateFormat dateFormat) {
    if (_error != null && _users.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 80),
        Center(child: Text(_error!, textAlign: TextAlign.center)),
        Center(child: TextButton(onPressed: _reload, child: const Text('Thử lại'))),
      ]);
    }
    if (!_loading && _users.isEmpty) {
      return ListView(children: const [
        SizedBox(height: 80),
        Center(child: Text('Không có tài khoản nào')),
      ]);
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _users.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Dòng cuối: vòng xoay khi đang tải trang tiếp
        if (index >= _users.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final user = _users[index];
        final isMe = user.id == currentUserId;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: user.isLocked ? Colors.grey : null,
            child: Icon(user.isAdmin ? Icons.admin_panel_settings : Icons.person),
          ),
          title: Text(isMe ? '${user.fullName} (bạn)' : user.fullName),
          subtitle: Text(
            '${user.email}\n${user.role} · Tạo ${dateFormat.format(user.createdAt)}'
            '${user.isLocked ? ' · ĐÃ KHÓA' : ''}',
          ),
          isThreeLine: true,
          trailing: isMe
              ? null
              : PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'role') _toggleRole(user);
                    if (value == 'lock') _toggleLock(user);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'role',
                      child: Text(user.isAdmin ? 'Đổi thành Member' : 'Đổi thành Admin'),
                    ),
                    PopupMenuItem(
                      value: 'lock',
                      child: Text(user.isLocked ? 'Mở khóa' : 'Khóa tài khoản'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
