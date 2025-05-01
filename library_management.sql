DROP DATABASE IF EXISTS library_management;

-- Create database
CREATE DATABASE library_management;
USE library_management;

-- Members table
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    join_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    membership_status ENUM('active', 'expired', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Authors table
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_year YEAR,
    country VARCHAR(50),
    bio TEXT
);

-- Publishers table
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100)
);

-- Categories table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    parent_category_id INT,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- Books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    publisher_id INT,
    publication_year YEAR,
    edition VARCHAR(20),
    language VARCHAR(30) DEFAULT 'English',
    page_count INT,
    description TEXT,
    category_id INT,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- Book copies (physical instances of books)
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    acquisition_date DATE DEFAULT (CURRENT_DATE),
    copy_status ENUM('available', 'checked_out', 'reserved', 'damaged', 'lost') DEFAULT 'available',
    shelf_location VARCHAR(50),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
);

-- Book-Author relationship (Many-to-Many)
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    role ENUM('main', 'co_author', 'editor', 'translator') DEFAULT 'main',
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Loans table
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    checkout_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE,
    fine_amount DECIMAL(10, 2) DEFAULT 0.00,
    status ENUM('active', 'returned', 'overdue', 'lost') DEFAULT 'active',
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT
);

-- Reservations table
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATE,
    status ENUM('pending', 'fulfilled', 'cancelled', 'expired') DEFAULT 'pending',
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- Staff table
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    role ENUM('librarian', 'assistant', 'admin', 'manager') NOT NULL,
    hire_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    login_username VARCHAR(50) UNIQUE NOT NULL
);

-- Events table
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    max_participants INT,
    location VARCHAR(100),
    organizer_id INT,
    FOREIGN KEY (organizer_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

-- Fine payments table
CREATE TABLE fine_payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('cash', 'credit_card', 'debit_card', 'online') NOT NULL,
    processed_by INT,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE RESTRICT,
    FOREIGN KEY (processed_by) REFERENCES staff(staff_id) ON DELETE SET NULL
);

-- Creating indexes for better performance
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_loans_status ON loans(status);
CREATE INDEX idx_members_status ON members(membership_status);
CREATE INDEX idx_book_copies_status ON book_copies(copy_status);

-- Insert sample data

-- Insert Categories
INSERT INTO categories (name) VALUES 
('Fiction'),
('Non-Fiction'),
('Science Fiction'),
('Mystery'),
('Biography'),
('History'),
('Computer Science'),
('Self-Help');

INSERT INTO categories (name, parent_category_id) VALUES 
('Fantasy', 1),
('Thriller', 1),
('Science', 2),
('Programming', 7),
('Web Development', 13);

-- Insert Publishers
INSERT INTO publishers (name, address, phone, email) VALUES
('Penguin Random House', '1745 Broadway, New York, NY 10019', '212-782-9000', 'contact@penguinrandomhouse.com'),
('HarperCollins', '195 Broadway, New York, NY 10007', '212-207-7000', 'info@harpercollins.com'),
('O\'Reilly Media', '1005 Gravenstein Highway North, Sebastopol, CA 95472', '707-827-7000', 'support@oreilly.com'),
('Packt Publishing', '651 N Broad St, Suite 201, Middletown, DE 19709', '800-323-9872', 'customercare@packtpub.com'),
('Simon & Schuster', '1230 Avenue of the Americas, New York, NY 10020', '212-698-7000', 'contact@simonandschuster.com');

-- Insert Authors
INSERT INTO authors (first_name, last_name, birth_year, country, bio) VALUES
('J.K.', 'Rowling', 1965, 'United Kingdom', 'British author best known for the Harry Potter series'),
('Stephen', 'King', 1947, 'United States', 'American author of horror, supernatural fiction, suspense, and fantasy novels'),
('Mark', 'Lutz', 1958, 'United States', 'Python trainer and author of several programming books'),
('Michelle', 'Obama', 1964, 'United States', 'American attorney, author, and former First Lady of the United States'),
('Yuval Noah', 'Harari', 1976, 'Israel', 'Israeli public intellectual, historian and professor'),
('George R.R.', 'Martin', 1948, 'United States', 'American novelist and short story writer, screenwriter, and television producer'),
('Agatha', 'Christie', 1890, 'United Kingdom', 'English writer known for her detective novels');

