# LumioWalls - Flutter Wallpaper Application

A production-ready Flutter wallpaper application with Firebase backend, BLoC state management, and modern UI/UX. Download beautiful wallpapers to your device with support for favorites and dark mode.

## Features

✨ **Dynamic Content Management**
- Categories and wallpapers managed through Firebase Firestore
- No app updates required to add new content
- Real-time content updates

🎨 **Modern UI/UX**
- Beautiful light and dark themes
- Smooth animations and transitions
- Skeleton loaders for better UX
- Responsive grid layouts

📥 **Download Wallpapers**
- Download full-resolution wallpapers to device gallery
- Progress tracking during downloads
- Automatic permission handling

❤️ **Favorites**
- Save favorite wallpapers locally
- Offline access to favorites
- Persistent across app restarts

⚙️ **Settings**
- Toggle between light, dark, and system theme
- Theme preference persistence
- App information and about section

## Tech Stack

### Frontend
- **Flutter** - Latest stable version
- **flutter_bloc** - State management
- **Google Fonts** - Premium typography
- **cached_network_image** - Image caching
- **shimmer** - Loading animations

### Backend (No Custom Server)
- **Firebase Firestore** - Database for categories and wallpapers
  # Firebase Storage - Image hosting (Removed)

### Local Storage
- **Hive** - Favorites persistence
- **SharedPreferences** - Theme preference

### Other Packages
- **dio** - HTTP client for downloads
- **permission_handler** - Runtime permissions
- **image_gallery_saver** - Save images to gallery
- **path_provider** - File system paths

## Project Structure

```
lib/
├── core/
│   ├── data/
│   │   ├── models/
│   │   │   ├── category_model.dart
│   │   │   └── wallpaper_model.dart
│   │   └── repositories/
│   │       ├── category_repository.dart
│   │       ├── wallpaper_repository.dart
│   │       └── favorites_repository.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── constants.dart
│       └── permission_helper.dart
├── features/
│   ├── splash/
│   │   └── view/
│   │       └── splash_screen.dart
│   ├── home/
│   │   ├── bloc/
│   │   │   └── category_bloc.dart
│   │   ├── view/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   │       ├── category_section.dart
│   │       └── wallpaper_thumbnail.dart
│   ├── category/
│   │   ├── bloc/
│   │   │   └── wallpaper_bloc.dart
│   │   └── view/
│   │       └── category_screen.dart
│   ├── wallpaper_detail/
│   │   ├── bloc/
│   │   │   └── download_cubit.dart
│   │   └── view/
│   │       └── wallpaper_detail_screen.dart
│   ├── favorites/
│   │   ├── bloc/
│   │   │   └── favorites_cubit.dart
│   │   └── view/
│   │       └── favorites_screen.dart
│   └── settings/
│       ├── bloc/
│       │   └── theme_cubit.dart
│       └── view/
│           └── settings_screen.dart
└── main.dart
```

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name (e.g., "LumioWalls")
4. Follow the setup wizard

### 2. Enable Firestore

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Start in **production mode**
4. Choose a location close to your users

### 3. Enable Firebase Storage

1. In Firebase Console, go to "Storage"
2. Click "Get started"
3. Start in **production mode**

### 4. Add Firebase to Your Flutter App

#### Android

1. In Firebase Console, click "Add app" → Android
2. Enter package name: `com.example.lumiowalls` (or your package name)
3. Download `google-services.json`
4. Place it in `android/app/`

#### iOS

1. In Firebase Console, click "Add app" → iOS
2. Enter bundle ID from `ios/Runner.xcodeproj`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/`

### 5. Configure Firebase Security Rules

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed security rules.

## Firestore Data Structure

### Categories Collection

Collection: `categories`

Example document:
```json
{
  "id": "cartoon",
  "name": "Cartoon",
  "order": 1,
  "thumbnail": "https://cloudinary.com/.../cartoon-thumb.jpg",
  "isActive": true
}
```

### Wallpapers Collection

Collection: `wallpapers`

Example document:
```json
{
  "id": "auto-generated",
  "title": "Naruto Sunset",
  "categoryIds": ["cartoon", "anime"],
  "thumbnail_url": "https://res.cloudinary.com/.../thumb.jpg",
  "full_url": "https://res.cloudinary.com/.../original.jpg",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "isActive": true
}
```

## How to Add Categories

1. Go to Firebase Console → Firestore Database
2. Click "Start collection" → Enter `categories`
3. Add a document with fields:
   - `name` (string): Category name (e.g., "Nature")
   - `order` (number): Display order (e.g., 1, 2, 3)
   - `thumbnail` (string): Thumbnail URL
   - `isActive` (boolean): true

## How to Add Wallpapers

1. **Host images externally (e.g., Cloudinary):**
   - Upload your images to a public host.
   - You need two URLs per wallpaper:
     - `thumbnail_url`: Small resolution for lists.
     - `full_url`: Full resolution for detail/download.

2. **Add wallpaper metadata to Firestore:**
   - Go to Firestore Database → `wallpapers` collection
   - Add document with fields:
     - `title` (string): Wallpaper title
     - `categoryIds` (array of strings): Category IDs (e.g. ["nature", "dark"])
     - `thumbnail_url` (string): Public URL for thumbnail
     - `full_url` (string): Public URL for full image
     - `createdAt` (timestamp): Current timestamp
     - `isActive` (boolean): true

## Running the App

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / Xcode
- Firebase project configured

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd lumiowalls
```

2. Install dependencies:
```bash
flutter pub get
```

3. Add Firebase configuration files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

4. Run the app:
```bash
flutter run
```

### Build for Release

#### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## Permissions

### Android

The app requires the following permissions (already configured in `AndroidManifest.xml`):
- `INTERNET` - Download wallpapers
- `WRITE_EXTERNAL_STORAGE` - Save to gallery (Android 12 and below)
- `READ_EXTERNAL_STORAGE` - Read from gallery (Android 12 and below)
- `READ_MEDIA_IMAGES` - Access photos (Android 13+)

### iOS

Add to `Info.plist`:
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save wallpapers to your photo library</string>
```

## Troubleshooting

### Firebase not initialized
- Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in the correct location
- Run `flutter clean` and `flutter pub get`

### Images not loading
- Check Firebase Storage security rules
- Verify image URLs in Firestore are correct and accessible

### Download not working
- Check storage permissions are granted
- Verify internet connection
- Check Firebase Storage CORS configuration

### Categories not showing
- Ensure categories exist in Firestore
- Check `isActive` is set to `true`
- Verify Firestore security rules allow read access

## License

This project is licensed under the MIT License.

## Support

For issues and questions, please create an issue in the repository.

---

**Built with ❤️ using Flutter and Firebase**
