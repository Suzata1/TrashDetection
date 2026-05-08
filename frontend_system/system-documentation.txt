# TrashDetectionApp — System Documentation

**Project:** TrashDetectionApp (Return. Recycle. Reward.)  
**Version:** 1.0  
**Date:** May 2026

---

## 1. System Overview

TrashDetectionApp is a waste management and recycling incentive platform consisting of three components:

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Mobile App** | Flutter (Dart) | End-users scan waste, earn credits, find recycling locations |
| **Admin Panel** | React + TypeScript (Vite) | Administrators manage users, partners, locations, rewards |
| **Backend API** | Node.js + Express + MongoDB | RESTful API serving both frontends |

**Actors:**
- **User** — A mobile app user who scans waste items using their phone camera, earns credits for recycling, views scan history/stats, checks the leaderboard, and finds nearby recycling locations.
- **Admin** — An administrator who logs into the web-based admin panel to manage users, partners, collection locations, process reward redemptions (eSewa payouts), and view dashboard analytics.
- **System (Email Service)** — Automated email delivery for password reset links via Gmail SMTP.

---

## 2. Use Case Diagram

```mermaid
graph TB
    subgraph "TrashDetectionApp System"
        UC1["Register Account"]
        UC2["Login"]
        UC3["Forgot / Reset Password"]
        UC4["Change Password"]
        UC5["Scan Waste Item"]
        UC6["Earn Credits"]
        UC7["View Scan History"]
        UC8["View Scan Stats"]
        UC9["View Leaderboard"]
        UC10["View Nearby Locations"]
        UC11["Update Profile"]
        UC12["View Dashboard Stats"]
        UC13["Manage Users (CRUD)"]
        UC14["Manage Partners (CRUD)"]
        UC15["Manage Locations (CRUD)"]
        UC16["Redeem User Credits (eSewa)"]
    end

    User(("👤 User<br/>(Mobile App)"))
    Admin(("🛡️ Admin<br/>(Web Panel)"))
    Email(("📧 Email<br/>Service"))

    User --> UC1
    User --> UC2
    User --> UC3
    User --> UC4
    User --> UC5
    UC5 --> UC6
    User --> UC7
    User --> UC8
    User --> UC9
    User --> UC10
    User --> UC11

    Admin --> UC2
    Admin --> UC3
    Admin --> UC12
    Admin --> UC13
    Admin --> UC14
    Admin --> UC15
    Admin --> UC16

    UC3 --> Email
```

### 2.1 Use Case Descriptions

#### UC1: Register Account
- **Actor:** User
- **Precondition:** User does not have an existing account.
- **Flow:** User provides name, email, phone, and password. System validates uniqueness of email, hashes the password, creates account with role "user" and 0 credits.
- **Postcondition:** Account created; user can log in.

#### UC2: Login
- **Actor:** User, Admin
- **Precondition:** Account exists.
- **Flow:** Actor provides email and password. System verifies credentials and returns a JWT token (valid for 7 days) along with user profile data.
- **Postcondition:** Actor receives JWT token for authenticated requests.

#### UC3: Forgot / Reset Password
- **Actor:** User, Admin
- **Precondition:** Account exists with a valid email.
- **Flow:** Actor submits email. System generates a JWT reset token (1-hour expiry), stores it on the user record, and sends an email with a reset link. Actor clicks the link, enters a new password, and system updates the stored hash.
- **Postcondition:** Password is updated; reset token is cleared.

#### UC4: Change Password
- **Actor:** User (authenticated)
- **Precondition:** User is logged in.
- **Flow:** User provides current password and new password (min 6 chars). System verifies current password, hashes the new one, and updates.
- **Postcondition:** Password changed.

#### UC5: Scan Waste Item
- **Actor:** User
- **Precondition:** User is authenticated.
- **Flow:** User captures a photo via the mobile camera. The app identifies the waste type (cardboard, glass, metal, paper, plastic, trash) with a confidence score. The result is sent to the backend.
- **Postcondition:** WasteScan record created; credits added to user balance.

#### UC6: Earn Credits
- **Actor:** System (triggered by UC5)
- **Flow:** Based on the waste type, credits are calculated from a predefined credit map (paper=1, cardboard=2, plastic=3, glass=4, metal=5, trash=1 Rs.) and CO2 savings are recorded. User's credit balance is incremented.
- **Credit Map:**

| Waste Type | Credits (Rs.) | CO2 Saved (g) |
|-----------|--------------|---------------|
| Paper | 1 | 100 |
| Cardboard | 2 | 150 |
| Plastic | 3 | 250 |
| Glass | 4 | 200 |
| Metal | 5 | 300 |
| Trash | 1 | 50 |

#### UC7: View Scan History
- **Actor:** User
- **Flow:** Returns the user's last 50 waste scan records sorted by date (newest first).

#### UC8: View Scan Stats
- **Actor:** User
- **Flow:** Aggregates user's total scans, total credits earned, and total CO2 saved.

#### UC9: View Leaderboard
- **Actor:** User
- **Flow:** Returns the top 10 users (role=user) sorted by credits descending, showing name, credits, and profile picture.

#### UC10: View Nearby Locations
- **Actor:** User
- **Flow:** Retrieves all active recycling collection locations with vendor name and address.

#### UC11: Update Profile
- **Actor:** User
- **Flow:** User updates name, phone, or profile picture.

#### UC12: View Dashboard Stats
- **Actor:** Admin
- **Flow:** Retrieves total user count, eco-metrics (recycled waste, CO2 saved, rewards earned), and the 5 most recently registered users.

#### UC13: Manage Users (CRUD)
- **Actor:** Admin
- **Flow:** Admin can list all users, view individual user details, update user information, or delete user accounts. Requires admin role.

#### UC14: Manage Partners (CRUD)
- **Actor:** Admin
- **Flow:** Admin can create, list, update, or delete partner organizations (name, email, phone).

#### UC15: Manage Locations (CRUD)
- **Actor:** Admin
- **Flow:** Admin can create, list, update, or delete recycling collection locations (vendor name, address, status: Active/Inactive).

#### UC16: Redeem User Credits (eSewa)
- **Actor:** Admin
- **Flow:** Admin selects a user, specifies an amount to redeem. System validates the user has sufficient credits, deducts the amount, and simulates an eSewa payout.
- **Postcondition:** User's credit balance is reduced by the redeemed amount.

---

## 3. Entity-Relationship (ER) Diagram

```mermaid
erDiagram
    USER {
        ObjectId _id PK
        String name
        String email UK
        String phone
        Number credits
        String password
        String role "user | admin"
        String profilePicture
        String passwordResetToken
        Date passwordResetExpires
        Date createdAt
        Date updatedAt
    }

    WASTE_SCAN {
        ObjectId _id PK
        ObjectId user FK
        String wasteType "cardboard|glass|metal|paper|plastic|trash"
        Number confidence
        Number creditsEarned
        Number co2Saved
        Date createdAt
        Date updatedAt
    }

    PARTNER {
        ObjectId _id PK
        String name
        String email UK
        String phone
        Date createdAt
        Date updatedAt
    }

    LOCATION {
        ObjectId _id PK
        String vendorName
        String vendorAddress
        String status "Active | Inactive"
        Date createdAt
        Date updatedAt
    }

    ROLE {
        ObjectId _id PK
        String name "Admin | User"
        Array permissions "DELETE, UPDATE_USER, etc."
    }

    ADMIN {
        ObjectId _id PK
        String name
        String email UK
        String password
        Date dateOfBirth
        String address
        String gender "Male | Female | Other"
        String passwordResetToken
        Date passwordResetExpires
        Date createdAt
        Date updatedAt
    }

    USER ||--o{ WASTE_SCAN : "performs"
    USER }o--|| ROLE : "has"
```

### 3.1 Entity Descriptions

| Entity | Description | Key Attributes |
|--------|------------|----------------|
| **User** | End-users and admins of the platform. The `role` field distinguishes between "user" and "admin". Password is excluded from default queries (`select: false`). | email (unique), role, credits |
| **WasteScan** | Each record represents one waste scanning event. Links to the User who performed it. Stores the detected waste type, AI confidence score, credits earned, and CO2 saved. | user (FK → User), wasteType, creditsEarned |
| **Partner** | Organizations that partner with the platform for recycling collection or reward programs. | email (unique) |
| **Location** | Physical recycling/collection points managed by vendors. Can be toggled Active/Inactive. | vendorName, status |
| **Role** | Defines named roles with permission arrays (e.g., DELETE, UPDATE_USER). Used for RBAC. | name, permissions[] |
| **Admin** | Separate admin profile model with extended fields (DOB, address, gender). Has its own password reset fields. | email (unique), gender |

### 3.2 Relationships

| Relationship | Cardinality | Description |
|-------------|-------------|-------------|
| User → WasteScan | 1 : N | One user can have many waste scan records. Each scan belongs to exactly one user. |
| User → Role | N : 1 | Each user has one role (stored as a string enum: "user" or "admin"). The Role collection provides additional permission metadata. |

---

## 4. Data Flow Diagrams (DFD)

### 4.1 DFD Level 0 — Context Diagram

The context diagram shows the entire TrashDetectionApp as a single process with its external entities and data flows.

```mermaid
graph LR
    U(("👤 User"))
    A(("🛡️ Admin"))
    E(("📧 Email Service"))
    DB[("🗄️ MongoDB<br/>Database")]

    U -- "Registration Data<br/>Login Credentials<br/>Waste Scan Data<br/>Profile Updates" --> P["0.0<br/>TrashDetection<br/>System"]
    P -- "JWT Token<br/>Credits Balance<br/>Scan History & Stats<br/>Leaderboard<br/>Location List" --> U

    A -- "Login Credentials<br/>User/Partner/Location CRUD<br/>Redemption Requests" --> P
    P -- "JWT Token<br/>Dashboard Stats<br/>User/Partner/Location Lists<br/>Redemption Confirmation" --> A

    P -- "Reset Email Request" --> E
    E -- "Email Delivered Status" --> P

    P <--> DB
```

**External Entities:**
- **User** — Interacts via the Flutter mobile app
- **Admin** — Interacts via the React admin panel
- **Email Service** — Gmail SMTP used for password reset emails
- **MongoDB Database** — Persistent data store (MongoDB Atlas)

---

### 4.2 DFD Level 1 — Major Processes

Decomposes the system into its major functional processes.

```mermaid
graph TB
    U(("👤 User"))
    A(("🛡️ Admin"))
    E(("📧 Email"))
    DB[("🗄️ MongoDB")]

    U -- "email, password, name, phone" --> P1["1.0<br/>Authentication<br/>& Authorization"]
    A -- "email, password" --> P1
    P1 -- "JWT token, user profile" --> U
    P1 -- "JWT token, admin profile" --> A
    P1 -- "Reset email with token link" --> E
    P1 <--> DB

    U -- "wasteType, confidence" --> P2["2.0<br/>Waste Scanning<br/>& Credits"]
    P2 -- "scan record, credits earned, CO2 saved" --> U
    P2 <--> DB

    U -- "request" --> P3["3.0<br/>User Profile<br/>& Leaderboard"]
    P3 -- "profile data, leaderboard, history" --> U
    P3 <--> DB

    A -- "CRUD operations" --> P4["4.0<br/>Admin<br/>Management"]
    P4 -- "users list, partners list, locations list" --> A
    P4 <--> DB

    A -- "userId, amount" --> P5["5.0<br/>Rewards &<br/>Redemption"]
    P5 -- "redemption confirmation, updated balance" --> A
    P5 <--> DB

    A -- "request" --> P6["6.0<br/>Dashboard<br/>Analytics"]
    P6 -- "stats, recent users, eco-metrics" --> A
    P6 <--> DB

    U -- "request" --> P7["7.0<br/>Location<br/>Service"]
    P7 -- "location list" --> U
    P7 <--> DB
```

#### Process Descriptions

| Process | Description | Input | Output |
|---------|------------|-------|--------|
| **1.0 Authentication** | Handles registration, login, forgot password (email), reset password, change password. Issues JWT tokens. | Credentials, email | JWT token, profile, reset email |
| **2.0 Waste Scanning** | Receives waste type + confidence from mobile camera AI, calculates credits and CO2, creates scan record, updates user balance. | wasteType, confidence | Scan record, credits, CO2 |
| **3.0 User Profile** | Returns current user's profile, scan history, scan stats, and leaderboard. | JWT token | Profile, history, stats, leaderboard |
| **4.0 Admin Management** | CRUD operations for users, partners, and locations. Requires admin role. | CRUD data | Entity lists, confirmations |
| **5.0 Rewards & Redemption** | Admin redeems a user's credits via simulated eSewa payout. Validates balance sufficiency. | userId, amount | Confirmation, updated balance |
| **6.0 Dashboard Analytics** | Aggregates platform-wide statistics for the admin dashboard. | Request | Stats, recent users |
| **7.0 Location Service** | Returns all recycling collection locations for mobile app users. | Request | Location list |

---

### 4.3 DFD Level 2 — Process Decomposition

#### 4.3.1 Process 1.0: Authentication & Authorization (Decomposed)

```mermaid
graph TB
    U(("👤 User / Admin"))
    E(("📧 Email"))
    DB[("🗄️ MongoDB")]

    U -- "name, email, phone, password" --> P1_1["1.1<br/>Register<br/>User"]
    P1_1 -- "Check email uniqueness" --> DB
    P1_1 -- "Store hashed password" --> DB
    P1_1 -- "User created confirmation" --> U

    U -- "email, password" --> P1_2["1.2<br/>Login"]
    P1_2 -- "Fetch user by email" --> DB
    P1_2 -- "Compare bcrypt hash" --> P1_2
    P1_2 -- "JWT token + user profile" --> U

    U -- "email" --> P1_3["1.3<br/>Forgot<br/>Password"]
    P1_3 -- "Fetch user by email" --> DB
    P1_3 -- "Store reset token + expiry" --> DB
    P1_3 -- "Send reset link email" --> E

    U -- "token, new password" --> P1_4["1.4<br/>Reset<br/>Password"]
    P1_4 -- "Verify JWT token" --> P1_4
    P1_4 -- "Check token matches + not expired" --> DB
    P1_4 -- "Store new hashed password, clear token" --> DB
    P1_4 -- "Password reset confirmation" --> U

    U -- "currentPassword, newPassword" --> P1_5["1.5<br/>Change<br/>Password"]
    P1_5 -- "Verify current password" --> DB
    P1_5 -- "Store new hashed password" --> DB
    P1_5 -- "Password changed confirmation" --> U
```

**Data Stores accessed:** User collection  
**Security:** Passwords hashed with bcrypt (10 rounds). JWT signed with `JWT_SECRET`, 7-day expiry for login, 1-hour expiry for reset tokens.

---

#### 4.3.2 Process 2.0: Waste Scanning & Credits (Decomposed)

```mermaid
graph TB
    U(("👤 User"))
    DB[("🗄️ MongoDB")]

    U -- "wasteType, confidence" --> P2_1["2.1<br/>Validate<br/>Waste Type"]
    P2_1 -- "Lookup credit & CO2 maps" --> P2_2["2.2<br/>Calculate<br/>Credits & CO2"]
    P2_2 -- "Create WasteScan document" --> P2_3["2.3<br/>Store Scan<br/>Record"]
    P2_3 -- "Save scan" --> DB
    P2_3 --> P2_4["2.4<br/>Update User<br/>Balance"]
    P2_4 -- "Increment user.credits" --> DB
    P2_4 -- "Scan result + updated credits" --> U

    U -- "request" --> P2_5["2.5<br/>Get Scan<br/>History"]
    P2_5 -- "Query scans (last 50)" --> DB
    P2_5 -- "Scan history list" --> U

    U -- "request" --> P2_6["2.6<br/>Get Scan<br/>Stats"]
    P2_6 -- "Aggregate totalScans, totalCredits, totalCO2" --> DB
    P2_6 -- "Aggregated statistics" --> U
```

**Data Stores accessed:** WasteScan collection, User collection  
**Business Rules:**
- Only 6 valid waste types: cardboard, glass, metal, paper, plastic, trash
- Credits and CO2 are determined by predefined lookup maps
- User balance is atomically incremented using MongoDB `$inc`

---

#### 4.3.3 Process 4.0: Admin Management (Decomposed)

```mermaid
graph TB
    A(("🛡️ Admin"))
    DB[("🗄️ MongoDB")]

    A -- "request" --> P4_1["4.1<br/>List All<br/>Users"]
    P4_1 -- "Query all users" --> DB
    P4_1 -- "Users list" --> A

    A -- "user updates" --> P4_2["4.2<br/>Update<br/>User"]
    P4_2 -- "findByIdAndUpdate" --> DB
    P4_2 -- "Updated user" --> A

    A -- "userId" --> P4_3["4.3<br/>Delete<br/>User"]
    P4_3 -- "findByIdAndDelete" --> DB
    P4_3 -- "Deletion confirmation" --> A

    A -- "partner data" --> P4_4["4.4<br/>Manage<br/>Partners"]
    P4_4 -- "Create/Read/Update/Delete" --> DB
    P4_4 -- "Partner data" --> A

    A -- "location data" --> P4_5["4.5<br/>Manage<br/>Locations"]
    P4_5 -- "Create/Read/Update/Delete" --> DB
    P4_5 -- "Location data" --> A
```

**Authorization:** All admin management routes require:
1. Valid JWT (authentication middleware)
2. `role === "admin"` (role authorization middleware)

---

#### 4.3.4 Process 5.0: Rewards & Redemption (Decomposed)

```mermaid
graph TB
    A(("🛡️ Admin"))
    DB[("🗄️ MongoDB")]

    A -- "userId, amount" --> P5_1["5.1<br/>Validate<br/>Redemption"]
    P5_1 -- "Check amount > 0" --> P5_1
    P5_1 -- "Fetch user by ID" --> DB
    P5_1 -- "Check credits >= amount" --> P5_2["5.2<br/>Process<br/>Payout"]
    P5_2 -- "Deduct credits from user" --> DB
    P5_2 -- "Simulate eSewa transfer" --> P5_3["5.3<br/>Confirm<br/>Redemption"]
    P5_3 -- "Success message + updated balance" --> A
```

**Business Rules:**
- Redemption amount must be positive
- User must have sufficient credits (credits >= amount)
- Credits are deducted atomically
- eSewa payout is currently simulated (not integrated with actual eSewa API)

---

## 5. API Endpoint Summary

| Method | Endpoint | Auth | Role | Description |
|--------|---------|------|------|-------------|
| POST | `/api/auth/register` | — | — | Register new user |
| POST | `/api/auth/login` | — | — | Login and receive JWT |
| POST | `/api/auth/forgot-password` | — | — | Send password reset email |
| POST | `/api/auth/reset-password/:token` | — | — | Reset password with token |
| POST | `/api/auth/change-password` | ✅ | — | Change password (logged in) |
| GET | `/api/users/me` | ✅ | — | Get current user profile |
| GET | `/api/users/leaderboard` | ✅ | — | Get top 10 leaderboard |
| GET | `/api/users` | ✅ | admin | List all users |
| GET | `/api/users/:id` | ✅ | — | Get single user |
| PUT | `/api/users/:id` | ✅ | — | Update user |
| DELETE | `/api/users/:id` | ✅ | admin | Delete user |
| POST | `/api/users/:id/redeem` | ✅ | admin | Redeem user credits |
| POST | `/api/waste/scan` | ✅ | — | Scan waste and earn credits |
| GET | `/api/waste/history` | ✅ | — | Get user's scan history |
| GET | `/api/waste/stats` | ✅ | — | Get user's scan statistics |
| GET | `/api/admin/stats` | — | — | Get dashboard statistics |
| POST | `/api/partners` | — | — | Create partner |
| GET | `/api/partners` | — | — | List all partners |
| PUT | `/api/partners/:id` | — | — | Update partner |
| DELETE | `/api/partners/:id` | — | — | Delete partner |
| POST | `/api/locations` | — | — | Create location |
| GET | `/api/locations` | — | — | List all locations |
| PUT | `/api/locations/:id` | — | — | Update location |
| DELETE | `/api/locations/:id` | — | — | Delete location |

---

## 6. Data Dictionary

| Field | Type | Constraints | Description |
|-------|------|------------|-------------|
| `User.name` | String | Required | Full name of the user |
| `User.email` | String | Required, Unique | Email address used for login |
| `User.phone` | String | Default: "" | Contact phone number |
| `User.credits` | Number | Default: 0 | Accumulated recycling reward balance (Rs.) |
| `User.password` | String | Required, select:false | Bcrypt-hashed password (never returned in queries) |
| `User.role` | String | Enum: user, admin. Default: user | Authorization role |
| `User.profilePicture` | String | Default: "" | URL to profile image |
| `WasteScan.user` | ObjectId | Required, ref: User | Foreign key to the scanning user |
| `WasteScan.wasteType` | String | Enum: 6 types, Required | Detected waste material category |
| `WasteScan.confidence` | Number | Required | AI detection confidence (0-1) |
| `WasteScan.creditsEarned` | Number | Required | Credits awarded for this scan |
| `WasteScan.co2Saved` | Number | Default: 0 | Estimated CO2 savings in grams |
| `Partner.name` | String | Required | Partner organization name |
| `Partner.email` | String | Required, Unique | Partner contact email |
| `Location.vendorName` | String | Required | Name of the collection point vendor |
| `Location.vendorAddress` | String | Required | Physical address |
| `Location.status` | String | Enum: Active, Inactive | Whether the location is currently operational |
