# 第14章_视图_课后练习

# 练习1：
# 1. 使用表employees创建视图employee_vu，其中包括姓名（LAST_NAME），员工号（EMPLOYEE_ID），部门号(DEPARTMENT_ID)
CREATE VIEW employee_vu
AS
SELECT last_name, employee_id, department_id
FROM employees;

# 2. 显示视图的结构
DESC employee_vu;

# 3. 查询视图中的全部内容
SELECT * FROM employee_vu;

# 4. 将视图中的数据限定在部门号是80的范围内
CREATE OR REPLACE VIEW employee_vu
AS
SELECT last_name, employee_id, department_id
FROM employees
WHERE department_id = 80; 


# 练习2：
# 1. 创建视图emp_v1,要求查询电话号码以‘011’开头的员工姓名和工资、邮箱
CREATE VIEW emp_v1
AS
SELECT last_name, salary, email
FROM employees
WHERE phone_number LIKE '011%';

SELECT * FROM emp_v1;

# 2. 要求将视图 emp_v1 修改为查询电话号码以‘011’开头的并且邮箱中包含 e 字符的员工姓名和工资、邮箱、电话号码
CREATE OR REPLACE VIEW emp_v1
AS
SELECT last_name, salary, email, phone_number
FROM employees
WHERE phone_number LIKE '011%' AND email LIKE '%e%';

# 3. 向 emp_v1 插入一条记录，是否可以？
# 不可以，视图中不包含基表中所有被定义为非空又未指定默认值的列，视图将不支持INSERT操作
# 错误代码： 1423	Field of view 'dbtest14.emp_v1' underlying table doesn't have a default value
INSERT INTO emp_v1 VALUES('张三', 15000, 'zs@126.com', '13611223344');

# 4. 修改emp_v1中员工的工资，每人涨薪1000
UPDATE emp_v1 SET salary = salary + 1000;

# 5. 删除emp_v1中姓名为Olsen的员工
DELETE FROM emp_v1 WHERE last_name = 'Olsen';

# 6. 创建视图emp_v2，要求查询部门的最高工资高于 12000 的部门id和其最高工资
CREATE VIEW emp_v2
AS
SELECT department_id, MAX(salary)
FROM employees
GROUP BY department_id
HAVING MAX(salary) > 12000;

# 7. 向 emp_v2 中插入一条记录，是否可以？
# 不可以，在定义视图时使用了子查询和聚合函数
INSERT INTO emp_v2
VALUES(207, 15000);

# 8. 删除刚才的emp_v2 和 emp_v1
DROP VIEW emp_v1, emp_v2;
