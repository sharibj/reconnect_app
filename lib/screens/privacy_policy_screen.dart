import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: October 4, 2025',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Important Notice',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Reconnect is a Minimum Viable Product (MVP) designed for testing purposes by a single developer. This application is provided as-is for evaluation and feedback.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              'Data Collection and Usage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'We collect and store the following information to provide the app\'s functionality:',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Contact information you enter (names, notes, group assignments)', style: TextStyle(fontSize: 16, height: 1.5)),
                  Text('• Interaction logs and timestamps', style: TextStyle(fontSize: 16, height: 1.5)),
                  Text('• Account information (username, email if provided)', style: TextStyle(fontSize: 16, height: 1.5)),
                  Text('• App usage analytics for improving functionality', style: TextStyle(fontSize: 16, height: 1.5)),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Data Storage and Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Your data is stored in a database hosted on a free platform (Render). While we implement reasonable security measures, please be responsible with your data and avoid entering sensitive or confidential information.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              'Data Sharing and Sales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'We do not sell your data or use it for any purposes other than providing the app\'s intended functionality. Your data is not shared with third parties for commercial purposes.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              'Your Responsibility',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'As this is an MVP hosted on a free platform, we recommend:',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Do not enter sensitive personal information', style: TextStyle(fontSize: 16, height: 1.5)),
                  Text('• Use the app responsibly and at your own discretion', style: TextStyle(fontSize: 16, height: 1.5)),
                  Text('• Regularly backup important data outside the app', style: TextStyle(fontSize: 16, height: 1.5)),
                  Text('• Be aware that this is testing software and may have limitations', style: TextStyle(fontSize: 16, height: 1.5)),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Changes to This Policy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'This privacy policy may be updated from time to time. We will notify users of any significant changes through the app or via email if contact information has been provided.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'If you have any questions about this privacy policy or the app, please contact us through the feedback option in the app settings.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

}