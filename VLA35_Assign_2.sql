USE SCIRT_JOBS_BOUND;   /* Setting up SCIRT_JOBS_BOUND as default schema*/
-- 1ST Normal Form - using split_column stored proceedure to break values in route column in to distcinct values-- 
call split_column();  

-- second and third normal form--
-- Decomposing scirt_job table into relevant smaller tables --

 create table locality_table (                        /* Creating a locality table with locality id and locality as columns */
 locality_id int(100) not null auto_increment,       /* New column locality_id is created to distinctly identify the locality*/
 primary key (locality_id),                          /*Assigning the locality_id column as primary key*/
 locality varchar(100));
 insert into locality_table(locality)                /*inserting locality column from scirt_job in to locality column from locality table*/
 select distinct locality from scirt_job;
 select * from locality_table;                       /* verifying data in the locality table*/
  
 
 create table delivery_team_table (                       /* Creating a delivery team table with delivery team id and delivery_team as columns */
 delivery_team_id int(100) not null auto_increment,      /* New column delivery_team_id is created to distinctly identify the delivery_team*/
 primary key (delivery_team_id),                         /* Assigning delivery_team_id  as primary key*/
 delivery_team varchar(100));
insert into delivery_team_table(delivery_team)          /*inserting delivery_team column from scirt_job in to delivery_team column from delivery_team table*/
select distinct delivery_team from scirt_job;
select * from delivery_team_table;                      /*Verifying data in Delivery_team_table*/


create table job_table (       /*creating a job table with job id , description,start data and end date as columns */
job_id int(100),
primary key (job_id),
description longtext,         /* Assigning job_id as primary key*/            
start_date date,
end_date date);
insert into job_table (job_id,description,start_date,end_date)            /*Inserting data in to job_table from scirt_job table*/
select  distinct job_id,description,start_date,end_date from scirt_job;
select * from job_table;    /*Veriying data correctly populated in job_table*/

                                            
create table route_table (         /*Creating a route table with route_id and route as columns*/
route_id int(10) auto_increment,
primary key (route_id),           /*setting route_id as primary key*/
route varchar(255));
insert into route_table (route) select distinct route from temp_table;  /*Inserting data in route column of route table from temp_table route column*/
select * from route_table;   /* Veriying data in route_table*/

-- Decomposing chch_address table --

create table Address_table (        /*Creating address table by decomposing chch_address_table*/
  address_id int,
  primary key (address_id),         /*setting address_id as primary key*/
  address_number int,
  unit_value varchar(100),
  address_number_suffix varchar(100),
  address_number_high varchar(100) );
insert into address_table (address_id,address_number,unit_value,address_number_suffix,address_number_high)  /*Inserting data in to address table from chch_address_table*/
select  address_id,address_number,unit_value,address_number_suffix,address_number_high 
from chch_street_address;
select * from address_table;   /*Verifying data in addres table */


CREATE TABLE suburb_locality_table(      /*Creating subrurb locality table*/
locality_id int auto_increment,          
primary key (locality_id),               /*setting up locality_id as primary key*/
suburb_locality varchar(100),
town_city varchar(100));
insert into suburb_locality_table(suburb_locality,town_city)  /*Inserting data in to subrurb locality table*/ 
select distinct suburb_locality,town_city from chch_street_address;
select * from suburb_locality_table;  /*Verifying data in subrurb locality table */


create table road_table(      /* creating a road table with road section_id and road name*/
road_section_id int,
primary key (road_section_id),     /*Setting up Road section id as primaey key */
road_name varchar(100));
insert into road_table(road_section_id,road_name) select distinct
road_section_id,road_name from chch_street_address;
select * from road_table;    /*verifying data correclty populated in the table*/



