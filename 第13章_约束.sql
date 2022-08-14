# 第13章_约束


# 1. 约束(constraint)概述
# 1.1 为什么需要约束
#	保护数据的完整性

# 1.2 什么是约束
#	表级的强制规定

# 1.3 约束的分类
/*
根据约束数据列的限制：
	单列约束：每个约束只约束一列
	多列约束：每个约束可约束多列数据
根据约束的作用范围：
	列级约束：只能作用在一个列上，跟在列的定义后面
	表级约束：可以作用在多个列上，不与列一起，而是单独定义
根据约束起的作用：
	NOT NULL 非空约束，规定某个字段不能为空
	UNIQUE 唯一约束，规定某个字段在整个表中是唯一的
	PRIMARY KEY 主键(非空且唯一)约束
	FOREIGN KEY 外键约束
	CHECK 检查约束
	DEFAULT 默认值约束

# 查看某个表已有的约束
# information_schema 数据库名(系统库)
# table_constraints 表名称(专门存储各个表的约束)
SELECT * FROM information_schema.table_constraints
WHERE TABLE_NAME='表名称';
*/


# 2. 非空约束
# 2.1 作用
#	限定某个字段/某列的值不允许为空

# 2.2 关键字
#	NOT NULL

# 2.3 特点
/*
	默认，所有类型的值都可以是NULL，包括INT、FLOAT等数据类型
	非空约束只能出现在表对象的列上，只能某个列单独限定非空，不能组合非空
	一个表可以有很多列都分别限定了非空
	空字符串''不等于NULL，0也不等于NULL
*/

# 2.4 添加非空约束
/*
(1)建表时
	CREATE TABLE 表名(
	字段名 数据类型,
	字段名 数据类型 NOT NULL,
	字段名 数据类型 NOT NULL
	);
*/
CREATE DATABASE IF NOT EXISTS dbtest13 CHARACTER SET 'utf8';
USE dbtest13;

CREATE TABLE emp(
id INT NOT NULL,
`name` VARCHAR(20) NOT NULL,
sex CHAR NULL
);

CREATE TABLE student(
sid INT,
sname VARCHAR(20) NOT NULL,
tel CHAR(11),
cardid CHAR(18) NOT NULL
);
# 成功
INSERT INTO student VALUES(1, '张三', '13710011002', '110222198912032545');

# 错误代码： 1048	Column 'cardid' cannot be null
INSERT INTO student VALUES(2, '李四', '13710011002', NULL);

# 成功
INSERT INTO student VALUES(2, '李四', NULL, '110222198912032546');

# 错误代码： 1048	Column 'sname' cannot be null
INSERT INTO student VALUES(3, NULL, NULL, '110222198912032547');

SELECT * FROM student;

/*
(2)建表后
	ALTER TABLE 表名称 MODIFY 字段名 数据类型 NOT NULL;
*/

ALTER TABLE emp MODIFY sex CHAR NOT NULL;

DESC emp;

# 2.5 删除非空约束
/*
	ALTER TABLE 表名称 MODIFY 字段名 数据类型 NULL;	# 修改成 NULL

	ALTER TABLE 表名称 MODIFY 字段名 数据类型;	# 去掉 NOT NULL
*/
ALTER TABLE emp MODIFY sex CHAR NULL;

ALTER TABLE emp MODIFY `name` VARCHAR(20);


# 3. 唯一性约束
# 3.1 作用
#	用来限制某个字段/列的值不能重复
# 注意：唯一约束允许出现多个空值NULL

# 3.2 关键字
#	UNIQUE

# 3.3 特点
/*
	同一个表可以有多个唯一约束
	唯一约束可以是某一个列的值唯一，也可以多个列组合的值唯一
	唯一性约束允许列值为空
	在创建唯一约束时，如果不给唯一约束命名，就默认和列名相同
	MySQL会给唯一约束的列上，默认创建一个唯一索引
*/

