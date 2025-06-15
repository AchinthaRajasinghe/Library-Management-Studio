create database Library;
use Library;

--Creating Tables

create table Book(
	BookId int PRIMARY KEY not null identity(1,1),
	Title varchar(100) not null,
	Author varchar(100) not null,
	ISBN varchar(20) UNIQUE not null,
	Category varchar(50),
	Publisher varchar(100),
);

create table Member(
	MemberId int IDENTITY(1,1) PRIMARY KEY not null,
	Name varchar(100) not null,
	Email varchar(50) not null,
	ContactNo varchar(10),
	Register_Date date DEFAULT GETDATE(),
);

create table Loan (
    LoanID int PRIMARY KEY identity(1,1),
    BookID int not null,
    MemberID int not null,
    LoanDate date DEFAULT GETDATE(),
    DueDate date not null,
    ReturnDate date,
    CONSTRAINT FK_Loan_Book FOREIGN KEY (BookId) REFERENCES Book(BookId),
    CONSTRAINT FK_Loan_Member FOREIGN KEY (MemberId) REFERENCES Member(MemberId)
);

create table Fine (
    FineID int PRIMARY KEY identity(1,1),
    LoanID int not null,
    Amount decimal(6,2) CHECK (Amount >= 0),
    Status varchar(20) CHECK (Status in ('Paid', 'Unpaid')) not null,
    CONSTRAINT FK_Fine_Loan FOREIGN KEY (LoanID) REFERENCES Loan(LoanID)
);

--View data--
select * from Book;
select * from Member;
select * from Fine;
select * from Loan;

--Insert 10 Examples into Each table

INSERT INTO Book (Title, Author, ISBN, Category, Publisher)
VALUES 
('Percy Jackson & The Olympians: The Lightning Thief', 'Rick Riordan', '978-0786856291 ', 'Fantasy', 'Hyperion Books for Children'),
('Eragon', 'Christopher Paolini', '978-0375826696', 'Fantasy', 'Alfred A. Knopf'), 
('A Court of Thorns and Roses', 'Sarah J. Maas', '978-1623178021', 'Fantasy', 'Bloomsbury Publishing'),
('The Magicians', 'Lev Grossman', 'Lev Grossman', 'Fantasy', 'Viking Press'),
('Mistborn: The Final Empire', 'Brandon Sanderson', '978-0765311711', 'Fantasy', 'Tor Books'),
('The Housemaid	', 'Freida McFadden', '978-1538742570', 'Mystery Thriller', 'Hachette Book Group'),
('Funny Story', 'Emily Henry', '978-0-7777', 'Romance', 'CodePub'),
('Database Design', 'Anna Bell', '978-0-8888', 'Computer Science', 'TechPub'),
('Ethical Hacking', 'Nina Patel', '978-0-9999', 'Cybersecurity', 'HackBooks'),
('Software Testing', 'Paul Allen', '978-0-0000', 'Software', 'QualityPress');

INSERT INTO Member (Name, Email, ContactNo)
VALUES
('Achintha Rajasinghe', 'achintha@gmail.com', '0771234567'),
('Ayesha Karunathilake', 'ayesha@gmail.com', '0762345678'),
('Heshan Wimalarathne', 'heshan@gmail.com', '0713456789'),
('Akila Premachandra', 'akila@gmail.com', '0784567890'),
('Janaka Herath', 'janaka@gmail.com', '0775678901'),
('Tharushi Karunarathne', 'tharu@gmail.com', '0716789012'),
('Sithumini Ranasinghe', 'sithumini@gmail.com', '0777890123'),
('Vidumini Jayasekara', 'vidumini@gmail.com', '0758901234'),
('Dewni Maheksha', 'Dewni@gmail.com', '0779012345'),
('Kasun Jayasuriya', 'kasun@gmail.com', '0710123456');

INSERT INTO Loan (BookID, MemberID, DueDate)
VALUES 
(5, 6, DATEADD(DAY, 14, GETDATE())),
(6, 7, DATEADD(DAY, 14, GETDATE())),
(7, 8, DATEADD(DAY, 14, GETDATE())),
(8, 9, DATEADD(DAY, 14, GETDATE())),
(9, 10, DATEADD(DAY, 14, GETDATE())),
(10, 11, DATEADD(DAY, 14, GETDATE())),
(11, 12, DATEADD(DAY, 14, GETDATE())),
(12, 13, DATEADD(DAY, 14, GETDATE())),
(21, 14, DATEADD(DAY, 14, GETDATE())),
(22, 15, DATEADD(DAY, 14, GETDATE()));

