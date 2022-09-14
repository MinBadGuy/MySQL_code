# 第16章_变量、流程控制与游标


# 1. 变量
/*
	系统变量
	用户自定义变量
*/

# 1.1 系统变量
# 1.1.1 系统变量分类
/*
全局系统变量：需要添加global关键字，简称为全局变量
会话系统变量：需要添加session关键字，简称为local变量，会话系统变量的初始值是全局系统变量值的复制
如果不写，默认会话级别
静态变量：在MySQL服务实例运行期间它们的值不能使用set动态修改，属于特殊的全局系统变量

- 全局系统变量针对所有会话（连接）有效，但不能跨重启
- 会话系统变量仅针对当前会话（连接）有效
- 会话1对某个全局系统变量值的修改会导致会话2中同一个全局系统变量值的修改
*/

# 1.1.2 查看系统变量
# - 查看所有或部分系统变量
# 查看所有全局变量
SHOW GLOBAL VARIABLES;

# 查看所有会话变量
SHOW SESSION VARIABLES;
SHOW VARIABLES;	# 不写GLOBAL或SESSION，默认是会话级别

# 查看满足条件的部分系统变量
SHOW GLOBAL VARIABLES LIKE '%标识符%';

# 查看满足条件的部分会话变量
SHOW SESSION VARIABLES LIKE '%标识符%';

SHOW GLOBAL VARIABLES LIKE 'admin_%';

# - 查看指定系统变量
/*
系统变量以`两个@`开头
`@@global`：标记全局系统变量
`@@session`：标记会话系统变量
`@@`首先标记会话系统变量，如果会话系统变量不存在，则标记全局系统变量
*/
# 查看指定的系统变量的值
SELECT @@global.变量名;

# 查看指定的会话变量的值
SELECT @@session.变量名;
SELECT @@变量名;

# - 修改系统变量的值
/*
方式1：修改MySQL配置文件，需要重启MySQL服务
方式2：使用`set`命令重新设置系统变量的值
*/
# 为某个系统变量赋值
SET @@global.变量名 = 变量值;
SET GLOBAL 变量名 = 变量值;

# 为某个会话变量赋值
SET @@session.变量名 = 变量值;
SET SESSION 变量名 = 变量值;

SELECT @@global.autocommit;
SET GLOBAL autocommit = 0;

# 错误代码： 1193	Unknown system variable 'tx_isolation'
SELECT @@session.tx_isolation;
SHOW SESSION VARIABLES LIKE '%tx%';

SELECT @@global.max_connections;
SET @@global.max_connections = 1000;

# 1.2 用户变量
# 1.2.1 用户变量分类
/*
用户变量以`一个@`开头
会话用户变量：作用域和会话变量一样，只对当前连接会话有效
局部变量：只在BEGIN和END语句块中有效，只能在存储过程和函数中使用
*/

# 1.2.2 会话用户变量
# - 变量的定义
# 方式1："="或":="
SET @用户变量 = 值;
SET @用户变量 := 值;

# 方式2：":=" 或 INTO关键字
SELECT @用户变量 := 表达式 [FROM 等子句];
SELECT 表达式 INTO @用户变量 [FROM 等子句];

# - 查看用户变量的值（查看、比较、运算等）
SELECT @用户变量;

SET @a = 1;
SELECT @a;


CREATE DATABASE IF NOT EXISTS dbtest16 CHARACTER SET 'utf8';
USE dbtest16;

CREATE TABLE employees AS SELECT * FROM atguigudb.employees;

SELECT @num := COUNT(*) FROM employees;
SELECT @num;

SELECT AVG(salary) INTO @avgsalary FROM employees;
SELECT @avgsalary;

SELECT @big;	# 查看某个未声明的变量时，将得到NULL值

