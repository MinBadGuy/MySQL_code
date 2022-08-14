# 第04章_运算符

# 1. 算术运算符
# 1.1 加法与减法运算符
SELECT 100, 100 + 0, 100 - 0, 100 + 50, 100 + 50 - 30, 100 + 35.5, 100 - 35.5 FROM DUAL;

# 在SQL中，+没有连接的作用，就表示加法运算。此时会将字符串隐式转换成数值，转换失败当作0
# 101	100
SELECT 100 + '1', 100 + "1", 100 + 'a' FROM DUAL;

# 1.2 乘法与除法运算符
# 分母为0时，结果为null
SELECT 100, 100 * 1, 100 * 1.0, 100 / 1.0, 100 / 2, 100 + 2 * 5 / 2, 100 / 3, 100 DIV 0 FROM DUAL;

SELECT employee_id, salary, salary *12 AS annual_salary FROM employees;


# 1.3 求模(求余)运算符
SELECT 12 % 3, 12 MOD 5 FROM DUAL;

SELECT * FROM employees WHERE employee_id % 2 = 0;

# 2. 比较运算符
# 2.1 等号运算符 =
# 1 = 'a' 结果是1，字符串会进行隐式转换，和1.2一样
# NULL = NULL 结果是NULL，只要有NULL参与比较运算，结果就为NULL
SELECT 1 = 1, 1 = '1', 1 = 0, 'a' = 'a', (5 + 3) =(2 + 6),'' = NULL, NULL = NULL FROM DUAL;

# 	0	 1	   0
SELECT 1 = 2, 0 = 'abc', 1 = 'abc' FROM DUAL;

SELECT employee_id, salary FROM employees WHERE salary = 10000;


# 2.2 安全等于运算符 <=>
# 为NULL而生，NULL <=> NULL
SELECT 1 <=> 1, 1 <=> '1', 1 <=> 0, 'a' <=> 'a', (5 + 3) <=> (2 + 6), '' <=> NULL, NULL <=> NULL FROM DUAL;

SELECT employee_id, commission_pct FROM employees WHERE commission_pct = 0.4;

SELECT employee_id, commission_pct FROM employees WHERE commission_pct <=> 0.4;


# 2.3 不等于运算符 <>和!=
SELECT 1 <> 1, 1 != 2, 'a' != 'b', (3 + 4) <> (2 + 6), 'a' != NULL, NULL <> NULL FROM DUAL;


# 2.4 空运算符	IS NULL, isNULL()
# 	1		null		1	0		0
SELECT NULL IS NULL, NULL ISNULL, ISNULL(NULL), ISNULL('a'), 1 IS NULL FROM DUAL;

SELECT employee_id, commission_pct FROM employees WHERE commission_pct IS NULL;	# 72 rows
SELECT employee_id, commission_pct FROM employees WHERE commission_pct ISNULL;	# error	
SELECT employee_id, commission_pct FROM employees WHERE commission_pct <=> NULL;# 72 rows
SELECT employee_id, commission_pct FROM employees WHERE ISNULL(commission_pct);	# 72 rows
SELECT employee_id, commission_pct FROM employees WHERE commission_pct = NULL;	# 0 row\

SELECT last_name, manager_id FROM employees WHERE manager_id IS NULL; 


# 2.5 非空运算符 IS NOT NULL
SELECT NULL IS NOT NULL, 'a' IS NOT NULL, 1 IS NOT NULL FROM DUAL;

SELECT employee_id, commission_pct FROM employees WHERE commission_pct IS NOT NULL;	# 35 rows
SELECT employee_id, commission_pct FROM employees WHERE NOT commission_pct <=> NULL;	# 35 rows
SELECT employee_id, commission_pct FROM employees WHERE NOT ISNULL(commission_pct);	# 35 rows


# 2.6 最小值运算符
SELECT LEAST(1, 0, 2), LEAST('b', 'a', 'c'), LEAST(1, NULL) FROM DUAL;


# 2.7 最大值运算符
SELECT GREATEST(1, 0, 2), GREATEST('b', 'a', 'c'), GREATEST(1, NULL) FROM DUAL;


# 2.8 BETWEEN AND 运算符
#     BETWEEN A AND B: 大于等于A，小于等于B
SELECT 1 BETWEEN 0 AND 1, 10 BETWEEN 11 AND 12, 'b' BETWEEN 'a' AND 'c' FROM DUAL;

SELECT last_name, salary FROM employees WHERE salary BETWEEN 2500 AND 3500;

# 2.9 IN 运算符
#     如果给定值是null，结果就是null
#	1			0		null		null			1
SELECT 'a' IN ('a', 'b', 'c'), 1 IN (2, 3), NULL IN ('a', 'b'), NULL IN ('a', NULL), 'a' IN ('a', NULL) FROM DUAL;


# 2.10 NOT IN 运算符
SELECT 'a' NOT IN ('a', 'b', 'c'), 1 NOT IN (2, 3), NULL NOT IN ('a', 'b'), NULL NOT IN ('a', NULL), 'a' NOT IN ('a', NULL) FROM DUAL;


