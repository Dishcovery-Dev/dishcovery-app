# 🍽️ DISHCOVERY App

-----

## 📝 About The App

Dishcovery is a mobile application that helps users discover and learn about Indonesian cuisine through advanced AI image recognition. Built for the BEKUP 2025 Capstone Project, this app makes exploring Indonesian culinary delights easier and more engaging.

-----

## ✨ Key Features

  - 📸 AI-powered food recognition
  - 🍳 Detailed food information and recipes
  - 📍 Location-based food recommendations
  - 📱 Offline-first architecture with ObjectBox
  - 🌙 Dark/Light theme support
  - 🌐 Multi-language support (ID/EN)
  - 📚 Search history management
  - 🎯 Personalized food preferences

-----

## 🏗️ Architecture

This project uses **Clean Architecture** with **Feature-First** organization for better scalability and maintainability:

-----

## 🛠️ Tech Stack

  - **Framework**: Flutter
  - **Language**: Dart
  - **State Management**: Provider
  - **Local Database**: ObjectBox
  - **Authentication**: Firebase Auth
  - **AI Services**: Custom AI API
  - **Analytics**: Firebase Analytics
  - **Image Processing**: Camera API
  - **Localization**: Easy Localization
  - **Navigation**: GoRouter

-----

## 🚀 Installation & Setup

### Prerequisites

  - [Flutter SDK](https://flutter.dev/docs/get-started/install)
  - [Firebase CLI](https://firebase.google.com/docs/cli)
  - [Git](https://git-scm.com/)

### Installation Steps

1.  **Clone the repository**

    ```bash
    git clone https://github.com/Dishcovery-Dev/dishcovery-app.git
    cd dishcovery-app
    ```

2.  **Install dependencies**

    ```bash
    flutter pub get
    ```

3.  **Firebase Setup**
    - Create a Firebase project
    - Add Android & iOS apps in Firebase Console
    - Download and place configuration files:
      - `google-services.json` in `android/app/`
      - `GoogleService-Info.plist` in `ios/Runner/`
    - Initialize Firebase:
      ```bash
      firebase login
      flutterfire configure
      ```

4.  **Generate ObjectBox Code**

    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

5.  **Run the app**

    ```bash
    flutter run
    ```

-----

## 📱 Development

### Code Generation

```bash
# One-time generation
flutter pub run build_runner build

# Watch mode
flutter pub run build_runner watch

# Force generation
flutter pub run build_runner build --delete-conflicting-outputs
```

### Building for Release

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

-----

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

-----

## 📁 Project Structure

For detailed project structure and organization, see the folder structure above in the Architecture section.

-----

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

-----

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

-----

## 👥 Team

BEKUP 2025 Capstone Project Team:
- [Fadhil Alif Priyatno](https://github.com/FadhilAlif)
- [Galih Putro Aji](https://github.com/galihvsx)
- [Yunanto Biantoro](https://github.com/Drmobkey)
- [Mochammad Rizky Ramadhani](https://github.com/Mokyra18)

-----

## 📞 Support

If you encounter any issues or have questions:

1. Check existing [Issues](https://github.com/Dishcovery-Dev/dishcovery-app/issues)
2. Create a new issue
3. Contact the development team

For questions or feedback, please contact us at:  
- Email: [contact.dishcovery@gmail.com](mailto:contact.dishcovery@gmail.com)  

-----

## 🙏 Acknowledgments

- [BEKUP 2025](https://bekup.com) for the opportunity
- The Flutter Community
- Our mentors and advisors

-----

**Happy Cooking! 🍳**
## 📂 Folder Structure

```text
lib/
├─ main.dart # Entry point aplikasi
├─ app.dart # Root MaterialApp, theme, route init
│
├─ routes/
│ └─ app_routes.dart # Route name & generator/GoRouter
│
├─ config/
│ ├─ env.dart # Runtime env (dart-define)
│ └─ theme.dart # Konfigurasi light/dark theme
│
├─ core/
│ ├─ utils/ # Helper (debounce, formatter, etc.)
│ ├─ errors/ # AppException, failure mapper
│ └─ widgets/ # Reusable UI atoms (EmptyState, Button, dll.)
│
├─ services/
│ ├─ api_client.dart # HTTP client (Dio singleton + interceptors)
│ ├─ image_picker_service.dart # Kamera / galeri handler
│ └─ storage_service.dart # Local storage wrapper (SharedPref/Hive/Isar)
│
├─ models/
│ ├─ recognition_result.dart # Data model hasil pengenalan
│ └─ food_item.dart # Data model item makanan
│
├─ repositories/
│ ├─ food_repository.dart # Akses API: recognize, recommendations
│ └─ history_repository.dart # Akses lokal CRUD history
│
├─ controllers/
│ ├─ recognition_controller.dart # State + logic untuk food recognition
│ ├─ history_controller.dart # State + logic untuk riwayat
│ └─ settings_controller.dart # State + logic untuk pengaturan
│
└─ views/
├─ capture/
│ ├─ capture_page.dart # UI untuk ambil/pilih foto
│ └─ widgets/...
│
├─ result/
│ ├─ result_page.dart # UI untuk hasil pengenalan
│ └─ widgets/...
│
├─ history/
│ ├─ history_page.dart # UI daftar riwayat pencarian
│ └─ widgets/...
│
└─ settings/
└─ settings_page.dart # UI halaman pengaturan