# 3.4 添加唯一约束
/*
(1)建表时
	CREATE TABLE 表名称(
	字段名 数据类型,
	字段名 数据类型 UNIQUE,		# 列级约束
	字段名 数据类型 UNIQUE KEY,
	字段名 数据类型
	);
	
	CREATE TABLE 表名称(
	字段名 数据类型,
	字段名 数据类型,
	字段名 数据类型,
	字段名 数据类型,
	[CONSTRAINT 约束名] UNIQUE KEY(字段名)	# 表级约束
	);
*/
CREATE TABLE student2(
sid INT,
sname VARCHAR(20),
tel CHAR(11) UNIQUE,
cardid CHAR(18) UNIQUE KEY
);

DESC student2;

CREATE TABLE t_course(
cid INT UNIQUE,
cname VARCHAR(100) UNIQUE,
`description` VARCHAR(200)
);

DESC t_course;

CREATE TABLE `user`(
id INT NOT NULL,
`name` VARCHAR(25),
`password` VARCHAR(16),
CONSTRAINT uk_name_pwd UNIQUE(`name`, `password`)	# 用户名与密码的组合不能重复
);

DESC `user`;

INSERT INTO student2 VALUES(1, '张三', '13710011002', '101223199012015623');

INSERT INTO student2 VALUES(2, '李四', '13710011003', '101223199012015624');

# 错误代码： 1062	Duplicate entry '101223199012015624' for key 'student2.cardid'
INSERT INTO student2 VALUES(3, '王五', '13710011004', '101223199012015624');

#错误代码： 1062	Duplicate entry '13710011003' for key 'student2.tel'
INSERT INTO student2 VALUES(3, '王五', '13710011003', '101223199012015625');

SELECT * FROM student2;

/*
(2)建表后指定唯一键约束
	字段列表中如果是一个字段，表示该列的值唯一，
	如果是两个或更多个字段，那么复合唯一，即多个字段的组合是唯一的
方式1：
	ALTER TABLE 表名称 ADD UNIQUE KEY(字段列表);
方式2：
	ALTER TABLE 表名称 MODIFY 字段名 数据类型 UNIQUE;
*/
ALTER TABLE `user` ADD UNIQUE(`name`, `password`);

ALTER TABLE `user` ADD CONSTRAINT uk_name_pwd UNIQUE(`name`, `password`);

ALTER TABLE `user` MODIFY `name` VARCHAR(25) UNIQUE;

DESC `user`;

CREATE TABLE student3(
sid INT PRIMARY KEY,
sname VARCHAR(20),
tel CHAR(11),
cardid CHAR(18)
);

DESC student3;

# 3.5 关于复合唯一约束
/*
	CREATE TABLE 表名称(
	字段名 数据类型,
	字段名 数据类型,
	字段名 数据类型,
	UNIQUE KEY(字段列表)	# 字段列表中写的是多个字段名，用逗号分隔，表示复合唯一，即多个字段的组合是唯一的
);
*/

CREATE TABLE STUDENT4(
sid INT,
sname VARCHAR(20),
tel CHAR(11) UNIQUE KEY,
cardid CHAR(18) UNIQUE KEY
);

DESC student4;

CREATE TABLE course(
cid INT,
cname VARCHAR(20)
);

DESC course;

CREATE TABLE student_course(
id INT,
sid INT,
cid INT,
score INT,
UNIQUE KEY(sid, cid)	# 复合唯一
);

DESC student_course;

INSERT INTO student4 VALUES(1, '张三', '13710011002', '101223199012015623');
INSERT INTO student4 VALUES(2, '李四', '13710011003', '101223199012015624');
INSERT INTO course VALUES(1001, 'Java'), (1002, 'MySQL');

SELECT * FROM student4;
SELECT * FROM course;

INSERT INTO student_course VALUES
(1, 1, 1001, 89),
(2, 1, 1002, 90),
(3, 2, 1001, 88),
(4, 2, 1002, 56);

SELECT * FROM student_course;

# 错误代码： 1062	Duplicate entry '1-1001' for key 'student_course.sid'
INSERT INTO student_course VALUES(5, 1, 1001, 88);

# 3.6 删除唯一约束
/*
	添加唯一性约束的列也会自动创建唯一索引
	删除唯一约束只能通过删除唯一索引的方式删除
	删除时需要指定唯一索引名，唯一索引名就和唯一约束名一样
	如果创建唯一约束时未指定名称，如果是单列，就默认和列名相同；如果是组合列，那么默认和()中排在第一个的列名相同。也可以自定义唯一性约束名
*/
# 查看表有哪些约束
SELECT * FROM information_schema.table_constraints WHERE TABLE_NAME='user';

