import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import 'image_upload_widget.dart';

class TestImageUploadScreen extends StatefulWidget {
  const TestImageUploadScreen({super.key});

  @override
  State<TestImageUploadScreen> createState() => _TestImageUploadScreenState();
}

class _TestImageUploadScreenState extends State<TestImageUploadScreen> {
  String? _profileImageUrl;
  String? _jobImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Test Image Upload',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ThemeConstants.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Upload
            const Text(
              'Profile Picture Upload',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: ImageUploadWidget(
                folder: 'profile_pictures',
                currentImageUrl: _profileImageUrl,
                onImageUploaded: (imageUrl) {
                  setState(() {
                    _profileImageUrl = imageUrl;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile image uploaded: $imageUrl'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                onImageDeleted: () {
                  setState(() {
                    _profileImageUrl = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile image deleted'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                width: 150,
                height: 150,
                label: 'Profile Picture',
                showDeleteButton: true,
              ),
            ),

            const SizedBox(height: 40),

            // Job Image Upload
            const Text(
              'Job Image Upload',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ImageUploadWidget(
              folder: 'job_images',
              currentImageUrl: _jobImageUrl,
              onImageUploaded: (imageUrl) {
                setState(() {
                  _jobImageUrl = imageUrl;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Job image uploaded: $imageUrl'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              onImageDeleted: () {
                setState(() {
                  _jobImageUrl = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Job image deleted'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              width: double.infinity,
              height: 200,
              label: 'Job Image',
              showDeleteButton: true,
            ),

            const SizedBox(height: 40),

            // Display uploaded URLs
            if (_profileImageUrl != null || _jobImageUrl != null) ...[
              const Text(
                'Uploaded Image URLs:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_profileImageUrl != null) ...[
                const Text(
                  'Profile Image:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _profileImageUrl!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_jobImageUrl != null) ...[
                const Text(
                  'Job Image:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _jobImageUrl!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
