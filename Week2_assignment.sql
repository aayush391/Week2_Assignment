--------Week 2 Assignment -----------
----------question 1------
CREATE TABLE author(
	author_id INT PRIMARY KEY ,
	author_name VARCHAR(100)
);
CREATE TABLE BOOK(
	book_id INT PRIMARY KEY,
	author_id INT,
	title VARCHAR(100),
	publish_year INT,
	FOREIGN KEY(author_id) REFERENCES author(author_id)
);
CREATE TABLE adaptation(
	book_id INT PRIMARY KEY,
	type VARCHAR(20),
	title VARCHAR(150),
	release_year INT,
	rating DECIMAL(4,2),
	FOREIGN KEY(book_id) REFERENCES book(book_id)
	);
CREATE TABLE book_review(
	review_id INT PRIMARY KEY,
	book_id INT,
	rating DECIMAL(4,2),
	FOREIGN KEY (book_id) REFERENCES book(book_id)
);
INSERT INTO author VALUES 
(1, 'Anita Rao'),
(2, 'Dev Malhotra'),
(3, 'Kiran Sethi'),
(4, 'Leela Thomas');
INSERT INTO book VALUES
(101, 1, 'The Monsoon Letters', 2015),
(102, 1, 'City of Lanterns', 2018),
(103, 2, 'Code of the Hills', 2012),
(104, 3, 'The Last Tea Garden', 2019),
(105, 4, 'Silent Harbour', 2016),
(106, 2, 'Paper Kites', 2020);
INSERT INTO adaptation VALUES
(101, 'Movie', 'Monsoon Letters', 2017, 8.10),
(102, 'Series', 'Lanterns', 2024, 7.90),
(103, 'Movie', 'Hill Code', 2014, 7.00),
(104, 'Series', 'Tea Garden', 2022, 8.60),
(105, 'Movie', 'Harbour', 2018, 6.50),
(106, 'Movie', 'Kites', 2021, 7.40);
INSERT INTO book_review VALUES
(1, 101, 7),
(2, 101, 8),
(3, 102, 6),
(4, 102, 7),
(5, 103, 8),
(6, 103, 7),
(7, 103, 9),
(8, 104, 8),
(9, 104, 8),
(10, 105, 6),
(11, 105, 7),
(12, 106, 7),
(13, 106, 7),
(14, 106, 7);
WITH BookRatings AS
(
    SELECT
      book_id,
      CAST(AVG(rating) AS DECIMAL(4,2)) AS book_rating
    FROM book_review
    GROUP BY book_id
)
SELECT
    b.title AS book_title,
    ad.title AS adaptation_title,
    ad.release_year AS adaptation_year,
    b.publish_year AS publication_year,
    au.author_name,
    br.book_rating,
    ad.rating AS adaptation_rating
FROM book b
INNER JOIN author au
    ON b.author_id = au.author_id
INNER JOIN adaptation ad
    ON b.book_id = ad.book_id
INNER JOIN BookRatings br
    ON b.book_id = br.book_id
WHERE
    br.book_rating < ad.rating
    AND ad.release_year BETWEEN b.publish_year
    AND b.publish_year + 4
ORDER BY
    b.title


-------question 2---------
CREATE TABLE customers
(
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);
CREATE TABLE orders
(
    order_id INT PRIMARY KEY,
    customer_id VARCHAR(10),
    order_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);