# 1.2.3 局部变量
/*
定义：使用`DECLARE`语句定义一个局部变量
作用域：仅在定义它的BEGIN...END中有效
位置：只能放在BEGIN...END中，且只能放在第一句

BEGIN
	# 声明局部变量
	DECLARE 变量名1 变量数据类型 [DEFAULT 变量默认值];
	DECLARE 变量名2, 变量名3, ..., 变量数据类型 [DEFAULT 变量默认值];
	
	# 为局部变量赋值
	SET 变量名1 = 值;
	SELECT 值 INTO 变量名2 [FROM 子句];
	
	# 查看局部变量的值
	SELECT 变量1, 变量2, 变量3;
END
*/

/*
1. 定义变量
DECLARE 变量名 类型 [DEFAULT 值];	# 如果没有DEFAULT子句，初始值为NULL

例：
DECLARE myparam INT DEFAULT 100;

2. 变量赋值
方式1：一般用于简单赋值
	SET 变量名 = 值;
	SET 变量名 := 值;
方式2：一般用于赋表中的字段值
	SELECT 字段名或表达式 INTO 变量名 FROM 表;

3. 使用变量
	SELECT 局部变量;
*/
# 举例1：声明局部变量，并分别赋值为employees表中employee_id为102的last_name和salary
DESC employees;

DELIMITER //

CREATE PROCEDURE set_value()
BEGIN
	DECLARE emp_name VARCHAR(25);
	DECLARE emp_salary DOUBLE; 
	SELECT last_name, salary INTO emp_name, emp_salary FROM employees WHERE employee_id = 102;
	SELECT emp_name, emp_salary;
END //

DELIMITER ;

CALL set_value();

# 举例2：声明两个变量，求和并打印 （分别使用会话用户变量、局部变量的方式实现）
# 会话用户变量
SET @num1 = 10;
SET @num2 = 20;
SET @sum = @num1 + @num2;
SELECT @sum;

# 局部变量
SELECT @@log_bin_trust_function_creators;
SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER //

CREATE FUNCTION add_value()
RETURNS INT
BEGIN
	DECLARE num1 INT;
	DECLARE num2 INT;
	
	SET num1 = 10;
	SET num2 = 20;
	
	RETURN (num1 + num2);
END //

DELIMITER ;

SELECT add_value();

# 举例3：创建存储过程“different_salary”查询某员工和他领导的薪资差距，并用IN参数emp_id接收员工id，用OUT参数dif_salary输出薪资差距结果。
DELIMITER //

CREATE PROCEDURE different_salary(IN emp_id INT, OUT dif_salary DOUBLE)
BEGIN
	DECLARE emp_salary, mgr_salary DOUBLE;
	
	SELECT e.salary, m.salary INTO emp_salary, mgr_salary
	FROM employees e JOIN employees m
	ON e.manager_id = m.employee_id
	WHERE e.employee_id = emp_id;
	
	SET dif_salary = mgr_salary - emp_salary;
END //

DELIMITER ;

CALL different_salary(101, @dif_salary);
SELECT @dif_salary;

# 1.2.4 对比会话用户变量与局部变量
/*
		作用域			定义位置		语法
会话用户变量	当前会话		会话的任何地方		加@符号，不用指定类型
局部变量	定义它的BEGIN END中	BEGIN END的第一句话	一般不用加@，需要指定类型
*/


# 2. 定义条件与处理程序
/*
定义条件：事先定义程序执行过程中可能遇到的问题
处理程序：定义在遇到问题时应当采取的处理方式，并且保证存储过程或函数在遇到警告或错误时能继续执行
*/

# 2.1 案例分析
# 案例分析：创建一个名称为“UpdateDataNoCondition”的存储过程，代码如下：
DESCRIBE employees;

DELIMITER //

CREATE PROCEDURE UpdateDataNoCondition()
BEGIN
	SET @x=1;
	UPDATE employees SET email = NULL WHERE last_name = 'Abel';
	SET @x=2;
	UPDATE employees SET email = 'aabbel' WHERE last_name = 'Abel';
	SET @x=3;
END //

DELIMITER ;

# 错误代码： 1048	Column 'email' cannot be null
# 存储过程中SQL语句报错，不再继续向下执行
CALL UpdateDataNoCondition();

