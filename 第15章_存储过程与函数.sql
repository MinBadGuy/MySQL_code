# 第15章_存储过程与函数


# 1. 存储过程概述
# 1.1 理解
# 一组经过预先编译的SQL语句的封装
# 存储过程没有返回值

# 1.2 分类
# 参数类型：IN, OUT, INOUT


# 2. 创建存储过程
# 2.1 语法分析
/*
语法：
	CREATE PROCEDURE 存储过程名(IN|OUT|INOUT 参数名 参数类型, ...)
	[characteristics ...]
	BEGIN
		存储过程体
	END

说明：
1. 参数
	IN:	输入参数，存储过程读取该参数的值。参数默认类型为IN
	OUT：	输出参数，经存储过程处理后，应用程序可以读取该参数值
	INOUT：	既可以作为输入参数，也可以作为输出参数
	
2. characteristics 表示创建存储过程时指定的约束条件，取值信息如下：
	LANGUAGE SQL
	| [NOT] DETERMINISTIC
	| { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
	| SQL SECURITY { DEFINER | INVOKER }
	| COMMENT 'string'
	
	LANGUAGE SQL：
		说明存储过程由SQL语句组成
	[NOT] DETERMINISTIC：
		指明存储过程执行的结果是否确定，默认 NOT DETERMINISTIC
	{ CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }：
		指明子程序使用SQL语句的限制
		CONTAINS SQL表示当前存储过程的子程序包含SQL语句，但是并不包含读写数据的SQL语句；
		NO SQL表示当前存储过程的子程序中不包含任何SQL语句；
		READS SQL DATA表示当前存储过程的子程序中包含读数据的SQL语句；
		MODIFIES SQL DATA表示当前存储过程的子程序中包含写数据的SQL语句。
		默认情况下，系统会指定为CONTAINS SQL。
	SQL SECURITY { DEFINER | INVOKER }：
		指明执行当前存储过程的权限，默认指定值为DEFINER
		DEFINER：表示只有当前存储过程的创建者或者定义者才能执行当前存储过程；
		INVOKER：表示拥有当前存储过程的访问权限的用户能够执行当前存储过程。
	
	COMMENT 'string'：
		注释信息

3. 存储过程中的SQL语句需要放在 BEGIN ... END 中
	1. BEGIN…END：BEGIN…END 中间包含了多个语句，每个语句都以（;）号为结束符。
	2. DECLARE：DECLARE 用来声明变量，使用的位置在于 BEGIN…END 语句中间，而且需要在其他语句使用之前进行变量的声明。
	3. SET：赋值语句，用于对变量进行赋值。
	4. SELECT… INTO：把从数据表中查询的结果存放到变量中，也就是为变量赋值。

4. 需要设置新的结束标记
	DELIMITER 新的结束标记

示例：
	DELIMITER //

	CREATE PROCEDURE 存储过程名(IN|OUT|INOUT 参数名 数据类型, ...)
	[characteristics ...]
	BEGIN
		sql语句1;
		sql语句2;
	END //
	
	DELIMITER ;

*/

# 2.2 代码举例
CREATE DATABASE IF NOT EXISTS dbtest15 CHARACTER SET 'utf8';
USE dbtest15;

CREATE TABLE emps AS SELECT * FROM atguigudb.employees; 

# 举例1：创建存储过程select_all_data()，查看emps表的所有数据
DELIMITER //
CREATE PROCEDURE select_all_data()
BEGIN
	SELECT * FROM emps;
END //
DELIMITER ;


# 举例2：创建存储过程avg_employee_salary()，返回所有员工的平均工资
DELIMITER //
CREATE PROCEDURE avg_employee_salary()
BEGIN
	SELECT AVG(salary) FROM emps;
END //
DELIMITER ;


# 举例3：创建存储过程show_max_salary()，用来查看“emps”表的最高薪资值
DELIMITER //
CREATE PROCEDURE show_max_salary()
BEGIN
	SELECT MAX(salary) FROM emps;
END //
DELIMITER ;


# 举例4：创建存储过程show_min_salary()，查看“emps”表的最低薪资值。并将最低薪资通过OUT参数“ms”输出
DESC emps;

DELIMITER //
CREATE PROCEDURE show_min_salary(OUT ms DOUBLE)
BEGIN
	SELECT MIN(salary) INTO ms FROM emps;
