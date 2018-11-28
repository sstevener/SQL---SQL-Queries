use sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
select `first_name`, `last_name` from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select upper (concat(`first_name`, ' ', `last_name`)) as 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor where first_name = 'JOE';

-- 2b. Find all actors whose last name contain the letters `GEN`:
select * from actor where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select * from actor where last_name like '%LI%' order by last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ('Afghanistan' , 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
-- update actor with col('description',  blob)
alter table actor
add column description Blob after last_name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table actor
drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) as last_name_count from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name) as last_name_count from actor group by last_name having count(last_name) >=2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
update actor
set first_name = 'HARPO' where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor
set first_name = 'GROUCHO' where actor_id = 172;

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html] (https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
show create table sakila.address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select first_name, last_name, address from staff
inner join address using (address_id);

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select first_name, last_name, sum(`payment`.`amount`) from staff
inner join payment using (staff_id)
where payment_date like '2005-08%'
group by staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select title, count(actor_id) as number_of_actors from film
inner join film_actor on `film`.`film_id` = `film_actor`.`film_id`
group by title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select title, count(inventory_id) from film
inner join inventory on `film`.`film_id` = `inventory`.`film_id`
where title = 'Hunchback Impossible';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name: ![Total amount paid](Images/total_payment.png)
select `customer`.`first_name`, `customer`.`last_name`, sum(`payment`.`amount`) as total_paid from payment
inner join customer on `payment`.`customer_id` = `customer`.`customer_id`
group by `payment`.`customer_id`
order by last_name asc;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title from film 
where language_id in
	(select language_id from language where name = 'English')
and (title like 'K%') or (title like 'Q%'); 

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select actor_id, first_name, last_name from actor
where actor_id in
	(select actor_id from film_actor where film_id in 
	(select film_id from film where title = 'Alone Trip')); 

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email from customer
join address using (address_id)
join city using (city_id)
join country using (country_id) where country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
select film_id, title, description from film
join film_category using (film_id)
join category using (category_id) where name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
select title, count(`film`.`film_id`) as rental_count from film
join inventory on `film`.`film_id` = `inventory`.`film_id`
join rental on `inventory`.`inventory_id` = `rental`.`inventory_id`
group by title order by rental_count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, sum(amount) AS total_$ FROM payment
JOIN staff
using(staff_id)
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store_id, city, country from store
join address using (address_id)
join city using (city_id)
join country using (country_id);

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select name as 'top_5', sum(amount) as 'gross_revenue' from category
join film_category using (category_id)
join inventory using (film_id)
join rental using (inventory_id)
join payment using (rental_id)
group by name order by gross_revenue DESC limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_5_genres as
select name as 'top_5', sum(amount) as 'gross_revenue' from category
join film_category using (category_id)
join inventory using (film_id)
join rental using (inventory_id)
join payment using (rental_id)
group by name order by gross_revenue DESC limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_5_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view top_5_genres;
