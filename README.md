# Goa Moments - Luxury Membership Mobile Application

A premium, production-ready mobile application built from scratch with Flutter, Dart, and Supabase. The application is styled with a sleek, luxury black and gold theme inspired by brands like Rolls Royce, Rolex, and Ritz Carlton.

---

## 🌟 Key Features

1. **Luxury Theme**: High-end black-and-gold design utilizing glassmorphism, gold glow animations, and premium typography (Outfit).
2. **Robust Security**:
   - **One Device Only**: Members are restricted to exactly one active device registration. Attempts to register from a different device prompt a luxury security alert.
   - **Screenshot Prevention**: The Membership Card screen restricts screenshots.
   - **Encrypted Local Storage**: Sessions and state are encrypted using `flutter_secure_storage`.
3. **Goa Geolocation Gate**: Activation is only allowed if the user is physically located inside Goa (validated using the `geolocator` package).
4. **Dynamic Content Engine**: Benefits, membership plans, support contacts, and service partners are loaded dynamically from Supabase.
5. **Admin Panel Readiness**: Full CRUD support for future Admin Dashboards integrated into services/repositories.
6. **QR-Code Verification**: A premium, secure QR code generated dynamically from membership data for partner check-ins.
7. **Graceful Demo Mode**: Automatically executes in a mock-data "Demo Mode" if Supabase keys are missing or invalid.

---

## 📂 Project Architecture

The codebase adheres strictly to **Clean Architecture** combined with the **MVVM (Model-View-ViewModel)** pattern:

```text
lib/
├── models/         # Data representation models (Member, Benefit, Partner, etc.)
├── services/       # Core system/infrastructure services (Supabase, Geolocation, OTP, QR, Notifications)
├── repositories/   # Abstract & concrete data brokers (Member, Activation, Content)
├── viewmodels/     # State management, business logic, and UI bindings
├── widgets/        # Reusable premium widgets (LuxuryCard, GoldButton, DashboardTile)
├── screens/        # Distinct application views (Splash, Welcome, Activation, OTP, Dashboard, etc.)
└── main.dart       # Application entry point & service providers
```

---

## 🛠️ Step-by-Step Supabase Connection Guide

To run this application in live production mode with your Supabase backend:

### Step 1: Create a Supabase Project
1. Visit [supabase.com](https://supabase.com) and sign in.
2. Click **New Project**, select an organization, enter a name (e.g., `Goa Moments`), set a secure database password, choose a region close to your users, and click **Create New Project**.

### Step 2: Initialize Database Schema
1. Inside your Supabase Project dashboard, navigate to the **SQL Editor** tab from the left sidebar.
2. Click **New Query** to create a blank query.
3. Open the `schema.sql` file located at the root of this Flutter project.
4. Copy the entire contents of `schema.sql`, paste them into the Supabase SQL editor, and click **Run**.
5. Verify that the SQL executes successfully (creating tables `membership_plans`, `members`, `device_registrations`, `activation_logs`, `benefits`, `support_tickets`, `notifications`, `service_partners`, their corresponding indexes, triggers, and seeding initial mock data).

### Step 3: Configure Environment Variables
1. In the Supabase project dashboard, navigate to **Project Settings** (gear icon) -> **API**.
2. Locate the **Project API keys**:
   - **Project URL** (under API Settings)
   - **anon public** key
3. At the root of this Flutter project, create a file named `.env` and paste these values:
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```
4. *Note: If this file is empty or missing, the application will fallback to **Demo Mode** automatically, allowing you to test the complete user experience with offline mock data.*

---

## 🚀 Installation & Running

### Requirements
- Flutter SDK (latest stable, 3.10+ recommended)
- Dart SDK
- Android SDK / Xcode (for running on emulator or physical devices)

### Setup
1. Clone or download the repository.
2. Open terminal in the directory and run:
   ```bash
   flutter pub get
   ```
3. Run the application on your connected device:
   ```bash
   flutter run
   ```

---

## 🔒 Security Settings & Notes

- **Android Screenshot Protection**: Handled at runtime via native window flags.
- **iOS Screenshot Protection**: Detects screenshots/screen recordings and overlays a security screen.
- **Device ID Retrieval**: Uses `device_info_plus` to extract unique OS identifiers.
- **Local Storage Encryption**: Uses `flutter_secure_storage` to write OAuth tokens and session data.
