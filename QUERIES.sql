-- SALESMAN DATABASE QUERIES

-- 1> Count the customers with grades above Bangalore’s average.

SELECT GRADE, COUNT(DISTINCT CUSTOMER_ID)
    FROM CUSTOMER
        GROUP BY GRADE
            HAVING GRADE > (SELECT AVG(GRADE) 
                                FROM CUSTOMER
                                    WHERE CUSTOMER_CITY = 'BANGALORE');

-- 2>   Find the name and numbers of all salesmen who had more than one customer.

    SELECT S.SALESMAN_NAME, S.SALESMAN_ID
        FROM SALESMAN S
            WHERE 1 < (SELECT COUNT(*)
                            FROM CUSTOMER C
                                WHERE C.SALESMAN_ID = S.SALESMAN_ID);

 --   (OR)

    SELECT S.SALESMAN_NAME, S.SALESMAN_ID
        FROM SALESMAN S, CUSTOMER C
            WHERE C.SALESMAN_ID = S.SALESMAN_ID
                GROUP BY SALESMAN_ID
                    HAVING COUNT(C.SALESMAN_ID) > 1;


-- 3> List all salesmen and indicate those who have and don’t have customers in their cities (Use UNION operation.)

SELECT SALESMAN.SALESMAN_ID, SALESMAN.SALESMAN_NAME, CUSTOMER.CUSTOMER_NAME
    FROM SALESMAN, CUSTOMER
        WHERE SALESMAN.CITY = CUSTOMER.CUSTOMER_CITY
UNION
SELECT SALESMAN_ID, SALESMAN_NAME, 'NO_MATCH'
    FROM SALESMAN
        WHERE  NOT CITY = ANY (SELECT CUSTOMER_CITY FROM CUSTOMER) 
ORDER BY 2 DESC;

-- 4> Create a view that finds the salesman who has the customer with the highest order of a day.

CREATE VIEW ELIGHT_SALESMAN AS
    SELECT O.ORDER_DATE, S.SALESMAN_ID, S.SALESMAN_NAME
        FROM ORDERS O, SALESMAN S
            WHERE S.SALESMAN_ID = O.SALESMAN_ID AND
                PURCHASE_AMT = (SELECT MAX(PURCHASE_AMT)
                                    FROM ORDERS 
                                        WHERE O.ORDER_DATE = ORDER_DATE);

-- 5> Demonstrate the DELETE operation by removing salesman with id 1000. All his orders
--      must also be deleted.

DELETE FROM SALESMAN
    WHERE SALESMAN_ID = 'S1000';



--COMPANY DATABASE QUERIES

-- 1>   Make a list of all project numbers for projects that involve an employee whose last
--      name is ‘Scott’, either as a worker or as a manager of the department that controls
--      the project.

(SELECT P.PNO 
    FROM PROJECT P, DEPARTMENT W, EMPLOYEE E
        WHERE E.SSN = W.MGR_SSN AND
                    E.LNAME = 'SCOTT')
UNION
(SELECT P1.PNO 
    FROM PROJECT P1, WORKS_ON W1, EMPLOYEE E1
        WHERE E1.SSN = W1.SSN AND
                P1.PNO = W1.PNO AND
                 E1.LNAME = 'SCOTT' );

-- 2>   Show the resulting salaries if every employee working on the ‘IoT’ project is given a
--      10 percent raise.

SELECT E.SSN, E.FNAME, E.SALARY, '->', (1.1*E.SALARY) AS CURRENT_SALARY
    FROM EMPLOYEE E, PROJECT P, WORKS_ON W
        WHERE E.SSN = W.SSN AND
                P.PNO = W.PNO AND
                    P.PNAME = 'IOT';

-- 3>   Find the sum of the salaries of all employees of the ‘Accounts’ department, as well
--      as the maximum salary, the minimum salary, and the average salary in this
--      department

