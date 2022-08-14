# 第12章_MySQL数据类型精讲


# 1. MySQL中的数据类型


# 2. 整数类型
# 2.1 类型介绍
/*
 	TINYINT, SMALLINT, MEDIUMINT, INT(INTEGER), BIGINT
	1字节	 2字节	   3字节      4字节	    8字节
*/

# 2.2 可选属性
# 2.2.1 M
/*
	M：表示显示宽度，取值范围(0, 255)
	   该项功能需要配合“ ZEROFILL ”使用，表示用“0”填满宽度，否则指定显示宽度无效
	如果设置了显示宽度，插入的数据宽度超过显示宽度限制，不会对插入的数据有任何影响，
	还是按照类型的实际宽度进行保存，即显示宽度与类型可以存储的值范围无关。
	从MySQL 8.0.17开始，整数数据类型不推荐使用显示宽度属性
*/
CREATE DATABASE IF NOT EXISTS mytest12 CHARACTER SET 'utf8';
USE mytest12;

CREATE TABLE test_int1(
X TINYINT,
Y SMALLINT,
z MEDIUMINT,
m INT,
n BIGINT
);

DESC test_int1;

CREATE TABLE test_int2(
f1 INT,
f2 INT(5),
f3 INT(5) ZEROFILL
);

DESC test_int2;

INSERT INTO test_int2(f1, f2, f3)
VALUES(1, 123, 123);

INSERT INTO test_int2(f1, f2)
VALUES(123456, 123456);

INSERT INTO test_int2(f1, f2, f3)
VALUES(123456, 123456, 123456);

SELECT * FROM test_int2;

# 2.2.2 UNSIGNED
CREATE TABLE test_int3(
f1 INT UNSIGNED
);

DESC test_int3;

# 2.2.3 ZEROFILL
# 0填充：如果指定了ZEROFILL只是表示不够M位时，用0在左边填充，如果超过M位，只要不超过数据存储范围即可

# 2.3 适用场景

# 2.4 如何选择


# 3. 浮点类型
# 3.1 类型介绍
/*
	FLOAT, DOUBLE, REAL
	4字节  8字节
	REAL默认是DOUBLE，如果把SQL模式设定为"REAL_AS_FLOAT"，那么MySQL就认为REAL是FLOAT
	SET sql_mode = "REAL_AS_FLOAT";
*/

# 3.2 数据精度说明
CREATE TABLE test_double1(
f1 FLOAT,
f2 FLOAT(5,2),
f3 DOUBLE,
f4 DOUBLE(5,2)
);

DESC test_double1;

INSERT INTO test_double1
VALUES(123.456, 123.456, 123.4567, 123.45);

# 错误：Out of range value for column 'f2' at row 1
INSERT INTO test_double1
VALUES(123.456, 1234.456, 123.4567, 123.45);

SELECT * FROM test_double1;

# 3.3 精度误差说明
#	浮点数不精准
CREATE TABLE test_double2(
f1 DOUBLE
);

INSERT INTO test_double2
VALUES
(0.47),
(0.44),
(0.19);

SELECT * FROM test_double2;

SELECT SUM(f1)
FROM test_double2;

SELECT SUM(f1)=1.1, 1.1=1.1
FROM test_double2;


# 4. 定点数类型
# 4.1 类型介绍
#	DECIMAL(M,D)	M+2字节		默认为DECIMAL(10,0)
#	定点数以字符串形式存储，是精准的
CREATE TABLE test_decimal1(
f1 DECIMAL,
f2 DECIMAL(5,2)
);

DESC test_decimal1;

INSERT INTO test_decimal1(f1, f2)
VALUES(123.123, 123.456);

# 错误：Out of range value for column 'f2' at row 1
INSERT INTO test_decimal1(f2)
VALUES(1234.34);

SELECT * FROM test_decimal1;

ALTER TABLE test_double2
MODIFY f1 DECIMAL(5,2);

SELECT SUM(f1), SUM(f1)=1.1
FROM test_double2;

# 4.2 开发中经验
#	由于精确性，一般使用DECIMAL


# 5. 位类型：BIT
#	BIT(M)	长度：M位，默认1位 (1<=M<=64)	占用空间约：(M+7)/8 字节
CREATE TABLE test_bit1(
f1 BIT,
f2 BIT(5),
f3 BIT(64)
);

DESC test_bit1;

INSERT INTO test_bit1(f1)
VALUES(1);

# error: Data too long for column 'f1' at row 1
INSERT INTO test_bit1(f1)
VALUES(2);

INSERT INTO test_bit1(f2)
VALUES(23);

SELECT * FROM test_bit1;

SELECT BIN(f1), HEX(f1), BIN(f2), HEX(f2)
FROM test_bit1;

