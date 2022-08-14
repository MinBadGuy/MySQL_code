# 第11章_数据处理之增删改


# 1. 插入数据
# 1.1 实际问题
#	使用INSER语句向表中插入数据

# 1.2 方式1：VALUES的方式添加
/*
情况1：为表的所有字段按默认顺序插入数据
	INSERT INTO 表名
	VALUES(value1, value2, ...);
*/
CREATE DATABASE IF NOT EXISTS mytest11_1 CHARACTER SET 'utf8';
USE mytest11_1;

CREATE TABLE departments AS (SELECT * FROM atguigudb.departments);
SELECT * FROM departments;

INSERT INTO departments
VALUES(280, 'Pub', 100, 1700);

SELECT * FROM departments;

/*
情况2：为表的指定字段插入数据
	INSERT INTO 表名(column1[, column2, ..., columnn])
	VALUES(value1[, value2, ..., valuen]);
*/
INSERT INTO departments(department_id, department_name)
VALUES(290, 'IT');
SELECT * FROM departments;

/*
情况3：同时插入多条记录
	INSERT INTO 表名
	VALUES
	(value1[, value2, ..., valuen]),
	(value1[, value2, ..., valuen]),
	...
	(value1[, value2, ..., valuen]);

	INSERT INTO 表名(column1[, column2, ..., columnn])
	VALUES
	(value1[, value2, ..., valuen]),
	(value1[, value2, ..., valuen]),
	...
	(value1[, value2, ..., valuen]);
*/

CREATE TABLE IF NOT EXISTS emp(
emp_id INT,
emp_name VARCHAR(15),
salary DECIMAL(10, 2)
);

DESC emp;

INSERT INTO emp(emp_id, emp_name)
VALUES
(1001, 'Tom'),
(1002, 'Jerry'),
(1003, 'Jack');

SELECT * FROM emp;

# 1.3 方式2：将查询结果插入到表中
/*
	INSERT INTO 目标表名
	(tar_column1[, tar_column2, ..., tar_columnn])
	SELECT
	(src_column1[, src_column2, ..., src_columnn])
	FROM 源表名
	[WHERE condition]
*/
CREATE TABLE IF NOT EXISTS emp2 AS (SELECT * FROM atguigudb.employees WHERE 1=2);
SELECT * FROM emp2;
DESC emp2;

INSERT INTO emp2
SELECT * FROM atguigudb.employees;

CREATE TABLE IF NOT EXISTS sales_reps(
id INT,
NAME VARCHAR(20),
salary DOUBLE(8,2),
commission_pct DOUBLE(2,2)
);

SELECT * FROM sales_reps;

INSERT INTO sales_reps(id, NAME, salary, commission_pct)
SELECT employee_id, last_name, salary, commission_pct
FROM atguigudb.employees
WHERE job_id LIKE '%REP%';

SELECT * FROM sales_reps;

SELECT * FROM atguigudb.employees WHERE job_id LIKE '%REP%';


# 2. 更新数据
/*
使用UPDATE语句更新数据
	UPDATE 表名
	SET column1=value1, column2=value2, ..., columnn=valuen
	[WHERE condition];	# 若没有WHERE子句，将更新所有数据
	
	如果需要回滚数据，需要再DML前设置：SET AUTOCOMMIT=FALSE;
*/
CREATE TABLE IF NOT EXISTS employees AS (SELECT * FROM atguigudb.employees);
SELECT * FROM employees;

UPDATE employees SET department_id = 70 WHERE employee_id = 113;

CREATE TABLE IF NOT EXISTS copy_emp AS (SELECT * FROM employees);
SELECT * FROM copy_emp;

# 如果没有WHERE子句，将更新所有数据
UPDATE copy_emp SET department_id = 110;

# 更新中的数据完整性错误
# 	修改数据时，可能不成功，可能原因是约束的影响


# 3. 删除数据
/*
使用DELETE语句从表中删除数据
	DELETE FROM 表名
	[WHERE CONDITION];	# 若没有WHERE子句，将删除所有记录
*/
DELETE FROM departments
WHERE department_name = 'Finance';

SELECT * FROM departments;

DELETE FROM copy_emp;

SELECT * FROM copy_emp;

# 删除中的数据完整性错误
# 	删除数据时，可能不成功，可能原因是约束的影响


# 4. MySQL8新特性：计算列
#	计算列：某一列的值是通过别的列值计算得来的
#		column datetype GENERATED ALWAYS AS (expression) VIRTUAL
CREATE TABLE tb1(
id INT,
a INT,
b INT, 
c INT GENERATED ALWAYS AS (a+b) VIRTUAL
);

INSERT INTO tb1(a, b) VALUES (100, 200);
SELECT * FROM tb1;

UPDATE tb1 SET a = 500;
SELECT * FROM tb1;


# 5. 综合案例
# 1、创建数据库test01_library
CREATE DATABASE IF NOT EXISTS test01_library CHARACTER SET 'utf8';
USE test01_library;

# 2、创建表 books，表结构如下：
/*
	字段名		字段说明	数据类型
	id		书编号		INT
	name 		书名 		VARCHAR(50)
	authors 	作者		VARCHAR(100)
	price		价格		FLOAT
	pubdate 	出版日期	YEAR
	note		说明		VARCHAR(100)
	num		库存		INT
*/
CREATE TABLE IF NOT EXISTS books(
id INT,
`name` VARCHAR(50),
`authors` VARCHAR(100),
price FLOAT,
pubdate YEAR,
note VARCHAR(100),
num INT
);

