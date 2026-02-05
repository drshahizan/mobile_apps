const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const pool = require('../config/db');
const { authenticateToken, isAdmin } = require('../middleware/auth');

const router = express.Router();

const documentsPath = process.env.DOCUMENTS_PATH || path.join(__dirname, '../documents');

if (!fs.existsSync(documentsPath)) {
  fs.mkdirSync(documentsPath, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, documentsPath);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + '-' + file.originalname);
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 50 * 1024 * 1024 }
});

router.get('/', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT d.*, u.username as uploaded_by_username 
       FROM documents d 
       LEFT JOIN users u ON d.uploaded_by = u.id 
       ORDER BY d.uploaded_at DESC`
    );
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching documents:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      `SELECT d.*, u.username as uploaded_by_username 
       FROM documents d 
       LEFT JOIN users u ON d.uploaded_by = u.id 
       WHERE d.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Document not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching document:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/', authenticateToken, isAdmin, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const { title, description } = req.body;

    if (!title) {
      fs.unlinkSync(req.file.path);
      return res.status(400).json({ error: 'Title is required' });
    }

    const result = await pool.query(
      `INSERT INTO documents (title, description, file_name, file_path, file_size, file_type, uploaded_by) 
       VALUES ($1, $2, $3, $4, $5, $6, $7) 
       RETURNING *`,
      [
        title,
        description || '',
        req.file.originalname,
        req.file.path,
        req.file.size,
        req.file.mimetype,
        req.user.id
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error uploading document:', error);
    if (req.file) {
      fs.unlinkSync(req.file.path);
    }
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.get('/:id/download', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM documents WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Document not found' });
    }

    const document = result.rows[0];
    const filePath = document.file_path;

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ error: 'File not found on server' });
    }

    res.download(filePath, document.file_name);
  } catch (error) {
    console.error('Error downloading document:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.put('/:id', authenticateToken, isAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description } = req.body;

    if (!title) {
      return res.status(400).json({ error: 'Title is required' });
    }

    const existingDoc = await pool.query('SELECT * FROM documents WHERE id = $1', [id]);

    if (existingDoc.rows.length === 0) {
      return res.status(404).json({ error: 'Document not found' });
    }

    const result = await pool.query(
      `UPDATE documents 
       SET title = $1, description = $2 
       WHERE id = $3 
       RETURNING *`,
      [title, description || '', id]
    );

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error updating document:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.delete('/:id', authenticateToken, isAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM documents WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Document not found' });
    }

    const document = result.rows[0];

    if (fs.existsSync(document.file_path)) {
      fs.unlinkSync(document.file_path);
    }

    await pool.query('DELETE FROM documents WHERE id = $1', [id]);

    res.json({ message: 'Document deleted successfully' });
  } catch (error) {
    console.error('Error deleting document:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
