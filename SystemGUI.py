import tkinter as tk
from tkinter import ttk, messagebox
import pyodbc 

#Connect to SQL Serer Database
conn = pyodbc.connect(
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=DELL;'
    'DATABASE=Library;'  
    'Trusted_Connection=yes;'
)
cursor = conn.cursor()

root = tk.Tk()
root.title("Library Management System - CRUD UI")

tabControl = ttk.Notebook(root)

# ****** BOOK Table *****
book_tab = ttk.Frame(tabControl)
tabControl.add(book_tab, text="Books")

labels = ["Book ID", "Title", "Author", "ISBN", "Category", "Publisher"]
book_entries = [tk.Entry(book_tab) for _ in labels]

for i, label in enumerate(labels):
    tk.Label(book_tab, text=label).grid(row=i, column=0)
    book_entries[i].grid(row=i, column=1)

def create_book():
    cursor.execute("EXEC dbo.sp_CreateBook ?, ?, ?, ?, ?",
                   (book_entries[1].get(), book_entries[2].get(),
                   book_entries[3].get(), book_entries[4].get(), book_entries[5].get()))
    conn.commit()
    messagebox.showinfo("Book", "Created")

def update_book():
    try:
        book_id = int(book_entries[0].get())
        title = book_entries[1].get()
        author = book_entries[2].get()
        isbn = book_entries[3].get()
        category = book_entries[4].get()
        publisher = book_entries[5].get()

        cursor.execute("EXEC dbo.sp_UpdateBook ?, ?, ?, ?, ?, ?",
                       book_id, title, author, isbn, category, publisher)
        conn.commit()
        messagebox.showinfo("Book", "Updated")
    except ValueError:
        messagebox.showerror("Error", "Please enter valid input values.")
    except Exception as e:
        messagebox.showerror("Error", str(e))

def delete_book():
    try:
        book_id = int(book_entries[0].get())
        print("Trying to delete BookID:", book_id) 
        cursor.execute("EXEC dbo.sp_DeleteBook ?", book_id)
        conn.commit()
        messagebox.showinfo("Success", f"Book with ID {book_id} deleted.")
    except Exception as e:
        messagebox.showerror("Error", f"Failed to delete book: {e}")

def view_books():
    book_output.delete("1.0", tk.END)
    for row in cursor.execute("EXEC sp_GetBooks"):
        book_output.insert(tk.END, f"{row[0]} | {row[1]} | {row[2]} | {row[3]}\n")

tk.Button(book_tab, text="Create", command=create_book).grid(row=6, column=0)
tk.Button(book_tab, text="Update", command=update_book).grid(row=6, column=1)
tk.Button(book_tab, text="Delete", command=delete_book).grid(row=7, column=0)
tk.Button(book_tab, text="View", command=view_books).grid(row=7, column=1)

book_output = tk.Text(book_tab, height=8, width=60)
book_output.grid(row=8, column=0, columnspan=2)

# ***** MEMBER TABLE *****
member_tab = ttk.Frame(tabControl)
tabControl.add(member_tab, text="Members")

labels = ["Member ID", "Name", "Email", "Contact No"]
member_entries = [tk.Entry(member_tab) for _ in labels]

for i, label in enumerate(labels):
    tk.Label(member_tab, text=label).grid(row=i, column=0)
    member_entries[i].grid(row=i, column=1)

def create_member():
    cursor.execute("EXEC dbo.sp_CreateMember ?, ?, ?",
                   member_entries[1].get(), member_entries[2].get(), member_entries[3].get())
    conn.commit()
    messagebox.showinfo("Member", "Created")

def update_member():
    try:
        member_id = int(member_entries[0].get())
        name = member_entries[1].get()
        email = member_entries[2].get()

        cursor.execute("EXEC dbo.sp_UpdateMember ?, ?, ?",
                       member_id, name, email)
        conn.commit()
        messagebox.showinfo("Member", "Updated")
    except ValueError:
        messagebox.showerror("Error", "Please enter valid input values.")
    except Exception as e:
        messagebox.showerror("Error", str(e))

def delete_member():
    try:
        member_id = int(member_entries[0].get())
        print("Trying to delete MemberID:", member_id) 
        cursor.execute("EXEC dbo.sp_DeleteMember ?", member_id)
        conn.commit()
        messagebox.showinfo("Success", f"Member with ID {member_id} deleted.")
    except Exception as e:
        messagebox.showerror("Error", f"Failed to delete member: {e}")

def view_members():
    member_output.delete("1.0", tk.END)
    for row in cursor.execute("EXEC sp_GetMembers"):
        member_output.insert(tk.END, f"{row[0]} | {row[1]} | {row[2]}\n")

tk.Button(member_tab, text="Create", command=create_member).grid(row=4, column=0)
tk.Button(member_tab, text="Update", command=update_member).grid(row=4, column=1)
tk.Button(member_tab, text="Delete", command=delete_member).grid(row=5, column=0)
tk.Button(member_tab, text="View", command=view_members).grid(row=5, column=1)

member_output = tk.Text(member_tab, height=8, width=60)
member_output.grid(row=6, column=0, columnspan=2)

