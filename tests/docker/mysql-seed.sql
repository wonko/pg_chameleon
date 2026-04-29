CREATE DATABASE IF NOT EXISTS sakila CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'usr_test'@'%' IDENTIFIED BY 'test';
GRANT ALL PRIVILEGES ON sakila.* TO 'usr_test'@'%';
GRANT RELOAD, REPLICATION CLIENT, REPLICATION SLAVE ON *.* TO 'usr_test'@'%';
FLUSH PRIVILEGES;

USE sakila;

DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS rental;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS film_actor;
DROP TABLE IF EXISTS actor;
DROP TABLE IF EXISTS film;
DROP TABLE IF EXISTS customer;

CREATE TABLE actor (
    actor_id int unsigned NOT NULL AUTO_INCREMENT,
    first_name varchar(45) NOT NULL,
    last_name varchar(45) NOT NULL,
    last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (actor_id)
) ENGINE=InnoDB;

CREATE TABLE film (
    film_id int unsigned NOT NULL AUTO_INCREMENT,
    title varchar(255) NOT NULL,
    description text,
    release_year year,
    rating enum('G','PG','PG-13','R','NC-17') DEFAULT 'G',
    metadata json,
    last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (film_id),
    KEY idx_title (title)
) ENGINE=InnoDB;

CREATE TABLE film_actor (
    actor_id int unsigned NOT NULL,
    film_id int unsigned NOT NULL,
    last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (actor_id, film_id),
    KEY idx_fk_film_id (film_id),
    CONSTRAINT fk_film_actor_actor FOREIGN KEY (actor_id) REFERENCES actor (actor_id),
    CONSTRAINT fk_film_actor_film FOREIGN KEY (film_id) REFERENCES film (film_id)
) ENGINE=InnoDB;

CREATE TABLE customer (
    customer_id int unsigned NOT NULL AUTO_INCREMENT,
    email varchar(100),
    active tinyint(1) NOT NULL DEFAULT 1,
    notes varchar(255),
    created_at datetime NOT NULL,
    PRIMARY KEY (customer_id),
    UNIQUE KEY uk_customer_email (email)
) ENGINE=InnoDB;

CREATE TABLE inventory (
    inventory_id int unsigned NOT NULL AUTO_INCREMENT,
    film_id int unsigned NOT NULL,
    store_id tinyint unsigned NOT NULL,
    PRIMARY KEY (inventory_id),
    KEY idx_inventory_film (film_id),
    CONSTRAINT fk_inventory_film FOREIGN KEY (film_id) REFERENCES film (film_id)
) ENGINE=InnoDB;

CREATE TABLE rental (
    rental_id int unsigned NOT NULL AUTO_INCREMENT,
    rental_date datetime NOT NULL,
    inventory_id int unsigned NOT NULL,
    customer_id int unsigned NOT NULL,
    return_date datetime NULL,
    PRIMARY KEY (rental_id),
    KEY idx_rental_inventory (inventory_id),
    KEY idx_rental_customer (customer_id),
    CONSTRAINT fk_rental_inventory FOREIGN KEY (inventory_id) REFERENCES inventory (inventory_id),
    CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
) ENGINE=InnoDB;

CREATE TABLE payment (
    payment_id int unsigned NOT NULL AUTO_INCREMENT,
    customer_id int unsigned NOT NULL,
    rental_id int unsigned NOT NULL,
    amount decimal(5,2) NOT NULL,
    payment_date datetime NOT NULL,
    PRIMARY KEY (payment_id),
    KEY idx_payment_customer (customer_id),
    CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id) REFERENCES customer (customer_id),
    CONSTRAINT fk_payment_rental FOREIGN KEY (rental_id) REFERENCES rental (rental_id)
) ENGINE=InnoDB;

INSERT INTO actor (first_name, last_name) VALUES
    ('PENELOPE', 'GUINESS'),
    ('NICK', 'WAHLBERG'),
    ('ED', 'CHASE'),
    ('JENNIFER', 'DAVIS'),
    ('JOHNNY', 'LOLLOBRIGIDA');

INSERT INTO film (title, description, release_year, rating, metadata) VALUES
    ('ACADEMY DINOSAUR', 'A drama about a dinosaur with a NUL marker', 2006, 'PG', JSON_OBJECT('tags', JSON_ARRAY('classic', 'family'))),
    ('ACE GOLDFINGER', 'A fast-paced thriller', 2006, 'G', JSON_OBJECT('tags', JSON_ARRAY('action'))),
    ('ADAPTATION HOLES', 'A reflective documentary', 2006, 'NC-17', JSON_OBJECT('tags', JSON_ARRAY('documentary'))),
    ('AFFAIR PREJUDICE', 'A romantic comedy', 2006, 'G', JSON_OBJECT('tags', JSON_ARRAY('romance'))),
    ('AFRICAN EGG', 'A database migration adventure', 2006, 'PG', JSON_OBJECT('tags', JSON_ARRAY('migration')));

INSERT INTO film_actor (actor_id, film_id) VALUES
    (1, 1), (1, 2), (2, 2), (3, 3), (4, 4), (5, 5);

INSERT INTO customer (email, active, notes, created_at) VALUES
    ('alice@example.test', 1, CONCAT('contains', CHAR(0), 'nul'), '2025-01-01 10:00:00'),
    ('bob@example.test', 1, 'plain text note', '2025-01-02 10:00:00'),
    ('carol@example.test', 0, 'inactive customer', '2025-01-03 10:00:00');

INSERT INTO inventory (film_id, store_id) VALUES
    (1, 1), (2, 1), (3, 1), (4, 2), (5, 2);

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date) VALUES
    ('2025-02-01 09:00:00', 1, 1, '2025-02-03 12:00:00'),
    ('2025-02-02 09:00:00', 2, 2, NULL),
    ('2025-02-03 09:00:00', 3, 3, '2025-02-04 12:00:00');

INSERT INTO payment (customer_id, rental_id, amount, payment_date) VALUES
    (1, 1, 4.99, '2025-02-01 09:05:00'),
    (2, 2, 2.99, '2025-02-02 09:05:00'),
    (3, 3, 3.99, '2025-02-03 09:05:00');
