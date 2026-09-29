-- CyberAware Database
-- Import this in phpMyAdmin or: mysql -u root < database.sql

CREATE DATABASE IF NOT EXISTS cyberaware;
USE cyberaware;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('learner', 'admin') DEFAULT 'learner',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE modules (
    module_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    topic VARCHAR(100),
    description TEXT,
    content_body TEXT,
    order_index INT DEFAULT 0,
    duration_min INT DEFAULT 5,
    level VARCHAR(50) DEFAULT 'Beginner'
);

CREATE TABLE questions (
    question_id INT AUTO_INCREMENT PRIMARY KEY,
    module_id INT NOT NULL,
    question_text TEXT NOT NULL,
    difficulty VARCHAR(20) DEFAULT 'Easy',
    FOREIGN KEY (module_id) REFERENCES modules(module_id) ON DELETE CASCADE
);

CREATE TABLE answers (
    answer_id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT NOT NULL,
    answer_text VARCHAR(500) NOT NULL,
    is_correct TINYINT(1) DEFAULT 0,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE
);

CREATE TABLE attempts (
    attempt_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    module_id INT NOT NULL,
    score INT NOT NULL,
    total_questions INT NOT NULL,
    date_taken TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (module_id) REFERENCES modules(module_id) ON DELETE CASCADE
);