INSERT INTO Fine (LoanID, Amount, Status)
VALUES 
(9, 100.00, 'Unpaid'),
(10, 0.00, 'Paid'),
(11, 50.00, 'Unpaid'),
(12, 20.00, 'Paid'),
(13, 0.00, 'Paid'),
(14, 10.00, 'Unpaid'),
(15, 30.00, 'Unpaid'),
(16, 0.00, 'Paid'),
(17, 60.00, 'Unpaid'),
(18, 0.00, 'Paid');

--------------
---Triggers---
--------------

CREATE TRIGGER trg_SetReturnDate
ON Loan
AFTER UPDATE
AS
BEGIN
    UPDATE Loan
    SET ReturnDate = GETDATE()
    WHERE ReturnDate IS NULL AND LoanID IN (
        SELECT LoanID FROM inserted WHERE ReturnDate IS NULL
    );
END;

CREATE TRIGGER trg_CheckLateReturn
ON Loan
AFTER UPDATE
AS
BEGIN
    INSERT INTO Fine (LoanID, Amount, Status)
    SELECT LoanID, DATEDIFF(DAY, DueDate, ReturnDate) * 10, 'Unpaid'
    FROM inserted
    WHERE ReturnDate > DueDate;
END;

---------------
---Functions---
---------------

CREATE FUNCTION fn_CalculateFine (@LoanID INT)
RETURNS DECIMAL(6,2)
AS
BEGIN
    DECLARE @FineAmount DECIMAL(6,2) = 0;
    SELECT @FineAmount = 
        CASE 
            WHEN ReturnDate > DueDate THEN DATEDIFF(DAY, DueDate, ReturnDate) * 10
            ELSE 0
        END
    FROM Loan
    WHERE LoanID = @LoanID;

    RETURN @FineAmount;
END;

CREATE FUNCTION fn_ActiveLoansByMember (@MemberID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM Loan
    WHERE MemberID = @MemberID AND ReturnDate IS NULL;

    RETURN @Count;
END;

----------
---View---
----------

CREATE VIEW vw_OverdueLoans AS
SELECT l.LoanID, m.Name AS MemberName, b.Title AS BookTitle, l.DueDate
FROM Loan l
JOIN Member m ON l.MemberID = m.MemberID
JOIN Book b ON l.BookID = b.BookID
WHERE l.ReturnDate IS NULL AND l.DueDate < GETDATE();

CREATE VIEW vw_MemberLoanSummary AS
SELECT m.MemberID, m.Name, COUNT(l.LoanID) AS TotalLoans
FROM Member m
LEFT JOIN Loan l ON m.MemberID = l.MemberID
GROUP BY m.MemberID, m.Name;

---------------
---Procedure---
---------------

CREATE PROCEDURE sp_AddBook
    @Title VARCHAR(100),
    @Author VARCHAR(100),
    @ISBN VARCHAR(20),
    @Category VARCHAR(50),
    @Publisher VARCHAR(100)
AS
BEGIN
    INSERT INTO Book (Title, Author, ISBN, Category, Publisher)
    VALUES (@Title, @Author, @ISBN, @Category, @Publisher);
END;

CREATE PROCEDURE sp_ReturnBook
    @LoanID INT
AS
BEGIN
    UPDATE Loan
    SET ReturnDate = GETDATE()
    WHERE LoanID = @LoanID;
END;

---------------------
---CRUD Operations---
---------------------

----------------
---Book Table---
----------------

--Crete new Book Record
CREATE PROCEDURE sp_CreateBook
    @Title VARCHAR(100),
    @Author VARCHAR(100),
    @ISBN VARCHAR(20),
    @Category VARCHAR(50),
    @Publisher VARCHAR(100)
AS
BEGIN
    INSERT INTO Book (Title, Author, ISBN, Category, Publisher)
    VALUES (@Title, @Author, @ISBN, @Category, @Publisher);
END;

--Select a Book Record
CREATE PROCEDURE sp_GetBooks
AS
BEGIN
    SELECT * FROM Book;
END;

--Update a Book Record
CREATE PROCEDURE sp_UpdateBook
    @BookID INT,
    @Title VARCHAR(100),
    @Author VARCHAR(100),
    @ISBN VARCHAR(20),
    @Category VARCHAR(50),
    @Publisher VARCHAR(100)
AS
BEGIN
    UPDATE Book
    SET Title = @Title,
        Author = @Author,
        ISBN = @ISBN,
        Category = @Category,
        Publisher = @Publisher
    WHERE BookID = @BookID;
END;

--Delete a Book Record
CREATE PROCEDURE sp_DeleteBook
    @BookID INT
AS
BEGIN
    DELETE FROM Book WHERE BookID = @BookID;
END;

--Updating Delete Procedure
ALTER PROCEDURE dbo.sp_DeleteBook
    @BookID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Book WHERE BookID = @BookID)
    BEGIN
        DELETE FROM Book WHERE BookID = @BookID;
    END
    ELSE
    BEGIN
        RAISERROR('BookID not found.', 16, 1);
    END
