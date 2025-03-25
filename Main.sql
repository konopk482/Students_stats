select * from Students_Grading_Dataset
-- I checked if everything is working fine, float numbers have too much decimal points, so I will round them to 2 decimal points
ALTER TABLE Students_Grading_Dataset
ALTER COLUMN Attendance NUMERIC(10, 2);
ALTER TABLE Students_Grading_Dataset
ALTER COLUMN Midterm_score NUMERIC(10, 2);
ALTER TABLE Students_Grading_Dataset
ALTER COLUMN Final_score NUMERIC(10, 2);
ALTER TABLE Students_Grading_Dataset
ALTER COLUMN Assignments_avg NUMERIC(10, 2);
ALTER TABLE Students_Grading_Dataset
ALTER COLUMN Quizzes_avg NUMERIC(10, 2);
ALTER TABLE Students_Grading_Dataset
ALTER COLUMN Projects_score NUMERIC(10, 2);
ALTER TABLE Students_Grading_Dataset
ALTER COLUMN Participation_score NUMERIC(10, 2);
ALTER TABLE Students_Grading_Dataset
ALTER COLUMN Total_score NUMERIC(10, 2);
-- My sql version doesn't allow me to do it one time for multiple columns.
-- I will also round the Study_hours_per_week column to 0 decimal points
ALTER TABLE Students_Grading_Dataset
ALTER COLUMN Study_hours_per_week Numeric(10, 0);
-- Let's check the most obvious correlation, the grades to attencande
Select grade , avg(attendance) as avg_attendance ,count(*) from Students_Grading_Dataset group by Grade order by AVG_ATTENDANCE desc
--from this query I can see that grades A and B are more likly to be obtained if students have at least 80% attendance and the rest 
--of the grades are more likly to be abstend around 35% of the time, and this database is filled with mostly smart studens because
-- there is a lot of A students

--Lets check if there is difference beetwen departments

select avg(attendance) , department from Students_Grading_Dataset group by department

-- There isnt much difference, so i assume that there is not difference in grade either

select grade, count(*) as student_count,
    round(100.0 * count(*) / sum(count(*)) over(), 2) as percentage from students_grading_dataset group by grade order by percentage desc;

--There is around 30% A students


SELECT min(attendance) , max(attendance) from Students_Grading_Dataset
--The attendace is from 50-100, so I can group it by 5 categories to, 50-60, 60-70 and so on
-- I want to see the distribution of grades by these categories

with attendancegroups as (
    select 
        case 
            when attendance between 50 and 60 then 'group5060'
            when attendance between 60 and 70 then 'group6070'
            when attendance between 70 and 80 then 'group7080'
            when attendance between 80 and 90 then 'group8090'
            when attendance between 90 and 100 then 'group90100'
        end as attendancegroup,
        grade
    from students_grading_dataset
)
select 
    attendancegroup,
    grade,
    round(100.0 * count(*) / sum(count(*)) over(partition by attendancegroup), 2) as percentage
from attendancegroups
group by attendancegroup, grade
order by attendancegroup, percentage desc;
-- That shows how attendance impact grades, If you have higher attendance your grades should be better 
--in group90100 ther is not even C grade so that is amazing

select 
    grade, 
    count(*) as count, 
    round(100.0 * count(*) / sum(count(*)) over(), 2) as percentage
from Students_Grading_Dataset
where attendance < 60
group by grade
order by percentage desc;

--Students who have 60> attendance doesnt even have B grade, 42% of these Studends are so close to fail, close to 30% is failing.


select 
    grade, 
    count(*) as count, 
    round(100.0 * count(*) / sum(count(*)) over(), 2) as percentage
from Students_Grading_Dataset
where attendance >= 80
group by grade
order by percentage desc;
--On the other hand, over 56% students that got more than 80% attendance got an A then 27%  

--RESULT of these queries is that Attendance is very important to get better grades, Statysticly if u get 80% attendance 
-- you shouldn't fail to get things better you are very likly to get at least B!!



--Let's check if gender has any impact
Select gender, avg(attendance) as AVG_ATTENDANCE, grade, count(*) as count from Students_Grading_Dataset group by gender ,grade order by gender

-- there is no much difference. There is slighty more female A students and slighty more B male students , 
--and there is 2% difference in B studends attendance

--There is 100 more male than female
Select gender, count(*) as count , age from Students_Grading_Dataset group by gender , age
-- Ages are distibuted equally, there is around 40 students difference in age group 
-- I will show distribution by department to check if there is any difference

Select department, count(*)  as count from Students_Grading_Dataset group by department

-- CS major has the most students, so I would focus on that department to make changes
Select department, count(*) as count , age from Students_Grading_Dataset group by department, age

-- I can assume that majority of students passing through classes  by looking at their ages

-- There is much difference between them, I will check average total score by department to see whitch department is doing alright

Select department, avg(total_score) as avg_total_score,  gender from Students_Grading_Dataset group by department,  gender order by avg_total_score desc
-- There is equally distibution in gender in each department so no tendecies occur , every department has the same populairty
-- There is no much difference so i assume there is not attendance difference either
-- I'm thinking about checking if there is any difference in study hours per week or even stress level
Select department, Grade ,  gender , count (*) from Students_Grading_Dataset group by department ,grade,  gender order by department

