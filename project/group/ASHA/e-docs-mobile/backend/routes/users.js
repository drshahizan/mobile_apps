const express = require('express');
const bcrypt = require('bcrypt');
const pool = require('../config/db');
const { authenticateToken, isAdmin } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticateToken, isAdmin, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, username, role, created_at FROM users ORDER BY created_at DESC'
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.get('/:id', authenticateToken, isAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'SELECT id, username, role, created_at FROM users WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/', authenticateToken, isAdmin, async (req, res) => {
  try {
    const { username, password, role } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    if (role && !['admin', 'user'].includes(role)) {
      return res.status(400).json({ error: 'Invalid role' });
    }

    const existingUser = await pool.query(
      'SELECT * FROM users WHERE username = $1',
      [username]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({ error: 'Username already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const userRole = role || 'user';

    const result = await pool.query(
      'INSERT INTO users (username, password, role) VALUES ($1, $2, $3) RETURNING id, username, role, created_at',
      [username, hashedPassword, userRole]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.put('/:id', authenticateToken, isAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { username, password, role } = req.body;

    const existingUser = await pool.query(
      'SELECT * FROM users WHERE id = $1',
      [id]
    );

    if (existingUser.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    if (username) {
      const duplicateCheck = await pool.query(
        'SELECT * FROM users WHERE username = $1 AND id != $2',
        [username, id]
      );

      if (duplicateCheck.rows.length > 0) {
        return res.status(409).json({ error: 'Username already exists' });
      }
    }

    if (role && !['admin', 'user'].includes(role)) {
      return res.status(400).json({ error: 'Invalid role' });
    }

    let query = 'UPDATE users SET ';
    const values = [];
    let paramCount = 1;

    if (username) {
      query += `username = $${paramCount}, `;
      values.push(username);
      paramCount++;
    }

    if (password) {
      const hashedPassword = await bcrypt.hash(password, 10);
      query += `password = $${paramCount}, `;
      values.push(hashedPassword);
      paramCount++;
    }

    if (role) {
      query += `role = $${paramCount}, `;
      values.push(role);
      paramCount++;
    }

    query = query.slice(0, -2);
    query += ` WHERE id = $${paramCount} RETURNING id, username, role, created_at`;
    values.push(id);

    const result = await pool.query(query, values);
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.delete('/:id', authenticateToken, isAdmin, async (req, res) => {
  try {
    const { id } = req.params;

    if (parseInt(id) === req.user.id) {
      return res.status(400).json({ error: 'Cannot delete your own account' });
    }

    const result = await pool.query('SELECT * FROM users WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    await pool.query('DELETE FROM users WHERE id = $1', [id]);

    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
