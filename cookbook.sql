
-- CASE expression
SELECT ename, sal,
CASE WHEN sal <= 2000 THEN 'underpaid'
     WHEN sal >= 4000 THEN 'overpaid'
     ELSE 'ok'
END AS status
FROM emp;

-- Returning n Random Records from a Table
SELECT ename, job
FROM emp
ORDER BY random()
LIMIT 5

-- Transforming Nulls into Real Values
SELECT coalesce(comm, 0)
FROM emp;
-- An alternative way to transform Nulls into Real Values
SELECT CASE 
WHEN comm IS NULL THEN 0
ELSE comm
END
FROM emp;

-- Searching pattern
SELECT ename, job
FROM emp
WHERE deptno IN (10,20)
AND (ename LIKE '%I%' OR job LIKE '%ER');

-- Sorting by substring
SELECT ename, job
FROM emp
ORDER BY substr(job, LENGTH(job)-1)

-- Sorting mixed alphanumerica data
CREATE VIEW V
AS 
SELECT ename||' '||deptno AS data
FROM emp;

SELECT data FROM V
ORDER BY REPLACE(data, REPLACE(TRANSLATE(data, '0123456789', '##########'), '#', ''),'')

SELECT data, REPLACE(data, REPLACE(TRANSLATE(data, '0123456789', '##########'), '#', ''), '')

SELECT data, REPLACE(TRANSLATE(data, '0123456789', '##########'), '##', '') AS chars FROM V;

-- Dealing with nulls when sorting
SELECT ename, sal, comm 
FROM(
    SELECT ename, sal, comm, CASE WHEN comm IS NULL THEN 0
                             ELSE 1
                             END AS is_null
    FROM emp
) AS x
ORDER BY is_null DESC, comm;

-- Sorting on a data dependent key
SELECT ename, sal, job, comm
FROM emp
ORDER BY CASE WHEN job = 'SALESMAN' THEN comm else sal END;

SELECT ename, sal, job, comm, 
       CASE WHEN job = 'SALESMAN' THEN comm 
            ELSE sal END AS ordered
            FROM emp
ORDER BY ordered;

-- Stacking one row atop another

SELECT ename as ename_and_dname, deptno
FROM emp
WHERE deptno = 10
UNION ALL
SELECT '----------', NULL 
UNION ALL
SELECT dname, deptno
FROM dept;

SELECT DISTINCT(deptno)
FROM 
(SELECT deptno
FROM emp
UNION ALL
SELECT deptno
FROM dept) AS comb;

SELECT deptno
FROM emp
UNION
SELECT deptno
FROM dept;

-- Combining related rows 
SELECT e.ename, d.loc
FROM emp e, dept d
WHERE e.deptno = d.deptno
AND e.deptno = 10;

SELECT e.ename, d.loc 
FROM emp e
INNER JOIN dept d
ON e.deptno = d.deptno
WHERE e.deptno = 10;

SELECT e.ename, d.loc
FROM emp e, dept d
WHERE e.deptno = 10;

-- Finding common rows between two tables
SELECT empno, ename, job, sal, deptno
FROM emp
WHERE (ename, job, sal) in (
    SELECT ename, job, sal
    FROM emp
    INTERSECT
    SELECT ename, job, sal
    FROM v
);

SELECT e.empno, e.ename, e.job, e.sal, e.deptno 
FROM emp AS e, v
WHERE e.ename = v.ename
AND e.job = v.job
AND e.sal = v.sal;

-- Retrieving values from one table that do not exist in another
SELECT DISTINCT(deptno)
FROM emp
WHERE deptno NOT IN (
    SELECT deptno FROM dept
);

SELECT deptno FROM dept
EXCEPT
SELECT deptno FROM emp;

-- An example showing using NOT IN NULL. 
SELECT * FROM dept
WHERE deptno NOT IN (SELECT deptno FROM new_dept);

SELECT d.deptno FROM dept d
WHERE NOT EXISTS ( SELECT NULL FROM emp e WHERE d.deptno = e.deptno);






