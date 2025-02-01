// lib/screens/details_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/repository.dart';

class DetailsScreen extends StatelessWidget {
  final Repository repository;
  const DetailsScreen({Key? key, required this.repository}) : super(key: key);

  Future<void> _launchURL(BuildContext context) async {
    final url = 'https://github.com/${repository.fullName}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
       
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('GitHub Explorer',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),),
              Divider(endIndent: 190,color: Colors.blue.shade300,),
              SizedBox(height: 10),
              // Header: Owner Avatar and Repository Name
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(repository.ownerAvatarUrl),
                    radius: 40,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      repository.fullName,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Description
              Text(
                repository.description,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              // Stats: Stars and Forks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(Icons.star, color: Colors.yellow[700]),
                      SizedBox(height: 4),
                      Text('${repository.stargazersCount}'),
                      Text('Stars'),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.call_split),
                      SizedBox(height: 4),
                      Text('${repository.forksCount}'),
                      Text('Forks'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              // Button to Open Repository in Browser
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchURL(context),
                  icon: Icon(Icons.open_in_browser),
                  label: Text('View on GitHub'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
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
