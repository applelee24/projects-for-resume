-- 1.Titles given to the employees

SELECT employees.emp_no, employees.first_name, employees.last_name, titles.title, titles.to_date
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.to_date='9999-01-01'

-- 2.When the employee 10010 was hired?

SELECT employees.emp_no, employees.first_name, employees.last_name, employees.hire_date
FROM employees
WHERE employees.emp_no=10010

-- 3.Number of days the employee 10010 worked for the Production department

SELECT employees.emp_no, employees.first_name, employees.last_name, departments.dept_name, 
datediff (dept_emp.to_date,dept_emp.from_date) AS days
FROM employees JOIN dept_emp ON dept_emp.emp_no=employees.emp_no JOIN departments ON departments.dept_no=dept_emp.dept_no
WHERE employees.emp_no=10010 AND departments.dept_name='Production'

-- 4.Number of days the employee 10010 worked for the Quality management department

SELECT employees.emp_no, employees.first_name, employees.last_name, departments.dept_name,  datediff (dept_emp.to_date,dept_emp.from_date) AS days
FROM employees JOIN dept_emp ON dept_emp.emp_no=employees.emp_no JOIN departments ON departments.dept_no=dept_emp.dept_no
WHERE employees.emp_no=10010 AND departments.dept_name='Quality Management'


/*5 The date the company started operating. Explain how you determined it (you assumption)
Explanation: the date the company started operating is the same the minimal date the company hired it’s first employee.*/

SELECT MIN(employees.hire_date) AS start_operating_date
FROM employees

/*6.The longest working employee(s). Explain how you determined it.
Explanation:
The longest working employee is the employee with maximum working days.
Maximum working days is defined in the next query:*/

SELECT max(t.sum_days) AS max_days FROM (SELECT employees.emp_no, SUM(
datediff (dept_emp.to_date,dept_emp.from_date))  AS sum_days
FROM employees JOIN dept_emp ON dept_emp.emp_no=employees.emp_no
GROUP BY  employees.emp_no) t

-- Now we can use this value as subquery to find the employee(s) who has this value of working days.

SELECT employees.emp_no, employees.first_name, employees.last_name, SUM(
datediff (dept_emp.to_date,dept_emp.from_date))  AS sum_days
FROM employees JOIN dept_emp ON dept_emp.emp_no=employees.emp_no
GROUP BY  employees.emp_no, employees.first_name, employees.last_name
HAVING SUM(datediff (dept_emp.to_date,dept_emp.from_date))= (SELECT max(t.sum_days) AS max_days FROM (SELECT employees.emp_no, SUM(
datediff (dept_emp.to_date,dept_emp.from_date))  AS sum_days
FROM employees JOIN dept_emp ON dept_emp.emp_no=employees.emp_no
GROUP BY  employees.emp_no) t)

-- 7.Number of current employees.

SELECT COUNT(*) AS num_of_emp
FROM employees JOIN dept_emp ON dept_emp.emp_no=employees.emp_no
WHERE dept_emp.to_date='9999-01-01'

-- 8. Employee(s) with the highest salary.

SELECT *
FROM employees JOIN salaries ON salaries.emp_no=employees.emp_no
WHERE salaries.to_date='9999-01-01' AND salaries.salary=(
SELECT MAX(salary) AS max_salary
FROM employees JOIN salaries ON salaries.emp_no=employees.emp_no
WHERE salaries.to_date='9999-01-01')

-- 9.Department numbers with corresponding department names.

SELECT * FROM departments

-- 10.Number of departments

SELECT COUNT(*) AS num_of_dep FROM departments

-- 11.Percentage of woman in every department.

SELECT d.dept_no, d.dept_name, COUNT(*)/(SELECT COUNT(*) FROM  dept_emp
WHERE dept_emp.dept_no=d.dept_no )*100 AS female_percentage
FROM employees e JOIN dept_emp d_e ON e.emp_no=d_e.emp_no JOIN departments d
ON d_e.dept_no=d.dept_no
WHERE e.gender='F'
GROUP BY d.dept_no, d.dept_name


-- 12. Percentage of current working woman in every department.

