CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);
CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_followers (
  id INTEGER PRIMARY KEY,
  question_id INTEGER,
  follower_id INTEGER,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (follower_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  author_id INTEGER NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER,
  liker_id INTEGER,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (liker_id) REFERENCES users(id)
);

INSERT INTO 
  users (fname, lname)
VALUES
('Bob', 'Jones'), ('Randy', 'Smith'), ('Ryan', 'Ngai'), ('John', 'Ochs');

INSERT INTO
  questions (title, body, author_id)
VALUES
('What am I doing?', 'Dude seriously I do not know what I am doing.', 2),
('Why am I not cool anymore?', 'Really... not cool anymore.', 3),
('I have a serious question!', 'This is a seriously serious question!', 3);

INSERT INTO
  question_followers (question_id, follower_id)
VALUES
(1, 1), (2, 4), (2, 3);

INSERT INTO
replies (body, question_id, parent_id, author_id)
VALUES
('Lol I have no idea either', 1, NULL, 1),
('You stopped showering, that was a bad idea', 2, NULL, 3),
('lol r u srs YOLO', 2, 2, 1);

INSERT INTO
question_likes (question_id, liker_id)
VALUES
(2, 2), (1, 3), (2, 4), (3, 1), (3, 2), (3, 3), (3, 4);
  