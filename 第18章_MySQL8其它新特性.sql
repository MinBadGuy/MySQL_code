# 第18章_MySQL8其它新特性


# 1. MySQL8新特性概述

# 1.1 MySQL8.0新增特性
/*
- 更简便的NoSQL支持
- 更好的索引
- 更完善的JSON支持
- 安全和账户管理
- InnoDB的变化
- 数据字典
- 原子数据定义语句
- 资源管理
- 字符集支持
- 优化器增强
- 公用表表达式
- 窗口函数
- 正则表达式支持
- 内部临时表
- 日志记录
- 备份锁
- 增强的MySQL复制
*/ 

# 1.2 MySQL8.0移除的旧特性
/*
- 查询缓存
- 加密相关
- 空间函数相关
- \N和NULL
- mysql_install_sb
- 通用分区处理程序
- 系统和状态变量信息
- mysql_plugin工具
*/


# 2. 新特性1：窗口函数
# 2.1 使用窗口函数前后对比
CREATE DATABASE dbtest18;
USE dbtest18;

# sales表显示了某购物网站在每个城市每个区的销售额
CREATE TABLE sales(
id INT PRIMARY KEY AUTO_INCREMENT,
city VARCHAR(15),
country VARCHAR(15),
sales_value DECIMAL
);

INSERT INTO sales(city, country, sales_value)
VALUES
('北京', '海淀', 10.00),
('北京', '朝阳', 20.00),
('上海', '黄埔', 30.00),
('上海', '长宁', 10.00);

SELECT * FROM sales;

# 需求：计算这个网站在每个城市的销售总额、在全国的销售总额、每个区的销售额占所在城市销售额中的比率，以及占总销售额中的比率

# 方式1：使用分组和聚合函数
# ① 计算总销售金额，并存入临时表
CREATE TEMPORARY TABLE a
SELECT SUM(sales_value) AS sales_value
FROM sales;

SELECT * FROM a;

# ② 计算每个城市的销售总额并存入临时表b
CREATE TEMPORARY TABLE b
SELECT city, SUM(sales_value) AS sales_value
FROM sales
GROUP BY city;

SELECT * FROM b;

# ③ 计算各区的销售占所在城市的总计金额的比例，和占全部销售总计金额的比例
SELECT s.city AS 城市, s.country AS 区, s.sales_value AS 区销售额,
b.sales_value AS 市销售额, s.sales_value / b.sales_value AS 市比率, 
a.sales_value AS 总销售额, s.sales_value / a.sales_value AS 总比率
FROM sales s
JOIN b ON s.city = b.city
JOIN a
ORDER BY s.city, s.country;

# 方式2：使用窗口函数
SELECT city AS 城市, country AS 区, sales_value AS 区销售额,
SUM(sales_value) OVER(PARTITION BY city) AS 市销售额, -- 计算市销售额
sales_value / SUM(sales_value) OVER(PARTITION BY city) AS 市比率,
SUM(sales_value) OVER() AS 总销售额, -- 计算总销售额
sales_value / SUM(sales_value) OVER() AS 总比率
FROM sales
ORDER BY city, country;

# 2.2 窗口函数分类
/*
- 静态窗口函数：窗口大小是固定的，不会因为记录的不同而不同
- 动态窗口函数：窗口大小会随着记录的不同而不同

- 序号函数：ROW_NUMBER(), RANK(), DENSE_RANK()
- 分布函数：PERCENT_RANK(), CUME_DIST()
- 前后函数：LAG(expr, n), LEAD(expr, n)
- 首尾函数：FIRST_VALUE(expr), LAST_VALUE(expr)
- 其他函数：NTH_VALUE(expr, n), NTILE(n) 
*/

# 2.3 语法结构
/*
	函数 OVER([PARTITION BY 字段名 ORDER BY 字段名 ASC|DESC])
	函数 OVER 窗口名 ... WINDOW 窗口名 AS ([PARTITION BY 字段名 ORDER BY 字段名 ASC|DESC])
	
*/

# 2.4 分类讲解
CREATE TABLE goods(
id INT PRIMARY KEY AUTO_INCREMENT,
category_id INT,
category VARCHAR(15),
NAME VARCHAR(30),
price DECIMAL(10,2),
stock INT,
upper_time DATETIME
);