-- Insert Books
INSERT INTO books (title, isbn, publisher_id, publication_year, edition, language, page_count, description, category_id) VALUES
('Harry Potter and the Philosopher\'s Stone', '9780747532743', 1, 1997, '1st', 'English', 223, 'Harry Potter\'s first adventure at Hogwarts School of Witchcraft and Wizardry', 9),
('The Shining', '9780385121675', 2, 1977, '1st', 'English', 447, 'A family heads to an isolated hotel for the winter where a sinister presence influences the father', 10),
('Learning Python', '9781449355739', 3, 2013, '5th', 'English', 1648, 'Comprehensive introduction to the Python programming language', 13),
('Becoming', '9781524763138', 1, 2018, '1st', 'English', 448, 'Memoir of former First Lady Michelle Obama', 5),
('Sapiens: A Brief History of Humankind', '9780062316097', 2, 2014, '1st', 'English', 443, 'A brief history of humankind from the Stone Age to the present day', 6),
('A Game of Thrones', '9780553103540', 5, 1996, '1st', 'English', 694, 'The first book in the A Song of Ice and Fire series', 9),
('Murder on the Orient Express', '9780062073501', 2, 1934, '1st', 'English', 256, 'Hercule Poirot solves a murder mystery on a luxurious train', 4);

-- Link Books and Authors
INSERT INTO book_authors (book_id, author_id, role) VALUES
(1, 1, 'main'),
(2, 2, 'main'),
(3, 3, 'main'),
(4, 4, 'main'),
(5, 5, 'main'),
(6, 6, 'main'),
(7, 7, 'main');

-- Insert Book Copies
INSERT INTO book_copies (book_id, acquisition_date, copy_status, shelf_location) VALUES
(1, '2023-01-15', 'available', 'A12-S3'),
(1, '2023-01-15', 'available', 'A12-S3'),
(2, '2023-02-20', 'checked_out', 'B05-S2'),
(3, '2023-03-10', 'available', 'C08-S1'),
(4, '2023-04-05', 'checked_out', 'D03-S4'),
(5, '2023-05-12', 'available', 'E06-S2'),
(6, '2023-06-18', 'damaged', 'F09-S3'),
(7, '2023-07-22', 'available', 'G11-S1');

-- Insert Members
INSERT INTO members (first_name, last_name, email, phone, address, join_date, membership_status) VALUES
('John', 'Smith', 'john.smith@email.com', '555-1234', '123 Main St, Anytown, USA', '2023-01-10', 'active'),
('Emily', 'Johnson', 'emily.j@email.com', '555-5678', '456 Oak Ave, Somewhere, USA', '2023-02-15', 'active'),
('Michael', 'Brown', 'michael.b@email.com', '555-9012', '789 Pine Rd, Nowhere, USA', '2023-03-20', 'suspended'),
('Sarah', 'Davis', 'sarah.d@email.com', '555-3456', '321 Elm St, Anywhere, USA', '2023-04-25', 'active'),
('David', 'Wilson', 'david.w@email.com', '555-7890', '654 Maple Dr, Everywhere, USA', '2023-05-30', 'expired');

-- Insert Staff
INSERT INTO staff (first_name, last_name, email, phone, role, hire_date, login_username) VALUES
('Anna', 'Garcia', 'anna.g@library.org', '555-1111', 'librarian', '2022-01-15', 'anna_g'),
('Robert', 'Lee', 'robert.l@library.org', '555-2222', 'assistant', '2022-03-20', 'robert_l'),
('Maria', 'Wong', 'maria.w@library.org', '555-3333', 'admin', '2022-05-25', 'maria_w'),
('James', 'Taylor', 'james.t@library.org', '555-4444', 'manager', '2022-07-30', 'james_t');

-- Insert Loans
INSERT INTO loans (copy_id, member_id, checkout_date, due_date, return_date, status) VALUES
(2, 1, '2023-08-01', '2023-08-15', NULL, 'active'),
(3, 2, '2023-07-15', '2023-07-29', '2023-07-28', 'returned'),
(5, 3, '2023-06-20', '2023-07-04', NULL, 'overdue'),
(4, 4, '2023-08-05', '2023-08-19', NULL, 'active');

-- Insert Reservations
INSERT INTO reservations (book_id, member_id, reservation_date, expiry_date, status) VALUES
(6, 1, '2023-08-02', '2023-08-09', 'pending'),
(7, 2, '2023-07-25', '2023-08-01', 'fulfilled'),
(1, 5, '2023-08-03', '2023-08-10', 'pending');

-- Insert Events
INSERT INTO events (title, description, event_date, start_time, end_time, max_participants, location, organizer_id) VALUES
('Book Club Meeting', 'Discussion of the month\'s book selection', '2023-08-15', '18:00:00', '20:00:00', 15, 'Reading Room 1', 1),
('Author Signing: Local Writers', 'Meet and greet with local authors', '2023-08-22', '14:00:00', '16:00:00', 50, 'Main Hall', 4),
('Children\'s Story Time', 'Weekly story reading for children ages 3-6', '2023-08-10', '10:00:00', '11:00:00', 20, 'Children\'s Area', 2);

-- Insert Fine Payments
INSERT INTO fine_payments (loan_id, payment_date, amount, payment_method, processed_by) VALUES
(3, '2023-07-30', 5.50, 'cash', 2),
(3, '2023-08-01', 2.75, 'credit_card', 1);

