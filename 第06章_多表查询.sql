# 第06章_多表查询

# 1. 一个案例引发的多表连接

# 1.1 案例说明
# 案例：查询员工的姓名及其部门名称

# 错误写法：产生了笛卡尔积的错误
SELECT last_name, department_name FROM employees, departments;	# 2889 rows	107 * 27

SELECT last_name FROM employees;		# 107 rows
SELECT department_name FROM departments;	# 27 rows


# 1.2 笛卡尔积(或交叉连接)的理解
# 笛卡尔积：集合X和集合Y的所有可能组合，第一个对象来自于X，第二个对象来自于Y，
#	    组合的个数为集合中元素个数的乘积数
#	    它的作用是把任意表进行连接，即使这两张表不相关
# 笛卡尔积也称为交叉连接，英文名是 CROSS JOIN

# 在MySQL中如下情况会出现笛卡尔积：都是 2889 rows
SELECT last_name, department_name FROM employees, departments;
SELECT last_name, department_name FROM employees CROSS JOIN departments;
SELECT last_name, department_name FROM employees INNER JOIN departments;
SELECT last_name, department_name FROM employees JOIN departments;


# 1.3 案例分析与问题解决
# 笛卡尔积的错误会在下面条件下产生
#	省略多个表的连接条件（或关联条件）
#	连接条件（或关联条件）无效
#	所有表中的所有行互相连接
# 为了避免笛卡尔积，可以在WHERE加入有效的连接条件
# 加入连接条件后的查询语法：
# select table1.column1, table2.column2 from table1, table2 where table1.colum = table2.column;

# 正确写法：在表中有相同列时，在列名前加上表名前缀
SELECT last_name, department_name FROM employees, departments
WHERE employees.department_id = departments.department_id;	# 106 rows


# 2. 多表查询分类讲解

# 分类1：等值连接 vs 非等值连接
SELECT e.employee_id, e.last_name, e.department_id, d.department_id, d.location_id
FROM employees AS e, departments AS d		# 给表起别名
WHERE e.department_id = d.department_id;	# 106 rows

# 拓展1：多个连接条件与AND操作符
# 查询员工工资及其工资等级
SELECT e.last_name, e.salary, j.grade_level
FROM employees AS e, job_grades AS j
WHERE e.salary BETWEEN j.lowest_sal AND j.highest_sal;


# 分类2：自连接 vs 非自连接
# 自连接：table1和table2本质上是同一张表，只是用取别名的方式虚拟成两张表以代表不同的意义
# 练习：查询员工id,员工姓名及其管理者的id和姓名
SELECT e.employee_id, e.last_name, m.employee_id, m.last_name
FROM employees e, employees m
WHERE e.manager_id = m.employee_id;

# 练习：查询employees表，返回“Xxx works for Xxx”
SELECT CONCAT(e.last_name, " works for ", m.last_name)
FROM employees e, employees m
WHERE e.manager_id = m.employee_id;

# 练习：练习：查询出last_name为 ‘Chen’ 的员工的 manager 的信息
SELECT m.employee_id, m.last_name
FROM employees e, employees m
WHERE e.manager_id = m.employee_id AND e.last_name = "Chen";


# 分类3：内连接 vs 外连接
# 内连接：合并具有同一列的两个以上的表的行，结果集中不包含一个表与另一个表不匹配的行
# 外连接：两个表在连接过程中除了返回满足连接条件的行以外还返回左（或右）表中不满足条件的行，这种连接称为左（或右）外连接。没有匹配的行时，结果表中相应的列为空（NULL）
#	如果是左外连接，则连接条件中左边的表也称为主表，右边的表称为从表
#	如果是右外连接，则连接条件中右边的表也称为主表，左边的表称为从表
#	SQL92：使用(+)创建连接，代表从表所在的位置，然而MySQL不支持SQL92的外连接
#	SQL92中只有左外连接和右外连接，没有满（或全）外连接

# MySQL不支持
#select last_name, department_name from employees, departments
#where employees.department_id = departments.department_id(+);	# 左外连接
#select last_name, department_name from employees, departments
#where employees.department_id(+) = departments.department_id;	# 右外连接


# 3. SQL99语法实现多表查询
# 3.1 基本语法
# 使用JOIN ... ON 子句创建连接的语法结构：
#	select table1.column, table2.column, table3.column
#	from table1
#	join table2 on table1 和 table2 的连接条件
#	join table3 on table2 和 table3 的连接条件

# 关键字 JOIN、INNER JOIN、CROSS JOIN 的含义是一样的，都表示内连接


# 3.2 内连接（INNER JOIN）的实现
# 语法：
#	select 字段列表
#	from A表 INNER JOIN B表
#	ON 关联条件
#	where 等其他子句;
SELECT e.employee_id, e.last_name, d.department_id, d.location_id
FROM employees e INNER JOIN departments d
ON e.department_id = d.department_id;	# 106 rows

