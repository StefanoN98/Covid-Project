
--Select data we are going to use
SELECT location, date, total_cases,new_cases, total_deaths, population 
FROM .CovidDeaths
ORDER BY 1,2

-- looking at total cases vs total deaths
-- shows likelihood od dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
FROM .CovidDeaths
WHERE location like '%italy%'
ORDER BY 1,2

--Looking at total cases vs population
-- show what percentage of population got Covid
SELECT location, date, total_cases, population, total_cases, (total_cases/population)*100 As PercentPopulationInfected
FROM .CovidDeaths
WHERE location like '%italy%'
ORDER BY 1,2

--Looking at countries with Highest infection rate compared to population
SELECT location , population , MAX (total_cases) AS HighestInfectionCount, max((total_cases/population)*100) As PercentPopulationInfected
FROM .CovidDeaths
--WHERE location like '%italy%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- showing countries with highest death count per population
SELECT location ,max(CAST(total_deaths as int)) AS Totale_Death_Count
FROM .CovidDeaths
--WHERE location like '%italy%'
GROUP BY location
ORDER BY Totale_Death_Count DESC

-- showing countries with highest death count per population (excluding continent, so considering only countries)
SELECT location ,max(CAST(total_deaths as int)) AS Totale_Death_Count
FROM .CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Totale_Death_Count DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent ,max(CAST(total_deaths as int)) AS Totale_Death_Count
FROM .CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Totale_Death_Count DESC

-- alternative query
SELECT location ,max(CAST(total_deaths as int)) AS Totale_Death_Count
FROM .CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY Totale_Death_Count DESC

--GLOBAL NUMBERS
SELECT  date, SUM(new_cases) as TotaleCases, SUM(CAST(new_deaths as int)) as Totaldeaths, SUM(CAST(new_deaths as int))/SUM(new_cases) As DeathPercentage
FROM .CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Looking at total population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY  dea.location, dea.date) as RollingPeopleVaccinated,
-- opp SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY  dea.location, dea.date)
	(RollingPeopleVaccinated/population)*100
FROM .CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location=vac.location
	AND dea.date=vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE Cte
with PopVsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY  dea.location, dea.date) as RollingPeopleVaccinated
FROM .CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location=vac.location
	AND dea.date=vac.date 
WHERE dea.continent IS NOT NULL
)

Select * , (RollingPeopleVaccinated/population)*100
from PopVsVac

-- use Temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continen nvarchar(255),
Location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY  dea.location, dea.date) as RollingPeopleVaccinated
FROM .CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location=vac.location
	AND dea.date=vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

Select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated