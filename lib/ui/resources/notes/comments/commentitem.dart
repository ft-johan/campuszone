import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campuszone/globals.dart' as globals;
import 'package:shimmer/shimmer.dart';

class CommentItem extends StatefulWidget {
  final Map<String, dynamic> comment;
  final String? currentUserId;
  final String formattedDate;
  final Future<void> Function() onDelete;

  const CommentItem({
    super.key,
    required this.comment,
    required this.currentUserId,
    required this.formattedDate,
    required this.onDelete,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem>
    with SingleTickerProviderStateMixin {
  bool _showOverlay = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
      if (_showOverlay) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _showDeleteConfirmation() async {
    _toggleOverlay(); // Hide the overlay first

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Comment'),
          content: const Text(
              'Are you sure you want to delete this comment? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await widget.onDelete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfilePic() {
    // Retrieve the user id from the comment data.
    final String userId = widget.comment['user']?['id'] ?? '';
    // If no userId, fallback to a default avatar.
    if (userId.isEmpty) {
      return const CircleAvatar(
        radius: 20,
        child: Icon(LineIcons.user),
      );
    }
    // Get the public URL from Supabase storage.
    final baseUrl = Supabase.instance.client.storage
        .from('profilepic')
        .getPublicUrl('$userId/profile_picture.jpg');

    // Use ValueListenableBuilder so that changes to the cache buster rebuild the image.
    return ValueListenableBuilder<String?>(
      valueListenable: globals.globalCacheBuster,
      builder: (context, cacheBuster, child) {
        final String updatedUrl = (cacheBuster ?? '').isNotEmpty
            ? '$baseUrl?cacheBuster=$cacheBuster'
            : baseUrl;
        return CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          child: ClipOval(
            child: Image.network(
              updatedUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 40,
                    height: 40,
                    color: Colors.white,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(LineIcons.user, color: Colors.white);
              },
            ),
          ),
        );
      },
    );
  }

  bool get _isOwnComment =>
      widget.currentUserId != null &&
      widget.currentUserId == widget.comment['user_id'];

  @override
  Widget build(BuildContext context) {
    final commentText = widget.comment['comment_text'] ?? '';
    final String userName = widget.comment['user']?['name'] ?? 'Anonymous';

    return GestureDetector(
      onLongPress: _isOwnComment ? _toggleOverlay : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            children: [
              Card(
                color: Colors.white,
                elevation: 2,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.grey.withAlpha(10),
                    width: 1,
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 2),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile picture section using globalCacheBuster.
                        _buildProfilePic(),
                        const SizedBox(width: 12),
                        // Content section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    widget.formattedDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                commentText,
                                style: const TextStyle(fontSize: 15),
                              ),
                              if (_isOwnComment)
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Tap and hold to manage',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[400],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Action overlay
              if (_showOverlay)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _toggleOverlay,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(70),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MaterialButton(
                              onPressed: _showDeleteConfirmation,
                              color: Colors.red,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LineIcons.trash, size: 18),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            MaterialButton(
                              onPressed: _toggleOverlay,
                              color: Colors.grey,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LineIcons.times, size: 18),
                                  SizedBox(width: 8),
                                  Text('Cancel'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
