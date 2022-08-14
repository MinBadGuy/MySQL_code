# 第06章_多表查询_课后练习


# 多表查询-1

# 1.显示所有员工的姓名，部门号和部门名称。
SELECT e.first_name, e.last_name, e.department_id, d.department_name
FROM employees e LEFT JOIN departments d
ON e.department_id = d.department_id;	# 107 rows


# 2.查询90号部门员工的job_id和90号部门的location_id
SELECT e.job_id, l.location_id
FROM employees e INNER JOIN departments d ON e.department_id = d.department_id
INNER JOIN locations l ON d.location_id = l.location_id
WHERE e.department_id = 90;	# 3 rows

SELECT e.job_id, l.location_id
FROM employees e INNER JOIN departments d INNER JOIN locations l
ON e.department_id = d.department_id AND d.location_id = l.location_id
WHERE e.department_id = 90;	# 3 rows


# 3.选择所有有奖金的员工的 last_name , department_name , location_id , city
SELECT e.last_name, d.department_name, d.location_id, l.city
FROM employees e LEFT JOIN departments d
ON e.department_id = d.department_id
LEFT JOIN locations l
ON d.location_id = l.location_id
WHERE e.commission_pct IS NOT NULL;	# 35 rows

# 以下报错，当两个都是INNER JOIN才不报错，34 rows，漏掉了e中department_name为null的一行
SELECT e.last_name, d.department_name, d.location_id#, l.city
FROM employees e LEFT JOIN departments d LEFT JOIN locations l
ON e.department_id = d.department_id AND d.location_id = l.location_id
WHERE e.commission_pct IS NOT NULL;


# 4.选择city在Toronto工作的员工的 last_name , job_id , department_id , department_name
SELECT e.last_name, e.job_id, e.department_id, d.department_name
FROM employees e INNER JOIN departments d
ON e.department_id = d.department_id
INNER JOIN locations l ON d.location_id = l.location_id
WHERE l.city = 'Toronto';	# 2 rows


# 5.查询员工所在的部门名称、部门地址、姓名、工作、工资，其中员工所在部门的部门名称为’Executive’
SELECT d.department_name, l.street_address, e.last_name, e.job_id, e.salary
FROM employees e JOIN departments d
ON e.department_id = d.department_id
JOIN locations l
ON d.location_id = l.location_id
WHERE d.department_name = 'Executive';	# 3 rows


# 6.选择指定员工的姓名，员工号，以及他的管理者的姓名和员工号，结果类似于下面的格式
#	employees Emp# manager Mgr#
#	kochhar 101 king 100
SELECT e.last_name AS 'employees', e.employee_id AS 'Emp#', m.last_name AS 'manager', m.employee_id AS 'Mgr#'
FROM employees e, employees m
WHERE e.manager_id = m.employee_id;	# 106 rows

SELECT e.last_name AS 'employees', e.employee_id AS 'Emp#', m.last_name AS 'manager', m.employee_id AS 'Mgr#'
FROM employees e LEFT JOIN employees m
ON e.manager_id = m.employee_id;	# 107 rows


# 7.查询哪些部门没有员工
SELECT d.department_id, d.department_name FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
WHERE e.department_id IS NULL;	# 16 rows


# 8. 查询哪个城市没有部门
SELECT l.location_id, l.city FROM locations l
LEFT JOIN departments d ON l.location_id = d.location_id
WHERE d.location_id IS NULL;	# 16 rows


# 9. 查询部门名为 Sales 或 IT 的员工信息
SELECT * FROM employees e
LEFT JOIN departments d
ON e.department_id = d.department_id
WHERE d.department_name IN ('Sales', 'IT');	# 39 rows



