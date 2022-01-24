
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

-- Retrieving rows from one table that do not correspond to rows in another.
SELECT * FROM dept  
WHERE dept.deptno NOT IN (
    SELECT emp.deptno FROM emp 
    INNER JOIN dept
    ON emp.deptno = dept.deptno);

SELECT d.* 
FROM dept d LEFT JOIN emp e
ON d.deptno = e.deptno
WHERE e.deptno IS NULL;

SELECT e.ename, e.deptno AS emp_deptno, d.*
FROM dept d 
LEFT JOIN emp e
ON (d.deptno = e.deptno);

SELECT e.*, d.*
FROM dept d 
LEFT JOIN emp e
ON (d.deptno = e.deptno);

-- Adding joins to a query without interfering with other joins
SELECT comb.ename, comb.loc, eb.received FROM emp_bonus eb
RIGHT JOIN
(SELECT * 
FROM emp e, dept d
WHERE e.deptno = d.deptno) comb
ON eb.empno = comb.empno;

SELECT e.ename, d.loc, eb.received
FROM emp e, dept d, emp_bonus eb
WHERE e.deptno = d.deptno
AND e.empno = eb.empno;

SELECT e.ename, d.loc, 
(SELECT eb.received FROM emp_bonus eb
WHERE eb.empno = e.empno) AS received 
FROM emp e, dept d
WHERE e.deptno = d.deptno
ORDER BY 2;

-- Determining whether two tables have the same data.
CREATE VIEW V
AS
SELECT * FROM emp WHERE deptno != 10
UNION ALL
SELECT * FROM emp WHERE ename = 'WARD';

SELECT emp.* 
FROM emp, v
WHERE emp.* = v.*;

(
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno, COUNT(*) AS cnt
FROM v
GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
EXCEPT
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno, COUNT(*) AS cnt
FROM emp
GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
)
UNION ALL
(
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno, COUNT(*) AS cnt
FROM emp
GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
EXCEPT
SELECT empno, ename, job, mgr, hiredate, sal, comm, deptno, COUNT(*) AS cnt
FROM v
GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
)

SELECT * FROM (
SELECT e.empno, e.ename, e.job, e.mgr, e.hiredate, e.sal, e.comm, e.deptno, COUNT(*) AS cnt
FROM emp e
GROUP BY e.empno, e.ename, e.job, e.mgr, e.hiredate, e.sal, e.comm, e.deptno
)


SELECT * FROM (
SELECT e.empno, e.ename, e.job, e.mgr, e.hiredate, e.sal, e.comm, e.deptno, COUNT(*) AS cnt
FROM emp e
GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno) e
WHERE NOT EXISTS (
SELECT NULL FROM (
SELECT v.empno, v.ename, v.job, v.mgr, v.hiredate, v.sal, v.comm, v.deptno, COUNT(*) AS cnt
FROM v
GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno) v
WHERE v.empno = e.empno
AND v.ename = e.ename
AND v.job = e.job
AND v.mgr = e.mgr
AND v.hiredate = e.hiredate
AND v.sal = e.sal
AND v.deptno = e.deptno
AND v.cnt = e.cnt
AND COALESCE(v.comm, 0) = COALESCE(e.comm, 0)
)
UNION ALL
SELECT * FROM (
SELECT v.empno, v.ename, v.job, v.mgr, v.hiredate, v.sal, v.comm, v.deptno, COUNT(*) AS cnt
FROM v
GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
) v
WHERE NOT EXISTS(
SELECT NULL FROM (
SELECT e.empno, e.ename, e.job, e.mgr, e.hiredate, e.sal, e.comm, e.deptno, COUNT(*) AS cnt
FROM emp e
GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno) e 
WHERE v.empno = e.empno
AND v.ename = e.ename
AND v.job = e.job
AND v.mgr = e.mgr
AND v.hiredate = e.hiredate
AND v.sal = e.sal
AND v.deptno = e.deptno
AND v.cnt = e.cnt
AND COALESCE(v.comm, 0) = COALESCE(e.comm, 0)
);

