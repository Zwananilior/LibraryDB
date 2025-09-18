\
# Library Management System (PostgreSQL)

## Overview
This project is a small Library Management System implemented with PostgreSQL. It contains SQL scripts to create a database, tables, sample data, and example queries and operations for adding, updating, deleting, and querying records.

## Files
- `library_setup.sql` — SQL script that creates the `LibraryDB` database, tables (`authors`, `books`, `patrons`), inserts sample data, and includes example queries and tasks for each sprint.
- `README.md` — This file.

## How to run (psql)
1. Open a terminal.
2. Start psql as a PostgreSQL superuser (or a user that can create databases):
   ```
   psql -U postgres
   ```
3. In the `psql` prompt, run the script (adjust path if necessary):
   ```
   \i /path/to/library_setup.sql
   ```
   The script will attempt to create `LibraryDB` and then connect to it. If you already created `LibraryDB` in pgAdmin, you can comment out the `CREATE DATABASE` line and the `\connect` line and run the rest of the script inside that database.
4. To run prepared statements or sample commands, copy and paste them into psql and execute. For prepared statements, use `EXECUTE ...` (examples are commented in the script).

## How to run in pgAdmin
1. Open pgAdmin and connect to your PostgreSQL server.
2. Right-click on `Databases` → `Create` → `Database` → name: `LibraryDB` (or any name you prefer).
3. Open the Query Tool for `LibraryDB` and paste the contents of `library_setup.sql` (except the `CREATE DATABASE` and `\connect` lines if you created the DB manually).
4. Run the script to create tables and insert sample data.
5. Use the Query Tool to run the sample queries included in the script.

## Sprint checklist & example commands
### Sprint 1: Project Setup
- Create the `LibraryDB` database (script does this).
- Create tables `authors`, `books`, `patrons` (script does this).

### Sprint 2: Insert Data
- The script inserts 10 sample authors, 10 books, and 10 patrons.

### Sprint 3: Read Operations
- Get all books:
  ```sql
  SELECT * FROM books ORDER BY id;
  ```
- Get a book by title (prepared):
  ```sql
  EXECUTE get_book_by_title('1984');
  ```
- Get all books by author:
  ```sql
  EXECUTE get_books_by_author('George Orwell');
  ```
- Get all available books:
  ```sql
  SELECT * FROM books WHERE available = TRUE;
  ```

### Sprint 4: Update Operations
- Borrow a book (example transaction):
  ```sql
  BEGIN;
  -- check availability
  SELECT available FROM books WHERE id = 1;
  UPDATE books SET available = FALSE WHERE id = 1;
  UPDATE patrons SET borrowed_books = array_append(borrowed_books, 1) WHERE id = 2;
  COMMIT;
  ```
- Return a book:
  ```sql
  UPDATE books SET available = TRUE WHERE id = 1;
  UPDATE patrons SET borrowed_books = array_remove(borrowed_books, 1) WHERE id = 2;
  ```
- Add a genre to a book:
  ```sql
  UPDATE books SET genres = array_append(genres, 'New Genre') WHERE id = 1;
  ```

### Sprint 5: Delete Operations
- Delete a book by title:
  ```sql
  EXECUTE delete_book_by_title('The Hobbit');
  ```
- Delete an author by ID:
  ```sql
  EXECUTE delete_author_by_id(10);
  ```

### Sprint 6: Advanced Queries
- Find books published after 1950:
  ```sql
  SELECT * FROM books WHERE published_year > 1950;
  ```
- Find all American authors:
  ```sql
  SELECT * FROM authors WHERE LOWER(nationality) = 'american';
  ```
- Set all books available:
  ```sql
  UPDATE books SET available = TRUE;
  ```

## Notes & Tips
- If a `CREATE DATABASE` fails due to permissions, create the database in pgAdmin or with a superuser account, then run the rest of the script inside that database.
