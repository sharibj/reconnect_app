# Reconnect - Enhanced Relationship Management App 🤝

A beautifully designed Flutter application that helps you maintain meaningful relationships by tracking interactions with your contacts and providing insights into your communication patterns.

## ✨ Key Features

### 🎨 Modern Design
- **Material Design 3** with custom color schemes
- **Google Fonts** (Inter) for clean typography
- **Dark/Light themes** with system integration
- **Gradient backgrounds** and smooth animations
- **Responsive design** for all screen sizes

### 🧭 Intuitive Navigation
- **Bottom Navigation Bar** with 5 main sections
- **Collapsing App Bars** with beautiful gradients
- **Smooth transitions** between screens
- **Pull-to-refresh** functionality

### 🏠 Smart Dashboard
- **Health Score** showing relationship maintenance quality
- **Quick Actions** for common tasks
- **Priority Contacts** needing attention
- **Overview Statistics** at a glance
- **Celebration states** when everything is up-to-date

### 👥 Advanced Contact Management
- **Visual Grid Layout** with contact avatars
- **Real-time Search** and filtering
- **Group Organization** with frequency settings
- **Detailed Contact Profiles** with click-to-call/email
- **Comprehensive Contact Information** storage

### 📊 Rich Analytics
- **Interactive Charts** using fl_chart library
- **Relationship Health Scoring** algorithm
- **Communication Pattern Analysis**
- **Urgency Distribution** visualization
- **Self-initiation Tracking** insights

### 💬 Enhanced Interactions
- **Rich Interaction Cards** with timestamps
- **Multiple Interaction Types** (calls, texts, video, social media, in-person)
- **Contact-specific Filtering**
- **Initiation Tracking** (who reached out first)
- **Safe Deletion** with confirmations

### ⚙️ Comprehensive Settings
- **Theme Management** (Light/Dark/System)
- **Data Export** (JSON/CSV formats)
- **App Information** and version details
- **Feedback System** for user input
- **Secure Account Management**

## 🛠️ Technical Stack

### Core Technologies
- **Flutter 3.35.4** - Cross-platform UI framework
- **Dart 3.9.2** - Programming language
- **Material Design 3** - Design system

### Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter

  # UI & Design
  google_fonts: ^6.2.1
  fl_chart: ^0.68.0
  shimmer: ^3.0.0

  # State Management
  provider: ^6.1.2

  # Networking & Storage
  http: ^1.4.0
  flutter_secure_storage: ^9.2.2
  flutter_dotenv: ^5.2.1

  # Utilities
  intl: ^0.20.2
  path_provider: ^2.1.4
  share_plus: ^10.1.2
  url_launcher: ^6.3.1
  flutter_local_notifications: ^18.0.1
```

### Architecture
- **Provider Pattern** for state management
- **Repository Pattern** for data access
- **Clean Architecture** principles
- **Reactive Programming** with streams
- **Modular Widget Structure**

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.35.4 or later)
- Dart SDK (3.9.2 or later)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd reconnect_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   Create a `.env` file in the root directory:
   ```env
   API_BASE_URL=http://your-api-server:8080/api/reconnect
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### Build Options

- **Debug Build**
  ```bash
  flutter run --debug
  ```

- **Release Build**
  ```bash
  flutter build apk --release  # Android
  flutter build ios --release  # iOS
  flutter build web --release  # Web
  ```

## 📱 App Structure

### Screen Hierarchy
```
Main Navigation
├── Home (Dashboard)
│   ├── Overview Statistics
│   ├── Quick Actions
│   └── Priority Contacts
├── Contacts
│   ├── Contact Grid
│   ├── Search & Filter
│   └── Contact Details
├── Interactions
│   ├── Interaction Timeline
│   ├── Contact Filter
│   └── Add Interaction
├── Analytics
│   ├── Health Score
│   ├── Charts & Graphs
│   └── Insights
└── Settings
    ├── Theme Options
    ├── Data Export
    ├── App Info
    └── Account
```

### State Management
```
Provider Tree
├── ThemeProvider (Dark/Light mode)
├── ContactProvider (Contact data & operations)
├── InteractionProvider (Interaction history)
└── AnalyticsProvider (Health scores & insights)
```

## 🎯 User Journey

### 1. **Onboarding**
- Login through existing authentication
- Automatic data loading and sync
- Welcome to enhanced features

### 2. **Daily Usage**
- Check dashboard for relationship health
- Review contacts needing attention
- Log new interactions quickly
- Browse analytics for insights

### 3. **Contact Management**
- Add new contacts with rich information
- Organize into meaningful groups
- Search and filter efficiently
- View detailed interaction history

### 4. **Analytics & Insights**
- Monitor relationship health score
- Understand communication patterns
- Identify improvement opportunities
- Track progress over time

## 🔧 Configuration

### Theme Customization
Update colors in `lib/theme/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF6C5CE7);
static const Color secondaryColor = Color(0xFFA29BFE);
static const Color accentColor = Color(0xFF00CEC9);
```

### API Configuration
Update endpoint in `.env` file:
```env
API_BASE_URL=https://your-production-api.com/api/reconnect
```

## 📊 Analytics Features

### Health Score Algorithm
The app calculates a relationship health score based on:
- Contact recency and frequency
- User-defined group frequencies
- Interaction consistency
- Response ratios

### Visualization Types
- **Pie Charts**: Health score breakdown, initiation ratios
- **Bar Charts**: Urgency distribution, interaction types
- **Progress Indicators**: Health scores, completion rates
- **Timeline Views**: Interaction history

## 🔐 Privacy & Security

- **Local Storage**: Sensitive data encrypted with flutter_secure_storage
- **API Security**: JWT token-based authentication
- **Data Export**: User-controlled data export options
- **No Tracking**: No third-party analytics or tracking

## 🎨 Design System

### Color Palette
- **Primary**: Purple (#6C5CE7)
- **Secondary**: Light Purple (#A29BFE)
- **Accent**: Teal (#00CEC9)
- **Success**: Green (#00B894)
- **Warning**: Orange (#FFB800)
- **Error**: Red (#E74C3C)

### Typography
- **Font Family**: Inter (Google Fonts)
- **Weights**: 400 (Regular), 500 (Medium), 600 (Semi-Bold), 700 (Bold)
- **Scales**: 10px - 32px with consistent line heights

### Spacing System
- **Base Unit**: 4px
- **Scale**: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64px
- **Consistent Margins**: 16px standard, 8px tight, 24px loose

## 🚀 Future Enhancements

### Planned Features
- **Push Notifications** for contact reminders
- **Calendar Integration** for automatic logging
- **Social Media Sync** for interaction detection
- **AI-Powered Suggestions** for contact timing

### Technical Improvements
- **Offline Support** with local database
- **Advanced Analytics** with ML insights
- **Performance Optimization** for large datasets
- **Accessibility Improvements** for inclusivity

## 🤝 Contributing

This is a personal relationship management app. For feature requests or bug reports, please use the in-app feedback system or contact the development team.

## 📄 License

This project is proprietary software. All rights reserved.

---

**Built with ❤️ using Flutter**

*Reconnect - Because relationships matter*