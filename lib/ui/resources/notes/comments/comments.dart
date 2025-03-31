import 'package:campuszone/ui/resources/notes/comments/commentitem.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsPage extends StatefulWidget {
  final String noteId;
  const CommentsPage({super.key, required this.noteId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  bool _isLoading = false;
  bool _isPosting = false;
  List<Map<String, dynamic>> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _commentController.addListener(() => setState(() {}));
  }

  Future<void> _fetchComments() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('ncomments')
          .select('*, user:users(name)')
          .eq('note_id', widget.noteId)
          .order('created_at', ascending: true);
      final data = List<Map<String, dynamic>>.from(response);
      if (mounted) {
        setState(() => _comments = data);
      }
    } catch (error) {
      debugPrint('Error fetching comments: ${error.toString()}');
      if (mounted) {
        _showErrorDialog('Failed to load comments. Please try again.');
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _postComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;
    setState(() => _isPosting = true);
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        _showErrorDialog('You must be logged in to post a comment.');
        setState(() => _isPosting = false);
        return;
      }
      // Insert the comment into the database.
      await Supabase.instance.client.from('ncomments').insert({
        'user_id': currentUser.id,
        'note_id': widget.noteId,
        'comment_text': commentText,
        'created_at': DateTime.now().toIso8601String(),
      }).select();
      // Clear the input field.
      _commentController.clear();
      // Refresh comments.
      await _fetchComments();
      // Scroll to the bottom.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (error) {
      debugPrint('Error posting comment: ${error.toString()}');
      _showErrorDialog('Error posting comment. Please try again.');
    }
    if (mounted) {
      setState(() => _isPosting = false);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await Supabase.instance.client
          .from('ncomments')
          .delete()
          .eq('id', commentId);
      if (mounted) {
        setState(() {
          _comments.removeWhere((comment) => comment['id'] == commentId);
        });
      }
    } catch (error) {
      debugPrint('Error deleting comment: ${error.toString()}');
      _showErrorDialog('Failed to delete comment. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error', style: TextStyle(color: Colors.redAccent)),
        content: Text(message, style: const TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Shimmer effect for loading comments.
  Widget _buildCommentShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 12,
                      width: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? _buildCommentShimmer()
                : RefreshIndicator(
                    onRefresh: _fetchComments,
                    color: Colors.black,
                    child: _comments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LineIcons.comment,
                                    size: 48, color: Colors.black26),
                                const SizedBox(height: 16),
                                const Text(
                                  'No comments yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to comment!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return CommentItem(
                                comment: comment,
                                currentUserId: currentUserId,
                                formattedDate:
                                    _formatDate(comment['created_at']),
                                onDelete: () => _deleteComment(comment['id']),
                              );
                            },
                          ),
                  ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  offset: const Offset(0, -1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isPosting
                      ? Container(
                          width: 36,
                          height: 36,
                          padding: const EdgeInsets.all(6),
                          child:
                              const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Material(
                          color: _commentController.text.trim().isEmpty
                              ? Colors.grey[300]
                              : Colors.black,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: _commentController.text.trim().isEmpty
                                ? null
                                : _postComment,
                            child: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              child: Icon(
                                LineIcons.paperPlane,
                                color: _commentController.text.trim().isEmpty
                                    ? Colors.grey[500]
                                    : Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return timeago.format(date);
    } catch (e) {
      return '';
    }
  }
}