SELECT @x;

# 2.2 定义条件
/*
给MySQL中的错误码命名，将一个错误名字和指定的错误条件关联起来
这个名字可以随后被用在定义处理程序的`DECLARE HANDLER`语句中

语法：
	DECLARE 错误名称 CONDITION FOR 错误码(或错误条件)
错误码说明：
	- MySQL_error_code 和 sqlstate_value 都可以表示MySQL的错误
		- MySQL_error_code 是数值类型错误代码
		- sqlstate_value 是长度为5的字符串类型错误代码
	- 例如，在ERROR 1418 (HY000)中，1418是MySQL_error_code，'HY000'是sqlstate_value
*/

# 举例1：定义“Field_Not_Be_NULL”错误名与MySQL中违反非空约束的错误类型是“ERROR 1048 (23000)”对应
# 使用MySQL_error_code
DECLARE Field_Not_Be_NULL CONDITION FOR 1048;

# 使用sqlstate_value
DECLARE Field_Not_Be_NULL CONDITION FOR SQLSTATE '23000';

# 举例2：定义"ERROR 1148(42000)"错误，名称为command_not_allowed
# 使用MySQL_error_code
DECLARE command_not_allowed CONDITION FOR 1148;

# 使用sqlstate_value
DECLARE command_not_allowed CONDITION FOR SQLSTATE '42000';


# 2.3 定义处理程序
/*
语法：
	DECLARE 处理方式 HANDLER FOR 错误类型 处理语句
处理方式：
	CONTINE：遇到错误不处理，继续执行
	EXIT：遇到错误马上退出
	UNDO：遇到错误后撤回之前的操作，MySQL暂不支持
错误类型：
	SQLSTATE '字符串错误码'：表示长度为5的sqlstate_value类型的错误码
	MySQL_error_code：匹配数值类型错误代码
	错误名称：表示DECLARE...CONDITION定义的错误条件名称
	SQLWARNING：匹配所有以01开头的SQLSTATE错误代码
	NOT FOUND：匹配所有以02开头的SQLSTATE错误代码
	SQLEXCEPTION：匹配所有没有被SQLWARNING或NOT FOUND捕获的SQLSTATE错误代码
处理语句：
	可以是简单语句，也可以是使用`BEGIN...END`编写的复合语句
*/
# 方法1：捕获sqlstae_value
DECLARE CONTINUE HANDLER FOR SQLSTATE '42S02' SET @info = 'NO_SUCH_TABLE';

# 方法2：捕获mysql_error_value
DECLARE CONTINUE HANDLER FOR 1146 SET @info = 'NO_SUCH_TABLE';

# 方法3：先定义条件，再调用
DECLARE no_such_table CONDITION FOR 1146;
DECLARE CONTINUE HANDLER FOR no_such_table SET @info = 'NO_SUCH_TABLE';

# 方法4：使用SQLWARNING
DECLARE EXIT HANDLER FOR SQLWARNING SET @info = 'ERROR';

# 方法5：使用NOT FOUND
DECLARE EXIT HANDLER FOR NOT FOUND SET @info = 'NO_SUCH_TABLE';

# 方法6：使用SQLEXCEPTION
DECLARE EXIT HANDLER FOR SQLEXCEPTION SET @info = 'ERROR';

# 2.4 案例解决
/*
	在存储过程中，定义处理程序，捕获mysql_error_value值，
	当遇见mysql_error_value值为1048时，执行CONTINUE操作，并将@proc_value的值设为-1
*/
DROP PROCEDURE UpdateDataNoCondition;

DELIMITER //

CREATE PROCEDURE UpdateDataNoCondition()
BEGIN
	# 定义处理程序
	DECLARE CONTINUE HANDLER FOR 1048 SET @proc_value = -1;
	
	SET @x=1;
	UPDATE employees SET email = NULL WHERE last_name = 'Abel';
	SET @x=2;
	UPDATE employees SET email = 'aabbel' WHERE last_name = 'Abel';
	SET @x=3;
