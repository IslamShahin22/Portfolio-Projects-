SELECT *
FROM Potofolio_project..CovidDeaths$
where continent is not null
order by 3,4


--SELECT *
--FROM Potofolio_project..CovidVaccinations$
--order by 3,4

-- select data that we are going to use

select location, date , total_cases, new_cases, total_deaths, population
FROM Potofolio_project..CovidDeaths$
where continent is not null
order by 1,2


-- looking at total cases vs total death in united states 
-- updated  liklihood daily of dying if infected by corona viruis 

select location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
FROM Potofolio_project..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2


--looking at total cases vs population 
-- shows what percentage of population got covid
select location, date , total_cases, population, (total_cases/population)*100 as infection_percentage
FROM Potofolio_project..CovidDeaths$
where continent is not null
--where location like '%states%'
order by 1,2


-- looking at countries with higest infection rate compared to population 
select location , population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as Infection_Percentage
FROM Potofolio_project..CovidDeaths$
--where location like '%states%'
where continent is not null
group by population, location
order by Infection_Percentage desc

--showing countries with higest date count per population
select location, population, max(cast(Total_deaths as int)) HighestDeath
FROM Potofolio_project..CovidDeaths$
--where location like '%states%'
where continent is not null
group by population, location 
order by HighestDeath desc


--higest death count by continent
select continent, sum(cast(Total_deaths as int)) HighestDeath
FROM Potofolio_project..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by HighestDeath desc

-- gloubal numbers (new total cases and total deaths updated daily)
select  date , sum((new_cases)) as DailyNewCases, sum(cast(new_deaths as int)) as DailyNewDeaths
, (sum(cast(new_deaths as int))/sum((new_cases)))*100 as DailyPercentageDeath
FROM Potofolio_project..CovidDeaths$
where continent is not null
group by date 
order by 1,2


-- looking ate total population vs vacination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location  order by dea.date) as AggregatVacinated
from Potofolio_project..CovidDeaths$ dea
join Potofolio_project..CovidVaccinations$ vac 
on dea.location = vac.location
and dea.date = vac.date
order by 2,3


-- use CTE
with popvsvacination (continent, location, date, population,new_vaccination, AggregatVacinated )
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location  order by dea.date) as AggregatVacinated
from Potofolio_project..CovidDeaths$ dea
join Potofolio_project..CovidVaccinations$ vac 
on dea.location = vac.location
and dea.date = vac.date
--order by 2,3
)
select *, (AggregatVacinated/population)*100 
from popvsvacination


--temp table 

DROP TABLE if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
AggregatVacinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location  order by dea.date) as AggregatVacinated
from Potofolio_project..CovidDeaths$ dea
join Potofolio_project..CovidVaccinations$ vac 
on dea.location = vac.location
and dea.date = vac.date
--order by 2,3


select *, (AggregatVacinated/population)*100 
from #percentpopulationvaccinated
