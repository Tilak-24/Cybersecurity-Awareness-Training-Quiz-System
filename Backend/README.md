# CyberAware Backend

Simple **Node.js + Express + MySQL** API for the CyberAware frontend.

---

## Requirements

- Node.js installed (https://nodejs.org)
- MySQL running (XAMPP MySQL or system MySQL)

---

## Setup (3 steps)

### 1. Import the database

Open phpMyAdmin or Terminal:

```bash
mysql -u root < database.sql
```

Or in phpMyAdmin → Import → select `database.sql` → Go.

### 2. Install dependencies

```bash
cd cyberaware-backend
npm install
```

### 3. Start the server

```bash
npm start
```

You should see:

```
CyberAware Backend running!
API:  http://localhost:3000
```

Test it: open **http://localhost:3000/api/health** in your browser.

---

## If MySQL has a password

Edit `db.js` and change:

```js
password: '',   // put your password here
```

---

## API Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| POST | `/api/login` | Login `{ email, password }` |
| GET | `/api/modules` | List all modules |
| GET | `/api/modules/:id` | One module |
| GET | `/api/modules/:id/questions` | Questions + answers for module |
| POST | `/api/quiz/submit` | Submit quiz `{ user_id, module_id, answers }` |
| GET | `/api/progress/:userId` | User progress |
| GET | `/api/attempts/:userId` | User quiz attempts |
| GET | `/api/users` | All users (admin) |
| GET | `/api/reports/modules` | Scores by module |
| GET | `/api/reports/stats` | Overall stats |
| GET | `/api/health` | Health check |

---

## Demo accounts (in database)

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@cyberaware.edu.au | password123 |
| Learner | learner@cyberaware.edu.au | password123 |

---

## Project structure

```
cyberaware-backend/
├── server.js        ← main API
├── db.js            ← MySQL connection
├── package.json
├── database.sql     ← import this first
└── README.md
```