# 删除唯一性约束
ALTER TABLE `user` DROP INDEX uk_name_pwd;

SHOW INDEX FROM `user`;


# 4. PRIMARY KEY约束
# 4.1 作用
# 	唯一标识表中的一行记录

# 4.2 关键字
#	PRIMARY KEY

# 4.3 特点
/*
	主键约束 = 非空约束 + 唯一约束
	一个表最多只能有一个主键约束
	主键约束对应表中的一列或者多列(复合主键)
	复合主键中的所有列都不允许为空
	主键名总是PRIMARY，自定义主键约束名无效
	系统默认会在主键约束的列或列组合上建立对应的主键索引，删除主键约束时，主键索引自动删除
	注意不要修改主键字段的值
*/

# 4.4 添加主键约束
/*
(1) 建表时指定主键约束
	CREATE TABLE 表名称(
	字段名 数据类型 PRIMARY KEY,	# 列级模式
	字段名 数据类型,
	字段名 数据类型
	);
	
	CREATE TABLE 表名称(
	字段名 数据类型,
	字段名 数据类型,
	字段名 数据类型,
	[CONSTARINT 约束名] PRIMARY KEY(字段名)	# 表级模式
	);
*/
CREATE TABLE temp(
id INT PRIMARY KEY,
NAME VARCHAR(20)
);

DESC temp;

INSERT INTO temp VALUES(1, "张三");
INSERT INTO temp VALUES(2, "李四");

SELECT * FROM temp;

# 错误代码： 1062	Duplicate entry '1' for key 'temp.PRIMARY'
INSERT INTO temp VALUES(1, "张三");
# 错误代码： 1062	Duplicate entry '1' for key 'temp.PRIMARY'
INSERT INTO temp VALUES(1, "王五");

INSERT INTO temp VALUES(3, "张三");

INSERT INTO temp VALUES(4, NULL);

# 错误代码： 1048	Column 'id' cannot be null
INSERT INTO temp VALUES(NULL, "赵六");

# 错误代码： 1068	Multiple primary key defined
CREATE TABLE temp2(
id INT PRIMARY KEY,
NAME VARCHAR(20) PRIMARY KEY
);

CREATE TABLE emp4(
id INT PRIMARY KEY AUTO_INCREMENT,
NAME VARCHAR(20)
);

DESC emp4;

CREATE TABLE emp5(
id INT NOT NULL AUTO_INCREMENT,
NAME VARCHAR(20),
pwd VARCHAR(15),
CONSTRAINT pk_emp5_id PRIMARY KEY(id)
);

DESC emp5;

SELECT * FROM information_schema.table_constraints WHERE TABLE_NAME = 'emp5';

/*
(2) 建表后增加主键约束
	ALTER TABLE 表名称 ADD PRIMARY KEY(字段列表);
*/

ALTER TABLE student ADD PRIMARY KEY(sid);

DESC student;

# 错误代码： 1068	Multiple primary key defined
ALTER TABLE emp5 ADD PRIMARY KEY(NAME, pwd);

# 4.5 关于复合主键
/*
	CREATE TABLE 表名称(
	字段名 数据类型,
	字段名 数据类型,
	字段名 数据类型,
	PRIMARY KEY(字段1, 字段2, ..., 字段n)
	);
*/
CREATE TABLE student5(
sid INT PRIMARY KEY,
sname VARCHAR(20)
);

CREATE TABLE course5(
cid INT PRIMARY KEY,
cname VARCHAR(20)
);

CREATE TABLE student_course5(
sid INT,
cid INT,
score INT,
PRIMARY KEY(sid, cid)
);

DESC student_course5;

INSERT INTO student5 VALUES(1, "张三"), (2, "李四");
SELECT * FROM student5;

INSERT INTO course5 VALUES(1001, "Java"), (1002, "MySQL");
SELECT * FROM course5;

