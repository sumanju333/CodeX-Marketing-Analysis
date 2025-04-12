-- Demographic Insights

-- Who prefers energy drink more?  (male/female/non-binary?) 
SELECT gender,COUNT(*) AS total, RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM dim_respondents
GROUP BY gender;

-- Which age group prefers energy drinks more? 
SELECT age, COUNT(*) AS total, RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM dim_respondents
GROUP BY age ;

-- Which type of marketing reaches the most Youth (15-30)? 
SELECT s.marketing_channels, COUNT(*) AS combined_total, RANK() OVER(ORDER BY count(*) DESC) AS ranking
FROM survey_responses s
JOIN dim_respondents r
ON s.Respondent_ID = r.Respondent_ID
WHERE r.age IN( "15-18" ,"19-30")
GROUP BY s.Marketing_channels;


-- Customer Preferences
-- What are the preferred ingredients of energy drinks among respondents?
SELECT Ingredients_expected ,COUNT(*) AS total, RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM survey_responses
GROUP BY Ingredients_expected;

-- What packaging preferences do respondents have for energy drinks? 
SELECT Packaging_preference ,COUNT(*) AS total, RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM survey_responses
GROUP BY Packaging_preference;

-- Competition Analysis: 
-- Who are the current market leaders?
SELECT Current_brands ,COUNT(*) AS total, RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM survey_responses
GROUP BY Current_brands;

-- What are the primary reasons consumers prefer those brands over ours?
SELECT Reasons_for_choosing_brands ,COUNT(*) AS total, RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM survey_responses
GROUP BY Reasons_for_choosing_brands;


-- Marketing Channels and Brand Awareness: 
-- Which marketing channel can be used to reach more customers?
SELECT Marketing_channels ,COUNT(*) AS total, RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM survey_responses
GROUP BY Marketing_channels;


-- Brand Penetration: 
-- What do people think about our brand? (overall rating) 
SELECT ROUND(AVG(Taste_experience),1) AS average_rating
FROM survey_responses
WHERE Heard_before = 'Yes';

-- Which cities do we need to foucs more on
with pos as (SELECT 
    c.City, 
    COUNT(*) AS positive_count
FROM dim_respondents r
JOIN survey_responses s ON s.Respondent_ID = r.Respondent_ID
LEFT JOIN dim_cities c ON r.City_ID = c.City_ID
WHERE s.Brand_perception = 'positive'
GROUP BY c.City),
negg as ( SELECT c.City, count(*) as negative_count
FROM dim_respondents r
JOIN survey_responses s ON s.Respondent_ID = r.Respondent_ID
LEFT JOIN dim_cities c ON r.City_ID = c.City_ID
WHERE s.Brand_perception = 'negative'
GROUP BY c.City),
neu as (SELECT c.city, count(*) as neutral_count
FROM dim_respondents r
JOIN survey_responses s ON s.Respondent_ID = r.Respondent_ID
LEFT JOIN dim_cities c ON r.City_ID = c.City_ID
WHERE s.Brand_perception = 'neutral'
GROUP BY c.City)
SELECT pos.city, pos.positive_count , negg.negative_count, neu.neutral_count
FROM pos
JOIN negg
ON pos.city = negg.city
JOIN neu
ON pos.city = neu.city;


-- purchase behaviour
-- Where do respondents prefer to purchase energy drinks?
SELECT Purchase_location ,COUNT(*) AS total, RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM survey_responses
GROUP BY Purchase_location;

-- What are the typical consumption situations for energy drinks among respondents? 
SELECT Typical_consumption_situations ,COUNT(*) AS total, RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM survey_responses
GROUP BY Typical_consumption_situations;

-- What factors influence respondents' purchase decisions, such as price range and limited edition packaging?
SELECT Price_range ,COUNT(*) AS total, RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM survey_responses
GROUP BY Price_range;
SELECT Limited_edition_packaging ,COUNT(*) AS total, RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM survey_responses
GROUP BY Limited_edition_packaging;

-- Which area of business should we focus more on our product development? (Branding/taste/availability)
SELECT Reasons_for_choosing_brands ,COUNT(*) AS total, RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM survey_responses
GROUP BY Reasons_for_choosing_brands;

-- Identify the city and age group combination with the highest percentage of respondents who consume energy drinks daily.
WITH TotalRespondents AS (
    SELECT c.City, r.Age, 
           COUNT(*) AS total_respondents
    FROM dim_respondents r
    JOIN survey_responses s ON s.Respondent_ID = r.Respondent_ID
    LEFT JOIN dim_cities c ON r.City_ID = c.City_ID
    GROUP BY c.City, r.Age)
SELECT c.City, r.Age, 
    Round((COUNT(*) * 100.0 / tr.total_respondents),2) AS daily_percentage
FROM dim_respondents r
JOIN survey_responses s ON s.Respondent_ID = r.Respondent_ID
LEFT JOIN dim_cities c ON r.City_ID = c.City_ID
JOIN TotalRespondents tr ON tr.City = c.City AND tr.Age = r.Age
WHERE s.Consume_frequency = "Daily"
GROUP BY c.City, r.Age, tr.total_respondents
ORDER BY daily_percentage DESC;

-- Which marketing channel is most preferred by respondents in Tier 2 cities ?
SELECT 
    s.Marketing_channels, 
    COUNT(*) AS total
FROM dim_respondents r
JOIN survey_responses s ON s.Respondent_ID = r.Respondent_ID
LEFT JOIN dim_cities c ON r.City_ID = c.City_ID
WHERE c.Tier = 'Tier 2' 
GROUP BY s.Marketing_channels
ORDER BY total DESC;


-- Which competing brand (CodeX, Cola-Coka, etc.) is most preferred by respondents aged 19-30, 
-- and what is the primary reason for their preference?
SELECT s.Current_brands, s.Reasons_for_choosing_brands,
COUNT(*) AS combined_total, 
RANK() OVER(ORDER BY count(*) DESC) AS ranking
FROM survey_responses s
JOIN dim_respondents r
ON s.Respondent_ID = r.Respondent_ID
WHERE r.age = "19-30"
group by s.Current_brands, s.Reasons_for_choosing_brands
HAVING s.Current_brands <> "Others";


-- Among respondents who purchase energy drinks from gyms and fitness centers, 
-- which consumption situation is the most common?
SELECT s.Typical_consumption_situations,
COUNT(*) AS total, 
RANK() OVER(ORDER BY count(*) DESC) AS ranking
FROM survey_responses s
WHERE s.Purchase_location = "Gyms and fitness centers"
group by s.Typical_consumption_situations;








