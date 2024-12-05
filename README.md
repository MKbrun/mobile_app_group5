# Group 5 Mobile App Project

Welcome to our mobile app project! This app is built for effective communication, scheduling, and collaboration among team members. We aimed to keep the app intuitive and user-friendly while implementing features like channels, private chats, and shift management.

---

## 📱 Features

### 🌐 Channels
- **Admins** can:
  - Create, update, and delete channels.
  - Add or remove members from channels.
- **Users** can:
  - View and interact with channels they are part of.
  - Access announcements and messages.
  - See other member of the channels

### 💬 Private Chats
- Chat one-on-one with other users.
- Send text and image messages.
- View the latest chat updates in the "Contacts" screen.

### 📅 Calendar & Shift Management
- View important dates on a shared calendar.
- Manage shifts:
  - Admins can add new shifts.
  - Users can claim available shifts.
  - Users can trade shifts between them

 ### 😂 Profile
 - See profile information, such as profile picture, username and email.
 - See settings
     -Change theme
 - Logout

---

## 🛠️ How It Works

### Navigation
- The app has a **bottom navigation bar** with three main sections:
  1. **Channels**: Manage and participate in group discussions.
  2. **Contacts**: Chat privately with team members.
  3. **Calendar**: View events and manage shifts.

### Roles
- Users are assigned **roles** (`Admin` or `User`) that determine their access:
  - **Admins** have full control over channels and shifts.
  - **Users** can view and interact with channels they are added to.

---

## 🎨 Screens Overview

| **Screen**            | **Description**                                                                 |
|-----------------------|---------------------------------------------------------------------------------|
| **Home**              | A welcome screen with quick access to the main navigation.                     |
| **Channels**          | A list of available channels. Admins can manage, and users can participate.     |
| **Private Chats**     | Chat privately with other users, view contact lists, and see last message previews. |
| **Calendar**          | A shared calendar for important dates.                                         |
| **Shift Management**  | Admins can manage shifts, and users can claim available ones.                  |

---

## 🚀 Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone <repository_url>
   cd <repository_folder>
   ```
2. **Install flutter dependencies:**
   ```bash
   flutter pub get
   ```
### :eggplant: Set Up Firebase

1. Download you Firebase configuration files:
   - For **Android**: Place the `google-services.json` file in the `andoird/app/` directory.
   - For **iOS**: Place the `GoogleService-Info.plist` file in the `ios/Runner/` directory.
2. Enable the follwing services in your Firebase Console:
   - Firestore Database
   - Firebase Authentication
   - Firebase Storage

### Run the App
use the following command to start the app:
```bash
flutter run
```

### Test Functionality
- Verify features like channels, private messaging, calendar, and role-based access.
- Test on both Android and iOS devices

---

## :dancers: Team Contributions
This projects is a group effort, and each team member contributed to different aspects of the application
- **Design**: Created a user-friendly and intuative interface.
- **Development**: Built frontend and backend logic for different parts of the app, making sure to integrate the Firebase services

## 🔗 Technologies Used
- **Flutter**: Framework for building the app
- **Firebase**: Backend services for authentication, database and storage
- **Mockito**: Used to mock firebase backend for testing
- **Android studio**: Testing the app in a virtual device
- **ChatGPT**: Helped research and debug the code.
  When error messages appeared after making changes, ChatGpt was useful for debugging what went wrong and how to fix it.
  It was also useful for understanding the firestore database rules, setup and correct usage of the features firebase has to offer.
  When we had an issue adding a new feature we could ask ChatGpt which solutions were relevant for our feature and how to best implement it.
- **CoPilot**: Helped alot during debugging with its autocompletion feature and its ability to answer question regarding specific files and segments of the code.

## Additional Information

For more detailed information, please refer to the [Wiki](https://github.com/MKbrun/mobile_app_group5/wiki).

* Class Diagram: [Read Wiki](https://github.com/MKbrun/mobile_app_group5/wiki/Class-diagram)
* Team Meetings: [Read Wiki](https://github.com/MKbrun/mobile_app_group5/wiki/Team-meetings)
* User Stories: [Read Wiki](https://github.com/MKbrun/mobile_app_group5/wiki/User-Stories)
* Wireframes: [Read Wiki](https://github.com/MKbrun/mobile_app_group5/wiki/Wireframe)