SELECT f1+0
FROM test_bit1;	# 使用b+0查询数据时，可查询出对应的十进制数值


# 6. 日期与时间类型
#	YEAR, TIME, DATE, DATETIME, TIMESTAMP
# 6.1 YEAR类型
#	1个字节，默认格式“YYYY”，没必要写成YEAR(4)
#	推荐使用4位格式形式，不用2位格式形式
CREATE TABLE test_year(
f1 YEAR,
f2 YEAR(4)
);

DESC test_year;

INSERT INTO test_year
VALUES('2020', '2021');

SELECT * FROM test_year;

INSERT INTO test_year
VALUES('45', '71');

INSERT INTO test_year
VALUES(0, '0');

# 6.2 DATE类型
#	3个字节，格式：YYYY-MM-DD
CREATE TABLE test_date1(
f1 DATE
);

DESC test_date1;

INSERT INTO test_date1
VALUES
('2020-10-01'),
('20201001'),
(20201001);

SELECT * FROM test_date1;

INSERT INTO test_date1
VALUES
('00-01-01'),
('000101'),
('69-10-01'),
('691001'),
('70-01-01'),
('700101'),
('99-01-01'),
('990101');

INSERT INTO test_date1
VALUES
(000301),
(690301),
(700301),
(990301);

INSERT INTO test_date1
VALUES
(CURRENT_DATE()),
(NOW());

# 6.3 TIME类型
#	3个字节	格式：“HH:MM:SS”
CREATE TABLE test_time1(
f1 TIME
);

DESC test_time1;

INSERT INTO test_time1
VALUES
('2 12:30:29'),
('12:35:29'),
('12:40'),
('2 12:40'),
('1 05'),
('45');

INSERT INTO test_time1
VALUES
('123520'),
(124011),
(1210);

SELECT * FROM test_time1;

INSERT INTO test_time1
VALUES
(NOW()),
(CURRENT_TIME());

# 6.4 DATETIME类型
#	8字节	格式：“YYYY-MM-DD HH:MM:SS”
CREATE TABLE test_datetime1(
dt DATETIME
);

DESC test_datetime1;

INSERT INTO test_datetime1
VALUES
('2021-01-01 06:50:30'),
(20210101065030);

INSERT INTO test_datetime1
VALUES
('99-01-01 00:00:00'),
('990101000000'),
('20-01-01 00:00:00'),
('200101000000');

INSERT INTO test_datetime1
VALUES
(20200101000000),
(200101000000),
(19990101000000),
(990101000000);

INSERT INTO test_datetime1
VALUES
(CURRENT_TIMESTAMP()),
(NOW());

SELECT * FROM test_datetime1;

# 6.5 TIMESTAMP类型
#	4字节	格式：“YYYY-MM-DD HH:MM:SS”
#	只能存储“1970-01-01 00:00:01 UTC” 到 “2038-01-19 03:14:07 UTC”之间的时间
CREATE TABLE test_timestamp1(
ts TIMESTAMP
);

DESC test_timestamp1;

INSERT INTO test_timestamp1
VALUES
('1999-01-01 03:04:05'),
('19990101030405'),
('99-01-01 03:04:05'),
('990101030405');

INSERT INTO test_timestamp1
VALUES
('2020@01@01@00@00@00'),
('20@01@01@00@00@00');

INSERT INTO test_timestamp1
VALUES
(CURRENT_TIMESTAMP()),
(NOW());

# error: Incorrect datetime value: '2038-01-20 03:14:07' for column 'ts' at row 1
INSERT INTO test_timestamp1
VALUES('2038-01-20 03:14:07');

SELECT * FROM test_timestamp1;

# 6.6 开发中经验
# 	尽量使用 DATETIME
#	一般存注册时间、商品发布时间等，不建议使用DATETIME存储，而是使用时间戳，因为DATETIME虽然直观，但不便于计算
SELECT UNIX_TIMESTAMP();	# 时间戳


# 7. 文本字符串类型
# 	CHAR, VARCHAR, TINYTEXT, TEXT, MEDIUMTEXT, LONGTEXT, ENUM, SET
# 7.1 CHAR与VARCHAR类型
/*
	CHAR(M):	固定长度	M个字节
	VARCHAR(M):	可变长度	(实际长度+1)个字节
*/
# CHAR类型：
CREATE TABLE test_char1(
c1 CHAR,
c2 CHAR(5)
);

DESC test_char1;

INSERT INTO test_char1
VALUES('a', 'Tom');

SELECT * FROM test_char1;

SELECT c1, CONCAT(c2, '***') FROM test_char1;

INSERT INTO test_char1(c2)
VALUES('a  ');	# 会去除尾部空格，所以长度为1

