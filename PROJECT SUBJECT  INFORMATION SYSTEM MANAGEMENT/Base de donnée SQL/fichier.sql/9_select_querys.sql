-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1st : This query retrieves the customer ID, annual income, credit score,
-- and the name and surname of their banker, along with the rank of the credit score
-- and the total number of loans for each customer.
SELECT C.customer_id, C.Annual_Income, C.Credit_Score, 
       B.Name AS Banker_Name, B.Surname AS Banker_Surname,
       RANK() OVER (ORDER BY C.Credit_Score DESC) AS Credit_Score_Rank,
       (SELECT COUNT(*) FROM loans L WHERE L.customer_id = C.customer_id) AS Total_Loans
FROM customers C
JOIN Banker B ON C.Banker_id = B.Banker_id;

-- Improvement
SELECT C.customer_id, 
       C.Annual_Income, 
       C.Credit_Score, 
       B.Name AS Banker_Name, 
       B.Surname AS Banker_Surname,
       RANK() OVER (ORDER BY C.Credit_Score DESC) AS Credit_Score_Rank,
       COUNT(L.loan_id) AS Total_Loans  -- Replaced the subquery with a join
FROM customers C
JOIN Banker B ON C.Banker_id = B.Banker_id
LEFT JOIN loans L ON C.customer_id = L.customer_id  -- Join to count loans
GROUP BY C.customer_id, C.Annual_Income, C.Credit_Score, B.Name, B.Surname; -- Added fields to GROUP BY

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2nd : This query counts the number of loans by purpose, calculates the percentage
-- of total loans, computes the average loan amount for each purpose,
-- and counts the total number of unique customers for each loan purpose.
SELECT L.purpose, 
       COUNT(*) AS Number_of_Loans,
       COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS Percentage_of_Total_Loans,
       AVG(L.current_loan_amount) AS Average_Loan_Amount,
       COUNT(DISTINCT C.customer_id) AS Total_Customers
FROM loans L
JOIN customers C ON L.customer_id = C.customer_id
GROUP BY L.purpose;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3rd : This query retrieves the customer ID and annual income,
-- along with the count of credit problems for each customer and the total number
-- of loans for each customer.
SELECT C.customer_id, C.Annual_Income,
       COUNT(CH.Number_of_Credit_Problems) OVER (PARTITION BY C.customer_id) AS Credit_Problem_Count,
       (SELECT COUNT(*) FROM loans L WHERE L.customer_id = C.customer_id) AS Total_Loans
FROM customers C
JOIN credit_history CH ON C.customer_id = CH.customer_id
WHERE CH.Number_of_Credit_Problems > 0;

-- Improvement
SELECT C.customer_id, 
       C.Annual_Income,
       COUNT(CH.Number_of_Credit_Problems) AS Credit_Problem_Count,
       COUNT(L.loan_id) AS Total_Loans  -- Replaced the subquery with a join
FROM customers C
LEFT JOIN credit_history CH ON C.customer_id = CH.customer_id
LEFT JOIN loans L ON C.customer_id = L.customer_id  -- Join to count loans
WHERE CH.Number_of_Credit_Problems > 0
GROUP BY C.customer_id, C.Annual_Income; -- Added fields to GROUP BY

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4th : This query retrieves the details of customers with loans and credit history,
-- including the total amount of loans, the number of loans, and the number of credit problems.
SELECT 
    C.customer_id,
    C.Annual_Income,
    SUM(L.current_loan_amount) AS Total_Loan_Amount,
    COUNT(L.loan_id) AS Total_Loans,
    COUNT(CH.Number_of_Credit_Problems) AS Credit_Problem_Count,
    RANK() OVER (ORDER BY SUM(L.current_loan_amount) DESC) AS Loan_Rank
FROM 
    Customers C
JOIN 
    loans L ON C.customer_id = L.customer_id
LEFT JOIN 
    credit_history CH ON C.customer_id = CH.customer_id
GROUP BY 
    C.customer_id, C.Annual_Income;
    
-- Improvement
SELECT 
    C.customer_id,
    C.Annual_Income,
    SUM(L.current_loan_amount) AS Total_Loan_Amount,
    COUNT(L.loan_id) AS Total_Loans,
    COUNT(CH.Number_of_Credit_Problems) AS Credit_Problem_Count,
    RANK() OVER (ORDER BY SUM(L.current_loan_amount) DESC) AS Loan_Rank
FROM 
    Customers C
LEFT JOIN -- Left Join and not Join
    loans L ON C.customer_id = L.customer_id
LEFT JOIN 
    credit_history CH ON C.customer_id = CH.customer_id
GROUP BY 
    C.customer_id, C.Annual_Income;

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5th : This query retrieves cstomers with loans and ranking them by total loan amount.
SELECT C.customer_id,
       SUM(L.current_loan_amount) AS Total_Loan_Amount,
       AVG(L.current_loan_amount) AS Average_Loan_Amount,
       RANK() OVER (ORDER BY SUM(L.current_loan_amount) DESC) AS Loan_Rank
FROM Customers C
JOIN loans L ON C.customer_id = L.customer_id
GROUP BY C.customer_id;

-- Improvement
WITH LoanSummary AS (
    SELECT customer_id,
           SUM(current_loan_amount) AS Total_Loan_Amount,
           AVG(current_loan_amount) AS Average_Loan_Amount
    FROM loans
    GROUP BY customer_id
)
SELECT C.customer_id,
       LS.Total_Loan_Amount,
       LS.Average_Loan_Amount,
       RANK() OVER (ORDER BY LS.Total_Loan_Amount DESC) AS Loan_Rank
FROM Customers C
JOIN LoanSummary LS ON C.customer_id = LS.customer_id;  -- Joining with the summarized loans

-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6th : This query retrieves the banker ID, name, surname, and counts the customers
-- with credit issues for each banker, ranking them.
SELECT B.Banker_id, B.Name, B.Surname, 
       COUNT(C.Customer_id) AS Customers_With_Credit_Issues,
       RANK() OVER (ORDER BY COUNT(C.Customer_id) DESC) AS Banker_Rank
FROM Banker B
JOIN Customers C ON B.Banker_id = C.Banker_id
WHERE EXISTS (
    SELECT 1 
    FROM Credit_History CH 
    WHERE CH.Customer_id = C.Customer_id AND CH.Number_of_Credit_Problems > 0
)
GROUP BY B.Banker_id, B.Name, B.Surname;

-- Improvement
WITH CreditIssueSummary AS (
    SELECT C.Banker_id,
           COUNT(C.Customer_id) AS Customers_With_Credit_Issues
    FROM Customers C
    JOIN Credit_History CH ON C.Customer_id = CH.Customer_id
    WHERE CH.Number_of_Credit_Problems > 0
    GROUP BY C.Banker_id
)
SELECT B.Banker_id, 
       B.Name, 
       B.Surname, 
       COALESCE(CIS.Customers_With_Credit_Issues, 0) AS Customers_With_Credit_Issues,
       RANK() OVER (ORDER BY COALESCE(CIS.Customers_With_Credit_Issues, 0) DESC) AS Banker_Rank
FROM Banker B
INNER JOIN CreditIssueSummary CIS ON B.Banker_id = CIS.Banker_id;  -- Changed to INNER JOIN