CREATE TABLE order_items
(
    order_id INT,
    product_id VARCHAR(10),
    qty INT,
    unit_price DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)
);
INSERT INTO customers
(customer_id, customer_name, city, signup_date)
VALUES
('C01', 'Rahul Mehta', 'Jaipur', '2025-11-02'),
('C02', 'Priya Nair', 'Kochi', '2025-12-15'),
('C03', 'Arjun Das', 'Kolkata', '2026-01-08'),
('C04', 'Fatima Sheikh', 'Mumbai', '2026-01-20'),
('C05', 'Karan Malhotra', 'Delhi', '2026-02-11'),
('C06', 'Sneha Kulkarni', 'Pune', '2026-02-25');
INSERT INTO orders
(order_id, customer_id, order_date, status)
VALUES
(1001, 'C01', '2026-03-02', 'Delivered'),
(1002, 'C02', '2026-03-03', 'Delivered'),
(1003, 'C01', '2026-03-10', 'Delivered'),
(1004, 'C03', '2026-03-12', 'Cancelled'),
(1005, 'C04', '2026-03-15', 'Shipped'),
(1006, 'C05', '2026-03-18', 'Delivered'),
(1007, 'C01', '2026-04-01', 'Shipped'),
(1008, 'C06', '2026-04-03', 'Pending');
INSERT INTO order_items
(order_id, product_id, qty, unit_price)
VALUES
(1001, 'P1', 2, 799),
(1001, 'P3', 5, 120),
(1002, 'P2', 1, 1999),
(1003, 'P4', 2, 250),
(1003, 'P6', 1, 499),
(1004, 'P5', 1, 1499),
(1005, 'P1', 1, 799),
(1005, 'P2', 1, 1999),
(1005, 'P3', 10, 120),
(1006, 'P6', 3, 499),
(1007, 'P5', 1, 1499),
(1008, 'P4', 4, 250);
SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM order_items;
GO
CREATE FUNCTION dbo.fn_format_us_date
(
    @input_date DATETIME
)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN CONVERT(VARCHAR(10), @input_date, 101);
END;
GO
SELECT dbo.fn_format_us_date('2006-11-21 23:34:05.920')
AS formatted_date;
GO
CREATE PROCEDURE dbo.sp_customer_orders
    @customer_id VARCHAR(10),
    @order_count INT OUTPUT,
    @total_value DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @order_count = 0;
    SET @total_value = 0;
    IF NOT EXISTS
    (
        SELECT 1
        FROM customers
        WHERE customer_id = @customer_id
    )
    BEGIN
        RETURN;
    END;
    DECLARE @CustomerOrders TABLE
    (
        order_id INT,
        order_date_us VARCHAR(10),
        status VARCHAR(20),
        order_value DECIMAL(10,2)
    );
    INSERT INTO @CustomerOrders
    (
        order_id,
        order_date_us,
        status,
        order_value
    )
    SELECT
        o.order_id,
        dbo.fn_format_us_date(o.order_date),
        o.status,
        SUM(oi.qty * oi.unit_price)
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.customer_id = @customer_id
      AND o.status <> 'Cancelled'
    GROUP BY
        o.order_id,
        o.order_date,
        o.status;
    SELECT
        @order_count = COUNT(*),
        @total_value = ISNULL(SUM(order_value), 0)
    FROM @CustomerOrders;
    SELECT
        order_id,
        order_date_us,
        status,
        order_value
    FROM @CustomerOrders
    ORDER BY order_id;
END;
GO
DECLARE @cnt INT,
        @val DECIMAL(10,2);
EXEC dbo.sp_customer_orders
    @customer_id = 'C01',
    @order_count = @cnt OUTPUT,
    @total_value = @val OUTPUT;
SELECT
    @cnt AS order_count,
    @val AS total_value;
    GO
 DECLARE @cnt INT,
        @val DECIMAL(10,2);
EXEC dbo.sp_customer_orders
    @customer_id = 'C99',
    @order_count = @cnt OUTPUT,
    @total_value = @val OUTPUT;
SELECT
    @cnt AS order_count,
    @val AS total_value;


--------question 3-------
CREATE TABLE datepro
(
    id INT PRIMARY KEY,
    Dateint INT,
    Datentime VARCHAR(50)
);
INSERT INTO datepro (id, Dateint, Datentime)
VALUES
(101, 20220510, '2022-05-10T09:30:00+05:30'),
(102, 20220227, '2022-02-27T18:45:00+05:30'),
(103, 20220925, '2022-09-25T12:16:00+05:30'),
(104, 20221229, '2022-12-29T07:05:00+05:30'),
(105, 20221228, '2022-12-28T11:29:00+05:30');
CREATE TABLE datepro_data
(
    Id INT,
    Dateint INT,
    Datentime VARCHAR(16),
    Dates DATE
);
GO
CREATE PROCEDURE dbo.sp_dateproc
    @ids VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM datepro_data
    WHERE Id IN
    (
        SELECT TRY_CAST(value AS INT)
        FROM STRING_SPLIT(@ids, ',')
    )
    ;WITH SelectedRows AS
    (
        SELECT
            dp.id,
            dp.Dateint,
            LEFT(REPLACE(dp.Datentime, 'T', ' '), 16) AS Datentime,
            CONVERT(DATE, CONVERT(CHAR(8), dp.Dateint), 112) AS StartDate
        FROM datepro dp
        INNER JOIN STRING_SPLIT(@ids, ',') s
            ON dp.id = TRY_CAST(s.value AS INT)
    ),

    DateSeries AS
    (
        SELECT
            id,
            Dateint,
            Datentime,
            StartDate,
            EOMONTH(StartDate) AS LastDate,
            StartDate AS Dates
        FROM SelectedRows
        UNION ALL
        SELECT
            id,
            Dateint,
            Datentime,
            StartDate,
            LastDate,
            DATEADD(DAY, 1, Dates)
        FROM DateSeries
        WHERE Dates < LastDate
    )
    INSERT INTO datepro_data
    (
        Id,
        Dateint,
        Datentime,
        Dates
    )
    SELECT
        id,
        Dateint,
        Datentime,
        Dates
    FROM DateSeries
    OPTION (MAXRECURSION 100)
    SELECT
        Id,
        Dateint,
        Datentime,
        Dates
    FROM datepro_data
    WHERE Id IN
    (
        SELECT TRY_CAST(value AS INT)
        FROM STRING_SPLIT(@ids, ',')
    )
    ORDER BY Id, Dates;

