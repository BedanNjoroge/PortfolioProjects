SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..[CovidVaccinations$']
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at total deaths vs population
-- Shows likelihood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%kenya%' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got COVID
SELECT location, date, population ,total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$ 
WHERE location like '%kenya%' AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population
SELECT location, population , MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%kenya%' 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing contries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%kenya%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Let's break things down by continent

-- Showing continents with highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%kenya%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global numbers
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%kenya%' 
WHERE continent IS NOT NULL
ORDER BY 1,2


SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%kenya%' 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%kenya%' 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


SELECT *
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..[CovidVaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date

-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..[CovidVaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY 1,2

--Use CTE
WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..[CovidVaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
--ORDER BY 1,2
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent varchar(255),
location varchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..[CovidVaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
--ORDER BY 1,2

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Create view to store data for later visualizations

CREATE VIEW 
PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..[CovidVaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
--ORDER BY 1,2

SELECT *
FROM PercentPopulationVaccinated


