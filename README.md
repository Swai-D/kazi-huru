# Kazi Huru - Tanzanian Job Marketplace

![Kazi Huru Logo](assets/images/logo.png)

A Flutter-based job marketplace application connecting job seekers and providers in Tanzania.

## Table of Contents
- [Project Overview](#project-overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [File Structure](#detailed-file-structure)
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Development Rules](#development-rules)
- [Development Phases](#development-phases)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)
- [Screen-by-Screen Implementation Guide](#screen-by-screen-implementation-guide)
- [Additional Features & Considerations](#additional-features-and-considerations)

## Project Overview
Kazi Huru is a Flutter-based job marketplace application connecting Job Seekers and Job Providers in Tanzania. The app facilitates job postings, applications, and communication between parties through a user-friendly interface supporting both English and Swahili languages.

## Features

### Core Features
- 🔐 Phone number-based authentication
- 📱 Role-based dashboards
- 💼 Quick job posting and application
- 💰 Integrated payment system
- 📍 Location-based job discovery
- 🔔 Real-time notifications
- 💬 In-app messaging
- 🌐 Swahili language support

### Job Management
- Create and post jobs
- Browse available jobs
- Apply for jobs
- Track application status
- Save favorite jobs

### Payment System
- M-Pesa integration
- Tigo Pesa support
- Airtel Money integration
- Commission management
- Transaction history

## Tech Stack
- **Frontend**: Flutter (Material Design)
- **Backend**: Firebase
  - Authentication (Phone & Email)
  - Firestore Database
  - Cloud Functions (if needed)
- **Localization**: Swahili & English support
- **Notifications**: flutter_local_notifications

## Project Structure
The project is divided into the following main sections:

### 1. Authentication Module
- Phone number authentication
- Email-password authentication
- Role-based access control
- User profile management

### 2. Job Seeker Dashboard
- Job search and filtering
- Job application management
- Profile management
- Application status tracking
- Saved jobs

### 3. Job Provider Dashboard
- Job posting management
- Application review
- Candidate management
- Company profile management
- Analytics and insights

### 4. Core Features
- Real-time notifications
- Chat/messaging system
- Payment integration
- Document upload and verification
- Rating and review system

## Detailed File Structure
```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── theme_constants.dart
│   │   └── api_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── network_info.dart
│   │   └── api_client.dart
│   ├── utils/
│   │   ├── extensions.dart
│   │   └── helpers.dart
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       └── loading_indicator.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_data_source.dart
│   │   │   │   └── auth_local_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in.dart
│   │   │       └── sign_up.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── auth_bloc.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── register_page.dart
│   │       └── widgets/
│   │           └── auth_form.dart
│   ├── job_seeker/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── job_provider/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   └── chat/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── config/
│   ├── routes.dart
│   └── theme.dart
├── main.dart
└── app.dart

assets/
├── images/
│   ├── logo.png
│   └── icons/
├── fonts/
└── translations/
    ├── en.json
    └── sw.json

test/
├── core/
├── features/
└── test_helper.dart

```

## Getting Started

### Prerequisites
- Flutter SDK (Latest stable version)
- Android Studio/VS Code
- Firebase account
- Mobile money provider accounts

### Installation
1. Clone the repository
```bash
git clone https://github.com/Swai-D/kazi-huru.git
cd kazi-huru
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Create a new Firebase project
- Add Android and iOS apps
- Download and add configuration files
- Enable Authentication and Firestore

4. Run the app
```bash
flutter run
```

## Development Rules
1. **Code Organization**
   - Follow Clean Architecture principles
   - Use feature-first folder structure
   - Implement proper state management
   - Maintain consistent naming conventions

2. **UI/UX Guidelines**
   - Material Design 3 compliance
   - Responsive layouts
   - Dark/Light theme support
   - Swahili language support
   - Accessibility considerations

3. **Security Rules**
   - Implement proper Firebase security rules
   - Secure API endpoints
   - Data encryption where necessary
   - Regular security audits

4. **Testing Requirements**
   - Unit tests for business logic
   - Widget tests for UI components
   - Integration tests for critical flows
   - Regular performance testing

5. **Documentation**
   - Code documentation
   - API documentation
   - User guides
   - Deployment guides

## Development Phases
1. **Phase 1: Foundation**
   - Project setup
   - Authentication implementation
   - Basic UI components
   - Database structure

2. **Phase 2: Core Features**
   - Job posting system
   - Search functionality
   - Application process
   - Basic notifications

3. **Phase 3: Enhanced Features**
   - Chat system
   - Payment integration
   - Advanced search
   - Analytics

4. **Phase 4: Polish & Scale**
   - Performance optimization
   - Advanced security
   - Multi-language support
   - Testing and bug fixes

## Architecture

### State Management
- Provider for state management
- Stream-based real-time updates
- Event-driven architecture

### Data Flow
- Clean Architecture implementation
- Repository pattern
- Dependency injection

### Security
- Firebase Authentication
- Role-based access control
- Encrypted data transmission
- Secure payment processing

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow Flutter's official style guide
- Use meaningful variable names
- Write clear comments
- Maintain consistent formatting

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments
- Flutter Team
- Firebase Team
- Mobile Money Providers
- Open Source Community

## Support
For support, email support@kazihuru.com or join our Slack channel.

## Roadmap
- [ ] Phase 1: MVP (Current)
  - [ ] Authentication
  - [ ] Basic job posting
  - [ ] Payment integration
  - [ ] Testing and optimization

- [ ] Phase 2: Enhanced Features
  - [ ] Advanced job matching
  - [ ] Multiple payment providers
  - [ ] Enhanced analytics

- [ ] Phase 3: Advanced Features
  - [ ] AI integration
  - [ ] Enterprise features
  - [ ] Regional expansion

## Screen-by-Screen Implementation Guide

This section provides step-by-step instructions for implementing each major screen in the Kazi Huru app, inspired by the provided wireframe. All screens should support Swahili and follow Material Design best practices.

### 1. Home / Dashboard (Mwanzo)
**Purpose:**
- Display user balance (Salio Lako)
- Allow user to add balance (Ongeza Salio)
- Show a list of available jobs (Kazi Zilizopo)
- Quick access to apply for jobs (Omba)

**Key UI Elements:**
- AppBar with app name (Kazi Za Chap)
- Balance card with current balance and 'Ongeza Salio' button
- Section header: 'Kazi Zilizopo'
- List of job cards, each with:
  - Job title (e.g., Kumuhamisha Mtu)
  - Location (e.g., Dar es Salaam)
  - Payment amount (e.g., TZS 20,000)
  - 'Omba' (Apply) button
- Bottom navigation bar (Mwanzo, Tuma Kazi, Kazi Zangu)

**Implementation Tips:**
- Use a `ListView` for jobs
- Use `Card` widgets for balance and job items
- Use `ElevatedButton` or `OutlinedButton` for actions
- Ensure all text is easily translatable to Swahili

### 2. Add Balance (Ongeza Salio)
**Purpose:**
- Allow users to top up their balance via mobile money

**Key UI Elements:**
- Input field for amount
- Mobile money provider selection (M-Pesa, Tigo Pesa, Airtel Money)
- Confirm button
- Success/failure feedback

**Implementation Tips:**
- Validate input for minimum/maximum amounts
- Integrate with payment APIs
- Show loading and error states

### 3. Job List & Application (Kazi Zilizopo & Omba)
**Purpose:**
- Display all available jobs
- Allow users to apply for a job

**Key UI Elements:**
- List of jobs with details (title, location, amount)
- 'Omba' button for each job
- Confirmation dialog when applying
- Feedback on application status

**Implementation Tips:**
- Fetch jobs from Firestore
- Use real-time updates for job availability
- Show application status (pending, accepted, rejected)

### 4. Post Job (Tuma Kazi)
**Purpose:**
- Allow job providers to post new jobs

**Key UI Elements:**
- Form fields: Job title, description, location, amount
- Submit button
- Success/failure feedback

**Implementation Tips:**
- Validate all fields
- Save job to Firestore under provider's account
- Show confirmation on success

### 5. My Jobs (Kazi Zangu)
**Purpose:**
- Show jobs the user has posted or applied for
- Track application status

**Key UI Elements:**
- Tabs or filters for 'Posted' and 'Applied' jobs
- List of jobs with status indicators
- Option to cancel or update jobs

**Implementation Tips:**
- Use Firestore queries to filter jobs by user
- Display clear status (e.g., In Progress, Completed, Cancelled)

### 6. Navigation & Localization
**Purpose:**
- Ensure smooth navigation between screens
- Support Swahili and English

**Key UI Elements:**
- Bottom navigation bar with icons and Swahili labels
- Drawer or profile menu for additional options

**Implementation Tips:**
- Use `BottomNavigationBar` for main navigation
- Use `Intl` package for localization
- Store translations in `assets/translations/`

### 7. General UI/UX Guidelines
- Use Material Design 3 components
- Ensure all buttons and text are accessible
- Use consistent padding and spacing
- Provide feedback for all user actions
- Test on various device sizes

## Additional Features & Considerations

To ensure Kazi Huru is robust, user-friendly, and competitive, consider implementing the following features and best practices:

### 1. User Onboarding & Help
- Onboarding screens for first-time users (explain app features, permissions, etc.)
- In-app help/FAQ section (Swahili and English)
- Contact support (chat, email, or phone)

### 2. Profile Management
- Profile picture upload (with cropping)
- Edit profile (name, phone, location, etc.)
- Verification (ID, phone, email, etc.)

### 3. Notifications
- Push notifications for job status, new jobs, messages, etc.
- In-app notification center (history of notifications)

### 4. Security & Privacy
- Two-factor authentication (optional, via SMS)
- User data privacy policy (link in app)
- Block/report users (for abuse or spam)

### 5. Job Management Enhancements
- Job filtering & sorting (by location, pay, type, etc.)
- Job details page (with full description, requirements, map, etc.)
- Job expiry/auto-archive (old jobs are hidden or archived)

### 6. Ratings & Reviews
- Rate/review after job completion (both for seekers and providers)
- Display average ratings on profiles

### 7. Payments & Transactions
- Transaction history (for both seekers and providers)
- Withdrawal requests (for providers)
- Receipts/invoices (downloadable or emailable)

### 8. Localization & Accessibility
- Full Swahili and English support (including error messages)
- Accessibility (screen reader support, large text, color contrast)

### 9. Admin/Moderation Tools
- Admin dashboard (web or app) for managing users, jobs, disputes
- Flagged content review (for inappropriate jobs or users)

### 10. Testing & Analytics
- Crash reporting (Firebase Crashlytics)
- User analytics (Firebase Analytics)
- A/B testing (for new features)

### 11. Other Best Practices
- Terms & Conditions and Privacy Policy links in the app
- App version and update check
- Offline/poor network handling (graceful error messages)
- Dark mode support

**Recommendation:**
- Review this list and prioritize features for MVP vs. future releases.
- Document any additional requirements or user stories as you go.
- Ensure all features are implemented with strong error handling, localization, and a focus on user experience.

---