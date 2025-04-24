
USE sakila;


-- 21) Obtén los 10 actores que han participado en más películas
-- (de mas a menos participaciones)
SELECT count(fa.actor_id) AS 'Cantidad', concat_ws(" ", ac.first_name, ac.last_name) AS 'Nombre Actor'
FROM film_actor fa
JOIN actor ac
ON fa.actor_id = ac.actor_id
GROUP BY fa.actor_id ORDER BY Cantidad DESC LIMIT 10
;

-- 22) Obtén los clientes de países que empiezan por S
SELECT concat_ws(" ", cu.first_name, cu.last_name) AS 'Nombre Cliente', co.country
FROM customer cu
JOIN address ad
ON cu.address_id = ad.address_id
JOIN city ci
ON ad.city_id = ci.city_id
JOIN country co
ON ci.country_id = co.country_id
WHERE ad.address_id IN 
(
SELECT address_id
FROM address
WHERE ci.city_id IN 
(
SELECT city_id
FROM city
WHERE ci.country_id IN 
(
SELECT country_id
FROM country
WHERE co.country like 's%'
)
)
);

-- 23) Obtén el top-10 de países con más clientes
SELECT count(cu.customer_id) AS Cantidad, co.country AS Pais
FROM customer cu
JOIN address ad
ON cu.address_id = ad.address_id
JOIN city ci
ON ad.city_id = ci.city_id
JOIN country co
ON ci.country_id = co.country_id
GROUP BY co.country_id
ORDER BY Cantidad DESC
LIMIT 10
;

-- 24) Muestra las 10 primeras películas alfabéticamente y el número de copias que se disponen de cada una de ellas
SELECT count(inv.film_id), fi.title -- , fi.film_id
FROM inventory inv
JOIN film fi
ON inv.film_id = fi.film_id
GROUP BY inv.film_id
ORDER BY fi.title ASC
LIMIT 10
;

-- 25 ¿ Cuántas películas ha alquilado Deborah Walker?
SELECT count(re.customer_id) AS 'Peliculas alquiladas', concat_ws(" ", cu.first_name, cu.last_name) AS Nombre -- , cu.customer_id 
FROM rental re
JOIN customer cu
ON re.customer_id = cu.customer_id 
WHERE concat_ws(" ", cu.first_name, cu.last_name) = "Deborah Walker"
GROUP BY re.customer_id
;


-- 26) Crea un procedimiento almacenado llamado 'rentals_by_client'
-- el cual, a partir del nombre y apellido del cliente,
-- muestre : nombre del cliente, apellido del cliente, título de la película, fecha de alquiler
-- ordenado por fecha de alquiler descendente
-- Pruébalo con el cliente 'Deborah Walker'
DELIMITER $$
CREATE PROCEDURE rentals_by_client(
sp_nombre VARCHAR(45),
sp_apellido VARCHAR(45)
)
BEGIN
	DECLARE idCliente INT; -- (customer_id)

	SELECT customer_id INTO idCliente FROM customer cu WHERE concat_ws(" ", cu.first_name, cu.last_name) = concat_ws(" ", sp_nombre, sp_apellido);

	IF idCliente IS NULL THEN
		SELECT "No hay ningún cliente con este nombre";
	ELSE
		SELECT cu.first_name, cu.last_name, fi.title, re.rental_date
		FROM rental re
		JOIN customer cu
		ON re.customer_id = idCliente
		JOIN inventory inv
		ON re.inventory_id = inv.inventory_id
		JOIN film fi
		ON inv.film_id = fi.film_id
		WHERE concat_ws(" ", cu.first_name, cu.last_name) = concat_ws(" ", sp_nombre, sp_apellido)
		ORDER BY re.rental_date DESC
		;
	END IF;
END $$
DELIMITER ;

SELECT cu.first_name, cu.last_name, fi.title, re.rental_date
FROM rental re
JOIN customer cu
ON re.customer_id = cu.customer_id
JOIN inventory inv
ON re.inventory_id = inv.inventory_id
JOIN film fi
ON inv.film_id = fi.film_id
WHERE concat_ws(" ", cu.first_name, cu.last_name) = "Deborah Walker"
ORDER BY re.rental_date DESC
;

-- DESCRIBE customer;
-- DROP PROCEDURE rentals_by_client;

CALL rentals_by_client ("Deborah", "Walker");
CALL rentals_by_client ("Linda", "Williams");
CALL rentals_by_client ("Paco", "Lopez");

-- 27) Crea un procedimiento almacenado llamado 'client_rental' que, realizando el alquiler de
-- una pelicula por parte de un cliente, nos retorne cuantos alquileres ha hecho.
-- la fecha del alquiler es la actual
-- Pruébalo así : call client_rental('Deborah', 'Walker', "ALADDIN CALENDAR" )

DELIMITER $$
CREATE PROCEDURE client_rental(
sp_nombre VARCHAR(45),
sp_apellido VARCHAR(45),
sp_pelicula VARCHAR(128)
)
BEGIN
	DECLARE idCliente INT; -- (customer_id)
    DECLARE idPelicula INT; -- (film_id)

	SELECT customer_id INTO idCliente FROM customer WHERE concat_ws(" ", first_name, last_name) = concat_ws(" ", sp_nombre, sp_apellido);
    SELECT film_id INTO idPelicula FROM film WHERE title = sp_pelicula;
    INSERT INTO rental (first_name, last_name, carnet_conducir, telefono, email)
 		VALUES (sp_nombre_cliente, sp_apellido_cliente, sp_carnet, sp_telefono, sp_email)
	;
END $$
DELIMITER ;

SELECT customer_id FROM customer WHERE concat_ws(" ", first_name, last_name) = "Deborah Walker";
SELECT film_id FROM film WHERE title = "ALADDIN CALENDAR";
DESCRIBE film;
-- DROP PROCEDURE client_rental;
-- call client_rental('Deborah', 'Walker', "ALADDIN CALENDAR" )