INSERT INTO student_course5 VALUES
(1, 1001, 89),
(1, 1002, 90),
(2, 1001, 88),
(2, 1002, 56);

SELECT * FROM student_course5;

# 错误代码： 1062	Duplicate entry '1-1001' for key 'student_course5.PRIMARY'
INSERT INTO student_course5 VALUES(1, 1001, 100);

CREATE TABLE emp6(
id INT NOT NULL,
NAME VARCHAR(20),
pwd VARCHAR(15),
CONSTRAINT pk_emp6_name_pwd PRIMARY KEY(NAME, pwd)
);

SELECT * FROM information_schema.table_constraints WHERE TABLE_NAME = 'emp6';

# 4.6 删除主键约束
/*
	ALTER TABLE 表名称 DROP PRIMARY KEY;
*/

ALTER TABLE emp6 DROP PRIMARY KEY;


# 5. 自增列：AUTO_INCREMENT
# 5.1 作用
# 	某个字段的值自增

# 5.2 关键字
# 	AUTO_INCREMENT

# 5.3 特点和要求
/*
	一个表最多只能有一个自增长列
	当需要产生唯一标识符或顺序值时，可设置自增长
	自增长列约束的列必须是键列(主键列，唯一键列)
	自增长列约束的列必须是整数类型
	如果自增列指定了0和null，会在当前最大值的基础上自增；如果自增列手动指定了具体值，直接赋值为具体值
*/
# 错误代码： 1075	Incorrect table definition; there can be only one auto column and it must be defined as a key
CREATE TABLE employee(
eid INT AUTO_INCREMENT,
ename VARCHAR(20)
);

# 错误代码： 1063	Incorrect column specifier for column 'ename'	ename不是整数类型
CREATE TABLE employee(
eid INT PRIMARY KEY,
ename VARCHAR(20) UNIQUE KEY AUTO_INCREMENT
);

# 5.4 如何指定自增约束
/*
(1) 建表时
	CREATE TABLE 表名称(
	字段名 数据类型 PRIMARY KEY AUTO_INCREMENT,
	字段名 数据类型 UNIQUE KEY NOT NULL,
	字段名 数据类型 UNIQUE KEY,
	字段名 数据类型 NOT NULL DEFAULT 默认值
	);
	
	CREATE TABLE 表名称(
	字段名 数据类型 DEFAULT 默认值,
	字段名 数据类型 UNIQUE KEY AUTO_INCREMENT,
	字段名 数据类型 NOT NULL DEFAULT 默认值,
	PRIMARY KEY(字段名)
	);
*/
CREATE TABLE employee(
eid INT PRIMARY KEY AUTO_INCREMENT,
sname VARCHAR(20)
);

DESC employee;

/*
(2) 建表后
	ALTER TABLE 表名称 MODIFY 字段名 数据类型 AUTO_INCREMENT;
*/
CREATE TABLE employee2(
eid INT PRIMARY KEY,
sname VARCHAR(20)
);

ALTER TABLE employee2 MODIFY eid INT AUTO_INCREMENT;

DESC employee2;

# 5.5 如何删除自增约束
# 	ALTER TABLE 表名称 MODIFY 字段名 数据类型;	# 去掉 AUTO_INCREMENT 相当于删除
ALTER TABLE employee MODIFY eid INT;

DESC employee;

# 5.6 MySQL8.0新特性——自增变量的持久化
/*
	在MySQL 8.0之前，自增主键AUTO_INCREMENT的值如果大于max(primary key)+1，在MySQL重启后，会重置AUTO_INCREMENT=max(primary key)+1，原因在于其计数器在内存中
	MySQL 8.0将自增主键的计数器持久化到重要日志中，如果数据库重启，InnoDB会根据重做日志中的信息来初始化计数器的内存值
*/
CREATE TABLE test1(
id INT PRIMARY KEY AUTO_INCREMENT
);

INSERT INTO test1 VALUES(0), (0), (0), (0);

SELECT * FROM test1;	# 1 2 3 4

DELETE FROM test1 WHERE id = 4;

SELECT * FROM test1;	# 1 2 3

INSERT INTO test1 VALUES(0);

SELECT * FROM test1;	# 1 2 3 5