SELECT d.dept_no, d.dept_name, COUNT(*)/(SELECT COUNT(*) FROM  dept_emp
WHERE dept_emp.dept_no=d.dept_no AND dept_emp.to_date='9999-01-01')*100 AS female_percentage
FROM employees e JOIN dept_emp d_e ON e.emp_no=d_e.emp_no JOIN departments d
ON d_e.dept_no=d.dept_no
WHERE d_e.to_date='9999-01-01' AND e.gender='F'
GROUP BY d.dept_no, d.dept_name


-- 13. The most commonly given title(s) to the new employee

SELECT titles.title, COUNT(*) AS num_of_title
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE employees.hire_date=titles.from_date
GROUP BY titles.title
HAVING COUNT(*)=(SELECT MAX(t.n) FROM (SELECT COUNT(*) AS n
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE employees.hire_date=titles.from_date
GROUP BY titles.title) t)


/*The most common title(s) of the employees at the time they quit. Explain how you determined it.

Explanation: The dates of the quit for each employee:*/

SELECT titles.emp_no, MAX(titles.to_date)
FROM titles
WHERE titles.to_date <> '9999-01-01'
GROUP by titles.emp_no

--Use subquery to define the titles corresponding these dates:
SELECT titles.emp_no,titles.title, titles.to_date
FROM titles
WHERE titles.to_date <> '9999-01-01'
AND (titles.emp_no, titles.to_date) IN (
SELECT titles.emp_no, MAX(titles.to_date)
FROM titles
WHERE titles.to_date <> '9999-01-01'
GROUP by titles.emp_no)

-- Use subquery to define maximum number of these title(s)
SELECT titles.title, COUNT(*) AS n
FROM titles
WHERE titles.to_date <> '9999-01-01'
AND (titles.emp_no, titles.to_date) IN (
SELECT titles.emp_no, MAX(titles.to_date)
FROM titles
WHERE titles.to_date <> '9999-01-01'
GROUP by titles.emp_no)
GROUP BY titles.title
HAVING COUNT(*)= (SELECT MAX(t.n) FROM (SELECT COUNT(*) AS n
FROM titles
WHERE titles.to_date <> '9999-01-01'
AND (titles.emp_no, titles.to_date) IN (
SELECT titles.emp_no, MAX(titles.to_date)
FROM titles
WHERE titles.to_date <> '9999-01-01'
GROUP by titles.emp_no)
GROUP BY titles.title) t)

-- The earliest born employee (Date an employee was born who would be the oldest now).

SELECT employees.emp_no, employees.first_name, employees.last_name, employees.birth_date,
YEAR(CURRENT_DATE())-YEAR(employees.birth_date) AS age FROM employees
WHERE YEAR(CURRENT_DATE())-YEAR(employees.birth_date) =
 (SELECT MAX( YEAR(CURRENT_DATE())-YEAR(employees.birth_date)) AS max_age FROM employees)

-- 16.Employees who became managers but their salary didn’t increase
SELECT t1.emp_no,  min(t2.salary- t1.salary) AS diff
FROM (SELECT salaries.salary, titles.title, titles.emp_no, titles.from_date, titles.to_date FROM titles JOIN salaries ON titles.emp_no=salaries.emp_no
WHERE titles.from_date<=salaries.from_date AND titles.to_date>=salaries.to_date
AND titles.title<>'Manager') t1
JOIN
(SELECT salaries.salary, titles.title, titles.emp_no, titles.from_date, titles.to_date FROM titles JOIN salaries ON titles.emp_no=salaries.emp_no
WHERE titles.from_date<=salaries.from_date AND titles.to_date>=salaries.to_date
AND titles.title='Manager') t2
ON t1.emp_no=t2.emp_no AND t1.to_date<=t2.from_date

GROUP BY t1.emp_no

HAVING diff<=0

-- 17.The youngest employee(s) at the time of hiring
SELECT employees.emp_no, employees.first_name, employees.last_name,
YEAR(employees.hire_date)-YEAR(employees.birth_date) AS age
FROM employees
WHERE YEAR(employees.hire_date)-YEAR(employees.birth_date)= (SELECT MIN(t.age) FROM
(SELECT YEAR(employees.hire_date)-YEAR(employees.birth_date) AS age
FROM employees) t)


-- 18. The youngest employee(s) at the time of becoming a manager

