# Firebase Setup Guide for Kazi Huru App

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: "Kazi Huru"
4. Enable Google Analytics (optional but recommended)
5. Choose your Analytics account or create a new one
6. Click "Create project"

## Step 2: Add Android App to Firebase

1. In Firebase Console, click the Android icon (</>) to add Android app
2. Enter Android package name: `com.example.kazi_huru_app`
3. Enter app nickname: "Kazi Huru"
4. Click "Register app"
5. Download the `google-services.json` file
6. Place the file in: `android/app/google-services.json`

## Step 3: Add iOS App to Firebase (if needed)

1. In Firebase Console, click the iOS icon to add iOS app
2. Enter iOS bundle ID: `com.example.kaziHuruApp`
3. Enter app nickname: "Kazi Huru iOS"
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Place the file in: `ios/Runner/GoogleService-Info.plist`

## Step 4: Enable Authentication Methods

1. In Firebase Console, go to "Authentication" > "Sign-in method"
2. Enable the following providers:
   - **Phone**: Enable phone number authentication
   - **Email/Password**: Enable email/password authentication
   - **Google**: Enable Google sign-in (optional)

### Phone Authentication Setup:
1. Click on "Phone" provider
2. Enable it
3. Add test phone numbers if needed for development
4. Save

### Email/Password Setup:
1. Click on "Email/Password" provider
2. Enable it
3. Enable "Email link (passwordless sign-in)" if desired
4. Save

## Step 5: Set up Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" for development
4. Select a location (choose closest to Tanzania)
5. Click "Done"

### Firestore Security Rules:
Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read jobs, but only job providers can create/update their own jobs
    match /jobs/{jobId} {
      allow read: if true;
      allow create, update, delete: if request.auth != null && 
        request.auth.uid == resource.data.jobProviderId;
    }
    
    // Applications - users can read their own applications, job providers can read applications for their jobs
    match /applications/{applicationId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.jobSeekerId || 
         request.auth.uid == get(/databases/$(database)/documents/jobs/$(resource.data.jobId)).data.jobProviderId);
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.jobSeekerId;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.jobSeekerId || 
         request.auth.uid == get(/databases/$(database)/documents/jobs/$(resource.data.jobId)).data.jobProviderId);
    }
    
    // Notifications - users can read their own notifications
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Verifications - users can read their own verifications, admins can read all
    match /verifications/{verificationId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
    
    // Wallet - users can read/write their own wallet
    match /wallet/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 6: Set up Storage

1. In Firebase Console, go to "Storage"
2. Click "Get started"
3. Choose "Start in test mode" for development
4. Select a location (same as Firestore)
5. Click "Done"

### Storage Security Rules:
Replace the default rules with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can upload their own profile images
    match /users/{userId}/profile_images/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can upload their own verification documents
    match /users/{userId}/verification_documents/{fileName} {
      allow read: if request.auth != null && 
        (request.auth.uid == userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can upload their own resumes
    match /users/{userId}/resumes/{fileName} {
      allow read: if request.auth != null && 
        (request.auth.uid == userId || 
         request.auth.uid == get(/databases/$(database)/documents/applications/$(applicationId)).data.jobProviderId);
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Company logos
    match /companies/{companyId}/logos/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && 
        request.auth.uid == get(/databases/$(database)/documents/companies/$(companyId)).data.ownerId;
    }
  }
}
```

## Step 7: Enable Cloud Messaging (for Push Notifications)

1. In Firebase Console, go to "Project settings"
2. Go to "Cloud Messaging" tab
3. Copy the Server key (you'll need this for sending notifications)

## Step 8: Update Android Configuration

### Update android/app/build.gradle.kts:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Add this line
}

android {
    // ... existing config
    defaultConfig {
        // ... existing config
        multiDexEnabled = true // Add this line
    }
}

dependencies {
    // ... existing dependencies
    implementation(platform("com.google.firebase:firebase-bom:32.7.4"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
    implementation("com.google.firebase:firebase-messaging")
}
```

### Update android/build.gradle.kts:
```kotlin
buildscript {
    dependencies {
        // ... existing dependencies
        classpath("com.google.gms:google-services:4.4.1")
    }
}
```

## Step 9: Update iOS Configuration (if needed)

### Update ios/Podfile:
```ruby
# Add this at the top
platform :ios, '12.0'

# Add this in the target section
target 'Runner' do
  # ... existing pods
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
end
```

## Step 10: Test Firebase Connection

Run the app and check if Firebase is properly initialized. You should see no Firebase-related errors in the console.

## Troubleshooting

### Common Issues:

1. **"No Firebase App '[DEFAULT]' has been created"**
   - Make sure `google-services.json` is in the correct location
   - Check that Firebase.initializeApp() is called in main()

2. **Authentication errors**
   - Verify that the authentication methods are enabled in Firebase Console
   - Check that the package name matches exactly

3. **Firestore permission errors**
   - Make sure the security rules are properly set
   - Check that the user is authenticated

4. **Storage upload errors**
   - Verify storage rules allow the operation
   - Check file size limits

## Next Steps

After completing this setup:

1. Test authentication (phone and email)
2. Test creating user profiles
3. Test job posting and applications
4. Test file uploads
5. Test notifications

The Firebase backend is now ready for your Kazi Huru app! 