/*Below is an analysis on a database from an online store. It includes details on their customers,
products, order details, and payment methods used.
We'll query the database and acquire a range of desired outputs
WELCOME! */

#Create a view where users will see the number of products per category
CREATE VIEW number_of_products_per_category AS
    (SELECT 
        category, COUNT(product_name) AS number_of_products
    FROM
        products
    GROUP BY category);


#a view where users will see customer spending habits
CREATE VIEW customer_expenditure AS
    (SELECT 
        o.customer_id,
        c.First_name,
        c.Last_name,
        SUM(o.quantity * o.unit_price) AS amount_spent
    FROM
        order_details o
            JOIN
        customers c ON o.Customer_id = c.Customer_id
    GROUP BY customer_id);


#create a procedure where users will input customer names and get their spending habits as output
delimiter $$
create procedure customer_expenditure (
in First_name varchar(60),
in Last_name varchar(60),
out amount_spent decimal(10,2))

begin
SELECT
sum(o.quantity * o.unit_price)  into amount_spent
FROM order_details o
join customers c on o.Customer_id=c.Customer_id
where c.First_name = First_name and c.Last_name = Last_name
 ;
end $$
delimiter ;


#get revenues per payment method
CREATE VIEW Payment_method_sum AS
    SELECT 
        Payment_method, SUM(order_total)
    FROM
        (SELECT 
            od.order_id,
                SUM(od.Quantity * od.Unit_price) AS order_total,
                p.Payment_method
        FROM
            order_details od
        JOIN payment p ON od.order_id = p.order_id
        GROUP BY od.order_id , p.Payment_method) AS subquery
    GROUP BY Payment_method
;


#get turnover of each product and arrange in descending order
SELECT 
    product_id, SUM(Quantity) AS numbers_sold
FROM
    order_details
GROUP BY product_id
ORDER BY numbers_sold DESC
;


#get the average number of goods sold per order
SELECT 
    order_id, ROUND(AVG(Quantity), 2) AS avg_goods_per_order
FROM
    order_details
GROUP BY order_id
;


#create procedure where users key in a date and get orders placed on that day
delimiter $$
create procedure cx_name_and_purchases (
in order_date date,
out order_details varchar(255)
)
begin
declare order_info varchar(255) ; #local variable to store details
set order_details = ''  ;
SELECT 
    CONCAT(Product_id, ':', Quantity)
INTO order_info FROM
    order_details
WHERE
    date = order_date;
set order_info=order_details
;
end $$
delimiter ;


#create another procedure which delivers similar results i.e. users input date and get respective order details
delimiter $$
create procedure date_order_details (
in order_date date )
begin
select od.Product_id, od.Quantity
from order_details od
where order_date=od.date ;
end $$
delimiter ;


#get revenues from each product category
select p.category, sum(od.Unit_price * od.Quantity) as revenues
from
order_details od
join products p on p.Product_id=od.Product_id
group by  p.category
order by revenues desc
;


#get quantites sold per product
SELECT 
    p.product_id, SUM(od.Quantity) AS quantites_sold
FROM
    order_details od
        JOIN
    products p ON p.Product_id = od.Product_id
GROUP BY p.product_id
ORDER BY times_sold DESC;


#get list of unordered products
SELECT 
    p.Product_id, p.Product_name
FROM
    products p
        LEFT JOIN
    order_details od ON p.Product_id = od.Product_id
WHERE
    od.Product_id IS NULL #no record of the product in the product details
GROUP BY Product_id;


#get monthly revenues
SELECT 
    YEAR(date) AS calendar_year,
    MONTH(Date) AS calendar_month,
    SUM(Quantity * Unit_price) AS revenues
FROM
    order_details
GROUP BY calendar_year , calendar_month;
