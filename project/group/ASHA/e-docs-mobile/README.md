# E-Docs Mobile Application

A Flutter-based document management system with role-based access control (Admin and User roles). The application uses a Node.js backend with PostgreSQL database for storing document metadata and local file storage for document files.

## Features

- **Role-Based Access Control**
  - Admin: Full access to all features
  - User: Can view, search, and download documents only
  
- **Document Management**
  - Upload documents with metadata (Admin only)
  - Edit document details (title, description, tags) (Admin only)
  - View document details
  - Download and open documents
  - Delete documents (Admin only)
  - Document tagging system (Procedure, Circular, Archive, Policy)
  - Filter documents by tags
  - Search documents by title, description, filename, or uploader
  
- **User Management** (Admin only)
  - Create new users with roles (admin/user)
  - Edit existing users (username, password, role)
  - Delete users (except self)
  - View all users with creation dates
  - Search users by username or role
  
- **Authentication**
  - Secure login system with JWT tokens
  - Persistent login sessions
  - Password hashing with bcrypt
  
- **User Interface**
  - Bottom navigation bar for admin (Documents/Users tabs)
  - Real-time search and filtering
  - Maroon theme (Material Design 3)
  - Responsive and intuitive design

## Architecture

- **Frontend**: Flutter (Mobile App)
- **Backend**: Node.js with Express
- **Database**: PostgreSQL
- **File Storage**: Local file system

## Prerequisites

Before running this application, ensure you have the following installed:

