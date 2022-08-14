# 第09章_子查询
# 子查询指一个查询语句嵌套在另一个查询语句内部的查询


# 1. 需求分析与问题解决
# 1.1 实际问题
# 问题：谁的工资比Abel高？

# 方式1：
SELECT salary FROM employees WHERE last_name = 'Abel';	# 11000.00
SELECT last_name, salary FROM employees WHERE salary > 11000.00;	# 10 rows

# 方式2：自连接
SELECT e2.last_name, e2.salary 
FROM employees e1, employees e2
WHERE e1.last_name = 'Abel' AND e2.salary > e1.salary;	# 10 rows

# 方式3：子查询
SELECT last_name, salary
FROM employees
WHERE salary > (
		SELECT salary
		FROM employees
		WHERE last_name = 'Abel'
		);	# 10 rows

# 1.2 子查询的基本使用
/*
语法结构：
	SELECT select_list
	FROM table
	WHERE expr operator (
			     SELECT select_list
			     FROM table
			     );
子查询（内查询）在主查询之前一次执行完成
子查询的结果被主查询（外查询）使用

注意：
	① 子查询要包含在括号内
	② 将子查询放在比较条件的右侧
	③ 单行操作符对应单行子查询，多行操作符对应多行子查询
*/

# 1.3 子查询的分类
/*
分类方式1：
	按内查询的结果返回一条还是多条记录，分为 单行子查询、多行子查询

分类方式2：
	按内查询是否被执行多次，分为 相关（或关联）子查询、不相关（或非关联）子查询
*/


# 2. 单行子查询
# 2.1 单行比较操作符
# 	=, >, >=, <, <=, <>

# 2.2 代码示例
# 题目：查询工资大于149号员工工资的员工的信息
SELECT *
FROM employees
WHERE salary > (
		SELECT salary 
		FROM employees
		WHERE employee_id = 149
		); 	# 13 rows

# 题目：返回job_id与141号员工相同，salary比143号员工多的员工姓名，job_id和工资
SELECT last_name, job_id, salary
FROM employees
WHERE job_id = (
		SELECT job_id
		FROM employees
		WHERE employee_id = 141
		)
AND salary > (
		SELECT salary
		FROM employees
		WHERE employee_id = 143
		);	# 11 rows

# 题目：返回公司工资最少的员工的last_name,job_id和salary
SELECT last_name, job_id, salary
FROM employees
WHERE salary = (
		SELECT MIN(salary)
		FROM employees 		
		);

# 题目：查询与141号或174号员工的manager_id和department_id相同的其他员工的employee_id，manager_id，department_id
SELECT employee_id, manager_id, department_id
FROM employees
WHERE (manager_id, department_id) IN (
					SELECT manager_id, department_id
					FROM employees
					WHERE employee_id IN (141, 174)
					)
AND employee_id NOT IN (141, 174);	# 11 rows

# 2.3 HAVING中的子查询
# 	首先执行子查询
#	向主查询中的HAVING子句返回结果
# 题目：查询最低工资大于50号部门最低工资的部门id和其最低工资
SELECT department_id, MIN(salary)
FROM employees
GROUP BY department_id
HAVING MIN(salary) > (
			SELECT MIN(salary)
			FROM employees
			WHERE department_id = 50
			);	# 11 rows

# 2.4 CASE中的子查询
# 题目：显式员工的employee_id,last_name和location。其中，若员工department_id与location_id为1800的department_id相同，则location为’Canada’，其余则为’USA’。
SELECT employee_id, last_name, CASE department_id WHEN (
							SELECT department_id 
							FROM departments 
							WHERE location_id = 1800
							) THEN 'Canada' 
						  ELSE 'USA' END AS location
FROM employees;

# 2.5 子查询中的空值问题
SELECT last_name, job_id
FROM employees
WHERE job_id = (
		SELECT job_id
		FROM employees
		WHERE last_name = 'Haas'
		);	# 0 row

# 2.6 非法使用子查询
# 错误的，子查询返回多行，salary不能与多行结果集进行比较
SELECT employee_id, last_name
FROM employees
WHERE salary =(
		SELECT MIN(salary)
		FROM employees
		GROUP BY department_id);
		

# 3. 多行子查询
# 也称为集合比较子查询，内查询返回多行，使用多行比较操作符
# 3.1 多行比较操作符
# IN、ANY、ALL、SOME(ANY的别名，作用相同)

# 3.2 代码示例
# 题目：返回其它job_id中 比job_id为‘IT_PROG’部门任一工资低的员工的员工号、姓名、job_id 以及salary
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE salary < ANY(
			SELECT salary
			FROM employees
			WHERE job_id = 'IT_PROG'
			)
AND job_id != 'IT_PROG';	# 76 rows

# 题目：返回其它job_id中比job_id为‘IT_PROG’部门所有工资都低的员工的员工号、姓名、job_id以及salary
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE salary < ALL(
			SELECT salary
			FROM employees
			WHERE job_id = 'IT_PROG'
			)
