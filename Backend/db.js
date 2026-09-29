// Database connection - simple MySQL config for XAMPP / local MySQL
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: '127.0.0.1',
  user: 'root',
  password: '',          // change if your MySQL has a password
  database: 'cyberaware',
  waitForConnections: true,
  connectionLimit: 10
});

module.exports = pool;