# ***** LOAN TABLE *****
loan_tab = ttk.Frame(tabControl)
tabControl.add(loan_tab, text="Loans")

labels = ["Loan ID", "Book ID", "Member ID", "Due Date (YYYY-MM-DD)", "Return Date (YYYY-MM-DD)"]
loan_entries = [tk.Entry(loan_tab) for _ in labels]

for i, label in enumerate(labels):
    tk.Label(loan_tab, text=label).grid(row=i, column=0)
    loan_entries[i].grid(row=i, column=1)

def create_loan():
    cursor.execute("EXEC dbo.sp_CreateLoan ?, ?, ?",
                   loan_entries[1].get(), loan_entries[2].get(), loan_entries[3].get())
    conn.commit()
    messagebox.showinfo("Loan", "Created")

def update_loan():
    try:
        loan_id = int(loan_entries[0].get())
        book_id = int(loan_entries[1].get())
        member_id = int(loan_entries[2].get())
        loan_date = loan_entries[3].get()   
        return_date = loan_entries[4].get() 

        cursor.execute("EXEC dbo.sp_UpdateLoan ?, ?, ?, ?, ?",
                       loan_id, book_id, member_id, loan_date, return_date)
        conn.commit()
        messagebox.showinfo("Loan", "Updated")
    except ValueError:
        messagebox.showerror("Error", "Please enter valid input values.")
    except Exception as e:
        messagebox.showerror("Error", str(e))

def delete_loan():
    try:
        loan_id = int(loan_entries[0].get())
        print("Trying to delete LoanID:", loan_id) 
        cursor.execute("EXEC dbo.sp_DeleteLoan ?", loan_id)
        conn.commit()
        messagebox.showinfo("Success", f"Loan with ID {loan_id} deleted.")
    except Exception as e:
        messagebox.showerror("Error", f"Failed to delete loan: {e}")    

def view_loans():
    loan_output.delete("1.0", tk.END)
    for row in cursor.execute("EXEC dbo.sp_GetLoans"):
        loan_output.insert(tk.END, f"{row.LoanID} | Book: {row.BookID} | Member: {row.MemberID} | Due: {row.DueDate}\n")

tk.Button(loan_tab, text="Create", command=create_loan).grid(row=5, column=0)
tk.Button(loan_tab, text="Update", command=update_loan).grid(row=5, column=1)
tk.Button(loan_tab, text="Delete", command=delete_loan).grid(row=6, column=0)
tk.Button(loan_tab, text="View", command=view_loans).grid(row=6, column=1)

loan_output = tk.Text(loan_tab, height=8, width=60)
loan_output.grid(row=7, column=0, columnspan=2)

# ***** FINE TABLE *****
fine_tab = ttk.Frame(tabControl)
tabControl.add(fine_tab, text="Fines")

labels = ["Fine ID", "Loan ID", "Amount", "Status"]
fine_entries = [tk.Entry(fine_tab) for _ in labels]

for i, label in enumerate(labels):
    tk.Label(fine_tab, text=label).grid(row=i, column=0)
    fine_entries[i].grid(row=i, column=1)

def create_fine():
    cursor.execute("EXEC dbo.sp_CreateFine ?, ?, ?",
                   fine_entries[1].get(), fine_entries[2].get(), fine_entries[3].get())
    conn.commit()
    messagebox.showinfo("Fine", "Created")

def update_fine():
    try:
        fine_id = int(fine_entries[0].get())
        amount = float(fine_entries[2].get())
        status = fine_entries[3].get()

        cursor.execute("EXEC dbo.sp_UpdateFine ?, ?, ?",
                       fine_id, amount, status)
        conn.commit()
        messagebox.showinfo("Fine", "Updated")
    except ValueError:
        messagebox.showerror("Error", "Please enter valid numbers for FineID and Amount.")
    except Exception as e:
        messagebox.showerror("Error", str(e))

def delete_fine():
    try:
        fine_id = int(fine_entries[0].get())
        print("Trying to delete FineID:", fine_id)  
        cursor.execute("EXEC dbo.sp_DeleteFine ?", fine_id)
        conn.commit()
        messagebox.showinfo("Success", f"Fine with ID {fine_id} deleted.")
    except Exception as e:
        messagebox.showerror("Error", f"Failed to delete fine: {e}")   


def view_fines():
    fine_output.delete("1.0", tk.END)
    for row in cursor.execute("EXEC sp_GetFines"):
        fine_output.insert(tk.END, f"{row.FineID} | Loan: {row.LoanID} | Amount: {row.Amount} | {row.Status}\n")

tk.Button(fine_tab, text="Create", command=create_fine).grid(row=4, column=0)
tk.Button(fine_tab, text="Update", command=update_fine).grid(row=4, column=1)
tk.Button(fine_tab, text="Delete", command=delete_fine).grid(row=5, column=0)
tk.Button(fine_tab, text="View", command=view_fines).grid(row=5, column=1)

fine_output = tk.Text(fine_tab, height=8, width=60)
fine_output.grid(row=6, column=0, columnspan=2)

# ***** GUI Setup *****
tabControl.pack(expand=1, fill="both")
root.mainloop()
