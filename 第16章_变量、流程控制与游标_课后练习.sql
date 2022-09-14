# 第16章_变量、流程控制与游标_课后练习

# 1. 变量

# 准备工作
CREATE DATABASE test16_var_cur;

USE test16_var_cur;

CREATE TABLE employees
AS
SELECT * FROM atguigudb.employees;

CREATE TABLE departments
AS
SELECT * FROM atguigudb.departments;

# 无参有返回
# 1. 创建函数get_count(),返回公司的员工个数
SHOW VARIABLES LIKE 'log_bin_trust_function_creators';
SET GLOBAL log_bin_trust_function_creators = ON;

DELIMITER //

CREATE FUNCTION get_count()
RETURNS INT
BEGIN
	RETURN (SELECT COUNT(*) FROM employees);
END //

DELIMITER ;

SELECT get_count();

# 有参有返回
# 2. 创建函数ename_salary(),根据员工姓名，返回它的工资
DESC employees;

DELIMITER //

CREATE FUNCTION ename_salary(emp_name VARCHAR(25))
RETURNS DOUBLE
BEGIN
	DECLARE emp_sal DOUBLE;
	SELECT salary INTO emp_sal FROM employees WHERE last_name = emp_name;
	RETURN emp_sal;
END //

DELIMITER ;

SELECT ename_salary('Abel');

# 3. 创建函数dept_sal() ,根据部门名，返回该部门的平均工资
DESC departments;

DELIMITER //

CREATE FUNCTION dept_sal(dept_name VARCHAR(30))
RETURNS DOUBLE
BEGIN
	DECLARE avg_sal DOUBLE;
	
	SELECT AVG(salary) INTO avg_sal 
	FROM employees 
	WHERE department_id = (SELECT department_id
				FROM departments
				WHERE department_name = dept_name);
	
	RETURN avg_sal;
	
END //

DELIMITER ;

SELECT * FROM departments;
SELECT dept_sal('Finance');

# 4. 创建函数add_float()，实现传入两个float，返回二者之和
DELIMITER //

CREATE FUNCTION add_float(f1 FLOAT, f2 FLOAT)
RETURNS FLOAT
BEGIN
	DECLARE s FLOAT;
	SET s = f1 + f2;
	RETURN s;
END //

DELIMITER ;

SELECT add_float(1.1, 2.2);


# 2. 流程控制
# 1. 创建函数test_if_case()，实现传入成绩，
# 如果成绩>90,返回A，如果成绩>80,返回B，如果成绩>60,返回C，否则返回D
# 要求：分别使用if结构和case结构实现
DELIMITER //

CREATE FUNCTION test_if_case(score INT)
RETURNS CHAR
BEGIN
	DECLARE grade CHAR;
	
	IF score > 90 THEN 
		SET grade = 'A';
	ELSEIF score > 80 THEN
		SET grade = 'B';
	ELSEIF score > 60 THEN
		SET grade = 'C';
	ELSE
		SET grade = 'D';
	END IF;
	
	RETURN grade;
END //

DELIMITER ;

SELECT test_if_case(95);
SELECT test_if_case(85);
SELECT test_if_case(65);
SELECT test_if_case(55);

# 2. 创建存储过程test_if_pro()，传入工资值，
# 如果工资值<3000,则删除工资为此值的员工，如果3000 <= 工资值 <= 5000,则修改此工资值的员工薪资涨1000，否则涨工资500
DELIMITER //

CREATE PROCEDURE test_if_pro(IN emp_sal DOUBLE)
BEGIN
	IF emp_sal < 3000 THEN
		DELETE FROM employees WHERE salary = emp_sal;
	ELSEIF emp_sal <= 5000 THEN
		UPDATE employees SET salary = salary + 1000 WHERE salary = emp_sal;
	ELSE
		UPDATE employees SET salary = salary + 500 WHERE salary = emp_sal;
	END IF;
END //

DELIMITER ;

SELECT * FROM employees;

CALL test_if_pro(2900);
CALL test_if_pro(3100);
CALL test_if_pro(24000);

# 3. 创建存储过程insert_data(),传入参数为 IN 的 INT 类型变量 insert_count,
# 实现向admin表中批量插入insert_count条记录
DESC ADMIN;

DELIMITER //

CREATE PROCEDURE insert_data(IN insert_count INT)
BEGIN
	DECLARE while_count INT DEFAULT 0;
	
	WHILE while_count < insert_count DO
		INSERT INTO ADMIN VALUES(while_count + 1);
		SET while_count = while_count + 1;
	END WHILE;
END //

DELIMITER ;

# 3. 游标的使用
/*
创建存储过程update_salary()，参数1为 IN 的INT型变量dept_id，表示部门id；参数2为 IN的INT型变量change_sal_count，表示要调整薪资的员工个数。
查询指定id部门的员工信息，按照salary升序排列，根据hire_date的情况，调整前change_sal_count个员工的薪资，详情如下。
hire_date 		salary
hire_date < 1995 			salary = salary*1.2
hire_date >=1995 and hire_date <= 1998	salary = salary*1.15
hire_date > 1998 and hire_date <= 2001	salary = salary *1.10
hire_date > 2001 			salary = salary * 1.05
*/
DESC employees;

DELIMITER //

CREATE PROCEDURE update_salary(IN dept_id INT, IN change_sal_count INT)
BEGIN
	DECLARE emp_id DOUBLE;
	DECLARE emp_hire_date DATE;
	DECLARE while_count INT DEFAULT 0;
	
	DECLARE cur_emp CURSOR FOR SELECT employee_id, hire_date FROM employees WHERE department_id = dept_id ORDER BY salary ASC;
	OPEN cur_emp;
	
	WHILE while_count < change_sal_count DO
		FETCH cur_emp INTO emp_id, emp_hire_date;
		
		IF YEAR(emp_hire_date) < 1995 THEN
			UPDATE employees SET salary = salary * 1.2 WHERE employee_id = emp_id;
		ELSEIF YEAR(emp_hire_date) <= 1998 THEN
			UPDATE employees SET salary = salary * 1.15 WHERE employee_id = emp_id;
		ELSEIF YEAR(emp_hire_date) <= 2001 THEN
			UPDATE employees SET salary = salary * 1.10 WHERE employee_id = emp_id;
		ELSE
			UPDATE employees SET salary = salary * 1.05 WHERE employee_id = emp_id;
		END IF;
		
		SET while_count = while_count + 1;
	END WHILE;
	
	CLOSE cur_emp;
END //

DELIMITER ;

SELECT * FROM employees WHERE department_id = 50 ORDER BY salary;
CALL update_salary(50, 2);

SELECT 2200*1.1, 2310*1.1;