# 多表查询-2
# 储备：建表操作：
CREATE TABLE `t_dept` (
`id` INT(11) NOT NULL AUTO_INCREMENT,
`deptName` VARCHAR(30) DEFAULT NULL,
`address` VARCHAR(40) DEFAULT NULL,
PRIMARY KEY (`id`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE `t_emp` (
`id` INT(11) NOT NULL AUTO_INCREMENT,
`name` VARCHAR(20) DEFAULT NULL,
`age` INT(3) DEFAULT NULL,
`deptId` INT(11) DEFAULT NULL,
empno INT NOT NULL,
PRIMARY KEY (`id`),
KEY `idx_dept_id` (`deptId`)
#CONSTRAINT `fk_dept_id` FOREIGN KEY (`deptId`) REFERENCES `t_dept` (`id`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


INSERT INTO t_dept(deptName,address) VALUES('华山','华山');
INSERT INTO t_dept(deptName,address) VALUES('丐帮','洛阳');
INSERT INTO t_dept(deptName,address) VALUES('峨眉','峨眉山');
INSERT INTO t_dept(deptName,address) VALUES('武当','武当山');
INSERT INTO t_dept(deptName,address) VALUES('明教','光明顶');
INSERT INTO t_dept(deptName,address) VALUES('少林','少林寺');
INSERT INTO t_emp(NAME,age,deptId,empno) VALUES('风清扬',90,1,100001);
INSERT INTO t_emp(NAME,age,deptId,empno) VALUES('岳不群',50,1,100002);
INSERT INTO t_emp(NAME,age,deptId,empno) VALUES('令狐冲',24,1,100003);
INSERT INTO t_emp(NAME,age,deptId,empno) VALUES('洪七公',70,2,100004);
INSERT INTO t_emp(NAME,age,deptId,empno) VALUES('乔峰',35,2,100005);
INSERT INTO t_emp(NAME,age,deptId,empno) VALUES('灭绝师太',70,3,100006);
INSERT INTO t_emp(NAME,age,deptId,empno) VALUES('周芷若',20,3,100007);
INSERT INTO t_emp(NAME,age,deptId,empno) VALUES('张三丰',100,4,100008);
INSERT INTO t_emp(NAME,age,deptId,empno) VALUES('张无忌',25,5,100009);
INSERT INTO t_emp(NAME,age,deptId,empno) VALUES('韦小宝',18,NULL,100010);


# 1. 所有有门派的人员信息
#（ A、B两表共有）
SELECT * FROM t_emp INNER JOIN t_dept ON t_emp.deptId = t_dept.id;	# 9 rows 


# 2. 列出所有用户，并显示其机构信息
#（A的全集）
SELECT e.*, d.* FROM t_emp e LEFT JOIN t_dept d ON e.deptId = d.id;	# 10 rows


# 3. 列出所有门派
#（B的全集）
SELECT * FROM t_dept;	# 6 rows


# 4. 所有不入门派的人员
#（A的独有）
SELECT * FROM t_emp e 
LEFT JOIN t_dept d ON e.deptId = d.id;
WHERE d.id IS NULL;	# 1 row


# 5. 所有没人入的门派
#（B的独有）
SELECT d.* FROM t_dept d
LEFT JOIN t_emp e ON d.id = e.deptId
WHERE e.deptId IS NULL;	# 1 row

SELECT d.* FROM t_emp e
RIGHT JOIN t_dept d ON e.deptId = d.id
WHERE e.deptId IS NULL;	# 1 row


# 6. 列出所有人员和机构的对照关系
# (AB全有)
# MySQL Full Join的实现 因为MySQL不支持FULL JOIN,下面是替代方法
# left join + union(可去除重复数据)+ right join
SELECT * FROM t_emp e
LEFT JOIN t_dept d ON e.deptId = d.id
UNION
SELECT * FROM t_emp e
RIGHT JOIN t_dept d ON e.deptId = d.id;	# 11 rows

# 7. 列出所有没入派的人员和没人入的门派
#（A的独有+B的独有）
SELECT * FROM t_emp e
LEFT JOIN t_dept d ON e.deptId = d.id
WHERE d.id IS NULL
UNION ALL
SELECT * FROM t_emp e
RIGHT JOIN t_dept d ON e.deptId = d.id
WHERE e.deptId IS NULL;	# 2 rows
