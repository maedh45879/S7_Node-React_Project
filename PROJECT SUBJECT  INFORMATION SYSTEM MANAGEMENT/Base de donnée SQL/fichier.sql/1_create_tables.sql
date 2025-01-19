
DROP TABLE loans;
DROP TABLE Financial_Obligations;
DROP TABLE deliquency;
DROP TABLE credit_history;
DROP TABLE customers;
DROP TABLE Banker;

CREATE TABLE Banker (
Banker_id VARCHAR2(11) PRIMARY KEY,
Name VARCHAR2(50) NOT NULL,
Surname VARCHAR(50) NOT NULL,
Phone VARCHAR2(11) UNIQUE,
Mail VARCHAR2(50) UNIQUE,
Years_of_Experiences VARCHAR2(11) CHECK (Years_of_Experiences >= '0')
);

CREATE TABLE customers (
customer_id VARCHAR2(100) PRIMARY KEY,
Banker_id VARCHAR2(11) NOT NULL,
Years_in_current_job VARCHAR2(20),
Home_ownership VARCHAR2(20) CHECK (Home_ownership IN ('Home Mortgage', 'Own Home' ,'Rent' ,'HaveMortgage')),
Annual_Income VARCHAR2(20),
Credit_Score VARCHAR2(20),
CONSTRAINT fk_customers_banker FOREIGN KEY (Banker_id)
REFERENCES Banker (Banker_id) ON DELETE SET NULL
);

CREATE TABLE loans (
loan_id VARCHAR2(100) PRIMARY KEY,
customer_id VARCHAR2(100) NOT NULL,
current_loan_amount VARCHAR2(20) NOT NULL,
Term VARCHAR2(50) NOT NULL,
purpose VARCHAR2(50) NOT NULL,
CONSTRAINT fk_loans_customer FOREIGN KEY (customer_id)
REFERENCES customers (customer_id) ON DELETE CASCADE
);

CREATE TABLE credit_history (
customer_id VARCHAR2(100) PRIMARY KEY,
Years_of_Credit_History VARCHAR2(11) CHECK (Years_of_Credit_History >= '0'),
Number_of_Open_Accounts VARCHAR2(11) CHECK (Number_of_Open_Accounts >= '0'),
Number_of_Credit_Problems VARCHAR2(11) CHECK (Number_of_Credit_Problems >= '0'),
Current_Credit_Balance VARCHAR2(20) NOT NULL,
Maximum_Open_Credit VARCHAR2(11),
CONSTRAINT fk_credit_history_customer FOREIGN KEY (customer_id)
REFERENCES customers (customer_id) ON DELETE CASCADE
);


CREATE TABLE deliquency (
customer_id VARCHAR2(100) PRIMARY KEY,
Months_Since_Last_Delinquent VARCHAR2(11),
Bankruptcies VARCHAR2(11) CHECK (Bankruptcies >= '0'),
Tax_Liens VARCHAR2(11) CHECK (Tax_Liens >= '0'),
CONSTRAINT fk_deliquency_customer FOREIGN KEY (customer_id)
REFERENCES customers (customer_id) ON DELETE CASCADE
);

CREATE TABLE Financial_Obligations (
customer_id VARCHAR2(100) PRIMARY KEY,
Monthly_Debt VARCHAR2(100) NOT NULL,
CONSTRAINT fk_financial_obligations_customer FOREIGN KEY (customer_id)
REFERENCES customers (customer_id) ON DELETE CASCADE
);