SELECT e.employee_id, e.last_name, d.department_id, d.department_name, l.location_id, l.city
FROM employees e 
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id;


# 3.3  外连接（OUTER JOIN）的实现
# 3.3.1 左外连接（LEFT OUTER JOIN）
# 语法：
#	select 字段列表
#	from A表 left join B表
#	ON 关联条件
#	where 等其他子句;

SELECT e.last_name, e.department_id, d.department_name
FROM employees e
LEFT OUTER JOIN departments d
ON e.department_id = d.department_id;	# 107 rows

# 3.3.2 右外连接（RIGHT OUTER JOIN）
# 语法：
#	select 字段列表
#	from A表 right join B表
#	on 关联条件
#	where 等其他子句;
SELECT e.last_name, e.department_id, d.department_name
FROM employees e
RIGHT OUTER JOIN departments d
ON e.department_id = d.department_id;	# 122 rows

# 3.3.3 满外连接（FULL OUTER JOIN）
#	满外连接的结果 = 左右表匹配的数据 + 做表没有匹配到的数据 + 右表没有匹配到的数据
#	SQL99是支持满外连接的。使用 FULL JOIN 或 FULL OUTER JOIN 来实现
#	MySQL不支持 FULL JOIN，可使用 LEFT JOIN UNION RIGHT JOIN 代替


# 4. UNION的使用
# 合并查询结果
#	利用UNION关键字，可以给出多条SELECT语句，并将它们的结果组合成单个结果集。
#	合并时，两个表对应的列数和数据类型必须相同，并且相互对应
#	各个SELECT语句之间使用UNION或UNION ALL关键字分隔
#	UNION：会执行去重操作
#	UNION ALL：不会执行去重操作
#	注意：执行UNION ALL语句时所需要的资源比UNION语句少
# 语法格式：
#	select column, ... from table1
#	UNION ALL
#	select column, ... from table2;

# 举例：查询部门编号>90或邮箱包含a的员工信息
SELECT * FROM employees WHERE department_id > 90 OR email LIKE '%a%';	# 67 rows
SELECT * FROM employees WHERE department_id > 90
UNION
SELECT * FROM employees WHERE email LIKE '%a%';	# 67 rows, 若使用 UNION ALL，70 rows


# 5. 7种SQL JOINS的实现
# 5.7.1 代码实现
# 中图：内连接	A ∩ B
SELECT e.employee_id, e.last_name, d.department_name
FROM employees e JOIN departments d
ON e.department_id = d.department_id;	# 106 rows


# 左上图：左外连接
SELECT e.employee_id, e.last_name, d.department_name
FROM employees e LEFT JOIN departments d
ON e.department_id = d.department_id;	# 107 rows


# 右上图：右外连接
SELECT e.employee_id, e.last_name, d.department_name
FROM employees e RIGHT JOIN departments d
ON e.department_id = d.department_id;	# 122 rows


# 左中图：A - (A ∩ B)
SELECT e.employee_id, e.last_name, d.department_name
FROM employees e LEFT JOIN departments d
ON e.department_id = d.department_id
WHERE d.department_id IS NULL;	# 1 row, 从表的关联字段 IS NULL


# 右中图: B - (A ∩ B)
SELECT e.employee_id, e.last_name, e.department_id, d.department_name
FROM employees e RIGHT JOIN departments d
ON e.department_id = d.department_id
WHERE e.department_id IS NULL;  # 16 row, 从表的关联字段 IS NULL


# 左下图：满外连接 A ∪ B
# 实现方式1：左中图 + 右上图
SELECT e.employee_id, e.last_name, e.department_id, d.department_name
FROM employees e LEFT JOIN departments d
ON e.department_id = d.department_id
WHERE d.department_id IS NULL
UNION ALL
SELECT e.employee_id, e.last_name, e.department_id, d.department_name
FROM employees e RIGHT JOIN departments d
ON e.department_id = d.department_id;	# 123 rows

# 实现方式2：左上图 + 右中图
SELECT e.employee_id, e.last_name, e.department_id, d.department_name
FROM employees e LEFT JOIN departments d
ON e.department_id = d.department_id
UNION ALL
SELECT e.employee_id, e.last_name, e.department_id, d.department_name
FROM employees e RIGHT JOIN departments d
ON e.department_id = d.department_id
WHERE e.department_id IS NULL;	# 123 rows

# 实现方式3：左上图 + 右上图 并 去重
SELECT e.employee_id, e.last_name, e.department_id, d.department_name
FROM employees e LEFT JOIN departments d
ON e.department_id = d.department_id
UNION
SELECT e.employee_id, e.last_name, e.department_id, d.department_name
FROM employees e RIGHT JOIN departments d
ON e.department_id = d.department_id;	# 123 rows


# 右下图：
# 实现方式1：左中图 + 右中图
SELECT e.employee_id, e.last_name, e.department_id, d.department_name
FROM employees e LEFT JOIN departments d
ON e.department_id = d.department_id
WHERE d.department_id IS NULL
UNION ALL
SELECT e.employee_id, e.last_name, e.department_id, d.department_name
FROM employees e RIGHT JOIN departments d
ON e.department_id = d.department_id
WHERE e.department_id IS NULL;	# 17 rows


# 5.7.2 语法格式小结
# 左中图
# 实现：A - (A ∩ B)
#	SELECT 字段列表
#	FROM A表 LEFT JOIN B表
#	ON 关联条件
#	WHERE 从表关联字段 IS NULL AND 等其他子句;


# 右中图
# 实现：B - (A ∩ B)
#	SELECT 字段列表
#	FROM A表 RIGHT JOIN B表
#	ON 关联条件
#	WHERE 从表关联字段 IS NULL AND 等其他子句;


# 左下图
# 实现：A ∪ B
#	SELECT 字段列表
#	FROM A表 LEFT JOIN B表
#	ON 关联条件
#	WHERE 等其他子句
#	UNION
#	SELECT 字段列表
#	FROM A表 RIGHT JOIN B表
#	ON 关联条件
#	WHERE 等其他子句;


# 右下图
# 实现：A ∪ B - A ∩ B	或	(A - A ∩ B) + (B - A ∩ B)
#	SELECT 字段列表
#	FROM A表 LEFT JOIN B表
#	ON 关联条件
#	WHERE 从表关联字段 IS NULL AND 等其他子句;
#	UNION
#	SELECT 字段列表
#	FROM A表 RIGHT JOIN B表
#	ON 关联条件
#	WHERE 从表关联字段 IS NULL AND 等其他子句;


# 6. SQL99语法新特性
# 6.1 自然连接
#	SQL99使用 NATURAL JOIN 表示自然连接，
#	它可以理解成SQL中的等值连接，它会自动查询两张表中的所有相同的字段，然后进行等值连接

DESC employees;
DESC departments;

# SQL92：
SELECT e.employee_id, e.last_name, d.department_name
FROM employees e JOIN departments d
ON e.department_id = d.department_id
AND e.manager_id = d.manager_id;	# 32 rows

# SQL99
SELECT e.employee_id, e.last_name, d.department_name
FROM employees e NATURAL JOIN departments d;


# 6.2 USING连接
#	SQL99支持使用USING指定数据表里的同名字段进行等值连接
#	只能配合JOIN一起使用

SELECT e.employee_id, e.last_name, d.department_name
FROM employees e JOIN departments d
USING (department_id);	# 106 rows

# 和以下语句结果相同
SELECT e.employee_id, e.last_name, d.department_name
FROM employees e JOIN departments d
WHERE e.department_id = d.department_id;	# 106 rows


# 7. 章节小结
# 表连接的约束条件可以有三种方式：WHERE, ON, USING
#	WHERE:	适用于所有关联查询
#	ON:	只能和JOIN使用，只能写关联条件。虽然关联条件可以并到WHERE中和其他条件一起写，但分开写可读性更好
#	USING:	只能和JOIN使用，而且要求两个关联字段在关联表中名称一致，而且只能表示关联字段值相等

# 把关联条件写在where后面
SELECT e.last_name, d.department_name
FROM employees e, departments d
WHERE e.department_id = d.department_id;	# 106 rows

# 把条件写在ON后面，只能和JOIN一起使用
SELECT e.last_name, d.department_name
FROM employees e INNER JOIN departments d
ON e.department_id = d.department_id;	# 106 rows

SELECT e.last_name, d.department_name
FROM employees e CROSS JOIN departments d
ON e.department_id = d.department_id;	# 106 rows

SELECT e.last_name, d.department_name
FROM employees e JOIN departments d
ON e.department_id = d.department_id;	# 106 rows

# 把关联字段放在 USING() 中，只能和JOIN一起使用
# 且两个表中的关联字段必须名称相同，而且只能表示 =
SELECT e.last_name, j.job_title
FROM employees e INNER JOIN jobs j
USING (job_id);	# 107 rows

# n张表关联，需要n-1个关联条件
SELECT e.last_name, j.job_title, d.department_name
FROM employees e, jobs j, departments d
WHERE e.job_id = j.job_id AND e.department_id = d.department_id;	# 106 rows

SELECT e.last_name, j.job_title, d.department_name
FROM employees e INNER JOIN departments d ON e.department_id = d.department_id
INNER JOIN jobs j ON e.job_id = j.job_id;	# 106 rows

SELECT e.last_name, j.job_title, d.department_name
FROM employees e INNER JOIN departments d INNER JOIN jobs j
ON e.department_id = d.department_id AND e.job_id = j.job_id;	# 106 rows
