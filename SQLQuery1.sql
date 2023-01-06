--Part 1 - DATA EXPLORATION

Select * 
from Project..CovidDeaths
order by 3,4

select *
from Project..CovidVaccinations
order by 3,4

select Location, date,total_cases, new_cases, total_deaths, population 
from Project..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

select Location, date,total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from Project..CovidDeaths
order by 1,2

-- For India. It shows the likelihood of dying if you contract covid

select Location, date,total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from Project..CovidDeaths
where location like 'india'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
select Location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from Project..CovidDeaths
where location like 'india'
order by 1,2


--Looking at countries with highest infection rate as compared to population
select Location, population, MAX(total_cases) as HighestInfection, MAX(total_cases/population)*100 as PercentPopulationInfected
from Project..CovidDeaths
Group by Location, population
order by PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count per population
select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Project..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Break down by continent

-- Showing continents with the highest death count per population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Project..CovidDeaths
where continent is not null 
Group by continent
order by TotalDeathCount desc 

-- GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases) * 100 as DeathPercentage 
from Project..CovidDeaths
where continent is not null
group by date
order by 1,2

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases) * 100 as DeathPercentage 
from Project..CovidDeaths
where continent is not null
--group by date
order by 1,2


--Joining Covid deaths table with Covid Vaccination table

select *
from Project..CovidDeaths dea
join Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


--Looking at Total Population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Project..CovidDeaths dea
join Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
from Project..CovidDeaths dea
join Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- USE CTE

with PopvsVac(Continent, location, date, population,  New_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date, dea.location ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from Project..CovidDeaths dea
join Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
)
select * , (RollingPeopleVaccinated/Population) * 100
from PopvsVac

-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.date, dea.location ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from Project..CovidDeaths dea
join Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

select * , (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualizantions

CREATE VIEW PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.date, dea.location ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
from Project..CovidDeaths dea
join Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null



SELECT * FROM PercentPopulationVaccinated

