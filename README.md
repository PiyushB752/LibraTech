# LibraTech - Public Library Management System

LibraTech is a **Flutter + Firebase–powered Library Management System** with **role-based access control**, real-time book management, and secure borrowing functionality.

The application supports **two roles**:
- 👤 **User** – Browse, search, borrow, and manage borrowed books
- 🛠 **Admin** – Manage library inventory (add, edit, delete books)

## 🚀 Features

### 🔐 Authentication
- Email & Password authentication using Firebase Auth
- Secure login and signup flow
- Persistent user sessions
- Logout functionality

### 👤 User Panel
- View all available books (real-time updates)
- Search books by **title or author**
- Filter books by **category**
- View detailed book information
- Borrow books (if available)
- Prevent duplicate borrowing
- View **My Borrowed Books**
- Return borrowed books
- Visual availability status (Available / Borrowed)

### 🛠 Admin Panel
- Add new books
- Edit existing book details
- Delete books
- View availability counts
- Admin-only access enforced by Firestore rules

### 🔒 Role-Based Access Control (RBAC)
- User roles stored in Firestore (`users/{uid}`)
- Default role: `user`
- Admin access controlled via Firestore
- UI and backend both enforce role restrictions
- **No client-side privilege escalation**


## 🧱 Tech Stack

| Layer | Technology |
|------|-----------|
| Frontend | Flutter |
| Backend | Firebase |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| State Updates | Firestore Streams |
| Environment | `flutter_dotenv` |

## 🗂 Project Structure
```
lib/
├── admin/
│ ├── screens/
│ └── services/
├── auth/
│ ├── screens/
│ └── services/
├── books/
│ ├── models/
│ ├── screens/
│ └── services/
├── core/
│ ├── screens/
│ └── theme/
├── shared/
│ └── widgets/
└── main.dart
```

## 🔐 Firestore Data Model

### 📘 Books Collection
```
books/{bookId}
{
title: string,
author: string,
isbn: string,
category: string,
description: string,
totalCopies: number,
availableCopies: number
}
```

### 📕 Borrowed Books Collection
```
borrowed_books/{borrowId}
{
bookId: string,
userId: string,
borrowedAt: timestamp,
dueDate: timestamp
}
```

### 👤 Users Collection
```
users/{uid}
{
email: string,
role: "user" | "admin",
createdAt: timestamp
}
```

## ▶️ Running the Project
```
cd client
flutter pub get
flutter run
```

## 🧪 Role Behavior

1. New users are assigned the user role by default
2. Admin role must be assigned manually in Firestore
3. Users can only access user features
4. Admins have exclusive access to the admin dashboard

## 👨‍💻 Creators

1. Piyush
2. Pawan
3. Nikhil