END;

------------------
---Member Table---
------------------

--Crete new Member Record
CREATE PROCEDURE sp_CreateMember
    @Name VARCHAR(100),
    @Email VARCHAR(50),
    @ContactNo VARCHAR(10)
AS
BEGIN
    INSERT INTO Member (Name, Email, ContactNo)
    VALUES (@Name, @Email, @ContactNo);
END;

--Select a Member Record
CREATE PROCEDURE sp_GetMembers
AS
BEGIN
    SELECT * FROM Member;
END;

--Update a Member Record
CREATE PROCEDURE sp_UpdateMember
    @MemberID INT,
    @Name VARCHAR(100),
    @Email VARCHAR(100),
    @ContactNo VARCHAR(15)
AS
BEGIN
    UPDATE Member
    SET Name = @Name,
        Email = @Email,
        ContactNo = @ContactNo
    WHERE MemberID = @MemberID;
END;

--Delete a Member Record
CREATE PROCEDURE sp_DeleteMember
   @MemberID INT
AS
BEGIN
    DELETE FROM Member WHERE MemberID = @MemberID;
END;

ALTER PROCEDURE sp_DeleteMember
    @MemberID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Member WHERE MemberID = @MemberID)
    BEGIN
        DELETE FROM Member WHERE MemberID = @MemberID;
    END
    ELSE
    BEGIN
        RAISERROR('MemberID not found.', 16, 1);
    END
END;

----------------
---Loan Table---
----------------

-- Create a Loan Record
CREATE PROCEDURE sp_CreateLoan
    @BookID INT,
    @MemberID INT,
    @DueDate DATE
AS
BEGIN
    INSERT INTO Loan (BookID, MemberID, LoanDate, DueDate)
    VALUES (@BookID, @MemberID, GETDATE(), @DueDate);
END;

-- Read Loan Records
CREATE PROCEDURE sp_GetLoans
AS
BEGIN
    SELECT * FROM Loan;
END;

-- Update a Loan Record
CREATE PROCEDURE dbo.sp_UpdateLoan
    @LoanID INT,
    @ReturnDate DATE
AS
BEGIN
    UPDATE Loan
    SET ReturnDate = @ReturnDate
    WHERE LoanID = @LoanID;
END;

-- Updating Update_Procedure Loan Table
ALTER PROCEDURE sp_UpdateLoan
    @LoanID INT,
    @BookID INT,
    @MemberID INT,
    @LoanDate DATE,
    @ReturnDate DATE
AS
BEGIN
    UPDATE Loan
    SET BookID = @BookID,
        MemberID = @MemberID,
        LoanDate = @LoanDate,
        ReturnDate = @ReturnDate
    WHERE LoanID = @LoanID;
END;

-- Delete a Loan Record
CREATE PROCEDURE sp_DeleteLoan
    @LoanID INT
AS
BEGIN
    DELETE FROM Loan WHERE LoanID = @LoanID;
END;

ALTER PROCEDURE dbo.sp_DeleteLoan
    @LoanID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Loan WHERE LoanID = @LoanID)
    BEGIN
        DELETE FROM Loan WHERE LoanID = @LoanID;
    END
    ELSE
    BEGIN
        RAISERROR('LoanID not found.', 16, 1);
    END
END;
select * from Loan;

----------------
---Fine Table---
----------------

-- Create a Fine Record
CREATE PROCEDURE sp_CreateFine
    @LoanID INT,
    @Amount DECIMAL(6,2),
    @Status VARCHAR(20)
AS
BEGIN
    INSERT INTO Fine (LoanID, Amount, Status)
    VALUES (@LoanID, @Amount, @Status);
END;

-- Read Fine Records
CREATE PROCEDURE sp_GetFines
AS
BEGIN
    SELECT * FROM Fine;
END;


-- Update a Fine Record
CREATE PROCEDURE sp_UpdateFine
    @FineID INT,
    @Amount DECIMAL(6,2),
    @Status VARCHAR(20)
AS
BEGIN
    UPDATE Fine
    SET Amount = @Amount,
        Status = @Status
    WHERE FineID = @FineID;
END;

-- Delete a Fine Record
CREATE PROCEDURE sp_DeleteFine
    @FineID INT
AS
BEGIN
    DELETE FROM Fine WHERE FineID = @FineID;
END;

-- Updating Delete Fine Record
ALTER PROCEDURE dbo.sp_DeleteFine
    @FineID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Fine WHERE FineID = @FineID)
    BEGIN
        DELETE FROM Fine WHERE FineID = @FineID;
    END
    ELSE
    BEGIN
        RAISERROR('FineID not found.', 16, 1);
    END
END;


