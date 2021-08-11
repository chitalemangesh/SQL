desc city;
select * from city;
-- Count cities
select count(id) from city;
-- Ans 4079
-- Country having highest number of cities
select count(id) as citycount, countrycode from city
group by CountryCode
order by citycount desc;
-- Ans China
-- Which language is its countries official language and spoken by 80 to 90% people?
select * from countrylanguage;
select count(Language) from countrylanguage
where IsOfficial = 'T' and percentage >= 80 and Percentage <= 90;
-- 26 Languages
select count(Language) from countrylanguage
where IsOfficial = 'T' and percentage >= 80 ;
-- 85 Languages
-- In india how many cities are listed in maharashtra district
select count(id) as citycount, district from city
where CountryCode = 'IND' and district = 'Maharashtra'
group by District ;
-- 35 cities
-- Which country has maximum population?
select  name,population from country
order by population desc
limit 1;
-- China
-- Which language is spoken in maximum number of countries?
select cl.Language, count(cl.language) as numberofcountires from countrylanguage cl 
inner join country c 
on c.code = cl. countrycode
group by language
order by count(cl.language) desc
limit 20;	

select language, count(Language) from countrylanguage
group by language
order by count(language) desc
limit 20;
-- Answer = English - 60 countries
-- Name and code of countries where hindi lanuage is spoken
select c. name, c.code, cl.language from countrylanguage cl
inner join country c
on c.code = cl.countrycode
where cl.language = 'hindi';
-- Among the languages which language is offical language of more number of countries?
select language, count(language) as numberofcountries from countrylanguage
where IsOfficial = 't'
group by language
order by numberofcountries desc
limit 1;
-- Ans - English - 44 countries
-- How many cities in northamerica where English is official language?
select count(cl.language)from country co
inner join city ci 
on ci.countrycode = co.code 
inner join countrylanguage cl
on cl.CountryCode = ci.CountryCode
where co.continent = 'north america' and cl.language = 'english';
-- 352 cities
-- Which city has maximum population among these?
select ci.name as cityname, ci.population from country co
inner join city ci 
on ci.countrycode = co.code 
inner join countrylanguage cl
on cl.CountryCode = ci.CountryCode
where co.continent = 'north america' and cl.language = 'english'
order by population desc
limit 1;
-- Ans New york - 8008278
-- How many rows are there where any value is NA in countries table?


-- How many countries are there whose name starts with I and ends with A?
 select name from country
 where name like 'I%A';
-- 2 (India, indonesia)
-- Which continent has least surface area?
select continent, sum(SurfaceArea) as surfacearea from country
group by continent
order by SurfaceArea 
limit 1;
-- Oceania - 8564294