SELECT SUM(E.SALARY), AVG(E.SALARY), MAX(E.SALARY), MIN(E.SALARY)
    FROM EMPLOYEE E, DEPARTMENT D
        WHERE D.DEPARTMENT_NO = E.DNO AND
                D.DEPATMENT_NAME = 'ACCOUNTS';

-- 4>   Retrieve the name of each employee who works on all the projects controlled by
--      department number 5 (use NOT EXISTS operator).

-- NOT WORKING IN XAMPP

SELECT E.FNAME, E.LNAME 
    FROM EMPLOYEE E
        WHERE NOT EXISTS ((SELECT P.PNO 
                            FROM PROJECT P
                                WHERE DEPARTMENT_NO = '5') NOT IN (SELECT W.PNO
                                                            FROM WORKS_ON W
                                                                WHERE W.SSN = E.SSN AND
                                                                        DEPARTMENT_NO = '5'));

-- 5>   For each department that has
--      more than five employees, retrieve the department number and the number of its
--      employees who are making more than Rs. 6,00,000.

SELECT D.DEPARTMENT_NO, COUNT(*)
    FROM DEPARTMENT D, EMPLOYEE E
        WHERE D.DEPARTMENT_NO = E.DNO
            AND E.SALARY > 600000
            AND D.DEPARTMENT_NO IN (SELECT E1.DNO
                                        FROM EMPLOYEE E1
                                            GROUP BY E1.DNO
                                                HAVING COUNT(DNO)>5)
            GROUP BY D.DEPARTMENT_NO;



--COLLAGE DATABASE QUERIES

-- 1>   List all the student details studying in fourth semester ‘C’ section.

SELECT S.*, SS.SEM, SS.SEC
    FROM STUDENT S, SEMSEC SS, CLASS C
        WHERE C.SSID = SS.SSID AND
            C.USN = S.USN AND
            SS.SEM = 4 AND
            SS.SEC = 'C';

-- 2>   Compute the total number of male and female students in each semester and in each section.

SELECT S.STUDENT_NAME, SS.SEM, SS.SEC, S.GENDER, COUNT(S.GENDER) AS GENDER_COUNT
    FROM STUDENT S, SEMSEC SS, CLASS C
        WHERE C.SSID = SS.SSID AND
                C.USN = S.USN
                    GROUP BY SS.SEM, SS.SEC, S.GENDER
                    ORDER BY SEM;

-- 3>   Create a view of Test1 marks of student USN '1RN13CS091' in all subjects.

CREATE VIEW TEST1_OF_1RN13CS091 AS
    SELECT S.USN, S.STUDENT_NAME, IA.TEST1 AS MARKS_OF_TEST_ONE
        FROM STUDENT S, IAMARKS IA
            WHERE IA.USN = S.USN AND        
                    IA.USN = '1RN13CS091';

-- 4>   Calculate the FinalIA (average of best two test marks) and update the
--      corresponding table for all students.

UPDATE IAMARKS SET FINALIA = CASE
    WHEN TEST1 < TEST2 AND TEST1 < TEST3 THEN ROUND((TEST2 + TEST3)/2)
    WHEN TEST2 < TEST3 AND TEST2 < TEST1 THEN ROUND((TEST1 + TEST3)/2)
    WHEN TEST3 < TEST1 AND TEST3 < TEST2 THEN ROUND((TEST1 + TEST2)/2)
    END
    WHERE FINALIA IS NULL;

-- 5>    Categorize students based on the following criterion:
--       IF FinalIA = 17 to 20 then CAT = ‘Outstanding’
--       IF FinalIA = 12 to 16 then CAT = ‘Average’
--       IF FinalIA< 12 then CAT = ‘Weak’
--       Give these details only for 8th semester A, B, and C section students.

    SELECT S.USN, S.STUDENT_NAME, IA.FINALIA, ( CASE
        WHEN FINALIA BETWEEN 17 AND 21 THEN 'OUTSTANDING'
        WHEN FINALIA BETWEEN 12 AND 16 THEN 'AVERAGE'
        WHEN FINALIA < 12  THEN 'WEAK' END ) AS CATAGORY
            FROM STUDENT S, IAMARKS IA, SEMSEC SS
                WHERE S.USN = IA.USN AND
                    IA.SSID = SS.SSID AND
                        SS.SEM = 8; 


