# 第14章_视图


# 1. 常见的数据库对象
/*
	表
	数据字典
	约束
	视图
	索引
	存储过程
	存储函数
	触发器
*/

# 2. 视图概述
# 2.1 为什么使用视图？

# 2.2 视图的理解
/*
	视图是一种虚拟表，本身不具有数据，占用很少的内存空间
	视图建立在已有表的基础上，视图赖以建立的这些表称为基表
	视图的创建和删除只影响视图本身，不影响对应的基表，但对视图中的数据进行增加、删除和修改操作时，数据表中的数据会相应地发生变化，反之亦然
	向视图提供数据内容的语句为SELECT语句，可以将视图理解成存储起来的SELECT语句
	视图是向用户提供基表数据的另一种表现形式，可以帮我们把经常查询的结果集放到虚拟表中，提升使用效率
*/

# 3. 创建视图
/*
在 CREATE VIEW 语句中嵌入子查询
	CREATE [OR REPLACE]
	[ALGORITHM = {UNDEFINED | MERGE | TEMPTABLE}]
	VIEW 视图名称 [(字段列表)]
	AS 查询语句
	[WITH [CASCADED | LOCAL] CHECK OPTION]
	
精简版：
	CREATE VIEW 视图名称
	AS 查询语句
*/

# 3.1 创建单表视图
CREATE DATABASE dbtest14;
USE dbtest14;

CREATE TABLE employees AS SELECT * FROM atguigudb.employees;
SELECT * FROM employees;

CREATE VIEW empvu80
AS
SELECT employee_id, last_name, salary 
FROM employees 
WHERE department_id = 80;

SELECT * FROM empvu80;

CREATE VIEW emp_year_salary(ename, year_salary)
AS
SELECT last_name, salary * 12 * (1+IFNULL(commission_pct, 0)) FROM employees;

SELECT * FROM emp_year_salary;

CREATE VIEW salvu50
AS
SELECT employee_id ID_NUMBER, last_name NAME, salary * 12 ANN_SALARY
FROM employees
WHERE department_id = 50;

SELECT * FROM salvu50;
/*
说明1：
	在查询语句的基础上封装了视图VIEW，这样就会基于SQL语句的结果集形成一张虚拟表
说明2：
	在创建视图时，如果没在视图名后面指定字段列表，则视图中字段列表默认和SELECT语句中的字段列表一致，
	如果SELECT语句中给字段取了别名，那么视图中的字段名和别名相同
*/

# 3.2 创建多表联合视图
CREATE TABLE departments AS SELECT * FROM atguigudb.departments;

CREATE VIEW empview
AS
SELECT employee_id emp_id, last_name NAME, department_name
FROM employees e, departments d
WHERE e.department_id = d.department_id;

SELECT * FROM empview;

CREATE VIEW emp_dept
AS
SELECT last_name, department_name
FROM employees e LEFT JOIN departments d
ON e.department_id = d.department_id;

SELECT * FROM emp_dept;

CREATE VIEW dept_sum_vu(NAME, minsal, maxsal, avgsal)
AS
SELECT d.department_name, MIN(e.salary), MAX(e.salary), AVG(e.salary)
FROM employees e, departments d
WHERE e.department_id = d.department_id
GROUP BY d.department_name;

SELECT * FROM dept_sum_vu;

# 利用视图对数据进行格式化
CREATE VIEW emp_depart
AS
SELECT CONCAT(e.last_name, '(', d.department_name, ')')
FROM employees e, departments d
WHERE e.department_id = d.department_id;

SELECT * FROM emp_depart;

# 3.3 基于视图创建视图
CREATE VIEW emp_dept_ysalary
AS
SELECT e1.last_name, e1.department_name, e2.year_salary
FROM emp_dept e1, emp_year_salary e2
WHERE e1.last_name = e2.ename;

SELECT * FROM emp_dept_ysalary;


# 4. 查看视图
/*
(1) 查看数据库的表对象、视图对象
	SHOW TABLES;
	
(2) 查看视图的结构
	DESC/DESCRIBE 视图名称;
	
(3) 查看视图的属性信息
	# 查看视图信息（显示数据表的存储引擎、版本、数据行数和数据大小）
	SHOW TABLE STATUS LIKE '视图名称';
	
	执行结果显示，注释Comment为VIEW，说明该表为视图，其他的信息为NULL，说明这是一个虚表
	
(4) 查看视图的详细定义信息
	SHOW CREATE VIEW 视图名称;
*/
SHOW TABLES;