-- Create a view for available books
CREATE VIEW available_books AS
SELECT b.book_id, b.title, b.isbn, a.first_name, a.last_name, 
       p.name AS publisher, c.name AS category, COUNT(bc.copy_id) AS available_copies
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
JOIN publishers p ON b.publisher_id = p.publisher_id
JOIN categories c ON b.category_id = c.category_id
JOIN book_copies bc ON b.book_id = bc.book_id
WHERE bc.copy_status = 'available'
GROUP BY b.book_id, b.title, b.isbn, a.first_name, a.last_name, p.name, c.name;

-- Create a view for member loan history
CREATE VIEW member_loan_history AS
SELECT m.member_id, m.first_name, m.last_name, b.title, l.checkout_date, 
       l.due_date, l.return_date, l.status, l.fine_amount
FROM members m
JOIN loans l ON m.member_id = l.member_id
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
ORDER BY m.member_id, l.checkout_date DESC;

-- Create a stored procedure to check out a book
DELIMITER //
CREATE PROCEDURE check_out_book(
    IN p_copy_id INT,
    IN p_member_id INT,
    IN p_due_days INT
)
BEGIN
    DECLARE v_copy_status VARCHAR(20);
    DECLARE v_member_status VARCHAR(20);
    
    -- Check if copy is available
    SELECT copy_status INTO v_copy_status FROM book_copies WHERE copy_id = p_copy_id;
    
    -- Check if member is active
    SELECT membership_status INTO v_member_status FROM members WHERE member_id = p_member_id;
    
    IF v_copy_status = 'available' AND v_member_status = 'active' THEN
        -- Update copy status
        UPDATE book_copies SET copy_status = 'checked_out' WHERE copy_id = p_copy_id;
        
        -- Create loan record
        INSERT INTO loans (copy_id, member_id, checkout_date, due_date, status)
        VALUES (p_copy_id, p_member_id, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL p_due_days DAY), 'active');
        
        SELECT 'Book checked out successfully.' AS message;
    ELSE
        IF v_copy_status != 'available' THEN
            SELECT 'Error: Book copy is not available.' AS message;
        ELSE
            SELECT 'Error: Member status is not active.' AS message;
        END IF;
    END IF;
END //
DELIMITER ;

-- Create a stored procedure to return a book
DELIMITER //
CREATE PROCEDURE return_book(
    IN p_copy_id INT
)
BEGIN
    DECLARE v_loan_id INT;
    DECLARE v_due_date DATE;
    DECLARE v_days_overdue INT;
    DECLARE v_fine_amount DECIMAL(10,2);
    
    -- Find the active loan for this copy
    SELECT loan_id, due_date INTO v_loan_id, v_due_date 
    FROM loans 
    WHERE copy_id = p_copy_id AND (status = 'active' OR status = 'overdue');
    
    IF v_loan_id IS NOT NULL THEN
        -- Update copy status
        UPDATE book_copies SET copy_status = 'available' WHERE copy_id = p_copy_id;
        
        -- Calculate fine if overdue
        IF CURRENT_DATE > v_due_date THEN
            SET v_days_overdue = DATEDIFF(CURRENT_DATE, v_due_date);
            SET v_fine_amount = v_days_overdue * 0.50; -- $0.50 per day
            
            -- Update loan with fine and overdue status
            UPDATE loans 
            SET return_date = CURRENT_DATE, 
                status = 'returned', 
                fine_amount = v_fine_amount 
            WHERE loan_id = v_loan_id;
            
            SELECT CONCAT('Book returned. Overdue by ', v_days_overdue, ' days. Fine: $', v_fine_amount) AS message;
        ELSE
            -- Update loan with normal return
            UPDATE loans 
            SET return_date = CURRENT_DATE, 
                status = 'returned' 
            WHERE loan_id = v_loan_id;
            
            SELECT 'Book returned successfully.' AS message;
        END IF;
    ELSE
        SELECT 'Error: No active loan found for this book copy.' AS message;
    END IF;
END //
DELIMITER ;

-- Create a trigger to update overdue loans
DELIMITER //
CREATE TRIGGER update_overdue_loans
BEFORE UPDATE ON loans
FOR EACH ROW
BEGIN
    -- If the loan is active and the due date has passed, mark it as overdue
    IF NEW.status = 'active' AND NEW.due_date < CURRENT_DATE THEN
        SET NEW.status = 'overdue';
    END IF;
END //
DELIMITER ;

-- Create a trigger for when a book copy is marked as lost
DELIMITER //
CREATE TRIGGER book_copy_lost
AFTER UPDATE ON book_copies
FOR EACH ROW
BEGIN
    -- If a copy is marked as lost, update any active/overdue loans accordingly
    IF NEW.copy_status = 'lost' AND OLD.copy_status != 'lost' THEN
        UPDATE loans 
        SET status = 'lost', 
            fine_amount = 25.00 -- Standard replacement fee
        WHERE copy_id = NEW.copy_id AND (status = 'active' OR status = 'overdue');
    END IF;
END //
DELIMITER ;