---- create a new table of Employee Demographics
--create table EmployeeDemographics
--(
--EmployeeID int,
--FirstName varchar(50),
--LastName varchar(50),
--Age int,
--Gender varchar(50)
--)

---- create a new table of Employee Salaries
--create table EmployeeSalaries
--(
--EmployeeID int,
--JobTitle varchar(50),
--Salary int
--)

---- insert data into table EmployeeDemographics
--insert into EmployeeDemographics values
--(1001, 'Alex', 'Analyst', 30, 'Male'),
--(1002, 'Amanda', 'Genius', 25, 'Female'),
--(1003, 'Bailey', 'Hotdog', 10, 'Male'),
--(1004, 'Rola', 'Sausage', 18, 'Female'),
--(1005, 'Latte', 'Wenier', 15, 'Female')

---- due to the repeat execution, i need to clear the table first and re-insert values
--truncate table EmployeeDemographics

-- insert data into table EmployeeSalaries
insert into EmployeeSalaries values
(1001, 'Manager', 100000),
(1002, 'CEO', 1000000),
(1003, 'Supervisor', 50000),
(1004, 'Sales', 60000),
(1005, 'Coordinator', 70000)