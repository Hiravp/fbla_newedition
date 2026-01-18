import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({Key? key}) : super(key: key);

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredMembers = [];
  bool _isSearching = false;

  final List<Map<String, dynamic>> _members = [
    {
      'name': 'Sarah Johnson',
      'role': 'Chapter President',
      'chapter': 'Lincoln High',
      'avatar': 'SJ',
      'isFollowing': false,
    },
    {
      'name': 'Michael Chen',
      'role': 'Vice President',
      'chapter': 'Lincoln High',
      'avatar': 'MC',
      'isFollowing': true,
    },
    {
      'name': 'Emma Rodriguez',
      'role': 'Secretary',
      'chapter': 'Central High',
      'avatar': 'ER',
      'isFollowing': false,
    },
    {
      'name': 'James Park',
      'role': 'Treasurer',
      'chapter': 'Lincoln High',
      'avatar': 'JP',
      'isFollowing': true,
    },
    {
      'name': 'Olivia Williams',
      'role': 'Member',
      'chapter': 'Riverside High',
      'avatar': 'OW',
      'isFollowing': false,
    },
  ];

  final List<Map<String, dynamic>> _feedPosts = [
    {
      'author': 'Sarah Johnson',
      'avatar': 'SJ',
      'role': 'Chapter President',
      'content': 'Just finished an amazing workshop on business management! Excited to apply these strategies to our next competition.',
      'timestamp': '2 hours ago',
      'likes': 24,
      'comments': 5,
      'liked': false,
    },
    {
      'author': 'Michael Chen',
      'avatar': 'MC',
      'role': 'Vice President',
      'content': 'Our chapter is organizing a study group for the upcoming regional competition. Anyone interested? 🙋',
      'timestamp': '4 hours ago',
      'likes': 18,
      'comments': 8,
      'liked': false,
    },
    {
      'author': 'Emma Rodriguez',
      'avatar': 'ER',
      'role': 'Secretary',
      'content': 'Congratulations to our team for winning first place in the Marketing competition! 🏆 So proud of everyone\'s hard work.',
      'timestamp': '1 day ago',
      'likes': 45,
      'comments': 12,
      'liked': false,
    },
    {
      'author': 'James Park',
      'avatar': 'JP',
      'role': 'Treasurer',
      'content': 'New resources added to our chapter library. Check them out in the Resources section!',
      'timestamp': '2 days ago',
      'likes': 12,
      'comments': 3,
      'liked': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredMembers = _members.map((m) => m['name'] as String).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterMembers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMembers = _members.map((m) => m['name'] as String).toList();
        _isSearching = false;
      } else {
        _isSearching = true;
        _filteredMembers = _members
            .where((m) => (m['name'] as String).toLowerCase().contains(query.toLowerCase()))
            .map((m) => m['name'] as String)
            .toList();
      }
    });
  }

  Map<String, dynamic>? _getMemberData(String name) {
    return _members.firstWhere(
      (m) => m['name'] == name,
      orElse: () => {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.feed),
              text: 'Feed',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: 'Members',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Feed Tab
          _buildFeedTab(),
          // Members Tab
          _buildMembersTab(),
        ],
      ),
    );
  }

  Widget _buildFeedTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _feedPosts.length,
      itemBuilder: (context, index) {
        final post = _feedPosts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          post['avatar'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['author'],
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${post['role']} • ${post['timestamp']}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.more_vert,
                      color: AppTheme.textLight,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Content
                Text(
                  post['content'],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                // Divider
                Divider(
                  color: AppTheme.lightGrey,
                  height: 1,
                ),
                const SizedBox(height: 12),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      icon: post['liked'] ? Icons.favorite : Icons.favorite_outline,
                      label: '${post['likes']}',
                      color: post['liked'] ? AppTheme.errorRed : AppTheme.textLight,
                      onTap: () {
                        setState(() {
                          post['liked'] = !post['liked'];
                          if (post['liked']) {
                            post['likes']++;
                          } else {
                            post['likes']--;
                          }
                        });
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.comment_outlined,
                      label: '${post['comments']}',
                      color: AppTheme.textLight,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Comment feature coming soon!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      color: AppTheme.textLight,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Shared!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search members...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        _filterMembers('');
                      },
                    )
                  : null,
            ),
            onChanged: _filterMembers,
          ),
        ),
        // Members List
        Expanded(
          child: _filteredMembers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_off,
                        size: 48,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No members found',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredMembers.length,
                  itemBuilder: (context, index) {
                    final memberName = _filteredMembers[index];
                    final member = _getMemberData(memberName);

                    if (member == null || member.isEmpty) return const SizedBox();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Text(
                              member['avatar'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          member['name'],
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member['role'],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              member['chapter'],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              member['isFollowing'] = !member['isFollowing'];
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  member['isFollowing']
                                      ? 'Following ${member['name']}'
                                      : 'Unfollowed ${member['name']}',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: member['isFollowing']
                                ? AppTheme.primaryBlue
                                : Colors.grey[300],
                            foregroundColor: member['isFollowing']
                                ? Colors.white
                                : AppTheme.textDark,
                          ),
                          child: Text(
                            member['isFollowing'] ? 'Following' : 'Follow',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
