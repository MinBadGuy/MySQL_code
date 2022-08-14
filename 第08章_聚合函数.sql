# 第08章_聚合函数

# 1. 聚合函数
# 定义：聚合函数作用于一组数据，并对一组数据返回一个值
# 类型：AVG(), SUM(), MAX(), MIN(), COUNT()
# 注意：聚合函数不能嵌套，比如不能出现类似 "AVG(SUM(字段名称))" 形式的调用
/*
语法：
SELECT [column,] group_function(column), ...
FROM table
[WHERE condition]
[GROUP BY column]
[ORDER BY column];
*/

# 1.1 AVG 和 SUM 函数
# 对数值型数据使用
SELECT AVG(salary), SUM(salary), job_id FROM employees WHERE job_id LIKE '%REP%';

# 1.2 MIN 和 MAX 函数
# 对任意数据类型使用
SELECT MIN(hire_date), MAX(hire_date), MIN(salary), MAX(salary) FROM employees;

# 1.3 COUNT 函数
# 返回记录数，可对任意类型使用
SELECT COUNT(*) FROM employees WHERE department_id = 50;


# 2. GROUP BY
# 2.1 基本使用
# 作用：将表中的数据分成若干组
/*
语法：
SELECT column, group_function(column)
FROM table
[WHERE condition]
GROUP BY group_by_expression
ORDER BY column;
*/
# 明确：① WHERE 一定放在 FROM 后面
#	② 在 SELECT 列表中所有未包含在组函数中的列都应该包含在 GROUP BY 子句中
#	③ 包含在 GROUP BY 子句中的列不必包含在 SELECT 列表中
SELECT department_id, AVG(salary) FROM employees GROUP BY department_id;

SELECT AVG(salary) FROM employees GROUP BY department_id;

# 2.2 使用多个列分组
SELECT department_id dep_id, job_id, SUM(salary) FROM employees GROUP BY dep_id, job_id; 

# 2.3 GROUP BY 中使用 WITH ROLLUP
# 作用：在所有查出的分组记录之后增加一条记录，该记录计算查询处的所有记录总和，即统计记录数量
# 注意：当使用ROLLUP时，不能同时使用ORDER BY子句进行结果排序
SELECT department_id, AVG(salary) avg_sal FROM employees WHERE department_id > 80 GROUP BY department_id WITH ROLLUP;
# 以下错误的
# SELECT department_id, AVG(salary) avg_sal FROM employees WHERE department_id > 80 GROUP BY department_id order by avg_sal WITH ROLLUP;


# 3. HAVING
# 3.1 基本使用
/*
过滤分组：HAVING
	1. 行已经被分组
	2. 使用了聚合函数
	3. 满足HAVING子句中条件的分组将被显示
	4. HAVING不能单独使用，必须要跟 GROUP BY 一起使用

语法：
SELECT column, group_function
FROM table
[WHERE condition]
GROUP BY group_by_expression
HAVING group_condition
[ORDER BY column]
*/
SELECT department_id, MAX(salary) FROM employees GROUP BY department_id HAVING MAX(salary) > 10000;

# 注意：不能在WHERE子句中使用聚合函数
# 错误的
# select department_id, max(salary) from employees where max(salary) > 10000 group by department_id;

# 3.2 WHERE 和 HAVING 的对比
/*
区别1：
	WHERE可以直接使用表中的字段作为筛选条件，但不能使用分组中的计算函数作为筛选条件；
	HAVING必须要与GROUP BY配合使用，可以把分组计算的函数和分组字段作为筛选条件。
区别2：
	如果需要通过连接从关联表中获取需要的数据，WHERE是先筛选后连接，而HAVING是先连接后筛选。

小结：
	优点					缺点
WHERE	先筛选数据再关联，执行效率高		不能使用分组中的计算函数进行筛选
HAVING	可以使用分组中的计算函数进行筛选	在最后的结果集中进行筛选，执行效率低

*/


# 4. SELECT的执行过程
# 4.1 查询的结构

# 4.2 SELECT执行顺序

# 4.3 SQL的执行原理