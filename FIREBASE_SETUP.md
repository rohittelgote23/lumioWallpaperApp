# Firebase Setup Guide for LumioWalls

This guide provides detailed instructions for setting up Firebase for the LumioWalls application.

## Table of Contents

1. [Create Firebase Project](#create-firebase-project)
2. [Enable Firestore](#enable-firestore)
3. [Enable Firebase Storage](#enable-firebase-storage)
4. [Configure Security Rules](#configure-security-rules)
5. [Add Sample Data](#add-sample-data)
6. [Upload Sample Wallpapers](#upload-sample-wallpapers)

## Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `LumioWalls` (or your preferred name)
4. **Google Analytics**: Optional (you can disable it for simplicity)
5. Click **"Create project"**
6. Wait for project creation to complete

## Enable Firestore

1. In the Firebase Console, select your project
2. Click **"Firestore Database"** in the left sidebar
3. Click **"Create database"**
4. **Security rules**: Start in **production mode**
5. **Location**: Choose a location close to your target users
6. Click **"Enable"**

## Enable Firebase Storage

1. In the Firebase Console, click **"Storage"** in the left sidebar
2. Click **"Get started"**
3. **Security rules**: Start in **production mode**
4. **Location**: Use the same location as Firestore
5. Click **"Done"**

## Configure Security Rules

### Firestore Security Rules

Go to **Firestore Database** → **Rules** tab and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow public read access to categories
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if false; // Only admin can write via Firebase Console
    }
    
    // Allow public read access to wallpapers
    match /wallpapers/{wallpaperId} {
      allow read: if true;
      allow write: if false; // Only admin can write via Firebase Console
    }
  }
}
```

**Important**: These rules allow public read access but prevent writes from the app. Only you (admin) can add/modify data through the Firebase Console.

### Firebase Storage Security Rules

Go to **Storage** → **Rules** tab and replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow public read access to wallpapers
    match /wallpapers/{allPaths=**} {
      allow read: if true;
      allow write: if false; // Only admin can upload via Firebase Console
    }
  }
}
```

**Publish** both rule sets after editing.

## Add Sample Data

### Create Categories

1. Go to **Firestore Database**
2. Click **"Start collection"**
3. Collection ID: `categories`
4. Add the following documents:

#### Document 1: Nature
```
Document ID: nature (or auto-generated)
Fields:
  - name: "Nature" (string)
  - order: 1 (number)
  - isActive: true (boolean)
```

#### Document 2: Abstract
```
Document ID: abstract (or auto-generated)
Fields:
  - name: "Abstract" (string)
  - order: 2 (number)
  - isActive: true (boolean)
```

#### Document 3: Minimal
```
Document ID: minimal (or auto-generated)
Fields:
  - name: "Minimal" (string)
  - order: 3 (number)
  - isActive: true (boolean)
```

### Create Wallpapers

1. In Firestore, create a new collection: `wallpapers`
2. Add sample wallpaper documents:

#### Sample Wallpaper Document
```
Document ID: (auto-generated)
Fields:
  - title: "Mountain Sunset" (string)
  - categoryId: "nature" (string) // Must match a category document ID
  - thumbnailUrl: "https://firebasestorage.googleapis.com/..." (string)
  - displayUrl: "https://firebasestorage.googleapis.com/..." (string)
  - downloadUrl: "https://firebasestorage.googleapis.com/..." (string)
  - createdAt: (timestamp) // Click "timestamp" type and set to current time
  - isActive: true (boolean)
```

**Note**: You'll need to upload images to Storage first to get the URLs.

## Upload Sample Wallpapers

### Prepare Images

For each wallpaper, prepare three versions:
1. **Thumbnail**: ~200px width (for fast loading in lists)
2. **Display**: ~800px width (for in-app preview)
3. **Original**: Full resolution (for download)

You can use online tools like [TinyPNG](https://tinypng.com/) or image editors to create these versions.

### Upload to Firebase Storage

1. Go to **Storage** in Firebase Console
2. Create folder structure:
   ```
   wallpapers/
   ├── nature/
   │   ├── thumbs/
   │   ├── display/
   │   └── original/
   ├── abstract/
   │   ├── thumbs/
   │   ├── display/
   │   └── original/
   └── minimal/
       ├── thumbs/
       ├── display/
       └── original/
   ```

3. Upload images to respective folders:
   - Click **"Upload file"**
   - Select image file
   - Upload to appropriate folder

4. Get download URLs:
   - Click on uploaded file
   - Copy the **"Download URL"** (or click the link icon)
   - Use this URL in Firestore wallpaper documents

### Example Upload Process

For a nature wallpaper called "mountain_sunset":

1. Upload `mountain_sunset_thumb.jpg` to `wallpapers/nature/thumbs/`
2. Upload `mountain_sunset_display.jpg` to `wallpapers/nature/display/`
3. Upload `mountain_sunset_original.jpg` to `wallpapers/nature/original/`
4. Copy all three download URLs
5. Create wallpaper document in Firestore with these URLs

## Testing

After setup:

1. Run the Flutter app
2. You should see categories on the home screen
3. Tap a category to see wallpapers
4. Tap a wallpaper to view details
5. Test download and favorite functionality

## Tips

### Finding Free Wallpapers

- [Unsplash](https://unsplash.com/) - Free high-quality images
- [Pexels](https://pexels.com/) - Free stock photos
- [Pixabay](https://pixabay.com/) - Free images and videos

### Image Optimization

- Use WebP format for smaller file sizes
- Compress images before uploading
- Maintain aspect ratio of 9:16 for mobile wallpapers

### Batch Upload

For uploading many wallpapers:
1. Use Firebase Admin SDK (Node.js/Python)
2. Write a script to batch upload images and create Firestore documents
3. See Firebase documentation for Admin SDK setup

## Common Issues

### "Permission denied" errors
- Check security rules are published
- Ensure rules allow read access

### Images not loading
- Verify download URLs are correct
- Check CORS settings in Storage
- Ensure images are publicly accessible

### Categories not showing
- Verify `isActive` is set to `true`
- Check `order` field exists and is a number
- Ensure collection name is exactly `categories`

## Next Steps

1. Add more categories and wallpapers
2. Organize wallpapers by themes
3. Consider adding tags or search functionality
4. Monitor usage in Firebase Analytics (if enabled)

---

**Need help?** Check the [Firebase Documentation](https://firebase.google.com/docs) or create an issue in the repository.
