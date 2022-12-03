USE 365_database;
SHOW TABLES;

-- Where most student come from AND what type of purchase?
SELECT p.student_id,student_country,purchase_type,date_registered, date_purchased
FROM 365_student_info i
JOIN 365_student_purchases p
ON i.student_id = p.student_id;

-- How many courses that student from countries bought?
SELECT i.student_id, COUNT(course_id) AS number_of_course, student_country
FROM 365_student_info i
JOIN 365_student_learning l
ON i.student_id = l.student_id
GROUP BY i.student_id;

-- Average rating of each course?
SELECT r.course_id,i.course_title, AVG(r.course_rating) as avg_course_rate
FROM 365_course_ratings r 
JOIN 365_course_info i
ON r.course_id = i.course_id
GROUP BY r.course_id
ORDER BY avg_course_rate;

-- which course is bought the most?
SELECT l.course_id, i.course_title, COUNT(l.student_id) as number_of_student_bought
FROM 365_student_learning l
JOIN 365_course_info i
ON l.course_id = i.course_id
GROUP BY l.course_id
ORDER BY number_of_student_bought DESC;

-- Clarify the exam category in 365_exam_info by creating a view

CREATE VIEW exam_cat_description AS
SELECT exam_id,exam_category,exam_duration,
CASE exam_category
	WHEN 1 THEN 'Course exam'
    WHEN 2 THEN 'Practice exam'
    WHEN 3 THEN 'Career track exam'
END AS exam_cat_descr
FROM 365_exam_info;

SELECT *
FROM exam_cat_description;

-- **How minutes_Watches affect the student exam
SELECT e.student_id,l.course_id,ci.course_title,e.exam_id,exam_result,minutes_watched, i.exam_category,exam_cat_descr,exam_completion_time,i.exam_duration
FROM 365_student_exams e
JOIN 365_student_learning l
ON e.student_id = l.student_id
JOIN 365_exam_info i
ON e.exam_id = i.exam_id
JOIN exam_cat_description d
ON d.exam_id=e.exam_id
JOIN 365_course_info ci
ON l.course_id=ci.course_id;

-- Exam category with the time completion and result
SELECT student_id,exam_category,exam_cat_descr,exam_result,exam_completion_time,exam_duration
FROM 365_student_exams e
JOIN exam_cat_description d
ON e.exam_id = d.exam_id;

-- The exam result of student who engaged in quiz, exams, lessons
SELECT es.student_id,AVG(exam_result) AS avg_exam_result,engagement_quizzes,engagement_exams, engagement_lessons
FROM 365_student_exams es
JOIN 365_student_engagement et
ON es.student_id = et.student_id
WHERE (engagement_quizzes=1 AND engagement_exams=1 AND engagement_lessons=1)
GROUP BY es.student_id;

SELECT sn.student_id,exam_result,ci.course_id,course_title,engagement_quizzes,engagement_exams,engagement_lessons
FROM 365_student_engagement sn
JOIN 365_student_learning sl
ON sn.student_id=sl.student_id
JOIN 365_course_info ci
ON sl.course_id=ci.course_id
JOIN 365_student_exams se
ON se.student_id=sn.student_id
WHERE engagement_quizzes=1 AND engagement_exams=1 AND engagement_lessons=0;

SELECT es.student_id,ed.exam_id,ci.course_id,course_title,exam_result,exam_cat_descr,exam_duration,exam_completion_time,engagement_quizzes,engagement_exams,engagement_lessons
FROM 365_student_exams es
JOIN 365_student_engagement eg
ON es.student_id = eg.student_id
JOIN exam_cat_description ed
ON ed.exam_id = es.exam_id
JOIN 365_student_learning sl
ON es.student_id=sl.student_id
JOIN 365_course_info ci
ON sl.course_id=ci.course_id;

-- The exam result of student who NOT engaged in exams, lessons
SELECT es.student_id,AVG(exam_result),engagement_quizzes,engagement_exams, engagement_lessons
FROM 365_student_exams es
JOIN 365_student_engagement et
ON es.student_id = et.student_id
WHERE (engagement_quizzes=1 AND engagement_exams=1 AND engagement_lessons=0)
GROUP BY es.student_id;

-- The exam result of student who answer not correct the quiz, have question in the hub. 
-- Number of hub_question from student
DROP VIEW student_hub_question;
CREATE VIEW student_hub_question AS
SELECT student_id,COUNT(hub_question_id) AS number_hub_questions
FROM 365_student_hub_questions
GROUP BY student_id;

-- student who has number of hub_questions and their exam result.
SELECT e.student_id,q.number_hub_questions, exam_result, exam_completion_time,exam_category, exam_cat_descr
FROM 365_student_exams e
JOIN student_hub_question q
ON e.student_id = q.student_id
JOIN exam_cat_description d
ON d.exam_id=e.exam_id;

-- students have engage in quiz, and their exam result
SELECT se.student_id,qi.quiz_id,answer_correct,exam_result
FROM 365_student_quizzes sq
JOIN 365_quiz_info qi
ON sq.quiz_id = qi.quiz_id
JOIN 365_student_exams se
ON sq.student_id=se.student_id
JOIN 365_student_engagement seg
ON seg.student_id=se.student_id
WHERE engagement_quizzes=1;