DELETE FROM test1 WHERE id = 5;

SELECT * FROM test1;	# 1 2 3

# 重启数据库，并插入一个空值
INSERT INTO test1 VALUES(0);

SELECT * FROM test1;	# 1 2 3 6


# 6. FOREIGN KEY 约束
# 6.1 作用
#	限定某个表某个字段的引用完整性

# 6.2 关键字
# 	FOREIGN KEY

# 6.3 主表和从表/父表和子表
/*
	主表(父表)：被引用的表，被参考的表
	从表(子表)：引用别人的表，参考别人的表
*/

# 6.4 特点
/*
(1) 从表的外键列，必须引用/参考主表的主键或唯一约束列，因为被依赖/被参考的值必须是唯一的
(2) 在创建外键约束时，如果不给外键约束命名，默认名不是列名，而是自动产生一个外键名，也可以指定外键约束名
(3) 创建表时就指定外键约束的话，先创建主表，再创建从表
(4) 删除表时，先删除从表(或先删除外键约束)，再删除主表
(5) 当主表的记录被从表参照时，主表的记录将不允许删除，如果要删除数据，需要先删除从表中依赖该记录的数据，然后才可以删除主表的数据
(6) 在从表中指定外键约束，并且一个表可以建立多个外键约束
(7) 从表的外键列与主表被参照的列名字可以不相同，但是数据类型必须一样，逻辑意义一致
(8) 当创建外键约束时，系统默认会在所在的列上建立对应的普通索引，索引名是外键的约束名
(9) 删除外键约束后，必须手动删除对应的索引
*/

# 6.5 添加外键约束
/*
(1) 建表时
	CREATE TABLE 主表名称(
	字段1 数据类型 PRIMARY KEY,
	字段2 数据类型
	);
	
	CREATE TABLE 从表名称(
	字段1 数据类型 PRIMARY KEY,
	字段2 数据类型,
	[CONSTRAINT <外键约束名称>] FOREIGN KEY(从表的某个字段) REFERENCES 主表名(被参考字段)
	);
*/
# 主表
CREATE TABLE dept(
did INT PRIMARY KEY,
dname VARCHAR(50)
);

DESC dept;

# 从表
CREATE TABLE emp7(
eid INT PRIMARY KEY,
ename VARCHAR(15),
deptid INT,
FOREIGN KEY(deptid) REFERENCES dept(did)
);

DESC emp7;

# 错误代码： 3730	Cannot drop table 'dept' referenced by a foreign key constraint 'emp7_ibfk_1' on table 'emp7'.
DROP TABLE dept;

/*
(2) 建表后
	ALTER TABLE 从表名 ADD [CONSTRAINT 约束名] FOREIGN KEY(从表字段) REFERENCES 主表名(被引用字段) [ON UPDATE xx] [ON DELETE xx]
*/
CREATE TABLE emp1(
eid INT PRIMARY KEY,
ename VARCHAR(15),
deptid INT
);

DESC emp1;

ALTER TABLE emp1 ADD CONSTRAINT fk_emp1_deptid FOREIGN KEY(deptid) REFERENCES dept(did);

# 6.6 演示问题
# (1) 失败：不是键列
CREATE TABLE dept_1(
did INT,
dname VARCHAR(50)
);

DESC dept_1;

# 错误代码： 1822	Failed to add the foreign key constraint. Missing index for constraint 'emp_1_ibfk_1' in the referenced table 'dept_1'
CREATE TABLE emp_1(
eid INT PRIMARY KEY,
ename VARCHAR(15),
deptid INT,
FOREIGN KEY(deptid) REFERENCES dept_1(did)	# dept_1的did不是键列
);

# (2) 失败：数据类型不一致
CREATE TABLE dept_2(
did INT PRIMARY KEY,
dname VARCHAR(50)
);

DESC dept_2;

# 错误代码： 3780 Referencing column 'deptid' and referenced column 'did' in foreign key constraint 'emp_2_ibfk_1' are incompatible.
CREATE TABLE emp_2(
eid INT PRIMARY KEY,
ename VARCHAR(5),
deptid CHAR,
FOREIGN KEY(deptid) REFERENCES dept_2(did)	# 从表deptid与主表的did字段类型不一致
);

