# 第17章_触发器

# 1. 触发器概述
/*
触发器是由事件来触发某个操作，这些事件包括INSERT, UPDATE, DELETE事件。
所谓事件就是指用户的动作或者触发某些行为。
如果定义了触发程序，当数据库执行这些语句时候，就相当于事件发生了，就会自动激发触发器执行相应的操作。

触发器的目的是为了保证数据的完整性，确保两个关联的操作称为一个原子操作。
*/

# 2. 触发器的创建
# 2.1 创建触发器语法
/*
语法：
	CREATE TRIGGER 触发器名称
	{BEFORE | AFTER} {INSERT | UPDATE | DELETE} ON 表名
	FOR EACH ROW
	触发器执行的语句块;

说明：
	- 表名：表示触发器监控的对象
	- BEFORE | AFTER：表示触发时间
	- INSERT | UPDATE | DELETE：表示触发的事件
	- 触发器执行的语句块：可以是单条SQL语句，也可以是由BEGIN...END结构组成的复合语句块
*/

# 2.2 代码举例
# 举例1：
# 1、创建数据表
CREATE DATABASE dbtest17;
USE dbtest17;

CREATE TABLE test_trigger(
id INT PRIMARY KEY AUTO_INCREMENT,
t_note VARCHAR(30)
);

CREATE TABLE test_trigger_log(
id INT PRIMARY KEY AUTO_INCREMENT,
t_log VARCHAR(30)
);

# 2、创建触发器：创建名称为before_insert的触发器，向test_trigger数据表插入数据之前，向
# test_trigger_log数据表中插入before_insert的日志信息
CREATE TRIGGER before_insert
BEFORE INSERT ON test_trigger
FOR EACH ROW
INSERT INTO test_trigger_log(t_log) VALUES ('before_insert');

# 3、向test_trigger数据表中插入数据
INSERT INTO test_trigger(t_note) VALUES ('测试 BEFORE INSERT 触发器');

# 4、查看test_trigger_log数据表中的数据
SELECT * FROM test_trigger_log;

# 举例2：
# 1、创建名称为after_insert的触发器，向test_trigger数据表插入数据之后，向test_trigger_log数据表中插
# 入after_insert的日志信息
CREATE TRIGGER after_insert
AFTER INSERT ON test_trigger
FOR EACH ROW
INSERT INTO test_trigger_log(t_log) VALUES('after_insert');

# 2、向test_trigger数据表中插入数据
INSERT INTO test_trigger(t_note) VALUES('测试 AFTER INSERT 触发器');

# 3、查看test_trigger_log数据表中的数据
SELECT * FROM test_trigger_log;

# 举例3：定义触发器“salary_check_trigger”，基于员工表“employees”的INSERT事件，在INSERT之前检查
# 将要添加的新员工薪资是否大于他领导的薪资，如果大于领导薪资，则报sqlstate_value为'HY000'的错
# 误，从而使得添加失败
CREATE TABLE employees AS
SELECT * FROM atguigudb.employees;

DELIMITER //

CREATE TRIGGER salary_check_trigger
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
	DECLARE mgr_sal DOUBLE;
	SELECT salary INTO mgr_sal FROM employees WHERE employee_id = new.manager_id;
	
	IF new.salary > mgr_sal THEN
		SIGNAL SQLSTATE 'HY000' SET MESSAGE_TEXT = '薪资高于领导薪资错误';
	END IF;
END //

DELIMITER ;

# 3. 查看、删除触发器
# 3.1 查看触发器
/*
方式1：查看当前数据库的所有触发器定义
	SHOW TRIGGERS

方式2：查看当前数据库中某个触发器的定义
	SHOW CREATE TRIGGER 触发器名

方式3：从系统库information_schema的TRIGGERS表中查询触发器的信息
	SELECT * FROM information_schema.triggers;
*/
SHOW TRIGGERS;

SHOW CREATE TRIGGER before_insert;

SELECT * FROM information_schema.triggers;

# 3.2 删除触发器
/*
语法：
	DROP TRIGGER IF EXISTS 触发器名称;
*/

# 4. 触发器的优缺点
# 4.1 优点
/*
- 确保数据的完整性
- 用来记录操作日志
- 用在操作数据前对数据进行合法性检查
*/

# 4.2 缺点
/*
- 可读性差
- 相关数据的变更可能会导致触发器出错
*/

# 4.3 注意点
/*
当存在外键约束时，并且在子表上定义了一个触发器，
对父表进行修改或删除操作，导致子表发生了相应的改变，但并不会引发触发器动作，
只有是直接对子表进行相关操作，才会引发触发器动作。
*/





