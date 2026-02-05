const express = require('express');
const cors = require('cors');
require('dotenv').config();

const pool = require('./config/db');
const authRoutes = require('./routes/auth');
const documentRoutes = require('./routes/documents');
const usersRoutes = require('./routes/users');

const app = express();
const PORT = process.env.PORT || 3000;

console.log('Starting E-Docs Backend Server...');
console.log('Environment:', {
  DB_HOST: process.env.DB_HOST,
  DB_PORT: process.env.DB_PORT,
  DB_NAME: process.env.DB_NAME,
  DB_USER: process.env.DB_USER,
  PORT: process.env.PORT
});

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

app.use('/api/auth', authRoutes);
app.use('/api/documents', documentRoutes);
app.use('/api/users', usersRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'E-Docs API Server is running' });
});

pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('Database connection error:', err);
  } else {
    console.log('Database connected successfully at:', res.rows[0].now);
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`API available at: http://localhost:${PORT}/api`);
  console.log(`Emulator can access at: http://10.0.2.2:${PORT}/api`);
});
