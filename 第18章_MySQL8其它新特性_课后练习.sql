# 第18章_MySQL8其它新特性_课后练习

# 1. 创建students数据表，如下
CREATE TABLE students(
id INT PRIMARY KEY AUTO_INCREMENT,
student VARCHAR(15),
points TINYINT
);

# 2. 向表中添加数据，如下
INSERT INTO students(student, points)
VALUES
('张三',89),
('李四',77),
('王五',88),
('赵六',90),
('孙七',90),
('周八',88);

SELECT * FROM students;

# 3. 分别使用RANK()、DENSE_RANK() 和 ROW_NUMBER()函数对学生成绩降序排列情况进行显示
SELECT RANK() OVER w AS row_num, id, student, points
FROM students
WINDOW w AS (ORDER BY points DESC);

SELECT DENSE_RANK() OVER w AS row_num, id, student, points
FROM students
WINDOW w AS (ORDER BY points DESC);

SELECT ROW_NUMBER() OVER w AS row_num, id, student, points
FROM students
WINDOW w AS (ORDER BY points DESC);