END //

DELIMITER ;

CALL UpdateDataNoCondition();

SELECT @x, @proc_value;

# 举例：
/*
	创建一个名称为“InsertDataWithCondition”的存储过程，代码如下。
	在存储过程中，定义处理程序，捕获sqlstate_value值，
	当遇到sqlstate_value值为23000时，执行EXIT操作，并且将@proc_value的值设置为-1
*/
# 准备工作
CREATE TABLE departments
AS
SELECT * FROM atguigudb.departments;

ALTER TABLE departments
ADD CONSTRAINT uk_dept_name UNIQUE(department_name);

DESC departments;

DELIMITER //

CREATE PROCEDURE InsertDataWithCondition()
BEGIN
	DECLARE EXIT HANDLER FOR SQLSTATE '23000' SET @proc_value = -1;
	
	SET @x=1;
	INSERT INTO departments(department_name) VALUES('测试');
	SET @x=2;
	INSERT INTO departments(department_name) VALUES('测试');
	SET @x=3;
END //

DELIMITER ;

CALL InsertDataWithCondition();
SELECT @x, @proc_value;


# 3. 流程控制
/*
	顺序结构、分支结构、循环结构
	条件判断语句：IF 和 CASE
	循环语句：LOOP、WHILE、REPEAT
	跳转语句：ITERATE 和 LEAVE
*/
# 3.1 分支结构之IF
/*
语法：
	IF 表达式1 THEN 操作1
	[ELSEIF 表达式2 THEN 操作2]
	...
	[ELSE 操作N]
	END IF
特点：
	① 不同的表达式对应不同的操作
	② 使用在begin end中
*/
# 举例1：
/*
IF val IS NULL 
	THEN SELECT 'val is null';
ELSE 
	SELECT 'val is not null';
END IF;
*/

# 举例2：声明存储过程“update_salary_by_eid1”，定义IN参数emp_id，输入员工编号。
# 判断该员工薪资如果低于8000元并且入职时间超过5年，就涨薪500元；否则就不变。
SELECT * FROM employees;

DELIMITER //

CREATE PROCEDURE update_salary_by_eid1(IN emp_id INT)
BEGIN
	DECLARE emp_sal DOUBLE;
	DECLARE hire_year INT;
	
	SELECT salary, YEAR(hire_date) INTO emp_sal, hire_year FROM employees WHERE employee_id = emp_id;
	
	IF emp_sal < 8000 AND YEAR(CURDATE()) - hire_year > 5
		THEN UPDATE employees SET salary = salary + 500 WHERE employee_id = emp_id;
	END IF;
END //

DELIMITER ;

CALL update_salary_by_eid1(104);


# 举例3：声明存储过程“update_salary_by_eid2”，定义IN参数emp_id，输入员工编号。
# 判断该员工薪资如果低于9000元并且入职时间超过5年，就涨薪500元；否则就涨薪100元。
DELIMITER //

CREATE PROCEDURE update_salary_by_eid2(IN emp_id INT)
BEGIN
	DECLARE emp_sal DOUBLE;
	DECLARE hire_year INT;
	
	SELECT salary, YEAR(hire_date) INTO emp_sal, hire_year FROM employees WHERE employee_id = emp_id;
	
	IF emp_sal < 9000 AND YEAR(CURDATE()) - hire_year > 5 THEN
		UPDATE employees SET salary = salary + 500 WHERE employee_id = emp_id;
	ELSE
		UPDATE employees SET salary = salary + 100 WHERE employee_id = emp_id;
	END IF;
END //

DELIMITER ;

CALL update_salary_by_eid2(104);
CALL update_salary_by_eid2(103);

# 举例4：声明存储过程“update_salary_by_eid3”，定义IN参数emp_id，输入员工编号。
# 判断该员工薪资如果低于9000元，就更新薪资为9000元；薪资如果大于等于9000元且低于10000的，但是奖金比例为NULL的，就更新奖金比例为0.01；
# 其他的涨薪100元。
DESC employees;