DESC emp_dept_ysalary;

SHOW TABLE STATUS LIKE 'emp_dept_ysalary';
SHOW TABLE STATUS LIKE 'employees';

SHOW CREATE VIEW emp_dept_ysalary;

# 5. 更新视图的数据
# 5.1 一般情况
/*
	MySQL支持使用INSERT、UPDATE、DELETE语句对视图中的数据进行插入、更新和删除操作
	当视图中的数据发生变化时，数据表中的数据也会发生变化，反之亦然
*/
SELECT * FROM empvu80 WHERE last_name = 'Hall';
SELECT * FROM employees WHERE last_name = 'Hall';

UPDATE empvu80 SET salary = 10000 WHERE last_name = 'Hall';

DELETE FROM empvu80 WHERE last_name = 'Hall';

# 5.2 不可更新的视图
/*
要使视图可更新，视图中的行和底层基本表中的行之间必须存在 一对一 的关系。另外当视图定义出现如
下情况时，视图不支持更新操作：
	在定义视图的时候指定了“ALGORITHM = TEMPTABLE”，视图将不支持INSERT和DELETE操作；
	视图中不包含基表中所有被定义为非空又未指定默认值的列，视图将不支持INSERT操作；
	在定义视图的SELECT语句中使用了 JOIN联合查询 ，视图将不支持INSERT和DELETE操作；
	在定义视图的SELECT语句后的字段列表中使用了 数学表达式 或 子查询 ，视图将不支持INSERT，也不支持UPDATE使用了数学表达式、子查询的字段值；
	在定义视图的SELECT语句后的字段列表中使用 DISTINCT 、 聚合函数 、 GROUP BY 、 HAVING 、UNION 等，视图将不支持INSERT、UPDATE、DELETE；
	在定义视图的SELECT语句中包含了子查询，而子查询中引用了FROM后面的表，视图将不支持INSERT、UPDATE、DELETE；
	视图定义基于一个 不可更新视图 ；
	常量视图。
*/
SELECT * FROM employees;
SELECT * FROM departments;

CREATE OR REPLACE VIEW emp_dept(ename, salary, tel, email, hiredate, dname)
AS
SELECT e.last_name, e.salary, e.phone_number, e.email, e.hire_date, d.department_name
FROM employees e INNER JOIN departments d
ON e.department_id = d.department_id;

SELECT * FROM emp_dept;

# 错误代码： 1393	Can not modify more than one base table through a join view 'dbtest14.emp_dept'
# 视图定义中使用了JOIN联合查询，不支持更新
INSERT INTO emp_dept(ename, salary, tel, email, hiredate, dname)
VALUES('张三', 15000, '18201587896', 'zs@163.com', '2020-05-15', '工程部');

/*
小结：
	虽然可以更新视图数据，但总的来说，视图作为虚拟表，主要用于方便查询，不建议更新视图的数据。
	对视图数据的更改，都是通过对实际数据表里数据的操作来完成的。
*/

# 6. 修改、删除视图
# 6.1 修改视图
# 方式1：使用 CREATE OR REPLACE VIEW 子句修改视图
CREATE OR REPLACE VIEW empvu80(id_number, NAME, sal, department_id)
AS
SELECT employee_id, last_name, salary, department_id
FROM employees
WHERE department_id = 80; 

SELECT * FROM empvu80;

# 方式2：ALTER VIEW
# ALTER VIEW 视图名称 AS 查询语句

# 6.2 删除视图
/*
	删除视图只是删除视图的定义，并不会删除基表的数据
	语法：
		DROP VIEW IF EXISTS 视图名称;
		
		DROP VIEW IF EXISTS 视图名称1, 视图名称2, ..., 视图名称n;
	说明：
		基于视图a、b创建了新的视图c，如果将视图a或者视图b删除，会导致视图c的查询失败，
		这样的视图c需要手动删除或修改，否则影响使用。
*/
DROP VIEW IF EXISTS empvu80;


# 7. 总结
# 7.1 视图优点
/*
	操作简单
	减少数据冗余
	数据安全
	适应灵活多变的需求
	能够分解复杂的查询逻辑
*/

# 7.2 视图不足
/*
	如果实际数据表的结构变更了，需要及时对相关视图进行维护，视图过多、嵌套视图的维护成本高
*/