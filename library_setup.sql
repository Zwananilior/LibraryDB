\
-- Library Management System SQL Script for PostgreSQL
-- File: library_setup.sql
-- Usage (psql): \i library_setup.sql
-- This script creates the database, tables, sample data, and includes common queries.

-- 1) Create database (run as a superuser or in psql shell)
-- Note: If you are using pgAdmin, create a database named LibraryDB first and then run the rest of this script in that DB.
CREATE DATABASE LibraryDB;
\connect LibraryDB;

-- 2) Create tables
CREATE TABLE authors (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  nationality TEXT,
  birth_year INT,
  death_year INT
);

CREATE TABLE books (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  author_id INT REFERENCES authors(id) ON DELETE SET NULL,
  genres TEXT[],
  published_year INT,
  available BOOLEAN DEFAULT TRUE
);

CREATE TABLE patrons (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE,
  borrowed_books INT[] DEFAULT ARRAY[]::INT[]
);

-- 3) Insert sample authors (10)
INSERT INTO authors (id, name, nationality, birth_year, death_year) VALUES
(1, 'George Orwell', 'British', 1903, 1950),
(2, 'Harper Lee', 'American', 1926, 2016),
(3, 'F. Scott Fitzgerald', 'American', 1896, 1940),
(4, 'Aldous Huxley', 'British', 1894, 1963),
(5, 'J.D. Salinger', 'American', 1919, 2010),
(6, 'Herman Melville', 'American', 1819, 1891),
(7, 'Jane Austen', 'British', 1775, 1817),
(8, 'Leo Tolstoy', 'Russian', 1828, 1910),
(9, 'Fyodor Dostoevsky', 'Russian', 1821, 1881),
(10, 'J.R.R. Tolkien', 'British', 1892, 1973);

-- 4) Insert sample books (10)
INSERT INTO books (id, title, author_id, genres, published_year, available) VALUES
(1, '1984', 1, ARRAY['Dystopian','Political Fiction'], 1949, TRUE),
(2, 'To Kill a Mockingbird', 2, ARRAY['Southern Gothic','Bildungsroman'], 1960, TRUE),
(3, 'The Great Gatsby', 3, ARRAY['Tragedy'], 1925, TRUE),
(4, 'Brave New World', 4, ARRAY['Dystopian','Science Fiction'], 1932, TRUE),
(5, 'The Catcher in the Rye', 5, ARRAY['Realist Novel','Bildungsroman'], 1951, TRUE),
(6, 'Moby-Dick', 6, ARRAY['Adventure Fiction'], 1851, TRUE),
(7, 'Pride and Prejudice', 7, ARRAY['Romantic Novel'], 1813, TRUE),
(8, 'War and Peace', 8, ARRAY['Historical Novel'], 1869, TRUE),
(9, 'Crime and Punishment', 9, ARRAY['Philosophical Novel'], 1866, TRUE),
(10, 'The Hobbit', 10, ARRAY['Fantasy'], 1937, TRUE);

-- 5) Insert sample patrons (10)
INSERT INTO patrons (id, name, email, borrowed_books) VALUES
(1, 'Alice Johnson', 'alice@example.com', ARRAY[]::INT[]),
(2, 'Bob Smith', 'bob@example.com', ARRAY[1,2]),
(3, 'Carol White', 'carol@example.com', ARRAY[]::INT[]),
(4, 'David Brown', 'david@example.com', ARRAY[3]),
(5, 'Eve Davis', 'eve@example.com', ARRAY[]::INT[]),
(6, 'Frank Moore', 'frank@example.com', ARRAY[4,5]),
(7, 'Grace Miller', 'grace@example.com', ARRAY[]::INT[]),
(8, 'Hank Wilson', 'hank@example.com', ARRAY[6]),
(9, 'Ivy Taylor', 'ivy@example.com', ARRAY[]::INT[]),
(10, 'Jack Anderson', 'jack@example.com', ARRAY[7,8]);

-- ==================
-- Task Queries (Sprint examples)
-- ==================

