/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From Project1..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Project1..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project1..CovidDeaths
Where location like '%Ukraine%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Project1..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Project1..CovidDeaths
--Where location like '%Ukraine%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
--Where location like '%Ukraine%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
--From Project1..CovidDeaths
--Where location IN ('World', 'Europe', 'North America', 'European Union', 'South America', 'Asia', 'Africa', 'Oceania', 'International' ) 
--Group by location
--order by TotalDeathCount desc

--Showing continents with the highest death count

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as NewDeathsSUM, SUM (new_deaths) / SUM(new_cases)*100 AS DeathPercentage
FROM Project1..CovidDeaths
Where continent is not null
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations
 --USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition By dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM Project1..CovidDeaths Dea
JOIN Project1..CovidVaccination Vac
ON Dea.location = Vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT Into #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition By dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM Project1..CovidDeaths Dea
JOIN Project1..CovidVaccination Vac
ON Dea.location = Vac.location
AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated1 as

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition By dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM Project1..CovidDeaths Dea
JOIN Project1..CovidVaccination Vac
ON Dea.location = Vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated1