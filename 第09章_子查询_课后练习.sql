# 第09章_子查询_课后练习


# 1. 查询和Zlotkey相同部门的员工姓名和工资
SELECT last_name, salary
FROM employees
WHERE department_id = (
			SELECT department_id
			FROM employees
			WHERE last_name = 'Zlotkey'
			);	# 34 rows

# 2. 查询工资比公司平均工资高的员工的员工号，姓名和工资
SELECT employee_id, last_name, salary
FROM employees
WHERE salary > (
		SELECT AVG(salary)
		FROM employees
		);	# 51 rows

# 3. 选择工资大于所有JOB_ID = 'SA_MAN'的员工的工资的员工的last_name, job_id, salary
SELECT last_name, job_id, salary
FROM employees
WHERE salary > ALL(
			SELECT salary
			FROM employees
			WHERE job_id = 'SA_MAN'
			);	# 3 rows

# 4. 查询和姓名中包含字母u的员工在相同部门的员工的员工号和姓名
SELECT employee_id, last_name
FROM employees
WHERE department_id IN (
			SELECT DISTINCT department_id
			FROM employees
			WHERE last_name LIKE '%u%'
			);	# 96 rows

# 5. 查询在部门的location_id为1700的部门工作的员工的员工号
SELECT employee_id
FROM employees
WHERE department_id = ANY(
				SELECT department_id
				FROM departments
				WHERE location_id = 1700
				);	#18 rows

# 6. 查询管理者是King的员工姓名和工资
SELECT last_name, salary
FROM employees
WHERE manager_id IN (
			SELECT employee_id
			FROM employees
			WHERE last_name = 'King' 
			);	# 14 rows

# 7. 查询工资最低的员工信息: last_name, salary
SELECT last_name, salary
FROM employees
WHERE salary = (
		SELECT MIN(salary)
		FROM employees
		);

# 8. 查询平均工资最低的部门信息
SELECT * 
FROM departments
WHERE department_id = (
			SELECT department_id
			FROM employees
			GROUP BY department_id
			ORDER BY AVG(salary)
			LIMIT 0, 1
			);

# 9.查询平均工资最低的部门信息和该部门的平均工资（相关子查询）
SELECT d.*, t_dept_avg_sal.avg_sal
FROM departments d, (
			SELECT department_id, AVG(salary) avg_sal
			FROM employees
			GROUP BY department_id
			ORDER BY AVG(salary)
			LIMIT 0, 1
			) t_dept_avg_sal
WHERE d.department_id = t_dept_avg_sal.department_id;


# 10. 查询平均工资最高的 job 信息
SELECT *
FROM jobs
WHERE job_id = (
		SELECT job_id
		FROM employees
		GROUP BY job_id
		ORDER BY AVG(salary) DESC
		LIMIT 0, 1 
		);

# 11.查询平均工资高于公司平均工资的部门有哪些?
SELECT department_id
FROM employees
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING (AVG(salary)) > (
			SELECT AVG(salary)
			FROM employees
			);	# 7 rows

# 12. 查询出公司中所有 manager 的详细信息
SELECT *
FROM employees
WHERE employee_id IN (
			SELECT DISTINCT manager_id
			FROM employees
			WHERE manager_id IS NOT NULL
			);	# 18 rows

# 13. 各个部门中 最高工资中最低的那个部门的 最低工资是多少?
SELECT MIN(salary)
FROM employees
WHERE department_id = (
			SELECT department_id
			FROM employees
			GROUP BY department_id
			ORDER BY MAX(salary)
			LIMIT 0, 1
			);	# 4400


# 14. 查询平均工资最高的部门的 manager 的详细信息: last_name, department_id, email, salary
SELECT last_name, department_id, email, salary
FROM employees
WHERE employee_id IN (
			SELECT manager_id
			FROM employees
			WHERE department_id = (
						SELECT department_id
						FROM employees
						GROUP BY department_id
						ORDER BY AVG(salary) DESC
						LIMIT 0, 1
						)
			AND manager_id IS NOT NULL
			);	# King	90	SKING	24000

# 15. 查询部门的部门号，其中不包括job_id是"ST_CLERK"的部门号
/*
以下错误，因为employees表中并不包含所有的部门
select distinct department_id
from employees
where job_id != 'ST_CLERK'
and department_id is not null;	# 11 rows
*/
SELECT department_id
FROM departments d
WHERE department_id NOT IN (
				SELECT DISTINCT department_id
				FROM employees
				WHERE job_id = 'ST_CLERK'
				);

# 16. 选择所有没有管理者的员工的last_name
SELECT last_name
FROM employees
WHERE manager_id IS NULL;	# 1 row

SELECT last_name
FROM employees e1
WHERE NOT EXISTS (
			SELECT 'X'
			FROM employees e2
			WHERE e1.manager_id = e2.employee_id
			);

# 17．查询员工号、姓名、雇用时间、工资，其中员工的管理者为 'De Haan'
SELECT employee_id, last_name, hire_date, salary
FROM employees
WHERE manager_id = (
			SELECT employee_id
			FROM employees
			WHERE last_name = 'De Haan'
			);	# 103	Hunold	1990-01-03	9000

# 18. 查询各部门中工资比本部门平均工资高的员工的员工号, 姓名和工资（相关子查询）
SELECT employee_id, last_name, salary
FROM employees e1
WHERE e1.salary > (
			SELECT AVG(salary)
			FROM employees e2
			WHERE e1.department_id = e2.department_id
			);	# 38 rows

# 19. 查询每个部门下的部门人数大于 5 的部门名称（相关子查询）
SELECT department_name
FROM departments d
WHERE (
	SELECT COUNT(*)
	FROM employees e
	WHERE d.department_id = e.department_id) > 5;	# 4 rows

# 20. 查询每个国家下的部门个数大于 2 的国家编号（相关子查询）
SELECT country_id
FROM locations l
WHERE 2 < (
		SELECT COUNT(*)
		FROM departments d
		WHERE d.location_id = l.location_id
		);	# US
		