--- LIBRARY DATABASE QUERIES ---

--   1>  Retrieve details of all books in the library – id, title, name of publisher, authors,
--       number of copies in each branch, etc.

SELECT B.*, BC.NO_OF_COPIES
    FROM BOOK B, BOOK_COPIES BC, LIBRARY_BRANCH LB
        WHERE B.BOOK_ID = BC.BOOK_ID AND
            LB.BRANCH_ID = BC.BRANCH_ID;


-- 2>   Get the particulars of borrowers who have borrowed more than 3 books, but from Jan
--      2017 to Jun 2017

SELECT CARD_NO
    FROM BOOK_LEANDING BL
        WHERE DATE_OUT BETWEEN '2017-01-01' AND '2017-06-01'
            GROUP BY CARD_NO
                HAVING COUNT(*) > 3 ;


-- 3>   Partition the BOOK table based on year of publication. Demonstrate its working with a
--      SIMPLE query.

CREATE VIEW PARTITION_EXAMPLE AS
    SELECT PUBLISH_YEAR
        FROM BOOK;


-- 4>   Create a view of all books and its number of copies that are currently available in the
--      Library

CREATE VIEW BOOK_IN_LIBRARY AS
    SELECT BC.BOOK_ID, BC.BRANCH_ID, BC.NO_OF_COPIES, LB.BRANCH_NAME, LB.ADDRESS
        FROM LIBRARY_BRANCH LB, BOOK_COPIES BC
            WHERE BC.BRANCH_ID = LB.BRANCH_ID;

-- 5>   Delete a book in BOOK table. Update the contents of other tables to reflect this data
--      manipulation operation.

DELETE FROM BOOK 
    WHERE BOOK_ID = 1003;

-- TRY

CREATE VIEW BOOK_IN_LIBRARY_CHECK AS
    SELECT BC.BOOK_ID, BC.BRANCH_ID, BC.NO_OF_COPIES, LB.BRANCH_NAME, LB.ADDRESS
        FROM LIBRARY_BRANCH LB, BOOK_COPIES BC
            WHERE BC.BRANCH_ID = LB.BRANCH_ID AND
            LB.BRANCH_ID = 5000 ;


-- QUERIES 

-- 1>  List the titles of all movies directed by ‘Hitchcock’.

SELECT M.MOV_TITLE
    FROM MOVIES M, DIRECTOR D
        WHERE M.DIR_ID = D.DIR_ID AND
            D.DIR_NAME = 'Hitchcock';

-- 2>   Find the movie names where one or more actors acted in two or more movies.

SELECT M.MOV_TITLE
    FROM MOVIES M, MOVIE_CAST MC
        WHERE MC.MOV_ID = M.MOV_ID
            GROUP BY MC.ACT_ID
                HAVING COUNT(ACT_ID) > 1;


SELECT MOV_TITLE
    FROM MOVIES M, MOVIE_CAST MV
        WHERE M.MOV_ID = MV.MOV_ID AND 
            ACT_ID IN ( SELECT ACT_ID
  						    FROM MOVIE_CAST 
                                GROUP BY ACT_ID 
                                    HAVING ACT_ID > 1)
                GROUP BY MOV_TITLE HAVING
  					COUNT(*) > 1;


-- 3>   List all actors who acted in a movie before 2000 and also in a movie after
2--     2015 (use JOIN operation).

SELECT A.ACT_NAME, A.ACT_GENDER
    FROM ACTOR A, MOVIES M, MOVIE_CAST MC
        WHERE MC.ACT_ID = A.ACT_ID AND
            MC.MOV_ID = M.MOV_ID AND
            M.MOV_YEAR NOT BETWEEN 2000 AND 2015;


