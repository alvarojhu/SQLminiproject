/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name
	FROM  `Facilities` 
	WHERE membercost > 0.0
LIMIT 0 , 30

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(name)
	FROM `Facilities`
	WHERE membercost = 0.0
LIMIT 0, 30


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM  `Facilities` 
WHERE membercost / monthlymaintenance <= 0.20
AND membercost != 0.0
LIMIT 0 , 30


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * 
FROM  `Facilities` 
WHERE facid
IN ( 1, 5 ) 
LIMIT 0 , 30

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance, 
	CASE WHEN monthlymaintenance <=100
	THEN  'cheap'
	ELSE  'expensive'
	END AS  'cheap_or_expensive'
FROM  `Facilities` 
GROUP BY 2 
LIMIT 0 , 30


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT joindate, firstname, surname
FROM  `Members` 
WHERE joindate = ( 
SELECT MAX( joindate ) 
FROM  `Members` ) 
ORDER BY joindate DESC 
LIMIT 0 , 30

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT surname, firstname, name
	FROM  `Bookings` booking
	JOIN  `Members` members ON booking.memid = members.memid
	JOIN  `Facilities` facilities ON facilities.facid = booking.facid
	WHERE name IN (
			'Tennis Court 1',  'Tennis Court 2'
			)
	GROUP BY 1 , 2
LIMIT 0 , 30


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT name as facility, CONCAT(firstname, ' ', surname) AS full_name,
	CASE WHEN firstname = 'GUEST' AND guestcost*slots >=30 THEN guestcost*slots
		WHEN firstname != 'GUEST' AND membercost*slots >=30 THEN membercost*slots
		ELSE NULL END AS cost
	FROM `Facilities` AS facilities
	JOIN `Bookings` AS bookings ON facilities.facid=bookings.facid
	JOIN `Members` AS members ON members.memid=bookings.memid
WHERE LEFT(starttime,10) = '2012-09-14' 
AND ((firstname = 'GUEST' AND guestcost*slots >= 30) OR (firstname != 'GUEST' AND membercost*slots >= 30))
ORDER BY 3 DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT sub.*
	FROM (
        SELECT name, CONCAT(firstname, ' ', surname) AS fullname, 
        CASE WHEN firstname = 'GUEST' AND guestcost*slots >=30 THEN guestcost*slots
		WHEN firstname != 'GUEST' AND membercost*slots >=30 THEN membercost*slots
		ELSE NULL END AS cost
        	FROM `Bookings` booking 
        	JOIN `Facilities` facilities ON booking.facid = facilities.facid
        	JOIN `Members` members ON members.memid = booking.memid
        WHERE LEFT(starttime, 10) = '2012-09-14'
        ) sub
WHERE sub.cost >= 30
ORDER BY sub.cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT sub2.name AS facility, revenue - sub2.monthlymaintenance*months_apart AS revenue
	FROM(
SELECT sub.name AS name, SUM(cost)-initialoutlay AS revenue, ROUND((MAX(sub.day)-MIN(sub.day))/100) AS months_apart, sub.monthlymaintenance AS monthlymaintenance
	FROM (
	SELECT name, initialoutlay, memid, CAST(LEFT(starttime, 10) AS DATE) as day, monthlymaintenance,
	CASE WHEN memid != 0 THEN membercost
		 WHEN memid = 0 THEN guestcost
		 ELSE NULL END AS cost
	FROM `Bookings` booking
	JOIN `Facilities` facilities ON booking.facid = facilities.facid
       ) sub
	GROUP BY sub.name
) sub2
WHERE revenue - monthlymaintenance*months_apart > 1000
