# Quick Start Guide

This guide will help you get the E-Docs application running quickly.

## Prerequisites Check

- [ ] Flutter SDK installed (`flutter --version`)
- [ ] Node.js installed (`node --version`)
- [ ] PostgreSQL installed and running
- [ ] Git Bash or PowerShell

## Step-by-Step Setup (5 minutes)

### Step 1: Database Setup (2 minutes)

1. Open PostgreSQL (pgAdmin or command line)
2. Create the database and tables:

```sql
-- Create database
CREATE DATABASE edocs_db;

-- Connect to the database
\c edocs_db;

-- Create users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(10) NOT NULL CHECK (role IN ('admin', 'user')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create documents table
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT,
    file_type VARCHAR(50),
    uploaded_by INTEGER REFERENCES users(id),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tags VARCHAR(50) DEFAULT 'procedure' NOT NULL CHECK (tags IN ('procedure', 'circular', 'archive', 'policy'))
);
```

### Step 2: Backend Setup (2 minutes)

1. Open terminal in the backend folder:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env` file:
```bash
copy .env.example .env
```

4. Edit `.env` with your PostgreSQL password:
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=edocs_db
DB_USER=postgres
DB_PASSWORD=YOUR_POSTGRES_PASSWORD_HERE

JWT_SECRET=my_super_secret_jwt_key_12345

PORT=3000

DOCUMENTS_PATH=C:/<path_to_your_project>/e_docs_mobile/backend/documents
```

5. Generate password hashes and create users:
```bash
node generate_password.js
```

Copy the generated hashes and run this SQL:
```sql
-- Insert admin user (replace HASH_HERE with generated hash)
INSERT INTO users (username, password, role) 
VALUES ('admin', 'HASH_HERE', 'admin');

-- Insert regular user (replace HASH_HERE with generated hash)
INSERT INTO users (username, password, role) 
VALUES ('user', 'HASH_HERE', 'user');
```

6. Create documents folder:
```bash
mkdir documents
```

7. Start the server:
```bash
npm start
```

You should see: "Server is running on port 3000"

### Step 3: Flutter App Setup (1 minute)

1. Open a NEW terminal in the project root:
```bash
cd ..
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. **IMPORTANT**: Update API URL in `lib/services/api_service.dart`:
   - For Android Emulator: Change `localhost` to `10.0.2.2`
   - For Physical Device: Change `localhost` to your PC's IP (e.g., `192.168.1.100`)

4. Run the app:
```bash
flutter run
```

## Testing the App

### Login Credentials
- **Admin**: username: `admin`, password: `admin123`
- **User**: username: `user`, password: `user123`

### Test as Admin
1. Login with admin credentials
2. You'll see a bottom navigation bar with "Documents" and "Users" tabs
3. **Test Documents Tab**:
   - Use the search bar to search documents
   - Use the "Filter by Tag" dropdown to filter by tag
   - Click the "+" button to upload a document
   - Select a file and choose a tag (Procedure, Circular, Archive, Policy)
   - Fill in title and description
   - View, edit, or delete documents
4. **Test Users Tab**:
   - View all users
   - Search users by username or role
   - Click "+" to add a new user
   - Edit existing users (username, password, role)
   - Delete users (except yourself)

### Test as User
1. Logout from admin account
2. Login with user credentials
3. You'll see a simple documents list (no bottom navigation)
4. Use the search bar to search documents
5. Use the "Filter by Tag" dropdown to filter documents
6. Open document details
7. Download and open documents
8. Verify you CANNOT upload, edit, or delete documents
9. Verify you CANNOT access user management

## Common Issues & Solutions

### Issue: Backend won't start
**Solution**: 
- Check if PostgreSQL is running
- Verify database credentials in `.env`
- Ensure port 3000 is not in use

### Issue: Flutter app can't connect
**Solution**:
- Ensure backend is running (`npm start` in backend folder)
- Check API URL in `api_service.dart`:
  - Emulator: `http://10.0.2.2:3000/api`
  - Physical device: `http://YOUR_PC_IP:3000/api`

### Issue: Can't find PC IP address
**Solution** (Windows):
```bash
ipconfig
```
Look for "IPv4 Address" under your active network adapter

### Issue: File upload fails
**Solution**:
- Check `DOCUMENTS_PATH` in `.env` exists
- Ensure the backend has write permissions to the folder

## Quick Commands Reference

### Start Backend
```bash
cd backend
npm start
```

### Start Flutter App
```bash
flutter run
```

### View Backend Logs
The terminal running `npm start` will show all API requests and errors

### Reset Database
```sql
DROP DATABASE edocs_db;
-- Then run Step 1 again
```

## Next Steps

- Read the full README.md for detailed documentation
- Customize the app theme in `lib/main.dart`
- Add more users via the registration endpoint
- Explore the API endpoints with Postman

## Support

If you encounter issues:
1. Check the terminal logs (both backend and Flutter)
2. Verify all prerequisites are installed
3. Ensure PostgreSQL is running
4. Check firewall settings if using physical device

Happy coding! 🚀