DELIMITER //

CREATE PROCEDURE update_salary_by_eid3(IN emp_id INT)
BEGIN
	DECLARE emp_sal, emp_pct DOUBLE;
	
	SELECT salary, commission_pct INTO emp_sal, emp_pct FROM employees WHERE employee_id = emp_id;
	
	IF emp_sal < 9000 THEN
		UPDATE employees SET salary = 9000 WHERE employee_id = emp_id;
	ELSEIF emp_sal < 10000 AND emp_pct IS NULL THEN
		UPDATE employees SET commission_pct = 0.01 WHERE employee_id = emp_id;
	ELSE
		UPDATE employees SET salary = salary + 100 WHERE employee_id = emp_id;
	END IF;
END //

DELIMITER ;

CALL update_salary_by_eid3(104);
CALL update_salary_by_eid3(103);
CALL update_salary_by_eid3(102);


# 3.2 分支结构之CASE
/*
语法结构1：
	CASE 表达式
	WHEN 值1 THEN 结果1或语句1(如果是语句，需要加分号)
	WHEN 值2 THEN 结果2或语句2(如果是语句，需要加分号)
	...
	ELSE 结果n或语句n(如果是语句，需要加分号)
	END [CASE](如果是放在begin end中需要加上case，如果放在select后不需要)

语法结构2：
	CASE
	WHEN 条件1 THEN 结果1或语句1(如果是语句，需要加分号)
	WHEN 条件2 THEN 结果2或语句2(如果是语句，需要加分号)
	...
	ELSE 结果n或语句n(如果是语句，需要加分号)
	END [CASE](如果是放在begin end中需要加上case，如果放在select后不需要)
*/
# 举例1：使用CASE流程控制语句的第1种格式，判断val值等于1、等于2，或者两者都不等
CASE val
WHEN 1 THEN SELECT 'val = 1'
WHEN 2 THEN SELECT 'val = 2'
ELSE SELECT 'val is not 1 or 2'
END CASE;

# 举例2：使用CASE流程控制语句的第2种格式，判断val是否为空、小于0、大于0或者等于0
CASE
WHEN val IS NULL THEN SELECT 'val is null'
WHEN val < 0 THEN SELECT 'val < 0'
WHEN val > 0 THEN SELECT 'val > 0'
ELSE SELECT 'val = 0'
END CASE;

# 举例3：声明存储过程“update_salary_by_eid4”，定义IN参数emp_id，输入员工编号。
# 判断该员工薪资如果低于9000元，就更新薪资为9000元；薪资大于等于9000元且低于10000的，但是奖金比例为NULL的，就更新奖金比例为0.01；其他的涨薪100元
DELIMITER //

CREATE PROCEDURE update_salary_by_eid4(IN emp_id INT)
BEGIN
	DECLARE emp_sal, emp_pct DOUBLE;
	
	SELECT salary, commission_pct INTO emp_sal, emp_pct FROM employees WHERE employee_id = emp_id;
	
	CASE
	WHEN emp_sal < 9000 THEN UPDATE employees SET salary = 9000 WHERE employee_id = emp_id;
	WHEN emp_sal < 10000 AND emp_pct IS NULL THEN UPDATE employees SET commission_pct = 0.01 WHERE employee_id = emp_id;
	ELSE UPDATE employees SET salary = salary + 100 WHERE employee_id = emp_id;
	END CASE;
END //

DELIMITER ;

CALL update_salary_by_eid4(105);
CALL update_salary_by_eid4(104);
CALL update_salary_by_eid4(102);

# 举例4：声明存储过程update_salary_by_eid5，定义IN参数emp_id，输入员工编号。
# 判断该员工的入职年限，如果是0年，薪资涨50；如果是1年，薪资涨100；如果是2年，薪资涨200；如果是3年，薪资涨300；如果是4年，薪资涨400；其他的涨薪500
DELIMITER //