END;
GO
EXEC dbo.sp_dateproc '101,102,104';
SELECT *
FROM datepro_data
ORDER BY Id, Dates;
SELECT COUNT(*) AS TotalRows
FROM datepro_data;


---------question 4------
CREATE TABLE StudentDetails
(
    StudentId BIGINT PRIMARY KEY,
    StudentName VARCHAR(100),
    GPA DECIMAL(3,2),
    Branch VARCHAR(20),
    Section CHAR(1)
);
INSERT INTO StudentDetails
(StudentId, StudentName, GPA, Branch, Section)
VALUES
(159103036, 'Mohit Agarwal', 8.90, 'CCE', 'A'),
(159103037, 'Rohit Agarwal', 5.20, 'CCE', 'A'),
(159103038, 'Shohit Garg', 7.10, 'CCE', 'B'),
(159103039, 'Mrinal Malhotra', 7.90, 'CCE', 'A'),
(159103040, 'Mehreet Singh', 5.60, 'CCE', 'A'),
(159103041, 'Arjun Tehlan', 9.20, 'CCE', 'B');
CREATE TABLE SubjectDetails
(
    SubjectId VARCHAR(10) PRIMARY KEY,
    SubjectName VARCHAR(100),
    MaxSeats INT,
    RemainingSeats INT
);
INSERT INTO SubjectDetails
(SubjectId, SubjectName, MaxSeats, RemainingSeats)
VALUES
('PO1491', 'Basics of Political Science', 60, 2),
('PO1492', 'Basics of Accounting', 120, 1),
('PO1493', 'Basics of Financial Markets', 90, 1),
('PO1494', 'Eco philosophy', 60, 1),
('PO1495', 'Automotive Trends', 60, 0);
CREATE TABLE StudentPreference
(
    StudentId BIGINT,
    SubjectId VARCHAR(10),
    Preference INT,
    PRIMARY KEY (StudentId, SubjectId),
    FOREIGN KEY (StudentId)
        REFERENCES StudentDetails(StudentId),
    FOREIGN KEY (SubjectId)
        REFERENCES SubjectDetails(SubjectId)
);
INSERT INTO StudentPreference
(StudentId, SubjectId, Preference)
VALUES
(159103036, 'PO1491', 1),
(159103036, 'PO1492', 2),
(159103036, 'PO1493', 3),
(159103036, 'PO1494', 4),
(159103036, 'PO1495', 5),
-- Student 159103037
(159103037, 'PO1494', 1),
(159103037, 'PO1495', 2),
(159103037, 'PO1492', 3),
(159103037, 'PO1491', 4),
(159103037, 'PO1493', 5),
-- Student 159103038
(159103038, 'PO1492', 1),
(159103038, 'PO1491', 2),
(159103038, 'PO1494', 3),
(159103038, 'PO1495', 4),
(159103038, 'PO1493', 5),
-- Student 159103039
(159103039, 'PO1491', 1),
(159103039, 'PO1492', 2),
(159103039, 'PO1495', 3),
(159103039, 'PO1493', 4),
(159103039, 'PO1494', 5),
-- Student 159103040
(159103040, 'PO1492', 1),
(159103040, 'PO1494', 2),
(159103040, 'PO1491', 3),
(159103040, 'PO1493', 4),
(159103040, 'PO1495', 5),
-- Student 159103041
(159103041, 'PO1491', 1),
(159103041, 'PO1493', 2),
(159103041, 'PO1492', 3),
(159103041, 'PO1494', 4),
(159103041, 'PO1495', 5);
CREATE TABLE Allotments
(
    SubjectId VARCHAR(10),
    StudentId BIGINT,
    FOREIGN KEY (SubjectId)
        REFERENCES SubjectDetails(SubjectId),
    FOREIGN KEY (StudentId)
        REFERENCES StudentDetails(StudentId)
);
CREATE TABLE UnallotedStudents
(
    StudentId BIGINT PRIMARY KEY,
    FOREIGN KEY (StudentId)
        REFERENCES StudentDetails(StudentId)
);
GO
CREATE PROCEDURE dbo.sp_allot_subjects
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Allotments;
    DELETE FROM UnallotedStudents;
    UPDATE SubjectDetails
    SET RemainingSeats =
        CASE
            WHEN RemainingSeats < 0 THEN 0
            ELSE RemainingSeats
        END;

    DECLARE
        @StudentId BIGINT,
        @SubjectId VARCHAR(10),
        @Preference INT,
        @Allocated BIT;
    DECLARE student_cursor CURSOR FOR
        SELECT StudentId
        FROM StudentDetails
        ORDER BY GPA DESC, StudentId ASC;
    OPEN student_cursor;
    FETCH NEXT FROM student_cursor INTO @StudentId;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Allocated = 0;
        DECLARE preference_cursor CURSOR FOR
            SELECT SubjectId, Preference
            FROM StudentPreference
            WHERE StudentId = @StudentId
            ORDER BY Preference ASC;
        OPEN preference_cursor;
        FETCH NEXT FROM preference_cursor
        INTO @SubjectId, @Preference;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF EXISTS
            (
                SELECT 1
                FROM SubjectDetails
                WHERE SubjectId = @SubjectId
                  AND RemainingSeats > 0
            )
            BEGIN
                INSERT INTO Allotments
                (SubjectId, StudentId)
                VALUES
                (@SubjectId, @StudentId);
                UPDATE SubjectDetails
                SET RemainingSeats = RemainingSeats - 1
                WHERE SubjectId = @SubjectId;
                SET @Allocated = 1;
                BREAK;
            END;
            FETCH NEXT FROM preference_cursor
            INTO @SubjectId, @Preference;
        END;
        CLOSE preference_cursor;
        DEALLOCATE preference_cursor
        IF @Allocated = 0
        BEGIN
            INSERT INTO UnallotedStudents(StudentId)
            VALUES (@StudentId);
        END;
        FETCH NEXT FROM student_cursor INTO @StudentId;
    END;
    CLOSE student_cursor;
    DEALLOCATE student_cursor;