# 2.11 LIKE运算符: 模糊查询
#	"%": 匹配0个、1个或多个字符
#	"_"：只能匹配一个字符
SELECT NULL LIKE "abc", "abc" LIKE NULL FROM DUAL;

# 查询last_name中包含字母'a'的员工信息
SELECT last_name FROM employees WHERE last_name LIKE '%a%';	# 56 rows

# 查询last_name中以字符'a'开头的员工信息
SELECT last_name FROM employees WHERE last_name LIKE 'a%';	# 4 rows

# 查询last_name中包含字符'a'且包含字符'e'的员工信息
# 写法1：
SELECT last_name FROM employees WHERE last_name LIKE '%a%' AND last_name LIKE '%e%';	# 20 rows
# 写法2：
SELECT last_name FROM employees WHERE last_name LIKE '%a%e%' OR last_name LIKE '%e%a%';	# 20 rows

# 查询last_name第3个字符是'a'的员工信息
SELECT last_name FROM employees WHERE last_name LIKE '__a%';

# 查询第2个字符是_且第三个字符是'a'的员工信息
# 需要对第2个_进行转义
# 写法1：使用 \
SELECT last_name FROM employees WHERE last_name LIKE '_\_a%';
# 写法2：使用 ESCAPE
SELECT last_name FROM employees WHERE last_name LIKE '_$_a%' ESCAPE '$';

# 查询job_id中第三个字符是_的信息
SELECT job_id FROM jobs WHERE job_id LIKE 'IT\_%';
SELECT job_id FROM jobs WHERE job_id LIKE 'IT$_%' ESCAPE '$';
SELECT job_id FROM jobs WHERE job_id LIKE 'IT#_%' ESCAPE '#';


# 2.12 REGEXP运算符：正则表达式
# '^'匹配以该字符后面的字符开头的字符串
# '$'匹配以该字符后面的字符结尾的字符串
# '.'匹配任何一个单字符
# '[...]'匹配在方括号内的任何字符。例如，'[abc]'匹配'a'或'b'或'c'，'[a-z]'匹配任何字母，'[0-9]'匹配任何数字
# '*'匹配零个或多个在它前面的字符。例如，'x*'匹配任何数量的'x'字符，'[0-9]*'匹配任何数量的数字，'*'匹配任何数量的任何字符

SELECT 'shkstart' REGEXP '^s', 'shkstart' REGEXP 't$', 'shkstart' REGEXP 'hk' FROM DUAL;

SELECT 'atguigu' REGEXP 'gu.gu', 'atguigu' REGEXP '[ab]', 'atguigu' REGEXP '[0-9]' FROM DUAL;


# 3. 逻辑运算符
# 3.1 逻辑非运算符 NOT、!
SELECT NOT 1, NOT 0, NOT (1 + 1), NOT !1, NOT NULL FROM DUAL;


# 3.2 逻辑与运算符 AND、&&
#	1	 0	  0		null
SELECT 1 AND -1, 0 AND 1, 0 AND NULL, 1 AND NULL FROM DUAL;

SELECT employee_id, last_name, job_id, salary FROM employees WHERE salary >= 10000 AND job_id LIKE '%MAN%';


# 3.3 逻辑或运算符 OR、||
SELECT 1 OR -1, 1 OR 0, 1 OR NULL, 0 || NULL, NULL || NULL FROM DUAL;

SELECT employee_id, salary FROM employees WHERE salary NOT BETWEEN 9000 AND 12000;		# 86 rows
SELECT employee_id, salary FROM employees WHERE salary < 9000 OR salary > 12000;		# 86 rows
SELECT employee_id, salary FROM employees WHERE NOT (salary >= 9000 AND salary <= 12000);	# 86 rows

SELECT employee_id, last_name, job_id, salary FROM employees WHERE salary >= 1000 OR job_id LIKE '%MAN%';


# 3.4 逻辑异或运算符 XOR、^
SELECT 1 XOR -1, 1 XOR 0, 0 XOR 0, 1 XOR NULL, 1 XOR 1 XOR 1, 0 XOR 0 XOR 0 FROM DUAL;


# 4. 位运算符
# 4.1 按位与运算符	&
# 0001		10100
# 1010		11110
SELECT 1 & 10, 20 & 30 FROM DUAL;


# 4.2 按位或运算符	|
SELECT 1 | 10, 20 | 30 FROM DUAL; 


# 4.3 按位异或运算符	^
SELECT 1 ^ 10, 20 ^ 30 FROM DUAL;

# 1100
# 0101
SELECT 12 & 5, 12 | 5, 12 ^ 5 FROM DUAL;


# 4.4 按位取反运算符	~
# 1010
# 1110
SELECT 10 & ~1 FROM DUAL;


# 4.5 按位右移运算符
SELECT 1 >> 2, 4 >> 2 FROM DUAL;


# 4.6 按位左移运算符
SELECT 1 << 2, 4 << 2 FROM DUAL;


