# 第05章_排序与分页

# 1. 排序数据
# 1.1 排序规则
# 使用 ORDER BY 子句排序
# 	ASC (ascend)：升序
#	DESC (descend): 降序
# ORDER BY 子句在 SELECT 语句的结尾


# 1.2 单列排序
SELECT last_name, job_id, department_id, hire_date FROM employees ORDER BY hire_date; 

SELECT last_name, job_id, department_id, hire_date FROM employees ORDER BY hire_date DESC;

SELECT employee_id, last_name, salary * 12 AS annual FROM employees ORDER BY annual;


# 1.3 多列排序
SELECT last_name, department_id, salary FROM employees ORDER BY department_id, salary DESC;


# 2. 分页
# 2.1 背景
#	显示部分结果

# 2.2 实现规则
#	分页使用 LIMIT 关键字实现
#     	格式：LIMIT [位置偏移量,] 行数
#		位置偏移量是可选参数，第一条记录的偏移量是：0
#		LIMIT子句必须放在整个SELECT语句的最后

# 前10条记录	第1页
SELECT * FROM employees LIMIT 0, 10;
SELECT * FROM employees LIMIT 10;

# 第11至20条记录	第2页
SELECT * FROM employees LIMIT 10, 10;

# 第21至30条记录	第3页
SELECT * FROM employees LIMIT 20, 10;

# MYSQL8.0 分页新特性: LIMIT 行数 OFFSET 位置偏移量
SELECT * FROM employees LIMIT 10 OFFSET 20; 
# 等价于
SELECT * FROM employees LIMIT 20, 10;

# 总结，分页显示公式：(当前页数 - 1) * 每页条数, 每页条数