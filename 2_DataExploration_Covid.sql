-- Data Exploration

select *
from [Portfolio Project 1].dbo.CovidDeaths
order by  3, 4

select *
from [Portfolio Project 1].dbo.CovidVaccinations
order by  3, 4

-- look at CovidDeaths data
-- 1. what is the total cases vs total deaths of each country - shows the likelihood to die if got covid in *Canada*
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 deathpercentage
from [Portfolio Project 1].dbo.CovidDeaths cd
where location = 'Canada'
order by 1, 2

-- 2. what is the total cases vs population of each country - shows the infection rate of covid in *Canada*
select location, date, population, total_cases, (total_cases/population)*100 infectionrate
from [Portfolio Project 1].dbo.CovidDeaths cd
where location = 'Canada'
order by 1, 2

-- find all the inproper locations that will affect the ranking (and will exclude them in calculation)
select distinct location, continent
from [Portfolio Project 1].dbo.CovidDeaths
where continent is null
order by 1, 2

-- 3. which country has the highest infection rate per population?
select location, population, max(total_cases) highestinfection, (max(total_cases)/population)*100 highestinfectionrate
from [Portfolio Project 1].dbo.CovidDeaths cd
where continent is not null
group by location, population
order by 4 desc

-- 4. which country has the highest death rate per population?
select location, population, max(cast(total_deaths as int)) highestdeaths, (max(cast(total_deaths as int))/population)*100 highestdeathsrate
from [Portfolio Project 1].dbo.CovidDeaths cd
where continent is not null
group by location, population
order by 3 desc

-- 5. which continent has the highest deaths in the period?
with countrydata as 
(
select distinct max(cast(total_deaths as int)) over (partition by location) as countryhighestdeaths, continent, location
from [Portfolio Project 1].dbo.CovidDeaths cd
where continent is not null
)
select continent, sum(countryhighestdeaths) continenthighestdeaths
from countrydata
group by continent
order by 2 desc

-- check if the above query gets the correct outputs by checking one example *North America*
select continent, sum(highestdeaths) totalhighestdeaths
from
(
select continent, location, max(cast(total_deaths as int)) highestdeaths
from [Portfolio Project 1].dbo.CovidDeaths cd
where continent = 'North America'
group by continent, location
) countryhighest
group by continent

-- 6. what is the global situation over time, incl. total cases, total deaths, deaths percentage?
select date, sum(total_cases) globalcases, sum(cast(total_deaths as int)) globaldeaths, sum(cast(total_deaths as int))/sum(total_cases)*100 globaldeathspercentage
from [Portfolio Project 1].dbo.CovidDeaths cd
where continent is not null
group by date
order by date

-- 7. what's the global situation so far (in total), incl. total cases, total deaths?
select sum(new_cases) globaltotcases, sum(cast(new_deaths as int)) globaltotdeaths, sum(cast(new_deaths as int))/sum(new_cases)*100  globaltotdeathpercentage
from [Portfolio Project 1].dbo.CovidDeaths cd
where continent is not null

-- look at CovidVaccinations data
-- join 2 tables CovidDeaths & CovidVaccinations
select *
from [Portfolio Project 1].dbo.CovidDeaths cd
join [Portfolio Project 1].dbo.CovidVaccinations cv
on cd.location = cv.location
	and cd.date = cv.date 

-- 1. how many new people are vaccinated everyday in each country?
select cd.continent, cd.location, cd.population, cd.date, cv.new_vaccinations
from [Portfolio Project 1].dbo.CovidDeaths cd
join [Portfolio Project 1].dbo.CovidVaccinations cv
on cd.location = cv.location
	and cd.date = cv.date 
where cd.continent is not null
order by 1, 2

-- 2. what is the total vaccinations over time in each country?
select cd.continent, cd.location, cd.population, cd.date, cv.new_vaccinations,
sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.date, cd.location) totvaccinations
-- sum(cast(cv.new_vaccinations as bigint))/cd.population over (partition by cd.location order by cd.date, cd.location) vaccinationrate
from [Portfolio Project 1].dbo.CovidDeaths cd
join [Portfolio Project 1].dbo.CovidVaccinations cv
on cd.location = cv.location
	and cd.date = cv.date 
where cd.continent is not null
-- group by cd.continent, cd.location, cd.population
order by 2, 3, 4


-- 3. what is the vaccination rate over time in each country?
-- solution No.1 - use total_vaccinations and aggregations
select cd.continent, cd.location, cd.population, cd.date, max(cast(cv.total_vaccinations as bigint)) totvaccinations, max(cast(cv.total_vaccinations as bigint))/cd.population vaccinationrate
from [Portfolio Project 1].dbo.CovidDeaths cd
join [Portfolio Project 1].dbo.CovidVaccinations cv
on cd.location = cv.location
	and cd.date = cv.date 
where cd.continent is not null
group by cd.continent, cd.location, cd.population, cd.date
order by 5 desc

-- solution No.2 - use CTE & window functions
with totvac as
(
select cd.continent, cd.location, cd.population, cd.date, cv.new_vaccinations,
sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.date, cd.location) totvaccinations
from [Portfolio Project 1].dbo.CovidDeaths cd
join [Portfolio Project 1].dbo.CovidVaccinations cv
on cd.location = cv.location
	and cd.date = cv.date 
where cd.continent is not null
-- order by 2, 3, 4
)
select continent, location, population, date, totvaccinations, totvaccinations/population*100 vaccinationrate
from totvac
order by 2, 3, 4

-- solution No.3 - use a temp table
drop table if exists #vacpercent
create table #vacpercent
(
continent nvarchar(255),
location nvarchar(255),
population bigint,
date datetime,
new_vaccinations bigint,
totvaccinations bigint
)
insert into #vacpercent
select cd.continent, cd.location, cd.population, cd.date, cv.new_vaccinations,
sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.date, cd.location) totvaccinations
from [Portfolio Project 1].dbo.CovidDeaths cd
join [Portfolio Project 1].dbo.CovidVaccinations cv
on cd.location = cv.location
	and cd.date = cv.date 
where cd.continent is not null
-- order by 2, 3, 4
select continent, location, population, date, totvaccinations, totvaccinations/population*100 vaccinationrate
from #vacpercent
order by 2, 3, 4

-- 4. create a view of vaccination percentage for later visualization
use [Portfolio Project 1];
go
create view dbo.vacpercent as
select cd.continent, cd.location, cd.population, cd.date, cv.new_vaccinations,
sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.date, cd.location) totvaccinations
from [Portfolio Project 1].dbo.CovidDeaths cd
join [Portfolio Project 1].dbo.CovidVaccinations cv
on cd.location = cv.location
	and cd.date = cv.date 
where cd.continent is not null;
go
-- drop view vacpercent

-- check the view created
select *
from vacpercent
