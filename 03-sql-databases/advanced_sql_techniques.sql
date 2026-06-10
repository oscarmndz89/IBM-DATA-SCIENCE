--Databases and SQL for Data Science with Python: Week 6 Bonus Module: Advanced SQL for Data Engineer (Honors): Final Project: Advanced SQL Techniques

--https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMDeveloperSkillsNetwork-DB0201EN-SkillsNetwork/labs/BonusModule_Coursera_v5/FinalProject_BonusModule.md.html?origin=www.coursera.org

--Q1.1 Using Joins: Write and execute a SQL query to list the school names, community names and average attendance for communities with a hardship index of 98.

SELECT CPS.NAME_OF_SCHOOL, CD.COMMUNITY_AREA_NAME, CPS.AVERAGE_STUDENT_ATTENDANCE
FROM CHICAGO_PUBLIC_SCHOOLS CPS
	JOIN CENSUS_DATA CD
ON CPS.COMMUNITY_AREA_NUMBER = CD.COMMUNITY_AREA_NUMBER
WHERE CD.HARDSHIP_INDEX = 98;

--Q1.1 Using Joins: Alternate solution with same result as following the 'hint' to use an outer join

SELECT CPS.NAME_OF_SCHOOL, CD.COMMUNITY_AREA_NAME, CPS.AVERAGE_STUDENT_ATTENDANCE
FROM CHICAGO_PUBLIC_SCHOOLS CPS
	LEFT JOIN CENSUS_DATA CD
ON CPS.COMMUNITY_AREA_NUMBER = CD.COMMUNITY_AREA_NUMBER
WHERE CD.HARDSHIP_INDEX = 98;

--Q1.2 Using Joins: Write and execute a SQL query to list all crimes that took place at a school. Include case number, crime type and community name.

SELECT CCD.CASE_NUMBER, CCD.PRIMARY_TYPE, CD.COMMUNITY_AREA_NAME, CCD.LOCATION_DESCRIPTION
FROM CHICAGO_CRIME_DATA CCD
	LEFT JOIN CENSUS_DATA CD ON CCD.COMMUNITY_AREA_NUMBER = CD.COMMUNITY_AREA_NUMBER
WHERE CCD.LOCATION_DESCRIPTION LIKE '%SCHOOL%';

--Q2.1 Creating a View: Write and execute a SQL statement to create a view showing the columns listed in the following table, with new column names as shown in the second column.

DROP VIEW FROM_CPS;

CREATE VIEW FROM_CPS AS
SELECT "NAME_OF_SCHOOL" AS School_Name,
				"Safety_Icon" AS Safety_Rating,
				"Family_Involvement_Icon" AS Family_Rating,
				"Environment_Icon" AS Environment_Rating,
				"Instruction_Icon" AS Instruction_Rating,
				"Leaders_Icon" AS Leaders_Rating,
				"Teachers_Icon" AS Teachers_Rating
FROM CHICAGO_PUBLIC_SCHOOLS;

--Q2.2 Creating a View: Write and execute a SQL statement that returns all of the columns from the view.

SELECT * FROM FROM_CPS;

--Q2.3 Creating a View: Write and execute a SQL statement that returns just the school name and leaders rating from the view.

SELECT School_Name, Leaders_Rating FROM FROM_CPS;

--Q3.1 Creating a Stored Procedure: Write the structure of a query to create or replace a stored procedure called UPDATE_LEADERS_SCORE that takes a in_School_ID parameter as an integer and a in_Leader_Score parameter as an integer. Don't forget to use the #SET TERMINATOR statement to use the @ for the CREATE statement terminator.

--#SET TERMINATOR @
CREATE OR REPLACE PROCEDURE UPDATE_LEADERS_SCORE_EXAMPLE       -- Name of this stored procedure routine

LANGUAGE SQL                        -- Language used in this routine 
READS SQL DATA                      -- This routine will only read data from the table

DYNAMIC RESULT SETS 1               -- Maximum possible number of result-sets to be returned to the caller query

BEGIN 

    DECLARE C1 CURSOR               -- CURSOR C1 will handle the result-set by retrieving records row by row from the table
    WITH RETURN FOR                 -- This routine will return retrieved records as a result-set to the caller query
    
    SELECT "School_ID", "Leaders_Score" FROM CHICAGO_PUBLIC_SCHOOLS;          -- Query to retrieve all the records from the table
    
    OPEN C1;                        -- Keeping the CURSOR C1 open so that result-set can be returned to the caller query

END
@                                   -- Routine termination character

CALL UPDATE_LEADERS_SCORE_EXAMPLE
@

--Q3.2 Creating a Stored Procedure: Inside your stored procedure, write a SQL statement to update the Leaders_Score field in the CHICAGO_PUBLIC_SCHOOLS table for the school identified by in_School_ID to the value in the in_Leader_Score parameter.

--#SET TERMINATOR @
CREATE OR REPLACE PROCEDURE UPDATE_LEADERS_SCORE(IN in_School_ID INTEGER, IN in_Leaders_Score INTEGER)       -- Name of this stored procedure routine
LANGUAGE SQL                        -- Language used in this routine
MODIFIES SQL DATA                      -- This routine can modify data from the table

BEGIN 

	UPDATE CHICAGO_PUBLIC_SCHOOLS
	SET "Leaders_Score"= in_Leaders_Score
	WHERE "School_ID" = in_School_ID;

--Q3.3 Creating a Stored Procedure: Inside your stored procedure, write a SQL IF statement to update the Leaders_Icon field in the CHICAGO_PUBLIC_SCHOOLS table for the school identified by in_School_ID using the following information.
	IF in_Leaders_Score > 0 AND in_Leaders_Score < 20 THEN
		UPDATE CHICAGO_PUBLIC_SCHOOLS
		SET "Leaders_Icon" = 'Very_weak'
		WHERE "School_ID" = in_School_ID;

	ELSEIF in_Leaders_Score < 40 THEN
		UPDATE CHICAGO_PUBLIC_SCHOOLS
		SET "Leaders_Icon" = 'Weak'
		WHERE "School_ID" = in_School_ID;

	ELSEIF in_Leaders_Score < 60 THEN
		UPDATE CHICAGO_PUBLIC_SCHOOLS
		SET "Leaders_Icon" = 'Average'
		WHERE "School_ID" = in_School_ID;

	ELSEIF in_Leaders_Score < 80 THEN
		UPDATE CHICAGO_PUBLIC_SCHOOLS
		SET "Leaders_Icon" = 'Strong'
		WHERE "School_ID" = in_School_ID;

	ELSEIF in_Leaders_Score < 100 THEN
		UPDATE CHICAGO_PUBLIC_SCHOOLS
		SET "Leaders_Icon" = 'Very_strong'
		WHERE "School_ID" = in_School_ID;
--Q4.1 Update your stored procedure definition. Add a generic ELSE clause to the IF statement that rolls back the current work if the score did not fit any of the preceding categories.	
	ELSE ROLLBACK WORK;
	END IF;
--Q4.2 Update your stored procedure definition again. Add a statement to commit the current unit of work at the end of the procedure.
	COMMIT WORK;
END
@                                   -- Routine termination character

--Q3.4 Run your code to create the stored procedure & Write a query to call the stored procedure, passing a valid school ID and a leader score of 50, to check that the procedure works as expected.
-- NOTE: I had to alter column to be able to run procedure using following command: ALTER TABLE CHICAGO_PUBLIC_SCHOOLS ALTER COLUMN "Leaders_Icon" SET DATA TYPE VARCHAR(11)
CALL UPDATE_LEADERS_SCORE(610185, 50)