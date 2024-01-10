# Create the Database and use it
create database laptops;
use laptops;


select * from laptops;
describe laptops;
# remove the index column
describe laptops;

alter table laptops drop column MyUnknowncolumn;

# Rename Columns like model name, screen size, operating system, operating System version

alter table laptops rename column `model name` to model_name;
alter table laptops rename column `screen size` to screen_size;
alter table laptops rename column `operating system` to operating_system;
alter table laptops rename column `operating system version` to operating_system_version;

# Remove " from screen_size
UPDATE laptops SET screen_size = REPLACE(screen_size, '"', '');
# remove GB from RAM
UPDATE laptops SET ram = REPLACE(ram, '','GB');
# remove kg from Weight
update laptops set weight = replace(weight, 'kgs', '');
update laptops set weight = replace(weight, 'kg', '');


# split the storage column
alter table laptops add column primary_storage varchar(50);
UPDATE LAPTOPS SET primary_storage = SUBSTRING_INDEX(STORAGE,"+",1);

# split the CPU column
alter table laptops add column CPU_Brand varchar(50);
UPDATE laptops SET CPU_Brand = SUBSTRING_INDEX(CPU," ",1);
-- alter table laptops add column secondary_storage varchar(50);
-- UPDATE LAPTOPS SET secondary_storage = SUBSTRING_INDEX(STORAGE,"+",-1);
# split the GPU column
alter table laptops add column GPU_Brand varchar(50);
UPDATE laptops SET GPU_Brand = SUBSTRING_INDEX(CPU," ",1);

# split the CPU column for CPU Speed
ALTER TABLE laptops ADD COLUMN CPU_speed VARCHAR(20);

-- Update the 'speed' column with the extracted GHz information
UPDATE laptops SET CPU_speed = (SUBSTRING_INDEX(cpu, ' ', -1));
select * from laptops;
alter table laptops drop column GPU_model;
select distinct(CPU_speed) from laptops;

# update operating Sustem column with macOS to Mac_OS
update laptops set operating_system = replace(operating_system,'macOS','Mac_OS');

alter table laptops modify operating_system_version varchar(50);

# UPDATE laptops SET operating_system_version = 'others' WHERE operating_system_version IS NULL;

# Q 1  maunfacturer and count of models
select manufacturer, count(distinct(model_name)) no_of_models 
from laptops 
group by manufacturer 
order by no_of_models desc limit 7 ;


# Q 2 fetch records of n number of top expensive laptop 
-- delimiter //
-- CREATE PROCEDURE top_n_exp_laptop(in top int)
-- BEGIN
-- select * from laptops order by price desc limit top;
-- END
-- delimiter //
call top_n_exp_laptop(6);

# Q 3 Category wise top 3 expensive laptops
select * from 
(select category, price,row_number() over (partition by Category order by price desc) Rank_ 
from laptops) sq 
where Rank_<4
group by category,price;


select distinct(operating_system) from laptops;

# Q 4 Count of operating_system based on RAM
SELECT RAM,  
  COUNT(CASE WHEN operating_system = 'No OS' THEN 1 END) AS No_OS,
  COUNT(CASE WHEN operating_system = 'Windows' THEN 1 END) AS Windows,
  COUNT(CASE WHEN operating_system = 'Mac OS' THEN 1 END) AS Mac_OS,
  COUNT(CASE WHEN operating_system = 'Linux' THEN 1 END) AS Linux,
  COUNT(CASE WHEN operating_system = 'Android' THEN 1 END) AS Android,
  COUNT(CASE WHEN operating_system = 'Chrome OS' THEN 1 END) AS Chrome_OS
FROM laptops
GROUP BY RAM;

select * from laptops;


select distinct(CPU_Brand) from laptops;

# Q 5 Using CTE fetch count of CPU Brand based on each manufacturer

WITH CTE AS (
  SELECT
    manufacturer,
    COUNT(CASE WHEN CPU_Brand = 'Intel' THEN 1 END) AS Intel,
    COUNT(CASE WHEN CPU_Brand = 'AMD' THEN 1 END) AS AMD,
    COUNT(CASE WHEN CPU_Brand = 'Samsung' THEN 1 END) AS Samsung
  FROM laptops
  GROUP BY manufacturer
)

SELECT * FROM CTE;

# Q 6 Using Subquery and SELF JOIN, Select all the laptops 
# where price of that laptop is greater than the avg price
# of all the laptops of each maunfacturer(19)

SELECT *
FROM laptops AS lt
WHERE lt.price > ( SELECT AVG(price)
    FROM laptops AS sub
    WHERE sub.manufacturer = lt.manufacturer
);

-- SELECT
--     lt.manufacturer,
--     lt.price,
--     AVG(lt.price) OVER (PARTITION BY lt.manufacturer) AS avg_price_by_manufacturer
-- FROM
--     laptops AS lt
-- WHERE
--     lt.price > (
--         SELECT AVG(sub.price) FROM laptops AS sub
--         WHERE sub.manufacturer = lt.manufacturer
--         GROUP BY sub.manufacturer
--     );


# Q5 using stored Procedure fetch all the records of laptops 
# where price range is between x and y.
-- delimiter //
-- CREATE PROCEDURE budget_x_y_brand(in x int,in y int)
-- BEGIN
-- select * from laptops 
-- where price between x and y;
-- END
-- delimiter //
call budget_x_y_brand(70000,100000);


# create views based on CPu_Brand

create view OS as 
select * from laptops where  operating_system ='Linux';
select * from OS;


create or replace view intel_laptops as
select * from laptops where CPU_Brand = 'Intel';

create or replace view AMD_laptops as
select * from laptops where CPU_Brand = 'AMD';


select * from intel_laptops;
select * from AMD_laptops;