AND job_id != 'IT_PROG';	# 44 rows

# 题目：查询平均工资最低的部门id
SELECT department_id
FROM employees
GROUP BY department_id
ORDER BY AVG(salary) ASC
LIMIT 0,1;	# 50

SELECT department_id
FROM employees
GROUP BY department_id
HAVING AVG(salary) <= ALL(
			SELECT AVG(salary)
			FROM employees
			GROUP BY department_id
			);

# 3.3 空值问题
SELECT last_name
FROM employees
WHERE employee_id NOT IN (
				SELECT manager_id
				FROM employees	
				);	# 0 row


# 4. 相关子查询
# 4.1 相关子查询执行流程
#	子查询中使用主查询中的列

# 4.2 代码示例
# 题目：查询员工中工资大于本部门平均工资的员工的last_name,salary和其department_id
# 方式1：相关子查询
SELECT last_name, salary, department_id
FROM employees e1
WHERE salary > (SELECT AVG(salary)
		FROM employees e2
		WHERE department_id = e1.department_id
		);	# 38 rows

# 方式2：在FROM中使用子查询
SELECT last_name,salary,e1.department_id
FROM employees e1,(
			SELECT department_id, AVG(salary) dept_avg_sal
			FROM employees
			GROUP BY department_id
			) e2
WHERE e1.department_id = e2.department_id
AND e2.dept_avg_sal < e1.salary;

# 题目：查询员工的id,salary,按照department_name 排序
# 方式1：外连接
SELECT employee_id, salary
FROM employees e LEFT JOIN departments d
ON e.department_id = d.department_id
ORDER BY d.department_name;

# 方式2：在ORDER BY中使用子查询
SELECT employee_id, salary
FROM employees e
ORDER BY (
		SELECT department_name
		FROM departments d
		WHERE e.department_id = d.department_id
		);

# 题目：若employees表中employee_id与job_history表中employee_id相同的数目不小于2，输出这些相同id的员工的employee_id,last_name和其job_id
SELECT e.employee_id, e.last_name, e.job_id
FROM employees e
WHERE (
	SELECT COUNT(*) 
	FROM job_history j
	WHERE j.employee_id = e.employee_id
	) >=2;	# 3 rows

# 4.3 EXISTS 和 NOT EXISTS 关键字 
# 题目：查询公司管理者的employee_id，last_name，job_id，department_id信息
# 方式1：
SELECT employee_id, last_name, job_id, department_id
FROM employees
WHERE employee_id IN (
				SELECT DISTINCT manager_id
				FROM employees
				);	# 18 rows

# 方式2：
SELECT employee_id, last_name, job_id, department_id
FROM employees e1
WHERE EXISTS (
		SELECT *
		FROM employees e2
		WHERE e2.manager_id = e1.employee_id
		);	# 18 rows

# 题目：查询departments表中，不存在于employees表中的部门的department_id和department_name
SELECT department_id, department_name
FROM departments d
WHERE NOT EXISTS (
			SELECT * 
			FROM employees e
			WHERE e.department_id = d.department_id
			);	# 16 rows


# 4.4 相关更新
/*
使用相关子查询依据一个表中的数据更新另一个表的数据
语法：
	UPDATE table1 alias1
	set column = (
			SELECT expression
			FROM table2 alias2
			WHERE alias1.column = alias2.column
		      );

# 题目：在employees中增加一个department_name字段，数据为员工对应的部门名称
ALTER TABLE employees
ADD department_name VARCHAR(20);

UPDATE employees e
SET department_name = (
			SELECT department_name
			FROM departments d
			WHERE d.department_id = e.department_id
			);
*/


# 4.5 相关删除
/*
使用相关子查询依据一个表中的数据删除另一个表的数据
语法：
	DELETE FROM table1 alias1
	WHERE column operator (
				SELECT expression
				FROM table2 alias2
				WHERE alias1.column = alias2.column
				);

# 题目：删除表employees中，其与emp_history表皆有的数据
DELETE FROM employees e
WHERE employee_id = (
			SELECT employee_id
			FROM emp_history emp
			WHERE emp.employee_id = e.employee_id
			);
*/


# 5. 抛一个思考题
#方式1：自连接
SELECT e2.last_name, e2.salary
FROM employees e1, employees e2
WHERE e1.last_name = 'Abel'
AND e1.salary < e2.salary;

#方式2：子查询
SELECT last_name,salary
FROM employees
WHERE salary > (
		SELECT salary
		FROM employees
		WHERE last_name = 'Abel'
);

/*
结论：
	自连接方式好，因为在许多DBMS的处理过程中，对于自连接的处理速度要比子查询快得多

理解：
	子查询实际上是通过未知表进行查询后的条件判断，而自连接是通过已知的自身数据表进行条件判断，
	因此在大部分 DBMS 中都对自连接处理进行了优化
*/