# (3) 成功，两个表字段名一样
CREATE TABLE dept_3(
did INT PRIMARY KEY,
dname VARCHAR(50)
);

CREATE TABLE emp_3(
eid INT PRIMARY KEY,
ename VARCHAR(5),
did INT,
FOREIGN KEY(did) REFERENCES dept_3(did)	# 数据类型一致，是否重名不重要，因为两个did在不同的表中
);

DESC emp_3;

# (4) 添加、删除、修改问题
CREATE TABLE dept_4(
did INT PRIMARY KEY,
dname VARCHAR(50)
);

CREATE TABLE emp_4(
eid INT PRIMARY KEY,
ename VARCHAR(5),
deptid INT,
FOREIGN KEY(deptid) REFERENCES dept_4(did)
);

DESC emp_4;

INSERT INTO dept_4 VALUES(1001, '教学部'), (1002, '财务部');
SELECT * FROM dept_4;

INSERT INTO emp_4 VALUES(1, '张三', 1001);

# 错误代码： 1452	Cannot add or update a child row: a foreign key constraint fails (`dbtest13`.`emp_4`, CONSTRAINT `emp_4_ibfk_1` FOREIGN KEY (`deptid`) REFERENCES `dept_4` (`did`))
INSERT INTO emp_4 VALUES(2, '李四', 1005);	# 主表dept_4中没有1005部门，从表插入失败

SELECT * FROM emp_4;

# 错误代码： 1452	Cannot add or update a child row: a foreign key constraint fails (`dbtest13`.`emp_4`, CONSTRAINT `emp_4_ibfk_1` FOREIGN KEY (`deptid`) REFERENCES `dept_4` (`did`))
UPDATE emp_4 SET deptid = 1003 WHERE eid = 1;	# 主表dept_4中没有1003部门，从表修改失败

# 错误代码： 1451	Cannot delete or update a parent row: a foreign key constraint fails (`dbtest13`.`emp_4`, CONSTRAINT `emp_4_ibfk_1` FOREIGN KEY (`deptid`) REFERENCES `dept_4` (`did`))
UPDATE dept_4 SET did = 1003 WHERE did = 1001;	# 从表emp_4中引用了1001，主表修改失败

UPDATE dept_4 SET did = 1003 WHERE did = 1002;	# 主表1002未被引用，主表修改成功

# 错误代码： 1451	Cannot delete or update a parent row: a foreign key constraint fails (`dbtest13`.`emp_4`, CONSTRAINT `emp_4_ibfk_1` FOREIGN KEY (`deptid`) REFERENCES `dept_4` (`did`))
DELETE FROM dept_4 WHERE did = 1001;		# 从表emp_4中引用了1001，主表删除失败

/*
总结：
	添加了外键约束后，主表的修改和删除数据受约束
	添加了外键约束后，从表的添加和修改数据受约束
	在从表上建立外键，要求主表必须存在
	删除主表时，要求从表先删除，或将从表中外键引用该主表的关系先删除
*/

# 6.7 约束等级
/*
	Cascade方式：	 在父表上update/delete记录时，同步update/delete掉子表的匹配记录
	Set null方式：	 在父表上update/delete记录时，将子表中匹配记录的列设为null，但要注意子表的外键列不能为not null
	No action方式：	 如果子表中有匹配的记录，则不允许对父表对应候选键进行update/delete操作
	Restrict方式：	 同no action，都是立即检查外键约束
	Set default方式：父表有变化时，子表将外键列设置成一个默认的值，但Innodb不能识别
	
	如果没有指定等级，就相当于Restrict方式
	对于外键约束，最好采用：ON UPDATE CASCADE ON DELETE RESTRICT 方式
*/

# 演示(1): on update cascade on delete set null
CREATE TABLE dept_5(
did INT PRIMARY KEY,
dname VARCHAR(50)
);

CREATE TABLE emp_5(
eid INT PRIMARY KEY,
ename VARCHAR(5),
deptid INT,
FOREIGN KEY(deptid) REFERENCES dept_5(did) ON UPDATE CASCADE ON DELETE SET NULL
);

