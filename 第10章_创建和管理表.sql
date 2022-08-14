# 第10章_创建和管理表


# 1. 基础知识
# 1.1 一条数据的存储过程
# 	创建数据库	确认字段	创建数据表	插入数据

# 1.2 标识符命名规则

# 1.3 MySQL中的数据类型


# 2. 创建和管理数据库
# 2.1 创建数据库
/*
方式1：创建数据库
	CREATE DATABASE 数据库名;
方式2：创建数据库并指定字符集
	CREATE DATABASE 数据库名 CHARACTER SET 字符集;
方式3：判断数据库是否已经存在，不存在则创建数据库（推荐）
	CREATE DATABASE IF NOT EXISTS 数据库名;

注意：DATABASE不能改名。一些可视化工具可以改名，它是新建库，把所有表复制到新库，再删除旧库完成的
*/
CREATE DATABASE mytest10_1;

CREATE DATABASE mytest10_2 CHARACTER SET 'utf8';

CREATE DATABASE IF NOT EXISTS mytest10_3 CHARACTER SET 'utf8';

# 2.2 使用数据库
/*
# 查看当前所有的数据库
	SHOW DATABASES;	# 有一个S，代表多个数据库

# 查看当前正在使用的数据库
	SELECT DATABASE();	# mysql中的一个全局函数

# 查看当前数据库中保存的数据表
	SHOW TABLES;

# 查看指定库下所有的表
	SHOW TABLES FROM 数据库名;

# 查看数据库的创建信息
	SHOW CREATE DATABASE 数据库名;
	或者
	SHOW CREATE DATABASE 数据库名\G

# 使用/切换数据库
	USE 数据库名;

注意：要操作表格和数据之前必须先说明是对哪个数据库进行操作，否则就要对所有对象加上"数据库名."
*/
SHOW DATABASES;

SELECT DATABASE();

SHOW TABLES;

SHOW TABLES FROM atguigudb;

SHOW CREATE DATABASE mytest10_1;
SHOW CREATE DATABASE mytest10_3;

USE mytest10_3;

# 2.3 修改数据库
/*
# 更改数据库字符集
	ALTER DATABASE 数据库名 CHARACTER SET 字符集;	# 比如：gbk, utf8等
*/
ALTER DATABASE mytest10_3 CHARACTER SET 'gbk';
SHOW CREATE DATABASE mytest10_3;

# 2.4 删除数据库
/*
方式1：删除指定的数据库
	DROP DATABASE 数据库名;
方式2：删除指定的数据库（推荐）
	DROP DATABASE IF EXISTS 数据库名;
*/
DROP DATABASE mytest10_1;
DROP DATABASE IF EXISTS mytest10_2;


# 3. 创建表
# 3.1 创建方式1
/*
# 必须具备：
	CREATE TABLE 权限
	存储空间

# 语法格式：
	CREATE TABLE [IF NOT EXISTS] 表名(
	字段1 数据类型 [约束条件] [默认值],
	字段2 数据类型 [约束条件] [默认值],
	字段3 数据类型 [约束条件] [默认值],
	...
	[表约束条件]
	);

# 必须指定：
	表名
	列名（或字段名），数据类型，长度

# 可选指定：
	约束条件
	默认值
*/
CREATE TABLE emp(
emp_id INT,
emp_name VARCHAR(20),
salary DOUBLE,
birthday DATE
);

DESC emp;

CREATE TABLE emp2(
# INT类型，自增
deptno INT(2) AUTO_INCREMENT,
dname VARCHAR(14),
loc VARCHAR(13),
# 逐渐
PRIMARY KEY(deptno)
);

DESC emp2;

# 3.2 创建方式2
/*
使用 AS subquery 选项，将创建表和插入数据结合起来
	CREATE TABLE table
	[(column, column, ...)]
	AS subquery;

指定的列和子查询中的列要一一对应

通过列名和默认值定义列
*/
USE atguigudb;

CREATE TABLE emp1 AS (SELECT * FROM employees);

CREATE TABLE emp2 AS (SELECT * FROM employees WHERE 1 = 2);	# emp2是空表

CREATE TABLE dept80 AS (
			SELECT employee_id, last_name, salary * 12 ANNSAL, hire_date
			FROM employees
			WHERE department_id = 80
			);

DESC dept80;

# 3.3 查看数据表结构
/*
DESCRIBE/DESC 表名;

SHOW CREATE TABLE 表名;
*/
SHOW CREATE TABLE dept80;


# 4. 修改表
# 4.1 追加一个列
/*
语法：
	ALTER TABLE 表名 ADD [COLUMN] 字段名 字段类型 [FIRST/AFTER 字段名];
*/
ALTER TABLE dept80 
ADD COLUMN job_id VARCHAR(15);

SELECT * FROM dept80;

# 4.2 修改一个列
/*
可以修改列的数据类型、长度、默认值和位置
语法：
	ALTER TABLE 表名 MODIFY [COLUMN] 字段名1 字段类型 [DEFAULT 默认值] [FIRST|AFTER 字段名2];
*/
ALTER TABLE dept80
MODIFY COLUMN last_name VARCHAR(30);

DESC dept80;

ALTER TABLE dept80
MODIFY COLUMN ANNSAL DOUBLE(9,3) DEFAULT 1000;

# 4.3 重命名一个列
/*
语法：
	ALTER TABLE 表名 CHANGE [COLUMN] 列名 新列名 新数据类型;
*/

ALTER TABLE dept80
CHANGE COLUMN last_name lname VARCHAR(25);

# 4.4 删除一个列
/*
语法：
	ALTER TABLE 表名 DROP [COLUMN] 列名;
*/
ALTER TABLE dept80
DROP COLUMN job_id;


# 5. 重命名表
# 方式1：使用RENAME
RENAME TABLE dept80 TO dept80_1;

# 方式2：
ALTER TABLE dept80_1 RENAME TO dept80_2;
ALTER TABLE dept80_2 RENAME dept80_3;


# 6. 删除表
/*
语法：
	DROP TABLE [IF EXISTS] 数据表1 [, 数据表2, ..., 数据表n];
作用：
	删除数据和表结构
注意：
	DROP TABLE语句不能回滚
*/
DROP TABLE IF EXISTS dept80_3;


# 7. 清空表
/*
语法：
	TRUNCATE TABLE 表名;
作用：
	删除表中所有数据，保留表结构

TRUNCATE 和 DELETE 的对比：
	① TRUNCATE语句不能回滚，DELETE可以回滚（ROLLBACK）、
	② TRUNCATE TABLE 比 DELETE 速度快，且使用的系统和事务日志资源少，
	  但 TRUNCATE 无事务且不触发 TRIGGER，有可能造成事故，故不建议在开发代码中使用此语句
	③ TRUNCATE TABLE 在功能上与不带 WHERE 子句的 DELETE 语句相同
*/
SET autocommit = FALSE;
DELETE FROM emp1;
SELECT * FROM emp1;	# 表中无数据
ROLLBACK;		# 回滚
SELECT * FROM emp1;	# 表中有数据


# 拓展：MySQL8新特性——DDL的原子化
# 在MySQL 8.0版本中，InnoDB表的DDL支持事务完整性，即 DDL操作要么成功要么回滚
USE mytest10_3;

CREATE TABLE book1(
book_id INT,
book_name VARCHAR(255)
);

SHOW TABLES;

# Unknown table 'mytest10_3.book2'
DROP TABLE book1, book2;

SHOW TABLES;	# book1并未被删除