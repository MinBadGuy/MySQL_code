#第03章_基本的SELECT语句

# 创建数据库
CREATE DATABASE dbtest2;
# 查看数据库创建的方式
SHOW CREATE DATABASE dbtest2;

# 使用数据库
USE dbtest2;

# 创建表
CREATE TABLE emp(id INT, lname VARCHAR(20));
# 查看表创建的方式
SHOW CREATE TABLE emp;

# 查询表中所有数据
SELECT * FROM emp;

# 查询表结构
DESCRIBE emp;
DESC emp;

#######################################
USE atguigudb;


# 1. 基本SELECT语句：SELECT 字段1, 字段2, ... FROM 表名
SELECT 1;	# 1

SELECT 9/2;	# 4.5

SELECT 1, 9/2 FROM DUAL;	# DUAL：伪表

SELECT * FROM departments;	# * 表示表中所有的列

SELECT department_name, location_id FROM departments;	# 查询指定列


# 2. 表的别名：使用AS关键字，as表示 alias，AS可省略，但不建议
#    列的别名尽量使用""引起来，不要使用单引号''
SELECT employee_id AS emp_id, last_name lname, department_id "部门id", salary * 12 AS 'annual sal' FROM employees;


# 3. 去除重复行：使用DISTINCT关键字
SELECT DISTINCT department_id FROM employees;

# DISTINCT 需要放到所有列名的前面
SELECT salary, DISTINCT department_id FROM employees;	# 报错

# DISTINCT 是对后面所有列名的组合进行去重，以下是对department_id, salary两字段的组合去重
SELECT DISTINCT department_id, salary FROM employees;	# 没报错，但无意义


# 4. 空值参与运算
#    空值：null，不等同于0，''，'null'
#    遇到null，运算结果即为null
SELECT employee_id, salary AS "月薪", salary * (1 + commission_pct) * 12 AS "年薪", commission_pct FROM employees;

# 实际解决问题方案：引入IFNULL
SELECT employee_id, salary AS "月薪", salary * (1 + IFNULL(commission_pct, 0)) * 12 AS "年薪", commission_pct FROM employees;


# 5. 着重号``：避免与mysql的关键字冲突
USE dbtest2;
CREATE TABLE ORDER(id INT);	# 报错
CREATE TABLE `order`(id INT);


# 6. 查询常数
USE atguigudb;
SELECT "你好", 123, employee_id, last_name FROM employees;


# 7. 显示表结构
DESCRIBE employees;
DESC departments;


# 8. 过滤数据：where子句

# 查询90号部门的员工信息
SELECT * FROM employees WHERE department_id = 90;

# 查询部门为null的员工信息
# 使用 IS NULL
SELECT * FROM employees WHERE department_id IS NULL;

# 使用<=>
SELECT * FROM employees WHERE department_id <=> NULL;