create external table departments (
department_id int,
department_name string
) row format delimited fields terminated by ',';

create external table categories (
category_id int,
category_department_id int,
category_name string
) row format delimited fields terminated by ',';

create external table products (
product_id int,
product_category_id int,
product_name string,
product_description string,
product_price float,
product_image string
) row format delimited fields terminated by ',';

create external table order_items (
order_item_id int,
order_item_order_id int,
order_item_product_id int,
order_item_quantity int,
order_item_subtotal float,
order_item_product_price float
) row format delimited fields terminated by ',';

create external table orders (
order_id int,
order_date string,
order_customer_id int,
order_status string
) row format delimited fields terminated by ',';

create external table customers (
customer_id int,
customer_fname string,
customer_lname string,
customer_email string,
customer_password string,
customer_street string,
customer_city string,
customer_state string,
customer_zipcode string
) row format delimited fields terminated by ',';

--5  Obtener los departamentos que empiezan con la letra G. La búsqueda-- 
--debe ser indistinta por mayúsculas o minúsculas.--
SELECT *  FROM departments WHERE LOWER(department_name) LIKE 'g%' limit 20; 

-- 6 Obtener los productos que nunca fueron vendidos (Nota: Utilizar LEFT-- 
--OUTER JOIN).--

SELECT P.product_id AS Id_producto, P.product_name AS Nombre_productos , O.order_item_product_id 
FROM products P 
LEFT OUTER JOIN order_items O ON P.product_id =O.order_item_product_id 
WHERE O.order_item_product_id  IS NULL 
LIMIT 20;

--7. Obtener el monto total de venta (en base a la columna 
--order_item_subtotal) por product_id, ordenar por dicho monto en orden-- 
--descendente.--

SELECT P.product_id AS Id_Producto, SUM(O.order_item_subtotal) AS TOTAL  
FROM order_items O
INNER JOIN products P ON P.product_id =O.order_item_product_id 
GROUP BY P.product_id 
ORDER BY TOTAL DESC LIMIT 20;

--8. Obtener el nombre de departamento y de categoría que le corresponden--
--al departamento “Fitness”--

SELECT D.department_name, C.category_name  FROM departments D
INNER JOIN categories C ON C.category_department_id =D.department_id
WHERE D.department_name = "Fitness" LIMIT 20;


--9. Obtener los productos cuyo departamento empieza con la letra “A”--

SELECT P.product_id, P.product_name,D.department_name 
FROM products P
INNER JOIN categories C ON P.product_category_id =C.category_id 
INNER JOIN departments D ON C.category_department_id =D.department_id 
WHERE D.department_name LIKE 'A%' LIMIT 20;

-- 10.Obtener el monto total comprado por la cliente “Ann Smith” en fechas-- 
--posteriores al 01 de julio de 2014. (Pista: usar la función to_date)--

SELECT  SUM(I.order_item_subtotal) AS TOTAL, CONCAT(C.customer_fname,' ',C.customer_lname) AS Name
FROM customers C
INNER JOIN orders O ON O.order_customer_id =C.customer_id 
INNER JOIN order_items I ON I.order_item_order_id =O.order_id 
WHERE CONCAT(C.customer_fname,' ',C.customer_lname)='Ann Smith' AND 
EXTRACT(YEAR FROM TO_DATE(O.order_date)) >= 2014 AND EXTRACT(MONTH FROM TO_DATE(O.order_date)) >= 7 AND 
EXTRACT(DAY FROM TO_DATE(O.order_date)) >= 1
GROUP BY CONCAT(C.customer_fname,' ',C.customer_lname)
ORDER BY TOTAL

--.Obtener:--
--Nombre de Departamento--
--Nombre de Categoría--
--Nombre de producto--
--De todos los productos cuyas ventas totales sobrepasaron 1000 dólares --
--en julio de 2014.--

SELECT D.department_name, C.category_name , P.product_name FROM departments D 
INNER JOIN categories C ON C.category_department_id =D.department_id 
INNER JOIN products P ON P.product_category_id =C.category_id 
INNER JOIN order_items O ON O.order_item_product_id =P.product_id 
INNER JOIN orders ORD ON O.order_item_order_id =ORD.order_id 
WHERE EXTRACT(YEAR FROM TO_DATE(ORD.order_date)) = 2014 AND EXTRACT(MONTH FROM TO_DATE(ORD.order_date)) = 7
GROUP BY P.product_name, D.department_name , C.category_name 
HAVING SUM(O.order_item_subtotal)>1000 LIMIT 20;

--12.Crear una nueva tabla “ventas totales” con el resultado del inciso 11--
--que esté separado por comas. Mostrar las primeras filas del contenido-- 
--de dicho archivo--

CREATE EXTERNAL TABLE ventas_totales
(
	department_name string,
 	category_name string,
  	product_name string
  	
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ',';

INSERT OVERWRITE TABLE ventas_totales 
SELECT D.department_name, C.category_name , P.product_name FROM departments D 
INNER JOIN categories C ON C.category_department_id =D.department_id 
INNER JOIN products P ON P.product_category_id =C.category_id 
INNER JOIN order_items O ON O.order_item_product_id =P.product_id 
INNER JOIN orders ORD ON O.order_item_order_id =ORD.order_id 
WHERE EXTRACT(YEAR FROM TO_DATE(ORD.order_date)) = 2014 AND EXTRACT(MONTH FROM TO_DATE(ORD.order_date)) = 7
GROUP BY P.product_name, D.department_name , C.category_name 
HAVING SUM(O.order_item_subtotal)>1000 LIMIT 20;

SELECT * FROM ventas_totales LIMIT 20;