SELECT ACT_NAME, MOV_TITLE, MOV_YEAR
    FROM ACTOR A
        JOIN MOVIE_CAST MC 
            ON A.ACT_ID = MC.ACT_ID
        JOIN MOVIES M 
            ON MC.MOV_ID = M.MOV_ID
                WHERE M.MOV_YEAR NOT BETWEEN 2000 AND 2015;

    
-- 4>   Find the title of movies and number of stars for each movie that has at least one
--  rating and find the highest number of stars that movie received. Sort the result by
--  movie title.

SELECT MOV_TITLE, MAX(REV_STARS) AS MAXIMUM_STARS
    FROM MOVIES M, RATING R 
        WHERE M.MOV_ID = R.MOV_ID
            GROUP BY MOV_TITLE
                HAVING MAX(REV_STARS) > 0
                    ORDER BY MOV_TITLE;

-- 5>   Update rating of all movies directed by ‘Steven Spielberg’ to 5.

UPDATE RATING
    SET REV_STARS = 5
        WHERE MOV_ID = (SELECT MOV_ID 
                            FROM MOVIES
                                WHERE DIR_ID = (SELECT DIR_ID 
                                                    FROM DIRECTOR
                                                        WHERE DIR_NAME = 'STEVEN SPLIELBREG'));


-- QUERIES

-- 1>   List all the student details studying in fourth semester ‘C’ section.

SELECT S.*, SS.SEM, SS.SEC
    FROM STUDENT S, SEMSEC SS, CLASS C
        WHERE C.SSID = SS.SSID AND
            C.USN = S.USN AND
            SS.SEM = 4 AND
            SS.SEC = 'C';

-- 2>   Compute the total number of male and female students in each semester and in each section.

SELECT S.STUDENT_NAME, SS.SEM, SS.SEC, S.GENDER, COUNT(S.GENDER) AS GENDER_COUNT
    FROM STUDENT S, SEMSEC SS, CLASS C
        WHERE C.SSID = SS.SSID AND
                C.USN = S.USN
                    GROUP BY SS.SEM, SS.SEC, S.GENDER
                    ORDER BY SEM;

-- 3>   Create a view of Test1 marks of student USN '1RN13CS091' in all subjects.

CREATE VIEW TEST1_OF_1RN13CS091 AS
    SELECT S.USN, S.STUDENT_NAME, IA.TEST1 AS MARKS_OF_TEST_ONE
        FROM STUDENT S, IAMARKS IA
            WHERE IA.USN = S.USN AND        
                    IA.USN = '1RN13CS091';

-- 4>   Calculate the FinalIA (average of best two test marks) and update the
--      corresponding table for all students.

UPDATE IAMARKS SET FINALIA = CASE
    WHEN TEST1 < TEST2 AND TEST1 < TEST3 THEN ROUND((TEST2 + TEST3)/2)
    WHEN TEST2 < TEST3 AND TEST2 < TEST1 THEN ROUND((TEST1 + TEST3)/2)
    WHEN TEST3 < TEST1 AND TEST3 < TEST2 THEN ROUND((TEST1 + TEST2)/2)
    END
    WHERE FINALIA IS NULL;

-- 5>    Categorize students based on the following criterion:
--       IF FinalIA = 17 to 20 then CAT = ‘Outstanding’
--       IF FinalIA = 12 to 16 then CAT = ‘Average’
--       IF FinalIA< 12 then CAT = ‘Weak’
--       Give these details only for 8th semester A, B, and C section students.

    SELECT S.USN, S.STUDENT_NAME, IA.FINALIA, ( CASE
        WHEN FINALIA BETWEEN 17 AND 21 THEN 'OUTSTANDING'
        WHEN FINALIA BETWEEN 12 AND 16 THEN 'AVERAGE'
        WHEN FINALIA < 12  THEN 'WEAK' END ) AS CATAGORY
            FROM STUDENT S, IAMARKS IA, SEMSEC SS
                WHERE S.USN = IA.USN AND
                    IA.SSID = SS.SSID AND
                        SS.SEM = 8; 