# 3、向books表中插入记录
/* 
	1）不指定字段名称，插入第一条记录
	2）指定所有字段名称，插入第二记录
	3）同时插入多条记录（剩下的所有记录）
	
	id	name		authors			price	pubdate		note		num
	1 	Tal of AAA 	Dickes 			23 	1995 		novel 		11
	2 	EmmaT 		Jane lura 		35 	1993 		joke 		22
	3 	Story of Jane 	Jane Tim 		40 	2001 		novel 		0
	4 	Lovey Day 	George Byron 		20 	2005 		novel 		30
	5 	Old land 	Honore Blade 		30 	2010 		law 		0
	6 	The Battle 	Upton Sara 		30 	1999 		medicine 	40
	7 	Rose Hood 	Richard haggard 	28 	2008 		cartoon 	28
*/
INSERT INTO books
VALUES(1, 'Tal of AAA', 'Dickes', 23, 1995, 'novel', 11);

INSERT INTO books(id, `name`, `authors`, price, pubdate, note, num)
VALUES(2, 'EmmaT', 'Jane lura', 35, 1993, 'joke', 22);

INSERT INTO books
VALUES
(3, 'Story of Jane', 'Jane Tim', 40, 2001, 'novel', 0),
(4, 'Lovey Day', 'George Byron', 20, 2005, 'novel', 30),
(5, 'Old land', 'Honore Blade',	30, 2010, 'law', 0),
(6, 'The Battle', 'Upton Sara', 30, 1999, 'medicine', 40),
(7, 'Rose Hood', 'Richard haggard', 28, 2008, 'cartoon',28);

SELECT * FROM books;

# 4、将小说类型(novel)的书的价格都增加5
UPDATE books
SET price = price + 5
WHERE note = 'novel';

# 5、将名称为EmmaT的书的价格改为40，并将说明改为drama
UPDATE books
SET price = 40, note = 'drama'
WHERE `name` = 'EmmaT';

# 6、删除库存为0的记录
DELETE FROM books
WHERE num = 0;

# 7、统计书名中包含a字母的书
SELECT *
FROM books
WHERE `name` LIKE '%a%';

# 8、统计书名中包含a字母的书的数量和库存总量
SELECT COUNT(*), SUM(num)
FROM books
WHERE `name` LIKE '%a%';

# 9、找出“novel”类型的书，按照价格降序排列
SELECT * 
FROM books
WHERE note = 'novel'
ORDER BY price DESC;

# 10、查询图书信息，按照库存量降序排列，如果库存量相同的按照note升序排列
SELECT * 
FROM books
ORDER BY num DESC, note ASC;

# 11、按照note分类统计书的数量
SELECT note, COUNT(*)
FROM books
GROUP BY note;

# 12、按照note分类统计书的库存量，显示库存量超过30本的
SELECT note, SUM(num)
FROM books
GROUP BY note HAVING SUM(num) > 30;

# 13、查询所有图书，每页显示5本，显示第二页
SELECT * 
FROM books
LIMIT 5, 5;

# 14、按照note分类统计书的库存量，显示库存量最多的
SELECT note, SUM(num)
FROM books
GROUP BY note
ORDER BY SUM(num) DESC
LIMIT 0, 1;

# 15、查询书名达到10个字符的书，不包括里面的空格
# 错误，LENGTH是返回字符串的字节数，CHAR_LENGTH才是返回字符串的字符数
SELECT * FROM books WHERE LENGTH(REPLACE(`name`, ' ', '')) >= 10;

SELECT * FROM books WHERE CHAR_LENGTH(REPLACE(`name`,' ',''))>=10;

# 16、查询书名和类型，其中note值为novel显示小说，law显示法律，medicine显示医药，cartoon显示卡通，joke显示笑话
SELECT `name`, note, CASE note 
WHEN 'novel' 	THEN '小说'
WHEN 'law'   	THEN '法律'
WHEN 'medicine' THEN '医药'
WHEN 'cartoon'  THEN '卡通'
WHEN 'joke'	THEN '笑话'
END AS "类型"
FROM books;

# 17、查询书名、库存，其中num值超过30本的，显示滞销，大于0并低于10的，显示畅销，为0的显示需要无货
SELECT `name`, num, CASE 
WHEN num > 30 THEN "滞销"
WHEN num > 0 AND num < 10 THEN "畅销"
WHEN num = 0 THEN "无货"
END
FROM books;

# 18、统计每一种note的库存量，并合计总量
SELECT note SUM(num)
FROM books
GROUP BY note WITH ROLLUP;

# 19、统计每一种note的数量，并合计总量
SELECT note, COUNT(*)
FROM books
GROUP BY note WITH ROLLUP;

# 20、统计库存量前三名的图书
SELECT *
FROM books
ORDER BY num DESC
LIMIT 0, 3;

# 21、找出最早出版的一本书
SELECT *
FROM books
ORDER BY pubdate
LIMIT 0, 1;

# 22、找出novel中价格最高的一本书
SELECT *
FROM books
WHERE note = 'novel'
ORDER BY price DESC
LIMIT 0, 1;

# 23、找出书名中字数最多的一本书，不含空格
SELECT * 
FROM books
ORDER BY CHAR_LENGTH(REPLACE(`name`, ' ', '')) DESC
LIMIT 0, 1;
