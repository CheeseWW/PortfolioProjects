-- create tables for visualization in tableau

-- 1. global data: cases, deaths, deaths percentage
select sum(new_cases) globaltotcases, sum(cast(new_deaths as int)) globaltotdeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 globaltotdeathpercentage
from [Portfolio Project 1].dbo.CovidDeaths cd
where continent is not null

-- 2. deaths data per country: total deaths count
select location, max(cast(total_deaths as int)) totdeaths 
from [Portfolio Project 1].dbo.CovidDeaths cd
where continent is null
and location not in ('World', 'Upper middle income', 'High income', 'Lower middle income', 'European Union', 'Low income', 'International')
group by location
order by 2 desc

-- 3. infection data per country: population, total case, infection rate
select location, population, max(cast(total_cases as int)) totcase, (max(cast(total_cases as int))/population)*100 infectionrate
from [Portfolio Project 1].dbo.CovidDeaths cd
where continent is not null
group by location, population 
order by 4 desc

-- 4. infection data per country overtime: population, date, total case per day, infection rate per day
select location, population, date, total_cases, total_cases/population*100 infectionrate
from [Portfolio Project 1].dbo.CovidDeaths cd
where continent is not null
order by 1 asc, 5 desc