INSERT INTO goods(category_id, category, NAME, price, stock, upper_time)
VALUES
(1, '女装/女士精品', 'T恤', 39.90, 1000, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '连衣裙', 79.90, 2500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '卫衣', 89.90, 1500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '牛仔裤', 89.90, 3500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '百褶裙', 29.90, 500, '2020-11-10 00:00:00'),
(1, '女装/女士精品', '呢绒外套', 399.90, 1200, '2020-11-10 00:00:00'),
(2, '户外运动', '自行车', 399.90, 1000, '2020-11-10 00:00:00'),
(2, '户外运动', '山地自行车', 1399.90, 2500, '2020-11-10 00:00:00'),
(2, '户外运动', '登山杖', 59.90, 1500, '2020-11-10 00:00:00'),
(2, '户外运动', '骑行装备', 399.90, 3500, '2020-11-10 00:00:00'),
(2, '户外运动', '运动外套', 799.90, 500, '2020-11-10 00:00:00'),
(2, '户外运动', '滑板', 499.90, 1200, '2020-11-10 00:00:00');

SELECT * FROM goods;

# 2.4.1 序号函数
# 2.4.1.1 ROW_NUMBER()函数
/*
	对数据中的序号进行顺序显示
*/
# 举例：查询 goods 数据表中每个商品分类下价格降序排列的各个商品信息
SELECT ROW_NUMBER() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
id, category_id, category, NAME, price, stock
FROM goods;

# 举例：查询 goods 数据表中每个商品分类下价格最高的3种商品信息
SELECT * 
FROM (SELECT ROW_NUMBER() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
	id, category_id, category, NAME, price, stock
	FROM goods) t
WHERE t.row_num <= 3;

# 2.4.1.2 RANK()函数
/*
	对序号进行并列排序，并且会跳过重复的序号，比如序号为1、1、3
*/
# 举例：使用RANK()函数获取 goods 数据表中各类别的价格从高到低排序的各商品信息
SELECT RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
id, category_id, category, NAME, price, stock
FROM goods;

# 使用RANK()函数获取 goods 数据表中类别为“女装/女士精品”的价格最高的4款商品信息
SELECT * 
FROM (SELECT RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
	id, category_id, category, NAME, price, stock
	FROM goods) t
WHERE t.category = '女装/女士精品' AND t.row_num <=4;

# 2.4.1.3 DENSE_RANK()函数
/*
	对序号进行并序排序，并且不会跳过重复的序号，比如序号为1、1、2
*/
# 举例：使用DENSE_RANK()函数获取 goods 数据表中各类别的价格从高到低排序的各商品信息
SELECT DENSE_RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
id, category_id, category, NAME, price, stock
FROM goods;

# 举例：使用DENSE_RANK()函数获取 goods 数据表中类别为“女装/女士精品”的价格最高的4款商品信息
SELECT * 
FROM (SELECT DENSE_RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS row_num,
	id, category_id, category, NAME, price, stock
	FROM goods) t
WHERE t.category = '女装/女士精品' AND t.row_num <=3;

# 2.4.2 分布函数
# 2.4.2.1 PERCENT_RANK()函数
/*
	等级值百分比函数
	计算方式：(rank - 1) / (rows -1)
	rank的值为使用RANK()函数产生的序号，rows的值为当前窗口的总记录数
*/

# 计算 goods 数据表中名称为“女装/女士精品”的类别下的商品的PERCENT_RANK值
# 写法1：
SELECT RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS r,
PERCENT_RANK() OVER(PARTITION BY category_id ORDER BY price DESC) AS pr,
id, category_id, category, NAME, price, stock
FROM goods
WHERE category = '女装/女士精品';

# 写法2：
SELECT RANK() OVER w AS r,
PERCENT_RANK() OVER w AS pr,
id, category_id, category, NAME, price, stock
FROM goods
WHERE category = '女装/女士精品' WINDOW w AS (PARTITION BY category_id ORDER BY price DESC);

# 2.4.2.2 CUME_DIST()函数
/*
	查询小于或等于某个值的比例
*/
SELECT CUME_DIST() OVER(PARTITION BY category_id ORDER BY price DESC) AS cd,
id, category_id, category, NAME, price, stock
FROM goods;

# 2.4.3 前后函数
# 2.4.3.1 LAG(expr, n)函数
/*
	返回当前行的前n行的expr的值
*/
# 举例：查询goods数据表中前一个商品价格与当前商品价格的差值
SELECT id, category, NAME, price, pre_price, price - pre_price AS diff_price
FROM (SELECT id, category, NAME, price, LAG(price, 1) OVER w AS pre_price
	FROM goods
	WINDOW w AS (PARTITION BY category_id ORDER BY price)) t;
	