-- SPRINT 3: Read Operations
-- Get all books
SELECT * FROM books ORDER BY id;

-- Get a book by title (case-insensitive)
PREPARE get_book_by_title(text) AS
  SELECT b.*, a.name AS author_name FROM books b LEFT JOIN authors a ON b.author_id = a.id WHERE LOWER(b.title) = LOWER($1);

-- Example: EXECUTE get_book_by_title('1984');

-- Get all books by a specific author (by author name)
PREPARE get_books_by_author(text) AS
  SELECT b.* FROM books b JOIN authors a ON b.author_id = a.id WHERE LOWER(a.name) = LOWER($1);

-- Example: EXECUTE get_books_by_author('George Orwell');

-- Get all available books
SELECT * FROM books WHERE available = TRUE ORDER BY title;

-- SPRINT 4: Update Operations
-- Mark a book as borrowed (set available = FALSE)
-- Usage: UPDATE books SET available = FALSE WHERE id = <book_id>;
-- Better: a single transaction to mark book as borrowed and add to patron's record
-- Borrow function (simple implementation using transaction steps)
-- 1) Check book availability, 2) update books.available, 3) append to patron.borrowed_books
-- Example SQL (manual):
-- BEGIN;
-- SELECT available FROM books WHERE id = 1;
-- UPDATE books SET available = FALSE WHERE id = 1;
-- UPDATE patrons SET borrowed_books = array_append(borrowed_books, 1) WHERE id = 2;
-- COMMIT;

-- Mark a book as returned:
-- UPDATE books SET available = TRUE WHERE id = <book_id>;
-- UPDATE patrons SET borrowed_books = array_remove(borrowed_books, <book_id>) WHERE id = <patron_id>;

-- Add a new genre to an existing book
-- Example: add "Political Satire" to book id 1
UPDATE books SET genres = array_append(genres, 'Political Satire') WHERE id = 1;

-- Add a borrowed book to a patron’s record (example)
UPDATE patrons SET borrowed_books = array_append(borrowed_books, 9) WHERE id = 1;

-- SPRINT 5: Delete Operations
-- Delete a book by title (example)
PREPARE delete_book_by_title(text) AS
  DELETE FROM books WHERE LOWER(title) = LOWER($1);

-- Delete an author by ID (this will set author_id in books to NULL because of ON DELETE SET NULL)
PREPARE delete_author_by_id(INT) AS
  DELETE FROM authors WHERE id = $1;

-- SPRINT 6: Advanced Queries
-- Find books published after 1950
SELECT * FROM books WHERE published_year > 1950 ORDER BY published_year;

-- Find all American authors
SELECT * FROM authors WHERE LOWER(nationality) = 'american' OR LOWER(nationality) = 'united states' OR LOWER(nationality) = 'usa';

-- Set all books as available
UPDATE books SET available = TRUE;

-- Find all books that are available AND published after 1950
SELECT * FROM books WHERE available = TRUE AND published_year > 1950;

-- Find authors whose names contain "George"
SELECT * FROM authors WHERE name ILIKE '%George%';

-- Increment the published year 1869 by 1 (for books published in 1869)
UPDATE books SET published_year = published_year + 1 WHERE published_year = 1869;

-- Helpful SELECTs / Joins
-- Books with author names
SELECT b.id, b.title, a.name AS author_name, b.genres, b.published_year, b.available
FROM books b LEFT JOIN authors a ON b.author_id = a.id
ORDER BY b.id;

-- Patrons and their borrowed books (expanded)
SELECT p.id, p.name, p.email, p.borrowed_books,
       array_agg(b.title ORDER BY b.id) FILTER (WHERE b.id IS NOT NULL) AS borrowed_titles
FROM patrons p LEFT JOIN LATERAL (
  SELECT unnest(p.borrowed_books) AS book_id
) AS ids ON true
LEFT JOIN books b ON b.id = ids.book_id
GROUP BY p.id, p.name, p.email, p.borrowed_books
ORDER BY p.id;

-- CLEANUP (optional)
-- DROP DATABASE LibraryDB; -- Be careful with this!
