/*1. Покажіть середню зарплату співробітників за кожен рік, до 2005 року.*/

SELECT 
  YEAR(from_date) AS report_year,
  ROUND(AVG(salary), 2) AS avg_salary
FROM salaries
GROUP BY report_year
HAVING report_year BETWEEN MIN(report_year) AND 2005
ORDER BY report_year;


/*2. Покажіть середню зарплату співробітників по кожному відділу. Примітка: потрібно розрахувати по поточній зарплаті, та поточному відділу співробітників*/

SELECT 
  d.dept_name,
  ROUND(AVG(s.salary), 2) AS avg_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE CURRENT_DATE BETWEEN de.from_date AND de.to_date
  AND CURRENT_DATE BETWEEN s.from_date AND s.to_date
GROUP BY d.dept_name
ORDER BY avg_salary DESC;

/*3. Покажіть середню зарплату співробітників по кожному відділу за кожний рік*/
SELECT 
  d.dept_name,
  YEAR(s.from_date) AS salary_year,
  ROUND(AVG(s.salary), 2) AS avg_salary
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
JOIN salaries s ON de.emp_no = s.emp_no
WHERE CURRENT_DATE BETWEEN de.from_date AND de.to_date
  AND CURRENT_DATE BETWEEN s.from_date AND s.to_date
GROUP BY d.dept_name, salary_year
ORDER BY salary_year, avg_salary DESC;


/*4. Покажіть відділи в яких зараз працює більше 15000 співробітників.*/

SELECT 
  d.dept_name,
  COUNT(de.emp_no) AS active_employees
FROM departments d
JOIN dept_emp de ON d.dept_no = de.dept_no
WHERE CURRENT_DATE BETWEEN de.from_date AND de.to_date
GROUP BY d.dept_name
HAVING COUNT(de.emp_no) > 15000
ORDER BY active_employees DESC;


/*5. Для менеджера який працює найдовше покажіть його номер, відділ, дату прийому на роботу, прізвище*/

SELECT 
  e.emp_no,
  e.last_name,
  e.hire_date,
  d.dept_name
FROM employees e
JOIN dept_manager dm ON e.emp_no = dm.emp_no
JOIN departments d ON dm.dept_no = d.dept_no
WHERE CURRENT_DATE BETWEEN dm.from_date AND dm.to_date
ORDER BY e.hire_date ASC
LIMIT 1;


/*6. Покажіть топ-10 діючих співробітників компанії з найбільшою різницею між їх зарплатою і середньою зарплатою в їх відділі.*/

WITH current_assignments AS (
  SELECT emp_no, dept_no
  FROM dept_emp
  WHERE CURRENT_DATE BETWEEN from_date AND to_date
),
current_salaries AS (
  SELECT emp_no, salary
  FROM salaries
  WHERE CURRENT_DATE BETWEEN from_date AND to_date
),
avg_salary_per_dept AS (
  SELECT ca.dept_no, ROUND(AVG(cs.salary), 2) AS avg_dept_salary
  FROM current_assignments ca
  JOIN current_salaries cs ON ca.emp_no = cs.emp_no
  GROUP BY ca.dept_no
),
employee_salary_diff AS (
  SELECT 
    ca.emp_no,
    d.dept_name,
    ROUND(cs.salary - a.avg_dept_salary, 2) AS salary_diff
  FROM current_assignments ca
  JOIN current_salaries cs ON ca.emp_no = cs.emp_no
  JOIN avg_salary_per_dept a ON ca.dept_no = a.dept_no
  JOIN departments d ON ca.dept_no = d.dept_no
)

SELECT emp_no, dept_name, salary_diff
FROM employee_salary_diff
ORDER BY salary_diff DESC
LIMIT 10;


/*7. Для кожного відділу покажіть другого по порядку менеджера. Необхідно вивести відділ, прізвище ім’я менеджера, дату прийому на роботу менеджера і дату коли він став менеджером відділу*/

WITH first_two_managers AS (
  SELECT dm.dept_no, dm.emp_no, dm.from_date
  FROM dept_manager dm
  WHERE EXISTS (
    SELECT 1
    FROM dept_manager dm2
    WHERE dm2.dept_no = dm.dept_no
      AND dm2.from_date < dm.from_date
  )
  AND NOT EXISTS (
    SELECT 1
    FROM dept_manager dm3
    WHERE dm3.dept_no = dm.dept_no
      AND dm3.from_date < dm.from_date
      AND EXISTS (
        SELECT 1
        FROM dept_manager dm4
        WHERE dm4.dept_no = dm.dept_no
          AND dm4.from_date < dm3.from_date
      )
  )
)

SELECT 
  d.dept_name,
  e.first_name,
  e.last_name,
  e.hire_date,
  fm.from_date AS manager_start_date
FROM first_two_managers fm
JOIN employees e ON fm.emp_no = e.emp_no
JOIN departments d ON fm.dept_no = d.dept_no;