CREATE PROCEDURE update_salary_by_eid5(IN emp_id INT)
BEGIN
	DECLARE emp_sal DOUBLE;
	DECLARE hire_year INT;
	
	SELECT salary, YEAR(CURDATE()) - YEAR(hire_date) INTO emp_sal, hire_year FROM employees WHERE employee_id = emp_id;
	
	CASE hire_year
	WHEN 0 THEN UPDATE employees SET salary = salary + 50 WHERE employee_id = emp_id;
	WHEN 1 THEN UPDATE employees SET salary = salary + 100 WHERE employee_id = emp_id;
	WHEN 2 THEN UPDATE employees SET salary = salary + 200 WHERE employee_id = emp_id;
	WHEN 3 THEN UPDATE employees SET salary = salary + 300 WHERE employee_id = emp_id;
	WHEN 4 THEN UPDATE employees SET salary = salary + 400 WHERE employee_id = emp_id;
	ELSE UPDATE employees SET salary = salary + 500 WHERE employee_id = emp_id;
	END CASE;
	
END // 

DELIMITER ;

CALL update_salary_by_eid5(104);


# 3.3 循环结构之LOOP
/*
语法：
	[loop_label:] LOOP
		循环执行的语句
	END LOOP [loop_label]
*/
# 举例1：使用LOOP语句进行循环操作，id值小于10时将重复执行循环过程
DECLARE id INT DEFAULT 0;
add_loop: LOOP
	SET id = id + 1;
	IF id >= 10 THEN LEAVE add_loop;
	END IF;
END LOOP add_loop;

# 举例2：当市场环境变好时，公司为了奖励大家，决定给大家涨工资。
# 声明存储过程“update_salary_loop()”，声明OUT参数num，输出循环次数。
# 存储过程中实现循环给大家涨薪，薪资涨为原来的1.1倍。直到全公司的平均薪资达到12000结束。并统计循环次数
DELIMITER //

CREATE PROCEDURE update_salary_loop(OUT num INT)
BEGIN
	DECLARE avg_sal DOUBLE;
	DECLARE loop_count INT DEFAULT 0;
	
	label_loop: LOOP
		SELECT AVG(salary) INTO avg_sal FROM employees;
		IF avg_sal >= 12000 THEN LEAVE label_loop;
		ELSE UPDATE employees SET salary = salary * 1.1;
		END IF;
		SET loop_count = loop_count + 1;
	END LOOP label_loop;
	
	SET num = loop_count;
END //

DELIMITER ;

SET @num = 0;
CALL update_salary_loop(@num);
SELECT @num;
SELECT AVG(salary) FROM employees;

# 3.4 循环结构之WHILE
/*
语法：
	[while_label:] WHILE 循环条件 DO
		循环体
	END WHILE [while_label];
*/
# 举例1：WHILE语句示例，i值小于10时，将重复执行循环过程
DELIMITER //

CREATE PROCEDURE test_while()
BEGIN
	DECLARE i INT DEFAULT 0;
	
	WHILE i < 10 DO
		SET i = i + 1;
	END WHILE;
	
	SELECT i;
END //

DELIMITER ;

CALL test_while();	# i = 10

# 举例2：市场环境不好时，公司为了渡过难关，决定暂时降低大家的薪资。
# 声明存储过程“update_salary_while()”，声明OUT参数num，输出循环次数。
# 存储过程中实现循环给大家降薪，薪资降为原来的90%。直到全公司的平均薪资达到5000结束。并统计循环次数
DELIMITER //

CREATE PROCEDURE update_salary_while(OUT num INT)
BEGIN
	DECLARE avg_sal DOUBLE;
	DECLARE while_count INT DEFAULT 0;
	
	SELECT AVG(salary) INTO avg_sal FROM employees;
	WHILE avg_sal > 5000 DO
		UPDATE employees SET salary = salary * 0.9;
		SET while_count = while_count + 1;
		SELECT AVG(salary) INTO avg_sal FROM employees;
	END WHILE;
	
	SET num = while_count;
END //

DELIMITER ;