END;
GO
EXEC dbo.sp_allot_subjects;
SELECT SubjectId, StudentId
FROM Allotments;
SELECT StudentId
FROM UnallotedStudents;
SELECT *
FROM SubjectDetails;


------question 5-----
CREATE TABLE payments
(
    payment_id VARCHAR(10) PRIMARY KEY,
    order_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),
    method VARCHAR(30)
);
INSERT INTO payments
(payment_id, order_id, payment_date, amount, method)
VALUES
('PM01', 1001, '2026-03-02', 2198, 'UPI'),
('PM02', 1002, '2026-03-03', 1000, 'Card'),
('PM03', 1002, '2026-03-05', 999, 'Card'),
('PM04', 1003, '2026-03-10', 500, 'UPI'),
('PM05', 1005, '2026-03-15', 3998, 'NetBanking'),
('PM06', 1006, '2026-03-18', 1497, 'UPI'),
('PM07', 1009, '2026-04-02', 750, 'UPI'),
('PM08', 1004, '2026-03-12', 1499, 'Card');
CREATE TABLE error_log
(
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    error_time DATETIME DEFAULT GETDATE(),
    proc_name VARCHAR(100),
    error_number INT,
    error_message VARCHAR(500),
    input_values VARCHAR(200)
);
GO
CREATE PROCEDURE dbo.sp_record_payment
    @payment_id VARCHAR(10),
    @order_id INT,
    @amount DECIMAL(10,2),
    @method VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @OrderValue DECIMAL(10,2);
        DECLARE @TotalPaid DECIMAL(10,2);
        DECLARE @OrderStatus VARCHAR(30);
    IF NOT EXISTS
        (
            SELECT 1
            FROM orders
            WHERE order_id = @order_id
        )
        BEGIN
            THROW 50001, 'Order not found', 1;
        END;
        SELECT
            @OrderValue = SUM(oi.qty * oi.unit_price),
            @OrderStatus = o.status
        FROM orders o
        INNER JOIN order_items oi
            ON o.order_id = oi.order_id
        WHERE o.order_id = @order_id
        GROUP BY o.status;
        IF @OrderStatus = 'Cancelled'
        BEGIN
            THROW 50002, 'Order is cancelled', 1;
        END;
        IF @amount <= 0
        BEGIN
            THROW 50003, 'Amount must be greater than zero', 1;
        END;
        SELECT
            @TotalPaid = ISNULL(SUM(amount), 0)
        FROM payments
        WHERE order_id = @order_id;
        IF @TotalPaid + @amount > @OrderValue
        BEGIN
            THROW 50004, 'Payment exceeds order value', 1;
        END;
        INSERT INTO payments
        (
            payment_id,
            order_id,
            payment_date,
            amount,
            method
        )
        VALUES
        (
            @payment_id,
            @order_id,
            GETDATE(),
            @amount,
            @method
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
        INSERT INTO error_log
        (
            proc_name,
            error_number,
            error_message,
            input_values
        )
        VALUES
        (
            'sp_record_payment',
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            CONCAT(
                @payment_id, ',',
                @order_id, ',',
                @amount, ',',
                @method
            )
        );

    END CATCH;
END;
GO
EXEC dbo.sp_record_payment
    'PM09', 1007, 1499, 'Card';
EXEC dbo.sp_record_payment
    'PM10', 1010, 500, 'UPI';
EXEC dbo.sp_record_payment
    'PM11', 1004, 100, 'UPI';
 EXEC dbo.sp_record_payment
    'PM12', 1003, 0, 'UPI';
EXEC dbo.sp_record_payment
    'PM13', 1003, 600, 'UPI';
    EXEC dbo.sp_record_payment
    'PM14', 1003, 499, 'UPI';
SELECT
    payment_id,
    order_id,
    amount,
    method
FROM payments
ORDER BY payment_id;
SELECT *
FROM error_log
ORDER BY log_id;


------question 6---------
CREATE TABLE emp_salary
(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary INT
);
INSERT INTO emp_salary
(emp_id, emp_name, department, salary)
VALUES
(1, 'Aditi', 'Engineering', 100000),
(2, 'Bharat', 'Engineering', 100000),
(3, 'Chetan', 'Engineering', 90000),
(4, 'Divya', 'Engineering', 80000),
(5, 'Eshan', 'Engineering', 80000),
(6, 'Farhan', 'Engineering', 70000),
(7, 'Gauri', 'Sales', 75000),
(8, 'Harsh', 'Sales', 72000),
(9, 'Ira', 'Sales', 72000),
(10, 'Jatin', 'Support', 50000),
(11, 'Kavya', 'HR', 60000),
(12, 'Lokesh', 'HR', 60000);
SELECT * FROM emp_salary;
SELECT
    emp_id,
    emp_name,
    department,
    salary,

    ROW_NUMBER() OVER
    (
        PARTITION BY department
        ORDER BY salary DESC, emp_id ASC
    ) AS row_num,

    RANK() OVER
    (
        PARTITION BY department
        ORDER BY salary DESC
    ) AS rnk,

    DENSE_RANK() OVER
    (
        PARTITION BY department
        ORDER BY salary DESC
    ) AS dense_rnk

FROM emp_salary

ORDER BY
    department,
    salary DESC,
    emp_id ASC;
    WITH SalaryRanking AS
(
    SELECT
        department,
        emp_name,
        salary,

        DENSE_RANK() OVER
        (
            PARTITION BY department
            ORDER BY salary DESC
        ) AS salary_level
    FROM emp_salary
)
SELECT
    department,
    emp_name,
    salary,
    salary_level
FROM SalaryRanking
WHERE salary_level <= 3
ORDER BY
    department,
    salary DESC,
    emp_name;
WITH SalaryRanking AS
(
    SELECT
        department,
        emp_name,
        salary,
        DENSE_RANK() OVER
        (
            PARTITION BY department
            ORDER BY salary DESC
        ) AS salary_level
    FROM emp_salary
)
SELECT
    department,
    emp_name,
    salary,
    salary_level
FROM SalaryRanking
WHERE salary_level <= 3
ORDER BY
    department,
    salary DESC,
    emp_name;
    IF OBJECT_ID('dbo.top3_salary_levels', 'U') IS NOT NULL
    DROP TABLE dbo.top3_salary_levels;
GO
WITH SalaryRanking AS
(
    SELECT
        department,
        emp_name,
        salary,
        DENSE_RANK() OVER
        (
            PARTITION BY department
            ORDER BY salary DESC
        ) AS salary_level
    FROM emp_salary
)
SELECT
    department,
    emp_name,
    salary,
    salary_level
INTO top3_salary_levels
FROM SalaryRanking
WHERE salary_level <= 3;
GO
SELECT *
FROM top3_salary_levels
ORDER BY department, salary DESC, emp_name;


---------question 7---------
CREATE TABLE Books
(
    BookID INT PRIMARY KEY,
    Title VARCHAR(100)
);
INSERT INTO Books (BookID, Title)
VALUES
(1, 'Desert Winds'),
(2, 'River Songs'),
(3, 'The Glass Fort'),
(4, 'Night Train'),
(5, 'Salt and Stone'),
(6, 'Paper Moons');
CREATE TABLE Authors
(
    AuthorID INT PRIMARY KEY,
    AuthorName VARCHAR(100)
);
INSERT INTO Authors (AuthorID, AuthorName)
VALUES
(1, 'Meera Kaul'),
(2, 'Rohan Sen'),
(3, 'Tanvi Bose'),
(4, 'Ishita Roy');
CREATE TABLE BookAuthors
(
    BookID INT,
    AuthorID INT,
    PRIMARY KEY (BookID, AuthorID),
    FOREIGN KEY (BookID)
        REFERENCES Books(BookID),
    FOREIGN KEY (AuthorID)
        REFERENCES Authors(AuthorID)
);
INSERT INTO BookAuthors (BookID, AuthorID)
VALUES
(1, 1),
(2, 2),
(3, 1),
(3, 3),
(4, 4),
(5, 2),
(6, 2),
(6, 1);
SELECT
    a.AuthorID,
    a.AuthorName,
    COUNT(ba.BookID) AS Book_count
FROM Authors a
INNER JOIN BookAuthors ba
    ON a.AuthorID = ba.AuthorID
GROUP BY
    a.AuthorID,
    a.AuthorName;
    SELECT STRING_AGG(AuthorName, ',') AS Authors
FROM Authors;
GO

CREATE VIEW dbo.vw_book_author
AS
WITH AuthorBookCounts AS
(
    SELECT
        AuthorID,
        COUNT(*) AS Book_count
    FROM BookAuthors
    GROUP BY AuthorID
)

SELECT
    b.Title AS Booktitle,
    STRING_AGG(a.AuthorName, ',')
        WITHIN GROUP (ORDER BY a.AuthorName) AS Authorname,
    STRING_AGG(
        CAST(abc.Book_count AS VARCHAR(10)),
        ','
    )
        WITHIN GROUP (ORDER BY a.AuthorName) AS Book_count
FROM Books b
INNER JOIN BookAuthors ba
    ON b.BookID = ba.BookID
INNER JOIN Authors a
    ON ba.AuthorID = a.AuthorID
INNER JOIN AuthorBookCounts abc
    ON a.AuthorID = abc.AuthorID
GROUP BY
    b.BookID,
    b.Title;
GO
SELECT *
FROM dbo.vw_book_author;


---------question 8------
CREATE TABLE Employee
(
    Empid INT PRIMARY KEY,
    Full_name VARCHAR(100),
    Salary DECIMAL(10,2),
    Hiredate DATE,
    deptid INT
);
INSERT INTO Employee
(Empid, Full_name, Salary, Hiredate, deptid)
VALUES
(1012, 'Raji K Nair', 35500, '2018-04-09', 1),
(1009, 'Jeena', 12000, '2018-11-17', 2),
(1005, 'Nidhi R Shetty', 10000, '2019-01-16', 3),
(1011, 'Jiya Shetty', 45500, '2019-03-27', 4),
(1003, 'Arun Kumar Menon', 45500, '2019-08-02', 5),
(1007, 'Farah Ali', 30000, '2020-02-10', NULL),
(1001, 'Manoj P Iyer', 52000, '2020-07-15', 2);
CREATE TABLE Dept_loc
(
    deptid INT PRIMARY KEY,
    deptname VARCHAR(100),
    loc VARCHAR(50)
);
INSERT INTO Dept_loc
(deptid, deptname, loc)
VALUES
(1, 'HR', 'Dallas'),
(2, 'Sales', 'Chicago'),
(3, 'Customer service', 'Chicago'),
(4, 'IT', 'Boston'),
(5, 'Research', 'Seattle'),
(6, 'Legal', 'New York');
SELECT
    Empid,
    Full_name,
    Salary,
    LAG(Salary) OVER
    (
        ORDER BY Hiredate
    ) AS Previous_emp_sal
FROM Employee;
SELECT
    e.Empid,
    e.Full_name,
    e.Salary,
    d.loc,
    CASE
        WHEN d.loc = 'Chicago' THEN e.Salary * 1.05
        WHEN d.loc = 'Boston' THEN e.Salary * 1.03
        WHEN d.loc IN ('Dallas', 'New York')
            THEN e.Salary * 1.10
        ELSE e.Salary
    END AS Inc_Sal
FROM Employee e
LEFT JOIN Dept_loc d
    ON e.deptid = d.deptid;
    GO
CREATE VIEW dbo.VW_EMP_DEPT
AS
WITH EmployeeData AS
(
    SELECT
        e.Empid,
        CASE
            WHEN CHARINDEX(' ', LTRIM(RTRIM(e.Full_name))) = 0
                THEN LTRIM(RTRIM(e.Full_name))
            ELSE
                LEFT(
                    LTRIM(RTRIM(e.Full_name)),
                    CHARINDEX(' ', LTRIM(RTRIM(e.Full_name))) - 1
                )
                + ' ' +
                RIGHT(
                    LTRIM(RTRIM(e.Full_name)),
                    CHARINDEX(' ', REVERSE(LTRIM(RTRIM(e.Full_name))) + ' ') - 1
                )
        END AS Full_name,
        e.Salary,
        CASE
            WHEN d.loc = 'Chicago' THEN e.Salary * 1.05
            WHEN d.loc = 'Boston' THEN e.Salary * 1.03
            WHEN d.loc IN ('Dallas', 'New York')
                THEN e.Salary * 1.10
            ELSE e.Salary
        END AS Inc_Sal,
        LAG(e.Salary) OVER
        (
            ORDER BY e.Hiredate, e.Empid
        ) AS Previous_emp_sal,
        e.Hiredate,
        ISNULL(d.deptname, 'NA') AS deptname,
        ISNULL(d.loc, 'NA') AS loc
    FROM Employee e
    LEFT JOIN Dept_loc d
        ON e.deptid = d.deptid
)
SELECT
    Empid,
    Full_name,
    Salary,
    Inc_Sal,
    Previous_emp_sal,
    Hiredate,
    deptname,
    loc,
    CASE
        WHEN Previous_emp_sal IS NULL
            THEN 'No previous employee'
        WHEN Salary > Previous_emp_sal
            THEN 'Salary is greater than previously hired employee'
        WHEN Salary < Previous_emp_sal
            THEN 'Salary is less than previously hired employee'
        ELSE 'Salary is same as previously hired employee'
    END AS message
FROM EmployeeData;
GO
SELECT *
FROM dbo.VW_EMP_DEPT
ORDER BY Hiredate;


---------question 9------
CREATE TABLE monthly_sales
(
    month_start DATE,
    region VARCHAR(20),
    revenue DECIMAL(12,2),
    PRIMARY KEY (month_start, region)
);
INSERT INTO monthly_sales (month_start, region, revenue)
VALUES
('2026-01-01', 'North', 120000),
('2026-02-01', 'North', 135000),
('2026-03-01', 'North', 128000),
('2026-04-01', 'North', 150000),
('2026-05-01', 'North', 160000),
('2026-06-01', 'North', 145000),
('2026-01-01', 'South', 90000),
('2026-02-01', 'South', 85000),
('2026-03-01', 'South', 110000),
('2026-04-01', 'South', 105000),
('2026-05-01', 'South', 130000),
('2026-06-01', 'South', 140000);
SELECT
    region,
    month_start,
    revenue,
    SUM(revenue) OVER
    (
        PARTITION BY region
        ORDER BY month_start
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    CAST(
        AVG(revenue) OVER
        (
            PARTITION BY region
            ORDER BY month_start
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        )
        AS DECIMAL(12,2)
    ) AS moving_avg_3m,
    CAST(
        revenue * 100.0 /
        SUM(revenue) OVER (PARTITION BY region)
        AS DECIMAL(10,2)
    ) AS pct_of_total
FROM monthly_sales
ORDER BY region, month_start;


---------question 10-------
CREATE TABLE customer_updates
(
    load_id INT PRIMARY KEY,
    customer_id VARCHAR(10),
    email VARCHAR(100),
    city VARCHAR(50),
    updated_at DATETIME
);
INSERT INTO customer_updates
(load_id, customer_id, email, city, updated_at)
VALUES
(1, 'C01', 'rahul@mail.com', 'Jaipur', '2026-05-01 10:00:00'),
(2, 'C02', 'priya@mail.com', 'Kochi', '2026-05-01 10:05:00'),
(3, 'C01', 'rahul.m@mail.com', 'Jaipur', '2026-05-03 09:00:00'),
(4, 'C03', 'arjun@mail.com', 'Kolkata', '2026-05-02 12:00:00'),
(5, 'C02', 'priya@mail.com', 'Kochi', '2026-05-01 10:05:00'),
(6, 'C01', 'rahul.m@mail.com', 'Delhi', '2026-05-03 09:00:00'),
(7, 'C04', 'fatima@mail.com', 'Mumbai', '2026-05-04 08:30:00'),
(8, 'C03', 'arjun.d@mail.com', 'Kolkata', '2026-05-05 18:45:00');
WITH RankedCustomers AS
(
    SELECT
        load_id,
        customer_id,
        email,
        city,
        updated_at,
        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY updated_at DESC, load_id DESC
        ) AS rn
    FROM customer_updates
)
SELECT
    customer_id,
    email,
    city,
    updated_at,
    load_id
FROM RankedCustomers
WHERE rn = 1
ORDER BY customer_id;
IF OBJECT_ID('dbo.customer_latest', 'U') IS NOT NULL
    DROP TABLE dbo.customer_latest;
GO
WITH RankedCustomers AS
(
    SELECT
        load_id,
        customer_id,
        email,
        city,
        updated_at,
        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY updated_at DESC, load_id DESC
        ) AS rn
    FROM customer_updates
)
SELECT
    customer_id,
    email,
    city,
    updated_at,
    load_id
