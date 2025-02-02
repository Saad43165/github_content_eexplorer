import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../models/repository.dart';

class DetailsScreen extends StatefulWidget {
  final Repository repository;
  const DetailsScreen({super.key, required this.repository});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _isDescriptionExpanded = false;

  Future<void> _launchURL(BuildContext context) async {
    final Uri url = Uri.parse('https://github.com/${widget.repository.fullName}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open URL')),
      );
    }
  }

  void _copyLink(BuildContext context) {
    final String repoUrl = 'https://github.com/${widget.repository.fullName}';
    Clipboard.setData(ClipboardData(text: repoUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Repository link copied to clipboard'),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Repository Details', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.indigoAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GlassContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Owner Avatar & Repo Name
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.repository.ownerAvatarUrl),
                      radius: 50,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.repository.fullName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    _getDescription(),
                    GestureDetector(
                      onTap: _toggleDescription,
                      child: Text(
                        _isDescriptionExpanded ? 'Show Less' : 'Show More',
                        style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats: Stars & Forks
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(Icons.star, Colors.amber, widget.repository.stargazersCount, 'Stars'),
                        _buildStatItem(Icons.call_split, Colors.blue, widget.repository.forksCount, 'Forks'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Additional Info: Repository Language & Last Updated
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(Icons.language, Colors.green, widget.repository.language ?? "Unknown", 'Language'),
                        _buildStatItem(Icons.update, Colors.orange, widget.repository.updatedAt, 'Last Updated'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons (View on GitHub & Copy Link)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _launchURL(context),
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('Open in GitHub'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(fontSize: 16),
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.copy, color: Colors.blueAccent),
                            tooltip: 'Copy Link',
                            onPressed: () => _copyLink(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Toggle Description Visibility
  void _toggleDescription() {
    setState(() {
      _isDescriptionExpanded = !_isDescriptionExpanded;
    });
  }

  // Get Description Text
  Text _getDescription() {
    if (widget.repository.description.isNotEmpty) {
      if (_isDescriptionExpanded) {
        return Text(
          widget.repository.description,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          textAlign: TextAlign.center,
        );
      } else {
        return Text(
          widget.repository.description.length > 100
              ? widget.repository.description.substring(0, 100) + '...'
              : widget.repository.description,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          textAlign: TextAlign.center,
        );
      }
    }
    return const Text(
      'No description available',
      style: TextStyle(fontSize: 16, color: Colors.black87),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStatItem(IconData icon, Color? color, dynamic count, String label) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  const GlassContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: child,
    );
  }
}