-- Performing joins when using aggregates
SELECT z.deptno, SUM(DISTINCT sal), SUM(bonus)
FROM
(
SELECT t.empno, t.ename, t.deptno, t.sal, CASE
WHEN t.type = 1 THEN sal * 0.1
WHEN t.type = 2 THEN sal * 0.2
WHEN t.type = 3 THEN sal * 0.3
END bonus
FROM
(SELECT e.*, eb.received, eb.type 
FROM emp e 
LEFT JOIN emp_bonus eb
ON e.empno = eb.empno) t
) z
GROUP BY z.deptno;

-- Alternative solution
SELECT d.deptno, d.total_sal, 
SUM(e.sal * CASE WHEN eb.type = 1 THEN .1
                 WHEN eb.type = 2 THEN .2
                 ELSE .3 END) AS total_bonus
FROM emp e, emp_bonus eb, 
(SELECT deptno, SUM(sal) AS total_sal 
FROM emp 
WHERE deptno = 10
GROUP BY deptno) d
WHERE e.deptno = d.deptno
AND e.empno = eb.empno
GROUP BY d.deptno, d.total_sal;

-- Performing outer joins when using aggregates

SELECT e.deptno, SUM(e.sal), SUM(b.bonus)
FROM emp e
LEFT JOIN
(SELECT eb.empno, SUM(e.sal * CASE 
WHEN eb.type = 1 THEN 0.1
ELSE 0.2 END) AS bonus
FROM emp_bonus eb 
LEFT JOIN emp e
ON eb.empno = e.empno
GROUP BY eb.empno) b
ON e.empno = b.empno
WHERE e.deptno = 10
GROUP BY e.deptno;

-- Returning missing data from multiple tables

INSERT INTO emp 
SELECT 1111, 'YODA', 'JEDI', NULL, hiredate, sal, comm, NULL
FROM emp 
WHERE ename = 'KING';

SELECT d.deptno, d.dname, e.ename
FROM dept d FULL OUTER JOIN emp e
ON d.deptno = e.deptno;

-- Using NULLs in operations and comparisons

SELECT * FROM emp 
WHERE COALESCE(comm, 0) > (SELECT comm FROM emp WHERE ename = 'WARD');


-- Copy rows from one table into another

INSERT INTO dept_east (deptno, dname, loc) 
SELECT deptno, dname, loc
FROM dept
WHERE loc IN ('NEW YORK', 'BOSTON'); 

-- Copying a table definition

CREATE TABLE dept_2
AS
SELECT *
FROM dept
WHERE 1 = 0;

-- Blocking inserts to certain columns
CREATE VIEW new_emps AS 
SELECT empno, ename, job
FROM emp

-- Modifying records in a table
UPDATE emp
SET sal = sal * 1.10
WHERE deptno = 20;

-- Updating when corresponding rows exist
UPDATE emp
SET sal = sal * 1.2
WHERE empno in (SELECT empno FROM emp_bonus)

UPDATE emp 
SET sal = sal * 1.2
WHERE EXISTS 
(
SELECT NULL FROM emp_bonus 
WHERE emp.empno = emp_bonus.empno
)

-- Updating with values from another table

UPDATE emp 
SET sal = (SELECT sal FROM new_sal), 
comm = 0.5 * (SELECT sal FROM new_sal)
WHERE emp.deptno = (SELECT deptno FROM new_sal);

UPDATE emp
SET sal = ns.sal, comm = ns.sal/2
FROM new_sal ns
WHERE ns.deptno = emp.deptno;

UPDATE emp e 
SET (sal, comm) = (SELECT ns.sal , ns.sal/2 
                       FROM new_sal ns 
                       WHERE ns.deptno = e.deptno)
WHERE EXISTS (SELECT NULL FROM emp e, new_sal ns
              WHERE e.deptno = ns.deptno)

SELECT * FROM emp e
WHERE EXISTS (SELECT NULL FROM new_sal ns, emp
              WHERE e.deptno = ns.deptno)
