INTO customer_latest
FROM RankedCustomers
WHERE rn = 1;
GO
SELECT
    (SELECT COUNT(*)
     FROM customer_updates) AS rows_loaded,
    (SELECT COUNT(*)
     FROM customer_latest) AS rows_kept,
    (SELECT COUNT(*)
     FROM customer_updates)
    -
    (SELECT COUNT(*)
     FROM customer_latest) AS rows_removed;


 --------question 11------
CREATE TABLE logins
(
    user_id VARCHAR(10),
    login_date DATE,
    PRIMARY KEY (user_id, login_date)
);
INSERT INTO logins (user_id, login_date)
VALUES
('U1', '2026-03-01'),
('U1', '2026-03-02'),
('U1', '2026-03-03'),
('U1', '2026-03-05'),
('U1', '2026-03-06'),
('U1', '2026-03-07'),
('U2', '2026-03-01'),
('U2', '2026-03-03'),
('U2', '2026-03-04'),
('U2', '2026-03-05'),
('U2', '2026-03-06'),
('U2', '2026-03-10'),
('U3', '2026-03-02'),
('U4', '2026-03-01'),
('U4', '2026-03-02'),
('U4', '2026-03-04'),
('U4', '2026-03-05'),
('U4', '2026-03-08'),
('U4', '2026-03-09');
WITH LoginGroups AS
(
    SELECT
        user_id,
        login_date,
        DATEADD
        (
            DAY,
            -ROW_NUMBER() OVER
            (
                PARTITION BY user_id
                ORDER BY login_date
            ),
            login_date
        ) AS grp
    FROM logins
),
Streaks AS
(
    SELECT
        user_id,
        MIN(login_date) AS streak_start,
        MAX(login_date) AS streak_end,
        COUNT(*) AS streak_days
    FROM LoginGroups
    GROUP BY user_id, grp
),
RankedStreaks AS
(
    SELECT
        user_id,
        streak_start,
        streak_end,
        streak_days,
        ROW_NUMBER() OVER
        (
            PARTITION BY user_id
            ORDER BY streak_days DESC, streak_end DESC
        ) AS rn

    FROM Streaks
)
SELECT
    user_id,
    streak_start,
    streak_end,
    streak_days
