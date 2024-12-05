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
 - Change theme of application
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
| **Profile**           | A way to see details, log out or change the applications theme from dark or light |

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
- **Managment**: Made sure we were on schedule and deliverd what we needed.

## 🔗 Technologies Used
- **Flutter**: Framework for building the app allowing the app to run on a range of devices.
- **Firebase**: Backend services for authentication, database and storage. Firebase had all the utility we needed including dynamic storage for easy expansion of channels, chats and users.
- **Mockito**: Used to mock firebase backend for testing purposes. This was a vital part to debug the channel's backend functionality, which took some time to implement correcly with the Firestore Database.
- **Android studio**: Testing the app in a virtual device. The ability to wipe the data and setup new devices on command was really helpfull. An example where we needed this was testing the stored data logic. It 
  would log directly in to the app if the devives had previously logged in to the app.
- **ChatGPT**: Helped research and debug the code.
  When error messages appeared after making changes, ChatGpt was useful for debugging what went wrong and how to fix it.
  It was also useful for understanding the firestore database rules, setup and correct usage of the features firebase had to offer.
  When we had an issue adding a new feature we could ask ChatGpt which solutions were relevant for our feature and how to best implement it.

  It also helped research tools we could use. For example the use of Mockito for testing, allowing us to test backend features that needed to communicate with a database. Co-Pilot and ChatGPT would sometimes propose outdated solutions, so only relying on AI is still not viable. Especially when asking about complex features, the AI would get confused and not awnser the question correctly. Stack Overflow is still a great tool to examine human made code which relates to what you're working on.
- **CoPilot**: Helped alot during debugging with its autocompletion feature and its ability to answer question regarding specific files and segments of the code.

## Additional Information

For more detailed information, please refer to the [Wiki](https://github.com/MKbrun/mobile_app_group5/wiki).

* Class Diagram: [Read Wiki](https://github.com/MKbrun/mobile_app_group5/wiki/Class-diagram)
* Team Meetings: [Read Wiki](https://github.com/MKbrun/mobile_app_group5/wiki/Team-meetings)
* User Stories: [Read Wiki](https://github.com/MKbrun/mobile_app_group5/wiki/User-Stories)
* Wireframes: [Read Wiki](https://github.com/MKbrun/mobile_app_group5/wiki/Wireframe)
