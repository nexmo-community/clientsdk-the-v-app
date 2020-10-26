CREATE TABLE IF NOT EXISTS users (
  username varchar(100) NOT NULL,
  password varchar(500) NOT NULL,
  name varchar(100) NOT NULL,
  PRIMARY KEY (username)
);