CampusZone is a comprehensive Flutter mobile application designed to enhance campus life by providing a centralized platform for students to connect, share resources, and stay informed about campus activities.

## Features

- **User Authentication**
  - Sign up/Login functionality
  - Password recovery
  - Profile creation

- **Profile Management**
  - View and edit profile details
  - Update profile picture with image cropping
  - Account settings

- **Community Section**
  - Campus events listing and details
  - Event registration via external URLs
  - Community announcements

- **Notice Board**
  - Campus-wide announcements and notifications
  - Interactive notices with expandable content
  - Timestamp and categorization

- **Resources Section**
  - Lost and Found system
    - Post lost/found items with images
    - Add descriptions
    - Comment functionality

- **Chat System**
  - Direct messaging between users
  - Message history
  - Real-time updates

## Screenshots

<div style="display: flex; flex-wrap: wrap; gap: 10px;">
  <img src="https://github.com/user-attachments/assets/a4ec75fb-01cc-443e-a90c-d06ed4bc2cdf" width="150">
  <img src="https://github.com/user-attachments/assets/7303e637-c207-4543-a016-01c879f7a77d" width="150">
  <img src="https://github.com/user-attachments/assets/e8e514c6-e537-4f60-a047-1698a4727693" width="150">
  <img src="https://github.com/user-attachments/assets/a0a0b57d-1ddc-40a9-a468-7c0e9c882cb5" width="150">
  <img src="https://github.com/user-attachments/assets/f96ff3f8-22e6-4e31-bd69-1ac408c9054a" width="150">
  <img src="https://github.com/user-attachments/assets/d997fae5-676d-409b-9df7-0c726f3a5fdf" width="150">
  <img src="https://github.com/user-attachments/assets/48bc5890-00c0-4a32-8dd2-169a0f08e319" width="150">
  <img src="https://github.com/user-attachments/assets/cf35e964-d149-4212-b5a8-ac241b9559ae" width="150">
</div>



## Project Structure

```
campuszone                              # project root
├── analysis_options.yaml
├── assets                              # custom assets including fonts
│   ├── fonts
│   │   └── Excalifont.ttf
│   └── profile.png
├── lib
│   ├── auth                            # Authentication related screens
│   │   ├── auth.dart
│   │   ├── forgot_pass.dart
│   │   ├── login_page.dart
│   │   ├── name_page.dart
│   │   └── register_page.dart
│   ├── chat                            # Chat functionality
│   │   ├── chatList.dart
│   │   └── chatmsgpage.dart
│   ├── custom                          # Custom UI components
│   │   └── custom_divider.dart
│   ├── globals.dart                    # Global variables and constants 
│   ├── main.dart
│   ├── pages                           # Main navigation pages
│   │   ├── navbar.dart
│   │   └── profilelink.dart
│   └── ui                              # UI components organized by feature
│       ├── community                   # Community and events related screens
│       │   ├── community.dart
│       │   └── events
│       │       ├── eventdetails.dart
│       │       └── events.dart
│       ├── home                        # Home screen and notice board
│       │   ├── home.dart
│       │   └── Noticeboard.dart
│       ├── profile                     # Profile related screens
│       │   ├── about.dart
│       │   ├── editprofile
│       │   │   ├── EditProfile.dart
│       │   │   └── profilepic
│       │   │       ├── fullscreenpicpage.dart
│       │   │       └── ProfilePicture.dart
│       │   ├── profile.dart
│       │   └── settings.dart
│       └── resources                   # Resources page including lost and found Section
│           ├── lostandfound
│           │   ├── comments
│           │   │   ├── commentitem.dart
│           │   │   └── comments.dart
│           │   ├── fullscreenpicpage.dart
│           │   ├── LostandFound.dart
│           │   └── UploadData.dart
│           └── resources.dart
├── pubspec.lock
├── pubspec.yaml                        # dependencies and assets 
├── README.md
```

## Setup Instructions

### Prerequisites

- Flutter SDK version 3.6.0 or higher
- Dart SDK
- Android Studio / VS Code with Flutter plugins
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/structnull/campuszone.git
   cd campuszone
   ```

2. **Set up environment variables**
   
   Create a .env file in the root directory with the following variables:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Configure Supabase**
   
   Create the following tables in your Supabase instance:
   - users (extends auth.users)
   - notices
   - events
   - Chat messages
   - Lost and found items

5. **Run the application**
   ```bash
   flutter run
   ```

## Dependencies

CampusZone relies on several key packages:

- [supabase_flutter](https://pub.dev/packages/supabase_flutter) - Backend and authentication
- [image_picker](https://pub.dev/packages/image_picker) & [image_cropper](https://pub.dev/packages/image_cropper) - Image handling
- [google_fonts](https://pub.dev/packages/google_fonts) - Typography
- [url_launcher](https://pub.dev/packages/url_launcher) - Open external links
- [permission_handler](https://pub.dev/packages/permission_handler) - Request permissions
- [connectivity_plus](https://pub.dev/packages/connectivity_plus) - Network state management
- [shimmer](https://pub.dev/packages/shimmer) & [flutter_staggered_animations](https://pub.dev/packages/flutter_staggered_animations) - UI effects

For a complete list of dependencies, see the pubspec.yaml file.

## Platform Support

CampusZone is configured for multiple platforms:
- Android
- iOS
- Web
- Linux
- macOS
- Windows

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Custom Fonts
The application uses a custom font called "Excalifont" located in assets/Fonts/Excalifont.ttf.

## Contributions

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the  License - see the LICENSE file for details.

## Acknowledgements

- Johan , kinnan , nandu for their ideas and support