SELECT CHAR_LENGTH(c2)
FROM test_char1;

# VARCHAR类型：
#	必须指定长度M
CREATE TABLE test_varchar1(
`name` VARCHAR	# error
);

# error: Column length too big for column 'name' (max = 21845); use BLOB or TEXT instead
CREATE TABLE test_varchar2(
`name` VARCHAR(65535)
);

CREATE TABLE test_varchar3(
`name` VARCHAR(5)
);

DESC test_varchar3;

INSERT INTO test_varchar3
VALUES
('尚硅谷'),
('尚硅谷教育');

SELECT * FROM test_varchar3;

# error：Data too long for column 'name' at row 1
INSERT INTO test_varchar3
VALUES('尚硅谷IT教育');

# 7.2 TEXT类型
CREATE TABLE test_text(
tx TEXT
);

DESC test_text;

INSERT INTO test_text
VALUES('atguigu   ');

SELECT CHAR_LENGTH(tx)
FROM test_text;	# 10, 不删除尾部空格


# 8. ENUM类型
CREATE TABLE test_enum(
season ENUM('春', '夏', '秋', '冬')
);

DESC test_enum;

INSERT INTO test_enum
VALUES
('春'),
('秋');

SELECT * FROM test_enum;

# error: Data truncated for column 'season' at row 1
INSERT INTO test_enum
VALUES('UNKNOW');

# 按照角标的方式获取指定索引位置的枚举值
INSERT INTO test_enum
VALUES
('1'),
(3);

# error: Data truncated for column 'season' at row 1
INSERT INTO test_enum
VALUES('ab');

# 当ENUM类型字段未被声明为NOT NULL时，插入NULL也是有效的
INSERT INTO test_enum
VALUES(NULL);


# 9. SET类型
CREATE TABLE test_set(
s SET('A', 'B', 'C')
);

DESC test_set;

INSERT INTO test_set(s)
VALUES
('A'),
('A,B');	# ,和B之间不能有空格

SELECT * FROM test_set;

# 自动删除重复的成员
INSERT INTO test_set(s)
VALUES('A,B,C,A');

# error：Data truncated for column 's' at row 1
INSERT INTO test_set(s)
VALUES('A,B,C,D');

CREATE TABLE temp_mul(
gender ENUM('男', '女'),
hobby SET('吃饭', '睡觉', '打豆豆', '写代码')
);

DESC temp_mul;

INSERT INTO temp_mul
VALUES('男', '睡觉,打豆豆');	# 字符串内的逗号不能时中文的

# error
INSERT INTO temp_mul
valuyes('男,女', '睡觉,打豆豆');

# error
INSERT INTO temp_mul
VALUES('妖', '睡觉,打豆豆');

INSERT INTO temp_mul
VALUES('男', '睡觉,打豆豆,写代码');

SELECT * FROM temp_mul;


# 10. 二进制字符串类型
#	BINARY, VARBINARY, TINTBLOB, BLOB, MEDIUMBLOB, LONGBLOB

# BINARY与VARBINARY类型
#	BINARY(M)	固定长度	M个字节		未指定M，存储一个字节
#	VARBINARY(M)	可变长度	M+1个字节	未指定M，报错
CREATE TABLE test_binary1(
f1 BINARY,
f2 BINARY(3),
#f3 varbinary,
f4 VARBINARY(10)
);

DESC test_binary1;

INSERT INTO test_binary1(f1, f2)
VALUES('a', 'a');

# error: Data too long for column 'f1' at row 1
INSERT INTO test_binary1(f1, f2)
VALUES('尚', '尚');

INSERT INTO test_binary1(f2, f4)
VALUES('ab', 'ab');

SELECT * FROM test_binary1;

SELECT LENGTH(f2), LENGTH(f4)
FROM test_binary1;

# BLOB类型
#	二进制大对象	图片、音频、视频等
#	实际应用中，不会直接存文件，而是存储文件的路径
CREATE TABLE test_blob1(
id INT,
img MEDIUMBLOB
);

DESC test_blob1;


# 11. JSON类型
#	一种轻量级的数据交换格式
CREATE TABLE test_json(
js JSON
);

INSERT INTO test_json(js)
VALUES('{"name":"songhk", "age":18, "address":{"province":"beijing", "city":"beijing"}}');

SELECT * FROM test_json;

SELECT js->'$.name' AS NAME, js->'$.age' AS age, js->'$.address.province' AS province, js->'$.address.city' AS city
FROM test_json;


# 12. 空间类型


# 13. 小结及选择建议
/*
	整数 使用 INT
	小数 使用 DECIMAL(M,D)
	日期与时间 使用 DATETIME
*/


