END //
DELIMITER ;


# 举例5：创建存储过程show_someone_salary()，查看“emps”表的某个员工的薪资，并用IN参数empname输入员工姓名
DELIMITER //
CREATE PROCEDURE show_someone_salary(IN empname VARCHAR(25))
BEGIN
	SELECT salary FROM emps WHERE last_name = empname;
END //
DELIMITER ;


# 举例6：创建存储过程show_someone_salary2()，查看“emps”表的某个员工的薪资，并用IN参数empname输入员工姓名，用OUT参数empsalary输出员工薪资
DELIMITER //
CREATE PROCEDURE show_someone_salary2(IN empname VARCHAR(25), OUT empsalary DOUBLE)
BEGIN
	SELECT salary INTO empsalary FROM emps WHERE last_name = empname;
END //
DELIMITER ;


# 举例7：创建存储过程show_mgr_name()，查询某个员工领导的姓名，并用INOUT参数“empname”输入员工姓名，输出领导的姓名
DELIMITER //
CREATE PROCEDURE show_mgr_name(INOUT empname VARCHAR(25))
BEGIN
	SELECT last_name INTO empname FROM emps
	WHERE employee_id = (SELECT manager_id FROM emps WHERE last_name = empname);
END //
DELIMITER ;


# 3. 调用存储过程
# 3.1 调用格式
/*
	CALL 存储过程名(实参列表);
	
	若要执行其他数据库中的存储过程，需要指明数据库名：
	CALL dbname.procname;


调用IN模式的参数：
	CALL procname('值');
调用OUT模式的参数：
	SET @name;
	CALL procname(@name);
	SELECT @name;
调用INOUT模式的参数
	SET @name=值;
	CALL procname(@name);
	SELECT @name;	
*/

# 3.2 代码举例
# 2.2节中举例1
CALL select_all_data();

# 2.2节中举例2
CALL avg_employee_salary();

# 2.2节中举例3
CALL show_max_salary();

# 2.2节中举例4
SET @ms;
CALL show_min_salary(@ms);
SELECT @ms;

# 2.2节中举例5
SET @empname='Abel';
CALL show_someone_salary(@empname);

# 2.2节中举例6
SET @empname='Abel';
SET @empsalary;
CALL show_someone_salary2(@empname, @empsalary);
SELECT @empname, @empsalary;

# 2.2节中举例7
SET @empname='Abel';
CALL show_mgr_name(@empname);
SELECT @empname;

# 举例8：创建存储过程，实现累加运算，计算 1+2+…+n 等于多少
DELIMITER //
CREATE PROCEDURE add_num(IN n INT)
BEGIN
	DECLARE i INT;
	DECLARE `sum` INT;
	SET i = 1;
	SET `sum` = 0;
	
	WHILE i <= n DO
		SET `sum` = `sum` + i;
		SET i = i + 1;
	END WHILE;
	
	SELECT `sum`;
END //
DELIMITER ;

CALL add_num(50);


# 3.3 如何调试
# 通过SELECT语句把程序的中间结果查询出来，来调试一个SQL语句的正确性


# 4. 存储函数的使用
# 4.1 语法分析
/*
语法格式：
	CREATE FUNCTION 函数名(参数名 参数类型, ...)
	RETURNS 返回值类型
	[characteristics ...]
	BEGIN
		函数体	# 函数体中肯定有 RETURN 语句
	END

说明：
	1. 参数列表：指定参数为 IN, OUT 或 INOUT 只对PROCEDURE是合法的，FUNCTION中总是默认为IN参数
	2. RETURNS type 语句表示函数返回数据的类型
	3. characteristic 创建函数时指定对函数的约束，取值与存储过程相同
	4. 函数体也用 BEGIN...END 来表示SQL代码的开始和结束
*/

# 4.2 调用存储函数
# 	SELECT 函数名(实参列表)

# 4.3 代码举例
/*
注意：
	若在创建存储函数中报错“ you might want to use the less safe log_bin_trust_function_creators variable ”，有两种处理方法：
	- 方式1：加上必要的函数特性“[NOT] DETERMINISTIC”和“{CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA}”
	- 方式2：SET GLOBAL log_bin_trust_function_creators = 1;
*/