-- Joining of tables to associate the data -- 
-- Joining roadname in chch_address and route in temp table to get integrated list of road\routes --
CREATE TABLE roadroute_table(   /* Creating a roadroute_table combining roadname in chch_address and route in temp table */
road_route_id int auto_increment not null,        
primary key (road_route_id),
road_route varchar(100));
insert into roadroute_table (road_route) select distinct road_name   /* Inserting data into the table*/
from chch_street_address union select distinct route from temp_table; /*UNION used combining roadname in chch_address and route in temp table */
select * from roadroute_table;  /*Verifying data in the table*/


-- Joining Locality and job table--
create table job_locality(   -- CREATING A JOB_LOCALITY TABLE TO DENOTE THE RELATION BETWEEN JOBS AND LOCALITIES--
job_id int,
locality_id int,
foreign key (job_id) references job_table(job_id),              /*Job_id and locality_id set as foreign keys from job_table and locality_table respectively*/
foreign key (locality_id) references locality_table(locality_id));
insert  into job_locality select distinct s.job_id,l.locality_id from scirt_job s 
right join locality_table l on (l.locality=s.locality); /*Joining the tables using locality column from locality table and scirt job table */
select * from job_locality;   /*Verifying the data in the table*/

-- Joining delivery team and job table--
create table job_delivery(   -- CREATING A JOB_delivery TABLE TO MERGE THE RELATION BETWEEN JOBS AND DELIVERY TEAM--
job_id int,
delivery_team_id int,
foreign key(job_id) references job_table(job_id), /*Job_id and delivery_team_id set as foreign keys from job_table and delivery_team_table respectively*/
foreign key(delivery_team_id) references delivery_team_table(delivery_team_id));
insert into job_delivery select distinct s.job_id,d.delivery_team_id from scirt_job s 
left join delivery_team_table d on (d.delivery_team = s.delivery_team); /* data inserted into the table and joined using delivery_team column */
select * from job_delivery;


-- Joining Road_route and job table--
create table job_road_route(      -- CREATING A JOB_ROAD\ROUTE TABLE TO MERGE THE RELATION BETWEEN JOBS AND ROADS\ROUTES--
job_id int,
road_route_id int,
foreign key (job_id) references job_table(job_id),    /*Job_id and road_route_id set as foreign keys from job_table and roadroute_table respectively*/
foreign key (road_route_id) references roadroute_table(road_route_id));
insert into job_road_route select distinct t.job_id,r.road_route_id from temp_table t 
inner join  roadroute_table r on (t.route = r.road_route);  /*Joining the tables using route column from route table and routes from temp table */
select * from job_road_route order by road_route_id asc;    /*Verifying the data in the table & displaying data in ascending order of road_route_id*/


 -- Joining Job, road route,delivery team and locality data to get associted information--
create table job_road_route_locality_delivery(  /*job_road_route_locality_delivery table created to establish clear relation between jobs from  scirt_job table to corresponding addresses from chch_address table */
RepairTask_id int not null auto_increment,
job_id int,
road_route_id int,
locality_id int,
delivery_team_id int,
primary key(RepairTask_id),              /*Repair_id is set as Primary key to uniquely identify each associated record*/
foreign key (job_id) references job_table(job_id),   /*Job_id,road_route_id,delivery_team_id and locality_id set as foreign keys from job_table,road_route,delivery_team_table and locality_table respectively*/
foreign key (locality_id) references locality_table(locality_id),
foreign key(delivery_team_id) references delivery_team_table(delivery_team_id), 
foreign key (road_route_id) references roadroute_table(road_route_id));
insert into job_road_route_locality_delivery(job_id,locality_id,delivery_team_id,road_route_id) select 
distinct s.job_id,l.locality_id,d.delivery_team_id, s.road_route_id from  
job_road_route s left join job_locality l on(s.job_id = l.job_id)       /*Joining the tables using job_id column */
inner join job_delivery d on (l.job_id = d.job_id);                
select * from job_road_route_locality_delivery;      /*Verifying data in the table* .Gives the normalised relation between Job and address through combned road/route data*/ 














