import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants.dart';
import '../../core/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      
      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('user_profiles').child('${_user!.uid}.jpg');
      
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        await storageRef.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await storageRef.putFile(File(image.path));
      }

      // Get download URL
      final String downloadUrl = await storageRef.getDownloadURL();

      // Update Firebase Auth profile
      await _user!.updatePhotoURL(downloadUrl);
      
      // Refresh user object
      await _user!.reload();
      
      setState(() {
        _user = _auth.currentUser;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!'), backgroundColor: AppColors.authPrimary),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update image: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.appBackgroundGradient),
        child: SafeArea(
          child: Column(
             children: [
               // Custom Text App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textDark),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Expanded(child: Center(child: Text("Profile", style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold)))),
                      const SizedBox(width: 40), // Balance the back button
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Profile Avatar Area
                GestureDetector(
                  onTap: _isUploading ? null : _pickAndUploadImage,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.iconPink, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.purple.shade200,
                          backgroundImage: _user?.photoURL != null ? NetworkImage(_user!.photoURL!) : null,
                          child: _user?.photoURL == null 
                            ? const Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
                        ),
                      ),
                      if (_isUploading)
                        const Positioned.fill(
                          child: CircularProgressIndicator(color: AppColors.iconPink),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.iconPink,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // User Info
                Text(
                  _user?.displayName ?? 'Welcome!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  _user?.email ?? 'No email available',
                  style: const TextStyle(fontSize: 16, color: AppColors.textLight),
                ),

                const Spacer(),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      minimumSize: const Size(double.infinity, 50),
                      elevation: 0,
                      shadowColor: Colors.black12,
                    ),
                    child: const Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
             ],
          ),
        )
      )
    );
  }
}