SET @num = 0;
CALL update_salary_while(@num);
SELECT @num;
SELECT AVG(salary) FROM employees;

# 3.5 循环结构之REPEAT
/*
语法：
	[repeat_label:] REPEAT
		循环体语句
	UNTIL 结束循环的条件表达式
	END REPEAT [repeat_label];
*/
# 举例1：
DELIMITER //

CREATE PROCEDURE test_repeat()
BEGIN
	DECLARE i INT DEFAULT 0;
	
	REPEAT
		SET i = i + 1;
	UNTIL i > 10
	END REPEAT;
	
	SELECT i;
END //

DELIMITER ;

CALL test_repeat();	# i = 11

# 举例2：当市场环境变好时，公司为了奖励大家，决定给大家涨工资。
# 声明存储过程“update_salary_repeat()”，声明OUT参数num，输出循环次数。
# 存储过程中实现循环给大家涨薪，薪资涨为原来的1.15倍。直到全公司的平均薪资达到13000结束。并统计循环次数
DELIMITER //

CREATE PROCEDURE update_salary_repeat(OUT num INT)
BEGIN
	DECLARE avg_sal DOUBLE;
	DECLARE repeat_count INT DEFAULT 0;
	
	REPEAT
		UPDATE employees SET salary = salary * 1.15;
		SELECT AVG(salary) INTO avg_sal FROM employees;
		SET repeat_count = repeat_count + 1;
	UNTIL avg_sal >= 13000
	END REPEAT;
	
	SET num = repeat_count;
END //

DELIMITER ;


SET @num = 0;
CALL update_salary_repeat(@num);
SELECT @num;
SELECT AVG(salary) FROM employees;

# 对比三种循环结构：
/*
- 都可以省略名称，但如果添加了循环控制语句(LEAVE 或 ITERATE)，则必须添加名称
- LOOP：一般用于实现简单的“死”循环
- WHILE：先判断后执行
- REPEAT：先执行后判断，无条件至少执行一次
*/

# 3.6 跳转语句之LEAVE语句
/*
LEAVE：可以用在循环语句内，或者以BEGIN和END包裹起来的程序体内，表示跳出循环或者跳出程序体的操作
语法：
	LEAVE 标记名
*/
/*举例1：
创建存储过程 “leave_begin()”，声明INT类型的IN参数num。给BEGIN...END加标记名，并在BEGIN...END中使用IF语句判断num参数的值
如果num<=0，则使用LEAVE语句退出BEGIN...END；
如果num=1，则查询“employees”表的平均薪资；
如果num=2，则查询“employees”表的最低薪资；
如果num>2，则查询“employees”表的最高薪资。
IF语句结束后查询“employees”表的总人数
*/
DELIMITER //

CREATE PROCEDURE leave_begin(IN num INT)
begin_label: BEGIN
	IF num <= 0 THEN
		LEAVE begin_label;
	ELSEIF num = 1 THEN
		SELECT AVG(salary) FROM employees;
	ELSEIF num = 2 THEN
		SELECT MIN(salary) FROM employees;
	ELSE
		SELECT MAX(salary) FROM employees;
	END IF;
	
	SELECT COUNT(*) FROM employees;
END //

DELIMITER ;

CALL leave_begin(0);
CALL leave_begin(1);
CALL leave_begin(2);
CALL leave_begin(3);

# 举例2：当市场环境不好时，公司为了渡过难关，决定暂时降低大家的薪资。
# 声明存储过程“leave_while()”，声明OUT参数num，输出循环次数，
# 存储过程中使用WHILE循环给大家降低薪资为原来薪资的90%，直到全公司的平均薪资小于等于10000，并统计循环次数
DELIMITER //

CREATE PROCEDURE leave_while(OUT num INT)
BEGIN
	DECLARE avg_sal DOUBLE;
	DECLARE while_count INT DEFAULT 0;
	
	SELECT AVG(salary) INTO avg_sal FROM employees;
	while_label: WHILE TRUE DO
		IF avg_sal <= 10000 THEN 
			LEAVE while_label;
		END IF;
		UPDATE employees SET salary = salary * 0.9;
		SET while_count = while_count + 1;
		SELECT AVG(salary) INTO avg_sal FROM employees;
	END WHILE while_label;
	
	SET num = while_count;