1. **Flutter SDK** (3.10.1 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   
2. **Node.js** (v16 or higher) and npm
   - Download from: https://nodejs.org/
   
3. **PostgreSQL** (v12 or higher)
   - Download from: https://www.postgresql.org/download/
   
4. **Android Studio** or **VS Code** with Flutter extensions

## Setup Instructions

### 1. PostgreSQL Database Setup

1. Install PostgreSQL on your PC
2. Open PostgreSQL command line or pgAdmin
3. Run the database setup script:

```bash
cd backend
psql -U postgres -f database.sql
```

Or manually execute the SQL commands in `backend/database.sql`

**Note**: The default users will be created with these credentials:
- Admin: `admin` / `admin123`
- User: `user` / `user123`

You'll need to update the password hashes in `database.sql` after first run. To generate proper password hashes, you can use the registration endpoint or run this Node.js script:

```javascript
const bcrypt = require('bcrypt');
const password = 'your_password';
bcrypt.hash(password, 10).then(hash => console.log(hash));
```

### 2. Backend Server Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file by copying `.env.example`:
```bash
copy .env.example .env
```

4. Edit the `.env` file with your PostgreSQL credentials:
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=edocs_db
DB_USER=postgres
DB_PASSWORD=your_postgres_password

JWT_SECRET=your_secret_key_here

PORT=3000

DOCUMENTS_PATH=C:/<path_to_your_project>/e_docs_mobile/backend/documents
```

5. Create the documents directory:
```bash
mkdir documents
```

6. Start the backend server:
```bash
npm start
```

Or for development with auto-reload:
```bash
npm run dev
```

The server will run on `http://localhost:3000`

### 3. Flutter App Setup

1. Navigate to the project root directory:
```bash
cd ..
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. **Important**: Update the API base URL in `lib/services/api_service.dart` if needed:
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

For Android emulator, use: `http://10.0.2.2:3000/api`
For physical device, use your PC's IP address: `http://192.168.x.x:3000/api`

4. Run the Flutter app:
```bash
flutter run
```

## Running the Application

### Start Backend Server
```bash
cd backend
npm start
```

### Start Flutter App
```bash
flutter run
```

## Default Login Credentials

- **Admin Account**
  - Username: `admin`
  - Password: `admin123`
  
- **User Account**
  - Username: `user`
  - Password: `user123`

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration

### Documents
- `GET /api/documents` - Get all documents
- `GET /api/documents/:id` - Get document by ID
- `POST /api/documents` - Upload document with tags (Admin only)
- `PUT /api/documents/:id` - Update document metadata (Admin only)
- `GET /api/documents/:id/download` - Download document
- `DELETE /api/documents/:id` - Delete document (Admin only)

### Users (Admin only)
- `GET /api/users` - Get all users
- `POST /api/users` - Create new user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

## Project Structure

```
e_docs_mobile/
├── backend/
│   ├── config/
│   │   └── db.js                 # Database configuration
│   ├── middleware/
│   │   └── auth.js               # Authentication middleware
│   ├── routes/
│   │   ├── auth.js               # Authentication routes
│   │   ├── documents.js          # Document routes
│   │   └── users.js              # User management routes
│   ├── documents/                # Uploaded documents storage
│   ├── .env.example              # Environment variables template
│   ├── database.sql              # Database schema with tags
│   ├── package.json              # Node.js dependencies
│   └── server.js                 # Express server
├── lib/
│   ├── models/
│   │   ├── user.dart             # User model
│   │   └── document.dart         # Document model with tags
│   ├── services/
│   │   ├── api_service.dart      # API service
│   │   └── auth_service.dart     # Authentication service
│   ├── screens/
│   │   ├── login_screen.dart     # Login screen
│   │   ├── home_screen.dart      # User home screen with search & filter
│   │   ├── admin_home_screen.dart # Admin home with tabs (Documents/Users)
│   │   ├── document_detail_screen.dart  # Document details
│   │   ├── upload_document_screen.dart  # Upload document with tags
│   │   ├── edit_document_screen.dart    # Edit document metadata
│   │   ├── users_screen.dart     # User management (Admin)
│   │   ├── add_user_screen.dart  # Add new user (Admin)
│   │   └── edit_user_screen.dart # Edit user (Admin)
│   └── main.dart                 # App entry point
└── pubspec.yaml                  # Flutter dependencies
```

## Troubleshooting

### Backend Issues

**Database connection error:**
- Verify PostgreSQL is running
- Check database credentials in `.env` file
- Ensure database `edocs_db` exists

**Port already in use:**
- Change the PORT in `.env` file
- Kill the process using port 3000: `netstat -ano | findstr :3000`

### Flutter App Issues

**Connection refused:**
- Ensure backend server is running
- Check the API base URL in `api_service.dart`
- For Android emulator, use `10.0.2.2` instead of `localhost`
- For physical device, use your PC's local IP address

**File picker not working:**
- Ensure proper permissions in `AndroidManifest.xml`
- For Android 11+, add storage permissions

**Cannot open downloaded files:**
- Ensure `open_file` package is properly configured
- Check file permissions on the device

## Development Notes

- The backend stores documents in the `backend/documents` directory
- JWT tokens expire after 24 hours
- File upload size limit is 50MB (configurable in `backend/routes/documents.js`)
- The app uses Material Design 3 with maroon theme
- Document tags are enforced at database level with CHECK constraint
- Admin users see a bottom navigation bar with Documents and Users tabs
- Regular users see a simple documents list with search and filter
- Search works across title, description, filename, and uploader name
- Tag filtering can be combined with text search for precise results

## Security Considerations

- Change default user passwords after first setup
- Use a strong JWT_SECRET in production
- Implement HTTPS for production deployment
- Add rate limiting for API endpoints
- Validate file types and sizes on upload
- Implement proper error handling and logging

## Completed Features

- [x] Search and filter documents
- [x] Document categories/tags (Procedure, Circular, Archive, Policy)
- [x] User management (Admin)
- [x] Edit documents and users
- [x] Role-based navigation (Admin tabs vs User simple view)

## Future Enhancements

- [ ] User profile management (self-service)
- [ ] Document sharing between users
- [ ] Document versioning
- [ ] Activity logs and audit trail
- [ ] Push notifications
- [ ] Dark mode support
- [ ] Export documents list to PDF/Excel
- [ ] Advanced filtering (date range, file type, size)

## License

This project is created for educational purposes.