# 举例1：创建存储函数，名称为email_by_name()，参数定义为空，该函数查询Abel的email，并返回，数据类型为字符串型
SET GLOBAL log_bin_trust_function_creators = 1;

DESC emps;

DELIMITER //

CREATE FUNCTION email_by_name()
RETURNS VARCHAR(25)
BEGIN
	RETURN (SELECT email FROM emps WHERE last_name = 'Abel');
END //

DELIMITER ;

SELECT email_by_name();


# 举例2：创建存储函数，名称为email_by_id()，参数传入emp_id，该函数查询emp_id的email，并返回，数据类型为字符串型
DELIMITER //

CREATE FUNCTION email_by_id(emp_id INT)
RETURNS VARCHAR(25)
BEGIN
	RETURN (SELECT email FROM emps WHERE employee_id = emp_id);
END //

DELIMITER ;

SELECT email_by_id(100);


# 举例3：创建存储函数count_by_id()，参数传入dept_id，该函数查询dept_id部门的员工人数，并返回，数据类型为整型
DELIMITER //

CREATE FUNCTION count_by_id(dept_id INT)
RETURNS INT
BEGIN
	RETURN (SELECT COUNT(*) FROM emps WHERE department_id = dept_id);
END //

DELIMITER ;

SELECT count_by_id(100);

# 4.4 对比存储函数和存储过程
/*
		关键字		调用语法		返回值			应用场景
存储过程	PROCEDURE	CALL存储过程()		理解为有0个或多个	一般用于更新
存储函数	FUNCTION	SELECT存储函数()	只能是一个		一般用于查询结果为一个值并返回时

存储函数可以放在查询语句中使用，存储过程不行
*/


# 5. 存储过程和函数的查看、修改、删除
# 5.1 查看
/*
1. 使用 SHOW CREATE 语句查看存储过程和函数的创建信息
语法：
	SHOW CREATE {PROCEDURE | FUNCTION} 存储过程或函数名
*/
SHOW CREATE PROCEDURE avg_employee_salary;

SHOW CREATE FUNCTION count_by_id;

/*
2. 使用 SHOW STATUS 语句查看存储过程和函数的状态信息
语法：
	SHOW {PROCEDURE | FUNCTION} STATUS [LIKE 'PATTERN']
*/
SHOW PROCEDURE STATUS LIKE 'avg_employee_salary';

SHOW PROCEDURE STATUS;	# 列出所有存储过程信息

SHOW FUNCTION STATUS LIKE 'count_by_id';

SHOW FUNCTION STATUS;	# 列出所有存储函数信息

/*
1. 从information_schema.Routines表中查看存储过程和函数的信息
语法：
	SELECT * FROM information_schema.Routines
	WHERE ROUTINE_NAME = '存储过程或函数名' [AND ROUTINE_TYPE = {'PROCEDURE | FUNCTION'}];
*/
SELECT * FROM information_schema.Routines;

SELECT * FROM information_schema.Routines WHERE ROUTINE_NAME = 'avg_employee_salary' AND ROUTINE_TYPE = 'PROCEDURE';

# 5.2 修改
/*
	修改存储过程或函数，不影响存储过程或函数的功能，只是修改相关特性
	ALTER {PROCEDURE | FUNCTION} 存储过程或函数名 [characteristic ...]
*/
# 举例1：修改存储过程 show_someone_salary 的定义。将读写权限改为MODIFIES SQL DATA，并指明调用者可以执行
SELECT * FROM information_schema.Routines WHERE ROUTINE_NAME = 'show_someone_salary';

ALTER PROCEDURE show_someone_salary
MODIFIES SQL DATA
SQL SECURITY INVOKER;

# 举例2：修改存储函数 email_by_name 的定义。将读写权限改为READS SQL DATA，并加上注释信息“FIND NAME”
SELECT * FROM information_schema.Routines WHERE ROUTINE_NAME = 'email_by_name';

ALTER FUNCTION email_by_name
READS SQL DATA
COMMENT 'FIND NAME';

# 5.3 删除
# DROP {PROCEDURE | FUNCTION} [IF EXISTS] 存储过程或函数名;

DROP PROCEDURE IF EXISTS show_someone_salary;

DROP FUNCTION IF EXISTS email_by_name;


# 6. 关于存储过程使用的争议
# 略