-- I can see that in buesiness females are doing better than male, male has 98 D students and female only 70
Select 
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY 
        case 
            when Study_Hours_per_Week between 1 and 6 then 'group6'
            when Study_Hours_per_Week between 7 and 12 then 'group712'
            when Study_Hours_per_Week between 13 and 18 then 'group1318'
            when Study_Hours_per_Week between 19 and 24 then 'group1924'
            when Study_Hours_per_Week between 25 and 30 then 'group30'
        end
    ), 2) AS percentage,
    case 
        when Study_Hours_per_Week between 1 and 6 then 'group6'
        when Study_Hours_per_Week between 7 and 12 then 'group712'
        when Study_Hours_per_Week between 13 and 18 then 'group1318'
        when Study_Hours_per_Week between 19 and 24 then 'group1924'
        when Study_Hours_per_Week between 25 and 30 then 'group30'
    end as Study_Hours_per_Week_Group, 
    grade 
from Students_Grading_Dataset 
group by 
    case 
        when Study_Hours_per_Week between 1 and 6 then 'group6'
        when Study_Hours_per_Week between 7 and 12 then 'group712'
        when Study_Hours_per_Week between 13 and 18 then 'group1318'
        when Study_Hours_per_Week between 19 and 24 then 'group1924'
        when Study_Hours_per_Week between 25 and 30 then 'group30'
    end, 
    grade 
order by Study_Hours_per_Week_Group desc, percentage desc;
-- There is equally distribution in % grade in study hours groups so I can assume that study hours doesn't impact grades
-- There is no much difference in either one, Let's check the family income

Select family_income_level, avg(total_score), avg(attendance) as avg_total_score, count(*) as count from Students_Grading_Dataset group by Family_Income_Level order by avg_total_score desc

--Family income doesn't impact total_score and attendance
--In distibution of grades there is no much difference in family income level at low and medium but high is around 20% of the total
-- the rest is 40% and 40%. There is more students in medium and low family income level than high

Select avg(Stress_Level_1_10) as stress , avg(Sleep_Hours_per_Night), age as sleep  from Students_Grading_Dataset  group by age

-- There is a problem in sleep, only 6 hours avg is not a good thing, there is no impact on grads but it can impact mental health, 5 stress is not a good thing either

--Maybe parents education has some impact
Select Parent_Education_Level, avg(total_score), avg(attendance) as avg_total_score, count(*) as count from Students_Grading_Dataset group by Parent_Education_Level order by avg_total_score desc
-- A lot of parents have not filled their education level , but  I can see that there is no much difference in total score and attendance
-- I will check the distribution of grades
Select Parent_Education_Level, grade, count(*) as count from Students_Grading_Dataset group by Parent_Education_Level, grade order by Parent_Education_Level
-- There is slighty more PHD parents that got A students, but there is not much difference in other grades
Select Extracurricular_Activities, count(*), gender from Students_Grading_Dataset group by Extracurricular_Activities, gender
-- More than 66% of students don’t participate in extracurricular activities

-- Is internet has some impact on grades?
Select Internet_Access_at_Home, avg(total_score), avg(attendance) as avg_total_score, grade, gender, count(*) as count from Students_Grading_Dataset group by Internet_Access_at_Home , grade , gender order by grade desc

-- There is no much difference, only there is a lot more students that have internet access at home than not

-- Maybe family income has impact on having internet access at home
Select Family_Income_Level, Internet_Access_at_Home, count(*) as count from Students_Grading_Dataset group by Family_Income_Level, Internet_Access_at_Home order by Family_Income_Level
-- No much differenece, we can see that high family income level has less internet acces at home due to the fact that their count is lower
-- maybe income has a matter in having tutoring
Select Family_Income_Level, avg(Study_Hours_per_Week) , count(*) as count from Students_Grading_Dataset group by Family_Income_Level order by Family_Income_Level
-- There isn’t much difference.

-- Correlation analysis in Python showed that only grades have an impact on grades, which turned out to be true. 
-- Therefore, there is no point in analyzing other columns in depth.

-- **Key Takeaways:**
-- 1. Attendance is very important for achieving better grades.
--    - Students with at least 80% attendance are very likely to get at least a B.  
--    - Students with less than 60% attendance are very likely to fail.  
-- 2. There is minimal impact on grades from stress, sleep, family income level, and other factors.  
-- 3. Even study hours per week have minimal impact on grades.  

-- **Summary:**
-- - The most important focus should be on boosting attendance.  
-- - Schools should implement a reward system for students who maintain at least 80% attendance.  
-- - Schools should offer more engaging and entertaining classes to encourage higher attendance.  
-- - Students should aim for at least 80% attendance, as it would practically guarantee them at least a B grade.  
-- - Schools should establish a support system for students with less than 60% attendance.  
-- - Teachers should be more flexible and understanding with students, which could help reduce stress levels.  
-- - Mental health support, including stress and sleep management programs, would benefit students.  
-- - The focus should be on the Computer Science (CS) department since it has the most students and the highest fail count.  
-- - More than 66% of students don’t participate in extracurricular activities, so schools should create a system to encourage participation.  