END //

DELIMITER ;

SET @num = 0;
CALL leave_while(@num);
SELECT @num;
SELECT AVG(salary) FROM employees;

# 3.7 跳转语句之ITERATE语句
/*
ITERATE：只能用在循环语句(LOOP、REPEAT和WHILE语句)内，表示重新开始循环，将执行顺序转到语句段开头
语法：
	ITERATE label
*/
# 举例：定义局部变量num，初始值为0，循环体中执行num+1操作
# 如果num < 10，则继续执行循环
# 如果num > 15，则退出循环结构
DELIMITER //

CREATE PROCEDURE test_iterate()
BEGIN
	DECLARE num INT DEFAULT 0;
	while_label: WHILE TRUE DO
		SET num = num + 1;
		IF num < 10 THEN
			ITERATE while_label;
		ELSEIF num > 15 THEN
			LEAVE while_label;
		END IF;
	END WHILE;
END //

DELIMITER ;


# 4. 游标
# 4.1 什么是游标(或光标)
/*
游标：能够对结果集中的每一条记录进行定位，并对指向的记录中的数据进行操作的数据结构
游标是一种临时的数据库对象，可以指向存储在数据库表中的数据行指针，游标充当了指针的作用
游标可以在存储过程和函数中使用
*/

# 查询employees表中工资高于15000的员工
SELECT employee_id, last_name, salary FROM employees
WHERE salary > 15000; 

# 4.2 使用游标步骤
/*
游标必须在声明处理程序之前被声明，并且变量和条件还必须在声明游标或处理程序之前被声明
*/

# 第一步：声明游标
# DECLARE cursor_name CURSOR FOR select_statement;
# 例：DECLARE cur_emp CURSOR FOR SELECT employee_id, salary FROM employees;

# 第二步：打开游标
# OPEN cursor_name;
# 例：OPEN cur_emp;

# 第三步：使用游标(从游标中取得数据)
# FETCH cursor_name INTO var_name[, var_name] ...
# 注：var_name必须在声明游标前就定义好，游标的查询结果集中的字段数必须跟INTO后面的变量数一致
# 例：FETCH cur_emp INTO emp_id, emp_sal;

# 第四步：关闭游标(释放系统资源)
# CLOSE cursor_name;
# 例：CLOSE cur_emp;

# 4.3 举例
/*
创建存储过程“get_count_by_limit_total_salary()”，
声明IN参数 limit_total_salary，DOUBLE类型；声明OUT参数total_count，INT类型。
函数的功能可以实现累加薪资最高的几个员工的薪资值，直到薪资总和达到limit_total_salary参数的值，返回累加的人数给total_count
*/

DELIMITER //

CREATE PROCEDURE get_count_by_limit_total_salary(IN limit_total_salary DOUBLE, OUT total_count INT)
BEGIN
	DECLARE emp_sal DOUBLE;
	DECLARE sum_sal DOUBLE DEFAULT 0;
	DECLARE while_count INT DEFAULT 0;
	
	DECLARE cur_emp CURSOR FOR SELECT salary FROM employees ORDER BY salary DESC;
	OPEN cur_emp;
	
	WHILE sum_sal < limit_total_salary DO
		FETCH cur_emp INTO emp_sal;
		SET sum_sal = sum_sal + emp_sal;
		SET while_count = while_count + 1;
	END WHILE;
	
	CLOSE cur_emp;
	SET total_count = while_count;
END //

DELIMITER ;

# 4.4 小结
/*
游标实现了对结果集中的数据逐条读取的功能
游标占用系统资源，使用完成后需要关闭
*/

SHOW VARIABLES LIKE '%max_execution_time%';
SET max_execution_time = 2000;

SHOW VARIABLES LIKE '%max_connections%';


