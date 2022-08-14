# 第08章_聚合函数_课后练习


# 1.where子句可否使用组函数进行过滤?
# 不可以

# 2.查询公司员工工资的最大值，最小值，平均值，总和
SELECT MAX(salary), MIN(salary), AVG(salary), SUM(salary)
FROM employees;

# 3.查询各job_id的员工工资的最大值，最小值，平均值，总和
SELECT job_id, MAX(salary), MIN(salary), AVG(salary), SUM(salary)
FROM employees
GROUP BY job_id;	# 19 rows

# 4.选择具有各个job_id的员工人数
SELECT job_id, COUNT(*)
FROM employees
GROUP BY job_id;

# 5.查询员工最高工资和最低工资的差距（DIFFERENCE）
SELECT MAX(salary) - MIN(salary) AS DIFFERENCE 
FROM employees;

# 6.查询各个管理者手下员工的最低工资，其中最低工资不能低于6000，没有管理者的员工不计算在内
SELECT manager_id, MIN(salary) min_sal
FROM employees
WHERE manager_id IS NOT NULL 
GROUP BY manager_id HAVING min_sal >= 6000;	# 9 rows

# 7.查询所有部门的名字，location_id，员工数量和平均工资，并按平均工资降序
DESC departments;

SELECT d.department_name, d.location_id, COUNT(*), AVG(e.salary) avg_sal
FROM departments d LEFT OUTER JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name, d.location_id
ORDER BY avg_sal DESC;	# 27 rows

# 8.查询每个工种、每个部门的部门名、工种名和最低工资
DESC jobs;
DESC departments;

SELECT j.job_id, d.department_name, j.job_title, MIN(e.salary)
FROM jobs j LEFT JOIN employees e ON j.job_id = e.job_id
RIGHT JOIN departments d ON e.department_id = d.department_id
GROUP BY j.job_id, d.department_id, j.job_title;	# 35 rows