DESC emp_5;

INSERT INTO dept_5 VALUES
(1001, '教学部'),
(1002, '财务部'),
(1003, '咨询部');

INSERT INTO emp_5 VALUES
(1, '张三', 1001),
(2, '李四', 1001),
(3, '王五', 1002);

SELECT * FROM dept_5;
SELECT * FROM emp_5;

# 修改主表成功，从表也跟着修改
UPDATE dept_5 SET did = 1004 WHERE did = 1002;

SELECT * FROM dept_5;
SELECT * FROM emp_5;	# 从表中1002修改成了1004

# 删除主表记录成功，从表记录对应字段被修改为null
DELETE FROM dept_5 WHERE did = 1001;

SELECT * FROM dept_5;
SELECT * FROM emp_5;	# 原来1001好部门的员工，现在deptid字段被修改为null

# (2) 演示：on update set null on delete cascade
CREATE TABLE dept_6(
did INT PRIMARY KEY,
dname VARCHAR(50)
);

CREATE TABLE emp_6(
eid INT PRIMARY KEY,
ename VARCHAR(5),
deptid INT,
FOREIGN KEY(deptid) REFERENCES dept_6(did) ON UPDATE SET NULL ON DELETE CASCADE
);

INSERT INTO dept_6 VALUES
(1001, '教学部'),
(1002, '财务部'),
(1003, '咨询部');

INSERT INTO emp_6 VALUES
(1, '张三', 1001),
(2, '李四', 1001),
(3, '王五', 1002);

SELECT * FROM dept_6;
SELECT * FROM emp_6;

# 成功修改主表，从表记录对应字段被设置成null
UPDATE dept_6 SET did = 1004 WHERE did = 1002;
SELECT * FROM dept_6;
SELECT * FROM emp_6;	# 原deptid是1002的字段被设置成null

# 成功删除主表记录，从表对应记录也被删除
DELETE FROM dept_6 WHERE did = 1001;
SELECT * FROM dept_6;
SELECT * FROM emp_6;	# 原deptid是1001的记录也被删除了

# (3) 演示：on update cascade on delete cascade
CREATE TABLE dept_7(
did INT PRIMARY KEY,
dname VARCHAR(50)
);

