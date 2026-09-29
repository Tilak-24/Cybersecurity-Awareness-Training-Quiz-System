/**
 * CyberAware Backend
 * Simple Node.js + Express + MySQL API
 * Run: npm install  then  npm start
 * API runs on http://localhost:3000
 */

const express = require('express');
const cors = require('cors');
const pool = require('./db');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// ========== AUTH ==========

// Login
app.post('/api/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password required' });
    }

    const [rows] = await pool.query(
      'SELECT user_id, name, email, role FROM users WHERE email = ? AND password = ?',
      [email, password]
    );

    if (rows.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    res.json({ user: rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// ========== MODULES ==========

// Get all modules
app.get('/api/modules', async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT module_id, title, topic, description, content_body, order_index, duration_min, level FROM modules ORDER BY order_index'
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get one module
app.get('/api/modules/:id', async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM modules WHERE module_id = ?',
      [req.params.id]
    );
    if (rows.length === 0) return res.status(404).json({ error: 'Module not found' });
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// ========== QUESTIONS ==========

// Get questions + answers for a module
app.get('/api/modules/:id/questions', async (req, res) => {
  try {
    const moduleId = req.params.id;
    const [questions] = await pool.query(
      'SELECT question_id, question_text, difficulty FROM questions WHERE module_id = ? ORDER BY question_id',
      [moduleId]
    );

    for (const q of questions) {
      const [answers] = await pool.query(
        'SELECT answer_id, answer_text, is_correct FROM answers WHERE question_id = ? ORDER BY answer_id',
        [q.question_id]
      );
      q.answers = answers;
    }

    res.json(questions);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// ========== QUIZ SUBMIT ==========

// Submit quiz answers and get score
app.post('/api/quiz/submit', async (req, res) => {
  try {
    const { user_id, module_id, answers } = req.body;
    // answers = [{ question_id, answer_id }, ...]

    if (!user_id || !module_id || !Array.isArray(answers)) {
      return res.status(400).json({ error: 'user_id, module_id and answers required' });
    }

    let correct = 0;
    const total = answers.length;

    for (const a of answers) {
      const [rows] = await pool.query(
        'SELECT is_correct FROM answers WHERE answer_id = ? AND question_id = ?',
        [a.answer_id, a.question_id]
      );
      if (rows.length && rows[0].is_correct === 1) correct++;
    }

    const score = total > 0 ? Math.round((correct / total) * 100) : 0;

    // Save attempt
    await pool.query(
      'INSERT INTO attempts (user_id, module_id, score, total_questions) VALUES (?, ?, ?, ?)',
      [user_id, module_id, score, total]
    );

    // Update progress
    const status = score >= 70 ? 'completed' : 'in_progress';
    const [existing] = await pool.query(
      'SELECT progress_id, best_score FROM progress WHERE user_id = ? AND module_id = ?',
      [user_id, module_id]
    );

    if (existing.length > 0) {
      const newBest = Math.max(existing[0].best_score, score);
      await pool.query(
        `UPDATE progress SET status = ?, best_score = ?,
         completion_date = IF(? = 'completed', NOW(), completion_date)
         WHERE progress_id = ?`,
        [status, newBest, status, existing[0].progress_id]
      );
    } else {
      if (status === 'completed') {
        await pool.query(
          'INSERT INTO progress (user_id, module_id, status, best_score, completion_date) VALUES (?, ?, ?, ?, NOW())',
          [user_id, module_id, status, score]
        );
      } else {
        await pool.query(
          'INSERT INTO progress (user_id, module_id, status, best_score) VALUES (?, ?, ?, ?)',
          [user_id, module_id, status, score]
        );
      }
    }

    res.json({ score, correct, total, passed: score >= 70 });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// ========== PROGRESS ==========

// Get progress for a user
app.get('/api/progress/:userId', async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT p.module_id, p.status, p.best_score, p.completion_date, m.title
       FROM progress p
       JOIN modules m ON p.module_id = m.module_id
       WHERE p.user_id = ?
       ORDER BY m.order_index`,
      [req.params.userId]
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get attempts for a user
app.get('/api/attempts/:userId', async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT a.attempt_id, a.module_id, a.score, a.total_questions, a.date_taken, m.title
       FROM attempts a
       JOIN modules m ON a.module_id = m.module_id
       WHERE a.user_id = ?
       ORDER BY a.date_taken DESC
       LIMIT 20`,
      [req.params.userId]
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// ========== USERS (admin) ==========

app.get('/api/users', async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT u.user_id, u.name, u.email, u.role,
        (SELECT COUNT(*) FROM attempts a WHERE a.user_id = u.user_id) AS attempt_count,
        (SELECT ROUND(AVG(score)) FROM attempts a WHERE a.user_id = u.user_id) AS avg_score
       FROM users u
       ORDER BY u.role, u.name`
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// ========== REPORTS (admin) ==========

app.get('/api/reports/modules', async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT m.module_id, m.title,
        COUNT(a.attempt_id) AS attempts,
        ROUND(AVG(a.score)) AS avg_score,
        SUM(CASE WHEN a.score >= 70 THEN 1 ELSE 0 END) AS passed
       FROM modules m
       LEFT JOIN attempts a ON m.module_id = a.module_id
       GROUP BY m.module_id
       ORDER BY m.order_index`
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

app.get('/api/reports/stats', async (req, res) => {
  try {
    const [users] = await pool.query('SELECT COUNT(*) AS c FROM users');
    const [learners] = await pool.query("SELECT COUNT(*) AS c FROM users WHERE role = 'learner'");
    const [modules] = await pool.query('SELECT COUNT(*) AS c FROM modules');
    const [attempts] = await pool.query('SELECT COUNT(*) AS c FROM attempts');
    const [avg] = await pool.query('SELECT ROUND(AVG(score)) AS a FROM attempts');
    const [passed] = await pool.query('SELECT COUNT(*) AS c FROM attempts WHERE score >= 70');

    res.json({
      users: users[0].c,
      learners: learners[0].c,
      modules: modules[0].c,
      attempts: attempts[0].c,
      avg_score: avg[0].a || 0,
      passed: passed[0].c
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'CyberAware API is running' });
});

// Start server
app.listen(PORT, () => {
  console.log('');
  console.log('  CyberAware Backend running!');
  console.log('  API:  http://localhost:' + PORT);
  console.log('  Test: http://localhost:' + PORT + '/api/health');
  console.log('');
});
