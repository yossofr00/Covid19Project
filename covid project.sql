SELECT * 
From [Portfolio Project]..CovidDeaths$
where continent is not null
order by 3,4

--Looking at total cases vs total deaths 
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE location like '%states%'
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths$
WHERE location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
Group By location, population
order by PercentPopulationInfected desc


-- Showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
Group By location
order by TotalDeathCount desc

--Lets break things down by continent 
-- Showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
Group By continent
order by TotalDeathCount desc



-- Global Numbers 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
where continent is not null
--Group by date
order by 1,2


--Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..Covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


--USING CTE 

WITH popvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..Covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
FROM popvsVac



-- Temp table 

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..Covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated




-- creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..Covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated