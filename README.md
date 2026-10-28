# AavenzaOne — Enterprise HRMS & Mobile Attendance Application

A production-ready native Flutter mobile application developed with **GetX**, **MVC Architecture**, and **Dio**, faithfully reproducing the existing AavenzaOne employee management web application.

- **Reference Web Application:** `https://aavenzaone.aavenzatechnologies.com/mobile/`
- **Target Platforms:** Android & iOS
- **State Management:** GetX (Reactive, DI, Named Routing, Lifecycle Bindings)
- **Architecture:** Feature-First MVC with Repository-based Data Access Layer
- **Networking:** Dio with custom interceptors, standardized error handling, and session restoration
- **Backend API Standard:** BillMaster Mobile API v1.0 (56 Actions Across 16 Modules)

---

## 1. Architectural Design

The application follows a strictly decoupled, feature-first **Model-View-Controller (MVC) + Repository** architecture:

```
lib/
├── app.dart                   # GetMaterialApp configuration, theme, and routing
├── main.dart                  # Core async services initialization and bootstrap
├── core/
│   ├── constants/             # App colors, strings, typography, API actions
│   ├── network/               # Centralized Dio client, exceptions, interceptors
│   ├── routes/                # Named routes and GetPage bindings
│   ├── services/              # AuthService (session restoration, role authorization)
│   ├── storage/               # SharedPreferences wrapper for tokens and server URL
│   ├── theme/                 # Centralized light theme & design tokens
│   ├── utils/                 # CurrencyFormatter (INR ₹), DateFormatter, Validators
│   └── widgets/               # Reusable UI widgets: buttons, badges, drawer, states
├── data/
│   ├── models/                # 16 Typed Dart models for all backend payloads
│   └── repositories/          # 16 Repositories handling backend mapping & API calls
└── features/                  # 16 Individual feature modules
    ├── authentication/        # Login, server URL configuration, session recovery
    ├── dashboard/             # Live clock, punch card, quick grid, attendance history
    ├── notice_board/          # Role-based notices, priority indicators, read marks
    ├── sticky_notes/          # Personal notes, pastel color selector, pin toggle
    ├── calendar/              # Monthly events list, event creation & filters
    ├── meetings/              # Meeting invitations, locations, duration
    ├── task_manager/          # Task board with status filters (todo, in_progress, review, done)
    ├── leave_management/      # Leave balances, application form, cancellation
    ├── digital_cards/         # Company ID card, Digital Visiting card, tagline, safety
    ├── support_tickets/       # IT tickets, categories, comment discussion threads
    ├── salary_slips/          # Payroll history, itemized earnings, deductions, bank info
    ├── travel_allowance/      # Local/outstation travel claims, vehicle modes, expenses
    ├── leads_contacts/        # CRM pipeline, lead status, timeline notes, sales team
    ├── sales_invoices/        # Invoices by billing month, itemized line items
    ├── sales_targets/         # Monthly quota vs achieved revenue, 6-month historical trends
    ├── messenger/             # Internal direct & group chats, live messaging
    └── employee_profile/      # Profile info, avatar management, server connection settings
```

---

## 2. API Endpoint Coverage Report (56 Actions Across 16 Modules)

| # | Module | Action | Endpoint / Method | Implemented Status |
|---|---|---|---|---|
| 1 | Auth | `login` | `POST /mobile/api.php?action=login` | Complete |
| 2 | Auth | `logout` | `POST /mobile/api.php?action=logout` | Complete |
| 3 | Attendance | `attendance_status` | `POST /mobile/api.php?action=attendance_status` | Complete |
| 4 | Attendance | `check_in` | `POST /mobile/api.php?action=check_in` | Complete |
| 5 | Attendance | `check_out` | `POST /mobile/api.php?action=check_out` | Complete |
| 6 | Attendance | `mark_status` | `POST /mobile/api.php?action=mark_status` | Complete |
| 7 | Attendance | `early_leave` | `POST /mobile/api.php?action=early_leave` | Complete |
| 8 | Notice Board | `notices_list` | `POST /mobile/api.php?action=notices_list` | Complete |
| 9 | Notice Board | `notice_mark_read` | `POST /mobile/api.php?action=notice_mark_read` | Complete |
| 10 | Sticky Notes | `notes_list` | `POST /mobile/api.php?action=notes_list` | Complete |
| 11 | Sticky Notes | `notes_create` | `POST /mobile/api.php?action=notes_create` | Complete |
| 12 | Sticky Notes | `notes_update` | `POST /mobile/api.php?action=notes_update` | Complete |
| 13 | Sticky Notes | `notes_toggle_pin` | `POST /mobile/api.php?action=notes_toggle_pin` | Complete |
| 14 | Sticky Notes | `notes_delete` | `POST /mobile/api.php?action=notes_delete` | Complete |
| 15 | Calendar | `calendar_list` | `POST /mobile/api.php?action=calendar_list` | Complete |
| 16 | Calendar | `calendar_create` | `POST /mobile/api.php?action=calendar_create` | Complete |
| 17 | Calendar | `calendar_update` | `POST /mobile/api.php?action=calendar_update` | Complete |
| 18 | Calendar | `calendar_delete` | `POST /mobile/api.php?action=calendar_delete` | Complete |
| 19 | Task Manager | `tasks_list` | `POST /mobile/api.php?action=tasks_list` | Complete |
| 20 | Task Manager | `tasks_create` | `POST /mobile/api.php?action=tasks_create` | Complete |
| 21 | Task Manager | `tasks_update` | `POST /mobile/api.php?action=tasks_update` | Complete |
| 22 | Task Manager | `tasks_update_status` | `POST /mobile/api.php?action=tasks_update_status` | Complete |
| 23 | Task Manager | `tasks_delete` | `POST /mobile/api.php?action=tasks_delete` | Complete |
| 24 | Leaves | `leave_types_list` | `POST /mobile/api.php?action=leave_types_list` | Complete |
| 25 | Leaves | `leaves_list` | `POST /mobile/api.php?action=leaves_list` | Complete |
| 26 | Leaves | `leaves_apply` | `POST /mobile/api.php?action=leaves_apply` | Complete |
| 27 | Leaves | `leaves_cancel` | `POST /mobile/api.php?action=leaves_cancel` | Complete |
| 28 | Meetings | `meetings_list` | `POST /mobile/api.php?action=meetings_list` | Complete |
| 29 | Messenger | `messenger_groups` | `POST /mobile/api.php?action=messenger_groups` | Complete |
| 30 | Messenger | `messenger_messages` | `POST /mobile/api.php?action=messenger_messages` | Complete |
| 31 | Messenger | `messenger_send` | `POST /mobile/api.php?action=messenger_send` | Complete |
| 32 | IT Tickets | `it_categories_list` | `POST /mobile/api.php?action=it_categories_list` | Complete |
| 33 | IT Tickets | `tickets_list` | `POST /mobile/api.php?action=tickets_list` | Complete |
| 34 | IT Tickets | `tickets_create` | `POST /mobile/api.php?action=tickets_create` | Complete |
| 35 | IT Tickets | `ticket_comments` | `POST /mobile/api.php?action=ticket_comments` | Complete |
| 36 | IT Tickets | `ticket_comment_add` | `POST /mobile/api.php?action=ticket_comment_add` | Complete |
| 37 | Salary Slips | `salary_slips_list` | `POST /mobile/api.php?action=salary_slips_list` | Complete |
| 38 | Salary Slips | `salary_slip_detail` | `POST /mobile/api.php?action=salary_slip_detail` | Complete |
| 39 | Travel | `travel_allowances_list` | `POST /mobile/api.php?action=travel_allowances_list` | Complete |
| 40 | Travel | `travel_allowances_apply` | `POST /mobile/api.php?action=travel_allowances_apply` | Complete |
| 41 | Travel | `travel_allowances_cancel` | `POST /mobile/api.php?action=travel_allowances_cancel` | Complete |
| 42 | CRM | `leads_list` | `POST /mobile/api.php?action=leads_list` | Complete |
| 43 | CRM | `lead_get` | `POST /mobile/api.php?action=lead_get` | Complete |
| 44 | CRM | `lead_create` | `POST /mobile/api.php?action=lead_create` | Complete |
| 45 | CRM | `lead_update_status` | `POST /mobile/api.php?action=lead_update_status` | Complete |
| 46 | CRM | `lead_note_add` | `POST /mobile/api.php?action=lead_note_add` | Complete |
| 47 | CRM | `sales_team_list` | `POST /mobile/api.php?action=sales_team_list` | Complete |
| 48 | Sales | `sales_invoices_list` | `POST /mobile/api.php?action=sales_invoices_list` | Complete |
| 49 | Sales | `sales_invoice_months` | `POST /mobile/api.php?action=sales_invoice_months` | Complete |
| 50 | Sales | `sales_invoice_get` | `POST /mobile/api.php?action=sales_invoice_get` | Complete |
| 51 | Sales | `sales_target_get` | `POST /mobile/api.php?action=sales_target_get` | Complete |
| 52 | Sales | `sales_target_history` | `POST /mobile/api.php?action=sales_target_history` | Complete |
| 53 | Profile | `profile_photo_upload` | `POST /mobile/api.php?action=profile_photo_upload` (multipart) | Complete |
| 54 | Profile | `profile_photo_remove` | `POST /mobile/api.php?action=profile_photo_remove` | Complete |
| 55 | Cards | `card_data` | `POST /mobile/api.php?action=card_data` | Complete |
| 56 | Cards | `card_update_tagline` | `POST /mobile/api.php?action=card_update_tagline` | Complete |
| 57 | Cards | `card_update_safety` | `POST /mobile/api.php?action=card_update_safety` | Complete |

---

## 3. Setup and Execution Instructions

### Prerequisites
- Flutter SDK 3.13.7 or higher
- Android SDK (API 34 / Java 17)
- Xcode 15+ (for iOS builds)

### Installation
1. Clone the repository and navigate into the workspace:
   ```bash
   cd c:\src\mbs_attendance_app
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run test suite:
   ```bash
   flutter test
   ```
4. Run static analysis:
   ```bash
   dart analyze
   ```

### Server Configuration
- The app defaults to connecting with `https://aavenzaone.aavenzatechnologies.com`.
- On the login screen, users can tap the edit button next to the **Server URL** field to target any custom on-premise or cloud installation (e.g., `http://192.168.1.100/accounts`).
- The Dio networking client automatically appends `/mobile/api.php?action=<action>` and manages session authentication tokens.

---

## 4. Build Instructions

### Android Release APK & App Bundle
- Build APK:
  ```bash
  flutter build apk --release
  ```
- Build App Bundle:
  ```bash
  flutter build appbundle --release
  ```

### iOS Archive & IPA
```bash
flutter build ipa --release
```
*(Requires macOS and Xcode signing certificates)*

---

## 5. Security & Session Handling
- Bearer tokens (64-character hex) are securely stored in persistent local storage.
- Request headers automatically inject `Authorization: Bearer <token>`.
- Auto-interception of HTTP 401 or expired session responses gracefully redirects the user to the Login screen while preserving configured server settings.
- Passwords and sensitive payroll details are strictly excluded from console logs.