# 2.4.3.2 LEAD(expr, n)函数
/*
	返回当前行的后n行的expr的值
*/
# 举例：查询goods数据表中后一个商品价格与当前商品价格的差值
SELECT id, category, NAME, price, post_price, post_price - price AS diff_price
FROM (SELECT id, category, NAME, price, LEAD(price, 1) OVER w AS post_price
	FROM goods
	WINDOW w AS (PARTITION BY category_id ORDER BY price)) t;
	
# 2.4.4 首尾函数
# 2.4.4.1 FIRST_VALUE(expr)函数
/*
	返回第一个expr的值
*/
# 举例：按照价格排序，查询第1个商品的价格信息
SELECT id, category, NAME, price, stock, FIRST_VALUE(price) OVER w AS first_price
FROM goods
WINDOW w AS (PARTITION BY category_id ORDER BY price);

# 2.4.4.2 LAST_VALUE(expr)函数
/*
	返回最后一个expr的值
*/
# 当前最后一个值即当前值，所以last_price和price的值相同。
SELECT id, category, NAME, price, stock, LAST_VALUE(price) OVER w AS last_price
FROM goods
WINDOW w AS (PARTITION BY category_id ORDER BY price);

# 2.4.5 其他函数
# 2.4.5.1 NTH_VALUE(expr, n)函数
/*
	返回第n个expr的值
*/
# 举例：查询goods数据表中排名第2和第3的价格信息
SELECT id, category, NAME, price, 
NTH_VALUE(price, 2) OVER w AS second_price,
NTH_VALUE(price, 3) OVER w AS third_price
FROM goods
WINDOW w AS (PARTITION BY category_id ORDER BY price);

# 2.4.5.2 NTILE(n)函数
/*
	将分区中的有序数据分为n个桶，记录桶编号
*/
# 举例：将goods表中的商品按照价格分为3组
SELECT NTILE(3) OVER w AS nt, id, category, NAME, price
FROM goods
WINDOW w AS (PARTITION BY category_id ORDER BY price); 

# 2.5 小结
/*
窗口函数的特点是可以分组，而且可以在分组内排序
窗口函数不会因为分组而减少原表中的行数
*/

# 3. 新特性2：公用表表达式
/*
公用表表达式（或通用表表达式）简称为CTE（Common Table Expressions）。
CTE是一个命名的临时结果集，作用范围是当前语句。
CTE可以理解成一个可以复用的子查询，当然跟子查询还是有点区别的，CTE可以引用其他CTE，但子查询不能引用其他子查询。所以，可以考虑代替子查询。
依据语法结构和执行方式的不同，公用表表达式分为 `普通公用表表达式` 和 `递归公用表表达式` 2 种
*/
# 3.1 普通公用表表达式
/*
语法：
	WITH CTE名称
	AS (子查询)
	SELECT | DELETE | UPDATE语句;
*/
# 举例：查询员工所在的部门的详细信息
CREATE TABLE departments AS SELECT * FROM atguigudb.departments;
CREATE TABLE employees AS SELECT * FROM atguigudb.employees;

# 子查询方法：
SELECT * FROM departments
WHERE department_id IN (SELECT DISTINCT department_id 
			FROM employees);

# 普通公用表表达式：
WITH emp_dept_id
AS (SELECT DISTINCT department_id FROM employees)
SELECT * 
FROM departments d
JOIN emp_dept_id e
ON d.department_id = e.department_id;

# 3.2 递归公用表表达式
/*
可以自己调用自己
语法：
	WITH RECURSIVE
	CTE名称 AS (子查询)
	SELECT | DELETE | UPDATE语句;
递归公用表表达式的组成：
	种子查询：获得递归的初始值
	递归查询：
*/
# 举例：
SELECT * FROM employees WHERE manager_id IS NULL;

WITH RECURSIVE cte
AS
(SELECT employee_id, last_name, manager_id, 1 AS n FROM employees WHERE employee_id = 100
-- 种子查询，找到第一代领导
UNION ALL
SELECT a.employee_id, a.last_name, a.manager_id, n+1 FROM employees AS a JOIN cte
ON (a.manager_id = cte.employee_id) -- 递归查询，找出以递归公用表表达式的人为领导的人
)
SELECT employee_id, last_name FROM cte WHERE n >= 3;

# 3.3 小结
/*
公用表表达式的作用是可以替代子查询，而且可以被多次引用。
递归公用表表达式对查询有一个共同根节点的树形结构数据非常高效，可以轻松搞定其他查询方式难以处理的查询
*/