SELECT employees.emp_no, employees.first_name, employees.last_name,
YEAR(titles.from_date)-YEAR(employees.birth_date) AS age
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.title='Manager'
AND YEAR(titles.from_date)-YEAR(employees.birth_date)= (SELECT min(t.age) FROM
(SELECT YEAR(titles.from_date)-YEAR(employees.birth_date) AS age
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.title='Manager') t

-- 19.Current oldest manager

SELECT employees.emp_no, employees.first_name, employees.last_name,
YEAR(CURRENT_DATE())-YEAR(employees.birth_date) AS age
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.title='Manager' AND titles.to_date='9999-01-01'
AND
YEAR(CURRENT_DATE())-YEAR(employees.birth_date)=(
SELECT MAX(t.age) FROM (SELECT
YEAR(CURRENT_DATE())-YEAR(employees.birth_date) AS age
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.title='Manager' AND titles.to_date='9999-01-01') t

-- 20.The smallest salary at the time of hiring

SELECT min(salaries.salary) AS min_hiring_salary
FROM employees JOIN salaries ON employees.emp_no=salaries.emp_no
WHERE employees.hire_date=salaries.from_date

-- 21.The highest salary, the name of employee(s) and his(their) birthdate at the time of hiring

SELECT employees.emp_no, employees.first_name, employees.last_name, employees.birth_date,
salaries.salary

FROM employees JOIN salaries ON employees.emp_no=salaries.emp_no
WHERE employees.hire_date=salaries.from_date AND salaries.salary=

(SELECT max(salaries.salary) AS min_hiring_salary

FROM employees JOIN salaries ON employees.emp_no=salaries.emp_no
WHERE employees.hire_date=salaries.from_date)

-- 22. Department that doesn’t have any employees at the moment. There can be more than one

SELECT * FROM departments WHERE departments.dept_no NOT IN (
SELECT dept_emp.dept_no FROM  dept_emp
WHERE dept_emp.to_date='9999-01-01')

-- 23. Department that currently doesn’t have any employees but have them before. There can be more than one
SELECT dept_emp.dept_no FROM dept_emp WHERE dept_emp.dept_no NOT IN (SELECT dept_emp.dept_no FROM  dept_emp
WHERE dept_emp.to_date='9999-01-01')

/* 24. Shortest working employee(s). Explain how you determined it.
Explanation:
There are two types of employees:  1) Currently working and 2) quitted.
This query shows employees who working currently and their numbers of days of working.*/

SELECT employees.emp_no, DATEDIFF(CURRENT_DATE(),employees.hire_date) AS years
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.to_date='9999-01-01'


-- This query shows the same for employees who had quitted.
SELECT employees.emp_no, datediff(max(titles.to_date),employees.hire_date) AS years
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.to_date<>'9999-01-01'
GROUP BY employees.emp_no,employees.hire_date


-- And next query unions them and shows all employees and number of days of working.
SELECT employees.emp_no, datediff(max(titles.to_date),employees.hire_date) AS years
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.to_date<>'9999-01-01'
GROUP BY employees.emp_no,employees.hire_date

UNION

SELECT employees.emp_no, DATEDIFF(CURRENT_DATE(),employees.hire_date) AS years
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.to_date='9999-01-01'


-- The next big query determines employees with minimum days of working (by subqueries). Subqueries are marked by yellow color.

SELECT employees.emp_no, datediff(max(titles.to_date),employees.hire_date) AS days
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.to_date<>'9999-01-01'
GROUP BY employees.emp_no,employees.hire_date
having datediff(max(titles.to_date),employees.hire_date)= (SELECT MIN(t.days) FROM

(SELECT employees.emp_no, datediff(max(titles.to_date),employees.hire_date) AS days
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.to_date<>'9999-01-01'
GROUP BY employees.emp_no,employees.hire_date

UNION

SELECT employees.emp_no, DATEDIFF(CURRENT_DATE(),employees.hire_date) AS days
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.to_date='9999-01-01') t)

UNION

SELECT employees.emp_no, DATEDIFF(CURRENT_DATE(),employees.hire_date) AS days
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.to_date='9999-01-01' and DATEDIFF(CURRENT_DATE(),employees.hire_date)= (SELECT MIN(t2.days) FROM

(SELECT employees.emp_no, datediff(max(titles.to_date),employees.hire_date) AS days
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.to_date<>'9999-01-01'
GROUP BY employees.emp_no,employees.hire_date

UNION

SELECT employees.emp_no, DATEDIFF(CURRENT_DATE(),employees.hire_date) AS days
FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.to_date='9999-01-01') t2)

-- 25. Employees that weren’t associated with any department at the time of hiring.

SELECT t.emp_no, t.hire_date, t1.associate_date FROM
(SELECT employees.emp_no,employees.hire_date FROM employees) t
left join
(SELECT dept_emp.emp_no, min(dept_emp.from_date) AS associate_date
FROM dept_emp
GROUP BY dept_emp.emp_no) t1
ON t.emp_no=t1.emp_no

WHERE t.hire_date <>t1.associate_date

-- 26. For each department and for each possible title the number of employees with that title in the department

SELECT  departments.dept_no, departments.dept_name, titles.title, COUNT(*) AS n FROM departments JOIN
dept_emp ON departments.dept_no=dept_emp.dept_no  JOIN titles ON dept_emp.emp_no=titles.emp_no WHERE
dept_emp.from_date<=titles.from_date AND dept_emp.to_date>=titles.to_date
GROUP BY departments.dept_no, departments.dept_name, titles.title

-- 27.The most common first name of woman
    
SELECT employees.first_name, count(employees.first_name) AS num_name FROM employees
WHERE employees.gender='F'
GROUP BY employees.first_name
HAVING count(employees.first_name)=(SELECT max(t.num_name) FROM (


SELECT count(employees.first_name) AS num_name FROM employees
WHERE employees.gender='F'
GROUP BY employees.first_name)t )


-- 28.The most common last name

SELECT employees.last_name, count(employees.last_name) AS num_name FROM employees
GROUP BY employees.last_name
HAVING count(employees.last_name)=(SELECT max(t.num_name) FROM (
SELECT count(employees.last_name) AS num_name FROM employees
GROUP BY employees.last_name)t )


-- 29. The average time after which the salary increases from the date of hiring

SELECT  avg(DATEDIFF(salaries.to_date,salaries.from_date)) AS avg_days  FROM salaries
WHERE (salaries.emp_no, salaries.from_date) IN
(SELECT salaries.emp_no, MIN(salaries.from_date) AS min_date FROM salaries
GROUP BY salaries.emp_no)


-- 30. Gender of most of the managers 
SELECT employees.gender, COUNT(*) AS num_of_managers FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.title='Manager'
group by employees.gender
HAVING COUNT(*)= (SELECT MAX(t.num_of_managers) FROM(
SELECT COUNT(*)  AS num_of_managers FROM employees JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.title='Manager'
group by employees.gender) t)


-- 31. Amount of money the department Production spent last month on salaries
SELECT * FROM dept_emp JOIN dept_manager ON dept_manager.emp_no=dept_emp.emp_no
AND dept_emp.from_date=dept_manager.from_date


-- That is why all managers are included in the solution:
SELECT SUM(salaries.salary) AS sum_salary FROM departments JOIN dept_emp ON departments.dept_no=dept_emp.dept_no JOIN
salaries ON dept_emp.emp_no=salaries.emp_no WHERE dept_emp.from_date<=salaries.from_date AND
dept_emp.to_date>=salaries.to_date AND salaries.from_date<='2020-09-01' AND salaries.to_date>='2020-09-30'
AND departments.dept_name='Production'

    
-- 32. Caree path in the production department
SELECT  titles.emp_no, group_concat(titles.title) FROM departments JOIN
dept_emp ON departments.dept_no=dept_emp.dept_no  JOIN titles ON dept_emp.emp_no=titles.emp_no WHERE
dept_emp.from_date<=titles.from_date AND dept_emp.to_date>=titles.to_date
and departments.dept_name='Production'
GROUP BY titles.emp_no


-- 33. Month and year most new employees were hired
SELECT DISTINCT  MONTH(employees.hire_date) AS 'MONTH', YEAR(employees.hire_date) AS 'year' FROM employees WHERE
employees.hire_date=(
SELECT max(employees.hire_date) FROM employees)

-- 34. Average salary of woman over the age 30 as well as average salary of men over the age of 30
SELECT t.gender, AVG(t.salary) FROM
(SELECT employees.gender, YEAR(CURRENT_DATE())-YEAR(employees.birth_date) AS age, salaries.salary
FROM employees JOIN salaries ON salaries.emp_no=employees.emp_no
WHERE YEAR(CURRENT_DATE())-YEAR(employees.birth_date)>30) t
GROUP BY t.gender

-- 35. Average salary in the Production department
SELECT AVG(salaries.salary) AS avg_salary FROM departments JOIN dept_emp ON dept_emp.dept_no=departments.dept_no
JOIN salaries ON salaries.emp_no=dept_emp.emp_no
WHERE departments.dept_name='Production' and dept_emp.from_date<=salaries.from_date AND dept_emp.to_date>=salaries.to_date

-- 36. How much the employee 10005 earned for the month of May 2009
SELECT salaries.salary/12 FROM employees JOIN salaries ON employees.emp_no=salaries.emp_no
WHERE employees.emp_no=10005 AND salaries.from_date<'2009-05-01' AND salaries.to_date>'2009-01-31'

-- 37. Position women work the longest

SELECT  employees.emp_no, employees.hire_date, titles.title, COUNT(*), titles.from_date,
if( max(titles.to_date)='9999-01-01', DATEDIFF(CURRENT_DATE(), employees.hire_date ),
datediff(max(titles.to_date),employees.hire_date)) AS  days_of_work
FROM employees JOIN titles ON titles.emp_no=employees.emp_no
WHERE employees.gender='F'
GROUP BY employees.emp_no, employees.hire_date, titles.title
HAVING COUNT(*)>1


-- If we don’t want to add such periods, let’s add field titles.from_date in subquery.
SELECT employees.emp_no, titles.title, if( max(titles.to_date)='9999-01-01', DATEDIFF(CURRENT_DATE(), employees.hire_date ), datediff(max(titles.to_date),employees.hire_date)) AS  days_of_work
FROM employees JOIN titles ON titles.emp_no=employees.emp_no
WHERE employees.gender='F'
GROUP BY employees.emp_no, employees.hire_date, titles.title
HAVING days_of_work=(SELECT MAX(t.days_of_work) FROM (SELECT  if( max(titles.to_date)='9999-01-01', DATEDIFF(CURRENT_DATE(), employees.hire_date ), datediff(max(titles.to_date),employees.hire_date)) AS  days_of_work
FROM employees JOIN titles ON titles.emp_no=employees.emp_no
WHERE employees.gender='F'
GROUP BY employees.emp_no, employees.hire_date, titles.title, titles.from_date)t)


-- 38. Current average salary of managers as well as average salary in the Development department
SELECT 'development', avg(salaries.salary) AS avg_salary FROM departments JOIN dept_emp ON dept_emp.dept_no=departments.dept_no
JOIN salaries ON salaries.emp_no=dept_emp.emp_no
WHERE departments.dept_name='Development' AND dept_emp.to_date='9999-01-01'  and dept_emp.from_date<=salaries.from_date AND dept_emp.to_date>=salaries.to_date
UNION
SELECT 'managers', avg(salaries.salary) AS avg_salary FROM dept_manager JOIN salaries ON salaries.emp_no=dept_manager.emp_no AND dept_manager.to_date='9999-01-01'
AND dept_manager.from_date<=salaries.from_date AND dept_manager.to_date>=salaries.to_date

-- 39. Average age of current managers as well as average age of other employees
SELECT  if(titles.title='Manager', 'Manager', 'other') AS t,
avg(YEAR(CURRENT_DATE())-YEAR(employees.birth_date) )AS avg_age
FROM employees JOIN titles ON titles.emp_no=employees.emp_no
WHERE titles.to_date='9999-01-01'
GROUP BY t

-- 40. Number of employees who have the same last name as some other employee’s first name
SELECT count(employees.last_name) AS n FROM employees
WHERE employees.last_name IN  (SELECT DISTINCT employees.first_name FROM employees)

-- 41. Number of employees with the last name ending with ‘ski’
SELECT  COUNT(*) AS num_ski FROM employees WHERE
employees.last_name LIKE '%ski'

-- 42. Number of employees with the last name starting with ‘Mc’ followed by capital letter

SELECT  COUNT(*) as num_Mc FROM employees WHERE
employees.last_name REGEXP 'Mc[A-Z]'

-- 43. The most common name given to girls in 2009

SELECT employees.first_name, COUNT(*) AS n FROM employees JOIN titles ON titles.emp_no=employees.emp_no
WHERE year(titles.from_date)<2009 AND year(titles.to_date)>2009
GROUP BY employees.first_name
having COUNT(*)= (SELECT MAX(t.n) FROM (SELECT COUNT(*) AS n FROM employees JOIN titles ON titles.emp_no=employees.emp_no
WHERE year(titles.from_date)<2009 AND year(titles.to_date)>2009
GROUP BY employees.first_name) t )

-- 44. The department(s) employees work the longest
    
SELECT t.dept_name, avg(t.period) as avg_period FROM
(SELECT departments.dept_no, departments.dept_name,titles.emp_no, sum(if(titles.to_date='9999-01-01',DATEDIFF( CURRENT_DATE(), titles.from_date),
DATEDIFF(titles.to_date,titles.from_date))) AS period
FROM departments join dept_emp ON departments.dept_no=dept_emp.dept_no
join titles
ON dept_emp.emp_no=titles.emp_no WHERE
dept_emp.from_date<=titles.from_date AND dept_emp.to_date>=titles.to_date
GROUP BY departments.dept_no, departments.dept_name,titles.emp_no) t
GROUP BY t.dept_name
HAVING avg(t.period)= (SELECT MAX(t1.avg_period) FROM (SELECT AVG(t2.period) as avg_period FROM
(SELECT departments.dept_no, departments.dept_name,titles.emp_no, sum(if(titles.to_date='9999-01-01',DATEDIFF( CURRENT_DATE(), titles.from_date),
DATEDIFF(titles.to_date,titles.from_date))) AS period
FROM departments join dept_emp ON departments.dept_no=dept_emp.dept_no
join titles
ON dept_emp.emp_no=titles.emp_no WHERE
dept_emp.from_date<=titles.from_date AND dept_emp.to_date>=titles.to_date
GROUP BY departments.dept_no, departments.dept_name,titles.emp_no) t2
GROUP BY t2.dept_name) t1 )

-- 45. Highest raise someone was given
SELECT MAX(t.diff) AS max_diff FROM(
SELECT t2.salary-t1.salary as diff
FROM salaries t1 JOIN salaries t2 ON t1.emp_no=t2.emp_no WHERE t1.from_date<>t2.from_date) t

-- 46. Manager(s) who didn’t have a word ‘manager’ in their title
SELECT employees.emp_no, employees.first_name, employees.last_name
FROM  employees join dept_manager ON employees.emp_no=dept_manager.emp_no  JOIN titles ON dept_manager.emp_no=titles.emp_no
AND titles.from_date=dept_manager.from_date WHERE employees.emp_no NOT IN(
SELECT employees.emp_no FROM  employees join dept_manager ON employees.emp_no=dept_manager.emp_no  JOIN titles ON dept_manager.emp_no=titles.emp_no
AND titles.from_date=dept_manager.from_date
WHERE titles.title LIKE '%Manager%'

-- 47.Titles given to the employees in each department
SELECT DISTINCT departments.dept_name, titles.title FROM departments JOIN
dept_emp ON departments.dept_no=dept_emp.dept_no  JOIN titles ON dept_emp.emp_no=titles.emp_no WHERE
dept_emp.from_date<=titles.from_date AND dept_emp.to_date>=titles.to_date

-- 48. Employees that didn’t quit at the end of the month

SELECT employees.*, titles.to_date FROM titles JOIN employees ON employees.emp_no=titles.emp_no
WHERE titles.to_date<>  LAST_DAY(titles.to_date) AND titles.to_date<>'9999-01-01'

--  49. Year(s) with the highest employment rent
SELECT t.emp_year, t.n/(SELECT COUNT(*) FROM titles WHERE year(titles.from_date)<=t.emp_year AND year(titles.to_date)>=t.emp_year) as emp_rate FROM (
SELECT YEAR(employees.hire_date) AS emp_year, COUNT(*) AS n  FROM employees
GROUP BY emp_year) t
WHERE t.n/(SELECT COUNT(*) FROM titles WHERE year(titles.from_date)<=t.emp_year AND year(titles.to_date)>=t.emp_year)=
(SELECT MAX(t1.emp_rate) FROM (SELECT t.emp_year, t.n/(SELECT COUNT(*) FROM titles WHERE year(titles.from_date)<=t.emp_year AND year(titles.to_date)>=t.emp_year) as emp_rate FROM (
SELECT YEAR(employees.hire_date) AS emp_year, COUNT(*) AS n  FROM employees
GROUP BY emp_year) t)t1)

-- 50. The most common title(s) of employees at the time they started working in another department

SELECT titles.title, COUNT(*) FROM employees join dept_emp on employees.emp_no=dept_emp.emp_no join titles
ON dept_emp.emp_no=titles.emp_no WHERE
dept_emp.from_date=titles.from_date AND employees.hire_date<>dept_emp.from_date
GROUP BY titles.title
HAVING COUNT(*)= (SELECT MAX(t.n) FROM (SELECT  COUNT(*)AS n FROM employees join dept_emp on employees.emp_no=dept_emp.emp_no join titles
ON dept_emp.emp_no=titles.emp_no WHERE
dept_emp.from_date=titles.from_date AND employees.hire_date<>dept_emp.from_date
GROUP BY titles.title) t)

-- 51. The most common title(s) of employees at the time they became manager of some department
SELECT titles.title, COUNT(*) FROM dept_manager JOIN titles ON dept_manager.emp_no=titles.emp_no
AND titles.from_date=dept_manager.from_date
GROUP BY titles.title
HAVING COUNT(*)=(SELECT MAX(t.n) FROM (SELECT  COUNT(*)AS n FROM dept_manager JOIN titles ON dept_manager.emp_no=titles.emp_no
AND titles.from_date=dept_manager.from_date
GROUP BY titles.title) t )

-- 52. Number of employees with unique last name

SELECT employees.last_name, COUNT(*) AS n  FROM employees
GROUP BY employees.last_name
having COUNT(*)=1

-- 53. Managers with a ‘Staff’ title.
SELECT employees.emp_no, employees.first_name, employees.last_name FROM  employees join dept_manager ON employees.emp_no=dept_manager.emp_no  JOIN titles ON dept_manager.emp_no=titles.emp_no
AND titles.from_date=dept_manager.from_date
WHERE titles.title='Staff'

--  54. Number of employees who right away became some department managers

SELECT COUNT(*) AS num_of_emp FROM employees JOIN dept_manager ON dept_manager.emp_no=employees.emp_no
WHERE employees.hire_date=dept_manager.from_date

-- 55. Employee(s) who had the longest break from this company
SELECT t1.emp_no,employees.first_name,employees.last_name, datediff(t1.from_date, t2.to_date) AS break
FROM employees join
titles t1 ON employees.emp_no=t1.emp_no
JOIN titles t2 ON t1.emp_no=t2.emp_no WHERE t1.from_date<>t2.from_date AND t1.to_date<>t2.from_date
and  datediff(t1.from_date, t2.to_date)=(SELECT MAX(t3.break) FROM (SELECT datediff(t1.from_date, t2.to_date) AS break FROM titles t1
JOIN titles t2 ON t1.emp_no=t2.emp_no WHERE t1.from_date<>t2.from_date AND t1.to_date<>t2.from_date) t3)

-- 56. Employee(s) who were managers in more than one department
SELECT dept_manager.emp_no, COUNT(*) FROM dept_manager
GROUP BY dept_manager.emp_no
HAVING COUNT(*) >1

-- 57. The smallest number of days an employee was a manager in some department
SELECT min(DATEDIFF(titles.to_date, titles.from_date)) as smallest_num_days
FROM titles WHERE titles.title='Manager'


-- 58. Employee (emp.nos) who were not managers

SELECT employees.emp_no,employees.first_name, employees.last_name FROM employees
WHERE employees.emp_no NOT IN (SELECT dept_manager.emp_no FROM dept_manager)


-- 59. Current title and emp_no of each current employee.
SELECT titles.emp_no, titles.title FROM titles
WHERE titles.to_date='9999-01-01'


/* 60. Employees hired the latest. If employee 5 (emp_no) was hired 2 weeks ago and no one else was hired since that time, 
then that query should return info about emp_no 5. If 2 employees were hired one week ago
and since that time any person was hired then info about these 2 employees should be returned in the result of the query.*/

SELECT * FROM employees where employees.hire_date=(
SELECT max(employees.hire_date)AS last_hir_date FROM employees)