FROM RankedStreaks
WHERE rn = 1
ORDER BY user_id;
;WITH LoginGroups AS
(
    SELECT
        user_id,
        login_date,
        DATEADD(
            DAY,
            -ROW_NUMBER() OVER (
                PARTITION BY user_id
                ORDER BY login_date
            ),
            login_date
        ) AS grp
    FROM logins
),
Streaks AS
(
    SELECT
        user_id,
        MIN(login_date) AS streak_start,
        MAX(login_date) AS streak_end,
        COUNT(*) AS streak_days
    FROM LoginGroups
    GROUP BY user_id, grp
),
RankedStreaks AS
(
    SELECT
        user_id,
        streak_start,
        streak_end,
        streak_days,
        ROW_NUMBER() OVER
       (
            PARTITION BY user_id
            ORDER BY streak_days DESC, streak_end DESC
        ) AS rn
    FROM Streaks
)
SELECT
    user_id,
    streak_start,
    streak_end,
    streak_days
FROM RankedStreaks
WHERE rn = 1
ORDER BY user_id;
IF OBJECT_ID('dbo.longest_streak', 'U') IS NOT NULL
    DROP TABLE dbo.longest_streak;
GO
WITH LoginGroups AS
(
    SELECT
        user_id,
        login_date,
        DATEADD
        (
            DAY,
            -ROW_NUMBER() OVER
            (
                PARTITION BY user_id
                ORDER BY login_date
            ),
            login_date
        ) AS grp
    FROM logins
),
Streaks AS
(
    SELECT
        user_id,
        MIN(login_date) AS streak_start,
        MAX(login_date) AS streak_end,
        COUNT(*) AS streak_days
    FROM LoginGroups
    GROUP BY user_id, grp
),
RankedStreaks AS
(
    SELECT
        user_id,
        streak_start,
        streak_end,
        streak_days,
        ROW_NUMBER() OVER
        (
            PARTITION BY user_id
            ORDER BY streak_days DESC, streak_end DESC
        ) AS rn
    FROM Streaks
)
SELECT
    user_id,
    streak_start,
    streak_end,
    streak_days
INTO longest_streak
FROM RankedStreaks
WHERE rn = 1;
GO
SELECT *
FROM longest_streak
ORDER BY user_id;