CREATE TABLE progress (
    progress_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    module_id INT NOT NULL,
    status ENUM('not_started', 'in_progress', 'completed') DEFAULT 'not_started',
    best_score INT DEFAULT 0,
    completion_date TIMESTAMP NULL,
    UNIQUE KEY unique_progress (user_id, module_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (module_id) REFERENCES modules(module_id) ON DELETE CASCADE
);

-- Demo users (password: password123)
INSERT INTO users (name, email, password, role) VALUES
('Admin User', 'admin@cyberaware.edu.au', 'password123', 'admin'),
('Demo Learner', 'learner@cyberaware.edu.au', 'password123', 'learner'),
('Sarah Mitchell', 'sarah@cyberaware.edu.au', 'password123', 'admin'),
('Priya Raman', 'priya@cyberaware.edu.au', 'password123', 'learner');

-- 5 Modules
INSERT INTO modules (title, topic, description, content_body, order_index, duration_min, level) VALUES
('Password Safety', 'Password Security',
 'Why length beats complexity and how password managers help.',
 '<h3>Why Strong Passwords Matter</h3><p>Weak or reused passwords are one of the most common ways attackers gain access. A strong password is long (at least 12 characters), unique, and ideally stored in a password manager.</p><h3>Key Practices</h3><ul><li>Use long passphrases (e.g. correct-horse-battery-staple).</li><li>Never reuse passwords across sites.</li><li>Use a password manager.</li><li>Change passwords after a known breach.</li></ul>',
 1, 6, 'Beginner'),

('Phishing Awareness', 'Phishing Recognition',
 'How to spot suspicious emails and messages before you click.',
 '<h3>What is Phishing?</h3><p>Phishing tricks you into revealing credentials or clicking malicious links by looking legitimate.</p><h3>How to Spot It</h3><ul><li>Check the real sender email address.</li><li>Hover over links to see the real URL.</li><li>Look for urgency or threats.</li><li>Be careful with unexpected attachments.</li></ul><p>If in doubt, contact the organisation through an official channel you already trust.</p>',
 2, 8, 'Beginner'),

('Safe Browsing', 'Safe Browsing',
 'Understanding HTTPS, domain names and public Wi-Fi risks.',
 '<h3>HTTPS and the Padlock</h3><p>The padlock means the connection is encrypted — it does not guarantee the site is trustworthy.</p><h3>Reading Domain Names</h3><ul><li>Watch for misspellings (go0gle.com, amaz0n-security.com).</li><li>Prefer typing known addresses or using bookmarks.</li></ul><h3>Public Wi-Fi</h3><p>Avoid logging into sensitive accounts on open public Wi-Fi. Use a VPN if you must.</p>',
 3, 6, 'Beginner'),

('Multi-Factor Authentication', 'MFA',
 'Why a second factor stops a stolen password from becoming a stolen account.',
 '<h3>What is MFA?</h3><p>MFA requires something you know (password) plus something you have (phone or key).</p><h3>Why It Matters</h3><p>Even if an attacker steals your password, they still need the second factor.</p><h3>Strong Methods</h3><ul><li>Authenticator apps and hardware keys are strongest.</li><li>SMS codes are useful but can be intercepted.</li><li>Never share MFA codes with anyone claiming to be IT support.</li></ul>',
 4, 5, 'Beginner'),

('Data Privacy', 'Data Privacy',
 'Handling personal information responsibly online.',
 '<h3>What is Personal Data?</h3><p>Name, email, phone, address, photos, health or financial details — anything that can identify a person.</p><h3>Good Habits</h3><ul><li>Think before you post or share.</li><li>Review app permissions.</li><li>Use privacy settings on social media.</li><li>Only grant permissions an app really needs.</li></ul>',
 5, 7, 'Intermediate');

-- Questions Module 1
INSERT INTO questions (module_id, question_text, difficulty) VALUES
(1, 'Which is the MOST important factor for password strength?', 'Easy'),
(1, 'Why is reusing the same password across sites dangerous?', 'Medium'),
(1, 'What is a good practice when creating passwords?', 'Easy'),
(1, 'A password manager is useful because:', 'Easy'),
(1, 'After a data breach that exposes your password, you should:', 'Medium');

INSERT INTO answers (question_id, answer_text, is_correct) VALUES
(1, 'Length (number of characters)', 1),
(1, 'Using special symbols only', 0),
(1, 'Using your birthday', 0),
(1, 'Changing it every day', 0),
(2, 'If one site is breached, attackers can try the same password elsewhere', 1),
(2, 'It is harder to remember', 0),
(2, 'Websites will reject it', 0),
(2, 'It uses more storage', 0),
(3, 'Use a unique long passphrase for each important account', 1),
(3, 'Write it on a sticky note on your monitor', 0),
(3, 'Use the same short password everywhere', 0),
(3, 'Share it with trusted colleagues', 0),
(4, 'You only need to remember one strong master password', 1),
(4, 'It makes passwords shorter', 0),
(4, 'It removes the need for MFA', 0),
(4, 'It automatically shares passwords', 0),
(5, 'Change the password on that site and any other site where you used the same one', 1),
(5, 'Ignore it if you have not noticed problems', 0),
(5, 'Only change the password on your email', 0),
(5, 'Post about it on social media', 0);

-- Questions Module 2
INSERT INTO questions (module_id, question_text, difficulty) VALUES
(2, 'What is the first thing you should check in a suspicious email?', 'Easy'),
(2, 'Hovering over a link before clicking helps you:', 'Easy'),
(2, 'A message that creates extreme urgency and asks for your password is likely:', 'Medium'),
(2, 'If you receive an unexpected request from IT Support asking for login details, you should:', 'Medium'),
(2, 'Which is a common sign of a phishing email?', 'Easy');

INSERT INTO answers (question_id, answer_text, is_correct) VALUES
(6, 'The actual sender email address (not just the display name)', 1),
(6, 'The company logo', 0),
(6, 'How long the email is', 0),
(6, 'Whether it has images', 0),
(7, 'See the real destination URL before deciding to click', 1),
(7, 'Make the page load faster', 0),
(7, 'Delete the email automatically', 0),
(7, 'Send a reply', 0),
(8, 'A phishing or social engineering attempt', 1),
(8, 'A legitimate security alert', 0),
(8, 'A normal system notification', 0),
(8, 'An internal company survey', 0),
(9, 'Contact IT through a known official channel (not the details in the message)', 1),
(9, 'Reply with your username and password', 0),
(9, 'Click any links provided and enter details', 0),
(9, 'Forward it to all colleagues', 0),
(10, 'Misspelled domain names or unexpected attachments', 1),
(10, 'Correct grammar and known sender', 0),
(10, 'A short subject line', 0),
(10, 'An official-looking logo', 0);

-- Questions Module 3
INSERT INTO questions (module_id, question_text, difficulty) VALUES
(3, 'What does the padlock icon in the browser actually mean?', 'Medium'),
(3, 'Which is a safer practice when visiting websites?', 'Easy'),
(3, 'On public Wi-Fi you should avoid:', 'Medium'),
(3, 'A domain like amaz0n-security-login.com is suspicious because:', 'Easy'),
(3, 'The safest way to open a known bank website is usually to:', 'Easy');

INSERT INTO answers (question_id, answer_text, is_correct) VALUES
(11, 'The connection is encrypted, but the site is not necessarily trustworthy', 1),
(11, 'The website is 100% safe and legitimate', 0),
(11, 'The website belongs to a government', 0),
(11, 'Your antivirus is active', 0),
(12, 'Type the address or use a trusted bookmark', 1),
(12, 'Click the first result without checking', 0),
(12, 'Follow links from random emails', 0),
(12, 'Ignore the domain name', 0),
(13, 'Logging into sensitive accounts without extra protection', 1),
(13, 'Reading the news', 0),
(13, 'Checking the weather', 0),
(13, 'Watching videos', 0),
(14, 'It uses a zero instead of the letter o and is not the real domain', 1),
(14, 'It is too long', 0),
(14, 'It has the word security', 0),
(14, 'It ends with .com', 0),
(15, 'Type the official address yourself or use a saved bookmark', 1),
(15, 'Click a link from an email that looks official', 0),
(15, 'Search bank login and click the first ad', 0),
(15, 'Use a link shared on social media', 0);

-- Questions Module 4
INSERT INTO questions (module_id, question_text, difficulty) VALUES
(4, 'What is the main benefit of Multi-Factor Authentication?', 'Easy'),
(4, 'Which MFA method is generally stronger than SMS codes?', 'Medium'),
(4, 'If someone claiming to be IT asks for the code on your authenticator app, you should:', 'Medium'),
(4, 'MFA typically combines:', 'Easy'),
(4, 'SMS-based codes can be weaker because:', 'Medium');

INSERT INTO answers (question_id, answer_text, is_correct) VALUES
(16, 'Even if a password is stolen, the attacker still needs the second factor', 1),
(16, 'It makes passwords unnecessary', 0),
(16, 'It speeds up login', 0),
(16, 'It automatically updates your password', 0),
(17, 'Authenticator apps or hardware security keys', 1),
(17, 'Writing the code on paper', 0),
(17, 'Email-only codes with no other protection', 0),
(17, 'Sharing codes with a colleague', 0),
(18, 'Refuse and contact IT through a known official channel', 1),
(18, 'Read the code to them so they can help', 0),
(18, 'Take a screenshot and send it', 0),
(18, 'Ignore the request but leave the app open', 0),
(19, 'Something you know + something you have (or are)', 1),
(19, 'Two different passwords', 0),
(19, 'Your email and phone number only', 0),
(19, 'A long and a short password', 0),
(20, 'They can be intercepted through SIM-swap or other attacks', 1),
(20, 'They are too long', 0),
(20, 'They expire too slowly', 0),
(20, 'They require internet', 0);

-- Questions Module 5
INSERT INTO questions (module_id, question_text, difficulty) VALUES
(5, 'Which of the following is considered personal data?', 'Easy'),
(5, 'A good everyday privacy habit is to:', 'Easy'),
(5, 'When an app asks for many permissions, you should:', 'Medium'),
(5, 'Once you post personal information publicly online:', 'Medium'),
(5, 'In Australia, organisations that handle personal information are expected to follow:', 'Easy');

INSERT INTO answers (question_id, answer_text, is_correct) VALUES
(21, 'Your name, email address and phone number', 1),
(21, 'The current weather', 0),
(21, 'A public company stock price', 0),
(21, 'The name of a city', 0),
(22, 'Review privacy settings and limit who can see your information', 1),
(22, 'Share everything so friends stay updated', 0),
(22, 'Use the same password for all social accounts', 0),
(22, 'Accept every permission request', 0),
(23, 'Only grant the permissions that are necessary for the feature you need', 1),
(23, 'Always allow all permissions for convenience', 0),
(23, 'Ignore the request and continue', 0),
(23, 'Grant location access even if the app does not need it', 0),
(24, 'You have limited control over how it is copied or reused', 1),
(24, 'You can always fully delete every copy', 0),
(24, 'It is automatically private', 0),
(24, 'Only your friends can ever see it', 0),
(25, 'The Australian Privacy Principles (APPs) under the Privacy Act', 1),
(25, 'Only company internal policies', 0),
(25, 'No rules at all', 0),
(25, 'Only state traffic laws', 0);