CREATE TABLE emp_7(
eid INT PRIMARY KEY,
ename VARCHAR(5),
deptid INT,
FOREIGN KEY(deptid) REFERENCES dept_7(did) ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO dept_7 VALUES
(1001, '教学部'),
(1002, '财务部'),
(1003, '咨询部');

INSERT INTO emp_7 VALUES
(1, '张三', 1001),
(2, '李四', 1001),
(3, '王五', 1002);

SELECT * FROM dept_7;
SELECT * FROM emp_7;

# 修改主表成功，从表对应字段也被修改
UPDATE dept_7 SET did = 1004 WHERE did = 1002;
SELECT * FROM dept_7;
SELECT * FROM emp_7;	# 原来deptid为1002的字段被修改成了1004

# 删除主表成功，从表对应记录也被删除
DELETE FROM dept_7 WHERE did = 1001;
SELECT * FROM dept_7;
SELECT * FROM emp_7;	# 原来deptid为1001的记录也被删除

# 6.8 删除外键约束
/*
(1) 查看约束名和删除外键约束
	SELECT * FROM information_schema.table_constraints WHERE table_name = '表名称';
	
	ALTER TABLE 从表名 DROP FOREIGN KEY 外键约束名;
	
(2) 查看索引名和删除索引（注意，只能手动删除）
	SHOW INDEX FROM 表名称;
	
	ALTER TABLE 从表名 DROP INDEX 索引名;
*/
SELECT * FROM information_schema.table_constraints WHERE TABLE_NAME = 'emp_7';

ALTER TABLE emp_7 DROP FOREIGN KEY emp_7_ibfk_1;

SHOW INDEX FROM emp_7;

ALTER TABLE emp_7 DROP INDEX deptid;


# 7. CHECK 约束
# 7.1 作用
#	检查某个字段的值是否符合xx要求，一般指的是值的范围

# 7.2 关键字
# 	CHECK

# 7.3 说明：MySQL 5.7 不支持
/*
	MySQL 5.7 可以使用check约束，但check约束对数据验证没有任何作用。添加数据时，没有任何错误或警告
	MySQL 8.0 中可以使用CHECKY约束
*/
# 错误代码： 3813	Column check constraint 'employee1_chk_1' references other column.
CREATE TABLE employee1(
eid INT PRIMARY KEY,
ename VARCHAR(5),
gender CHAR CHECK('男' OR '女')
);

# 成功
CREATE TABLE employee1(
eid INT PRIMARY KEY,
ename VARCHAR(5),
gender CHAR CHECK(gender IN ('男', '女'))
);

# 错误代码： 3819	Check constraint 'employee1_chk_1' is violated.
INSERT INTO employee1 VALUES(1, '张三', '妖');

INSERT INTO employee1 VALUES(1, '张三', '男');

SELECT * FROM employee1;


# 8. DEFAULT 约束
# 8.1 作用
# 	给某个字段/某列指定默认值，一旦设置默认值，在插入数据时，如果此字段没有显示赋值，则赋值为默认值	

# 8.2 关键字
# 	DEFAULT

# 8.3 如何给字段加默认值
/*
(1) 建表时
	CREATE TABLE 表名称(
	字段名 数据类型 PRIMARY KEY,
	字段名 数据类型 UNIQUE KEY NOT NULL,
	字段名 数据类型 UNIQUE KEY,
	字段名 数据类型 NOT NULL DEFAULT 默认值
	);
	
	CREATE TABLE 表名称(
	字段名 数据类型 DEFAULT 默认值,
	字段名 数据类型 NOT NULL DEFAULT 默认值,
	字段名 数据类型 NOT NULL DEFAULT 默认值,
	PRIMARY KEY(字段名),
	UNIQUE KEY(字段名)
	);
	
	说明：默认值约束一般不在唯一键和主键列上加
*/
CREATE TABLE employee3(
eid INT PRIMARY KEY,
ename VARCHAR(20) NOT NULL,
gender CHAR DEFAULT '男',
tel CHAR(11) NOT NULL DEFAULT ''	# 默认是空字符串
);

DESC employee3;

INSERT INTO employee3 VALUES(1, '张三', '男', '13700102535');

SELECT * FROM employee3;

INSERT INTO employee3(eid, ename) VALUES(2, '李四');

INSERT INTO employee3(eid, ename) VALUES(3, '王五');

CREATE TABLE myemp(
id INT AUTO_INCREMENT PRIMARY KEY,
NAME VARCHAR(15),
salary DECIMAL(10,2) DEFAULT 2000
);

DESC myemp;

/*
(2) 建表后
	ALTER TABLE 表名称 MODIFY 字段名 数据类型 DEFAULT 默认值;
	#如果这个字段原来有非空约束，你还保留非空约束，那么在加默认值约束时，还得保留非空约束，否则非空约束就被删除了
	#同理，在给某个字段加非空约束也一样，如果这个字段原来有默认值约束，你想保留，也要在modify语句中保留默认值约束，否则就删除了
	
	ALTER TABLE 表名称 MODIFY 字段名 数据类型 DEFAULT 默认值 NOT NULL;
*/
CREATE TABLE employee4(
eid INT PRIMARY KEY,
ename VARCHAR(20),
gender CHAR,
tel CHAR(11) NOT NULL
);

DESC employee4;

ALTER TABLE employee4 MODIFY gender CHAR DEFAULT '男';

ALTER TABLE employee4 MODIFY tel CHAR(11) DEFAULT '';	# 同时删除了非空约束

ALTER TABLE employee4 MODIFY tel CHAR(11) DEFAULT '' NOT NULL;

# 8.4 如何删除
/*
	ALTER TABLE 表名称 MODIFY 字段名 数据类型;	# 删除默认值约束，也不保留非空约束
	
	ALTER TABLE 表名称 MODIFY 字段名 数据类型 NOT NULL;	# 删除默认值约束，保留非空约束
*/
ALTER TABLE employee4 MODIFY gender CHAR;

ALTER TABLE employee4 MODIFY tel CHAR(11) NOT NULL;

DESC employee4;
