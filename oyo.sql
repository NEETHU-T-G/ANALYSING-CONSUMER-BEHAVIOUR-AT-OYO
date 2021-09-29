USE [project 4]
SELECT * FROM hotel ORDER BY 1
SELECT * FROM Oyoplace

--Number of hotels in different cities--
SELECT C.City, COUNT(DISTINCT(H.hotel_id)) AS Number_of_hotels FROM hotel H JOIN Oyoplace C
ON C.Hotel_id=H.hotel_id
GROUP BY C.City ORDER BY 2
WITH TOCTE AS
(
SELECT C.City, COUNT(DISTINCT(H.hotel_id)) AS Number_of_hotels  FROM hotel H JOIN Oyoplace C
ON C.Hotel_id=H.hotel_id
GROUP BY C.City

)
SELECT SUM(Number_of_hotels) AS Total FROM TOCTE 
--Average room rates of different cities--
ALTER TABLE hotel
ADD Total_Amount NUMERIC
UPDATE hotel
SET Total_Amount = amount+discount
ALTER TABLE hotel
ADD No_of_Days NUMERIC
UPDATE hotel
SET No_of_Days = DATEDIFF(day,check_in,check_out)
ALTER TABLE hotel
ADD Rate FLOAT
UPDATE hotel
SET Rate=ROUND(CASE WHEN no_of_rooms=1 THEN (Total_Amount/No_of_Days)
ELSE (Total_Amount/No_of_Days)/no_of_rooms END,2)

SELECT C.City,ROUND(AVG(H.Rate),2) AS Average_Rate  FROM hotel H JOIN Oyoplace C
ON C.Hotel_id=H.hotel_id
GROUP BY C.City ORDER BY 2 DESC

--ALTER TABLE hotel DROP COLUMN Total_Amount_After_Discount 

--Cancellation Rate--
WITH CanCTE AS
(

SELECT C.City,
SUM(CASE WHEN status= 'Cancelled' THEN 1 WHEN status='Stayed' THEN 0 ELSE 0 END) AS Total_Cancelled,
SUM(CASE WHEN status= 'Stayed' THEN 1 WHEN status='Cancelled' THEN 0 ELSE 0 END) AS Total_Stayed,
SUM(CASE WHEN status= 'Cancelled' THEN 1 WHEN status='Stayed' THEN 1 ELSE 1 END) AS Total
FROM hotel H JOIN Oyoplace C
ON C.Hotel_id=H.hotel_id
GROUP BY C.City 
)
SELECT City,(Total_Cancelled*100)/Total AS Cancellation_rate FROM CanCTE ORDER BY 2 DESC
--Bookings made in the months of January,February and March--
SELECT C.City,MONTH(H.date_of_booking) AS Month,COUNT(*) AS Total_Booking FROM hotel H JOIN Oyoplace C
ON C.Hotel_id=H.hotel_id
WHERE MONTH(date_of_booking) BETWEEN 1 AND 3  GROUP BY C.City,MONTH(date_of_booking) ORDER BY 1
--NATURE OF BOOKINGS--
--Number of days prior the bookings were made--
WITH DAYCTE AS(
SELECT DATEDIFF(day,date_of_booking,check_in) AS Prior_checkin_day FROM hotel
)
SELECT COUNT(*)AS Total ,Prior_checkin_day  FROM DAYCTE GROUP BY Prior_checkin_day
--Most number of rooms booked--
SELECT COUNT(*) AS Total ,no_of_rooms FROM hotel GROUP BY no_of_rooms ORDER BY 2
--Most number of days spended--
SELECT COUNT(*) AS Total ,No_of_Days FROM hotel GROUP BY No_of_Days ORDER BY 2
--Ranking of cities based on Gross Revenue--
SELECT SUM(H.amount) AS Revenue,C.City FROM hotel H JOIN Oyoplace C
ON C.Hotel_id=H.hotel_id WHERE MONTH(date_of_booking) BETWEEN 1 AND 3   GROUP BY C.City ORDER BY 1 DESC
---Ranking of cities based on Net Revenue--
SELECT SUM(H.amount) AS Net_Revenue,C.City FROM hotel H JOIN Oyoplace C
ON C.Hotel_id=H.hotel_id WHERE MONTH(date_of_booking) BETWEEN 1 AND 3 AND  status NOT IN('Cancelled')
GROUP BY C.City ORDER BY 1 DESC
--Total Gross Revenue--
WITH GRCTE AS
(
SELECT SUM(H.amount) AS Gross_Revenue,C.City FROM hotel H JOIN Oyoplace C
ON C.Hotel_id=H.hotel_id WHERE MONTH(date_of_booking) BETWEEN 1 AND 3   GROUP BY C.City 
)
SELECT SUM(Gross_Revenue) AS TOTAL_Gross_Revenue FROM GRCTE
--Total Net Revenue--
WITH NRCTE AS
(
SELECT SUM(H.amount) AS Net_Revenue,C.City FROM hotel H JOIN Oyoplace C
ON C.Hotel_id=H.hotel_id WHERE MONTH(date_of_booking) BETWEEN 1 AND 3 AND  status NOT IN('Cancelled')
GROUP BY C.City 
)
SELECT SUM(Net_Revenue) AS TOTAL_Net_Revenue FROM NRCTE
--Comparison of Revenue based on Different cities--
CREATE VIEW GROSS AS
SELECT SUM(H.amount) AS Gross_Revenue,C.City FROM hotel H JOIN Oyoplace C
ON C.Hotel_id=H.hotel_id WHERE MONTH(date_of_booking) BETWEEN 1 AND 3   GROUP BY C.City 

CREATE VIEW NET AS
SELECT SUM(H.amount) AS Net_Revenue,C.City FROM hotel H JOIN Oyoplace C
ON C.Hotel_id=H.hotel_id WHERE MONTH(date_of_booking) BETWEEN 1 AND 3 AND  status NOT IN('Cancelled')
GROUP BY C.City 

SELECT G.Gross_Revenue,N.Net_Revenue,G.City FROM GROSS G JOIN NET N  ON G.City=N.City ORDER BY 1 DESC 

---Discount offered---

--DROP VIEW DISCOUNTS
CREATE VIEW DISCOUNT AS
SELECT C.City,(H.discount/H.Total_Amount)*100 AS Discount_Percentage FROM hotel H JOIN Oyoplace C
ON C.Hotel_id=H.hotel_id 

SELECT AVG(Discount_Percentage) AS Discount_Percentage,City  FROM DISCOUNT GROUP BY City ORDER BY 1 DESC
SELECT AVG(Discount_Percentage) AS Total_Average_Discount_Percentage FROM DISCOUNT
