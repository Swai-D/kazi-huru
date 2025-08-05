import 'dart:io';
import 'package:path/path.dart' as path;

void main() async {
  print('🔥 Kazi Huru Firebase Setup Checker 🔥\n');
  
  // Check if google-services.json exists
  final googleServicesPath = path.join('android', 'app', 'google-services.json');
  final googleServicesFile = File(googleServicesPath);
  
  if (await googleServicesFile.exists()) {
    print('✅ google-services.json found in android/app/');
    print('   File size: ${await googleServicesFile.length()} bytes');
  } else {
    print('❌ google-services.json NOT found in android/app/');
    print('   Please download it from Firebase Console and place it in android/app/');
  }
  
  // Check if Firebase dependencies are in pubspec.yaml
  final pubspecFile = File('pubspec.yaml');
  if (await pubspecFile.exists()) {
    final content = await pubspecFile.readAsString();
    final hasFirebaseCore = content.contains('firebase_core:');
    final hasFirebaseAuth = content.contains('firebase_auth:');
    final hasCloudFirestore = content.contains('cloud_firestore:');
    final hasFirebaseStorage = content.contains('firebase_storage:');
    
    print('\n📦 Firebase Dependencies Check:');
    print(hasFirebaseCore ? '✅ firebase_core' : '❌ firebase_core');
    print(hasFirebaseAuth ? '✅ firebase_auth' : '❌ firebase_auth');
    print(hasCloudFirestore ? '✅ cloud_firestore' : '❌ cloud_firestore');
    print(hasFirebaseStorage ? '✅ firebase_storage' : '❌ firebase_storage');
  }
  
  // Check Android build.gradle.kts
  final buildGradlePath = path.join('android', 'app', 'build.gradle.kts');
  final buildGradleFile = File(buildGradlePath);
  
  if (await buildGradleFile.exists()) {
    final content = await buildGradleFile.readAsString();
    final hasGoogleServices = content.contains('com.google.gms.google-services');
    final hasMultiDex = content.contains('multiDexEnabled = true');
    final hasFirebaseDeps = content.contains('com.google.firebase:firebase-bom');
    
    print('\n🔧 Android Configuration Check:');
    print(hasGoogleServices ? '✅ Google Services Plugin' : '❌ Google Services Plugin');
    print(hasMultiDex ? '✅ MultiDex Enabled' : '❌ MultiDex Enabled');
    print(hasFirebaseDeps ? '✅ Firebase Dependencies' : '❌ Firebase Dependencies');
  }
  
  print('\n📋 Next Steps:');
  print('1. Go to https://console.firebase.google.com/');
  print('2. Create a new project named "Kazi Huru"');
  print('3. Add Android app with package name: com.example.kazi_huru_app');
  print('4. Download google-services.json and place it in android/app/');
  print('5. Enable Authentication (Phone & Email/Password)');
  print('6. Create Firestore Database');
  print('7. Create Storage');
  print('8. Run: flutter run');
  print('9. Navigate to /firebase_test in the app to verify connection');
  
  print('\n🚀 Ready to test? Run: flutter run');
} 