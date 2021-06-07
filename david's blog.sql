--highest revenue/user ratio by country(first read)
SELECT country, source,
       SUM(buy.price)::FLOAT/ COUNT(DISTINCT (first_read.user_id))::FLOAT AS ratio
FROM first_read
  FULL JOIN buy ON first_read.user_id = buy.user_id
GROUP BY country, source;


-- first reads-------------------------------------------------------------------------------------


-- count by source(first)
SELECT source, COUNT(*) as number_users
FROM first_read
GROUP BY source;

-- count users by country
SELECT country, COUNT(*) as number_users 
FROM first_read
GROUP BY country
ORDER BY number_users DESC;

-- count users by country, source
SELECT country, source, COUNT(*) as number_users 
FROM first_read
GROUP BY country, source;

-- count users by country, topic
SELECT country, topic, COUNT(*) as number_users 
FROM first_read
GROUP BY country, topic;

--trends
-- country
SELECT my_date, country, COUNT(*) as number_users 
FROM first_read 
GROUP BY my_date, country;

--source
SELECT my_date, source, COUNT(*) as number_users 
FROM first_read 
GROUP BY my_date, source;


-- first AND returned readers-----------------------------------------------------------------------------


-- count users by country 
SELECT country, COUNT(DISTINCT(user_id)) as number_users FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned
GROUP BY country
ORDER BY number_users DESC; 


-- count users by country, topic 
SELECT country, topic, COUNT(DISTINCT(user_id)) as number_users FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned
GROUP BY country, topic; 

--trends-----------------------------------
-- country
SELECT my_date, country, COUNT(*) as number_users FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned
GROUP BY my_date, country; 


-- subcribe--------------------------------------------------------------------------------------------------


-- count by source(first)
SELECT source, COUNT(*) as number_users
FROM subscribe JOIN first_read ON subscribe.user_id = first_read.user_id
GROUP BY source;

-- count by country(first+returned)
SELECT country, COUNT(*) number_users FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned JOIN subscribe ON read_and_returned.user_id = subscribe.user_id
GROUP BY country; 

-- count by country, source(first)
SELECT country, source, COUNT(DISTINCT(subscribe.user_id)) as number_users
FROM subscribe JOIN first_read ON subscribe.user_id = first_read.user_id
GROUP BY country, source;

-- count by country, topic(first+returned)
SELECT country ,topic, COUNT(DISTINCT(subscribe.user_id)) number_users FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned JOIN subscribe ON read_and_returned.user_id = subscribe.user_id
GROUP BY country, topic; 

-- trends----------------------------------------------------
-- by source(first)
SELECT subscribe.my_date, source, COUNT(*) as number_users
FROM subscribe JOIN first_read ON subscribe.user_id = first_read.user_id
GROUP BY subscribe.my_date, source;

-- by country(first + returned)
SELECT subscribe.my_date, country, COUNT(*) number_users FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned JOIN subscribe ON read_and_returned.user_id = subscribe.user_id
GROUP BY subscribe.my_date, country;


-- buy---------------------------------------------------------------------------------------------


-- by source(first)
SELECT source, COUNT(*) as number_purchases
FROM first_read JOIN buy ON first_read.user_id = buy.user_id
GROUP BY source;

-- revenue/user ratio (first read)
SELECT source,
       SUM(buy.price)::FLOAT/ COUNT(DISTINCT (first_read.user_id))::FLOAT AS ratio
FROM first_read
  FULL JOIN buy ON first_read.user_id = buy.user_id
GROUP BY source;

-- by country no. purchases(first+returned)
SELECT country, COUNT(*) number_purchases FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned JOIN buy ON read_and_returned.user_id = buy.user_id
GROUP BY country; 

-- by country sum purchases(first+returned)
SELECT country, SUM(price) sum_of_revenue FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned JOIN buy ON read_and_returned.user_id = buy.user_id
GROUP BY country;

-- count by country, topic no. purchases(first+returned)
SELECT country ,topic, COUNT(DISTINCT(buy.user_id)) number_users FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned JOIN buy ON read_and_returned.user_id = buy.user_id
GROUP BY country, topic; 

-- by country, topic sum purchases(first+returned)
SELECT country, topic, SUM(price) sum_of_revenue FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned JOIN buy ON read_and_returned.user_id = buy.user_id
GROUP BY country, topic;

--trends--------------------------------------------------------------------
-- by source(first)
SELECT buy.my_date, source, COUNT(*) as number_users
FROM buy JOIN first_read ON buy.user_id = first_read.user_id
GROUP BY buy.my_date, source;

-- by country(first + returned)
SELECT buy.my_date, country, COUNT(*) number_users FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned JOIN buy ON read_and_returned.user_id = buy.user_id
GROUP BY buy.my_date, country;

--by sum of purchases
SELECT buy.my_date, SUM(price) sum_purchases FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned JOIN buy ON read_and_returned.user_id = buy.user_id
GROUP BY buy.my_date; 

--by sum of purchases/country
SELECT buy.my_date, country, SUM(price) sum_purchases FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned JOIN buy ON read_and_returned.user_id = buy.user_id
GROUP BY buy.my_date, country; 



--all readers, subscribers, buyers by country (union the 4 tables)
SELECT readers.country, readers.number_readers, subscribers.number_subscribers, purchasers.number_purchases FROM
(SELECT country, COUNT(DISTINCT(user_id)) as number_readers FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned
GROUP BY country) as readers
JOIN 
(SELECT country, COUNT(DISTINCT(subscribe.user_id)) number_subscribers FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned JOIN subscribe ON read_and_returned.user_id = subscribe.user_id
GROUP BY country) as subscribers ON readers.country = subscribers.country
JOIN
(SELECT country, COUNT(DISTINCT(buy.user_id)) number_purchases FROM
(SELECT my_date, event, country, user_id, topic FROM first_read
UNION ALL
SELECT * FROM returned_read) as read_and_returned JOIN buy ON read_and_returned.user_id = buy.user_id
GROUP BY country) as purchasers ON subscribers.country = purchasers.country; 


-- books, videos
SELECT country, price, COUNT(*) as num_of_products FROM 
(SELECT * FROM buy JOIN first_read ON buy.user_id = first_read.user_id) AS sub
GROUP BY country, price;
