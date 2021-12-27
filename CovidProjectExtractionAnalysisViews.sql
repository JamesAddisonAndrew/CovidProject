SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccines
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2 

--Total Cases Vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2 

-- Total Cases Vs Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS CovidDensity
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2 

-- Highest Infection Rate in Relation to Population 

SELECT Location, Population, MAX(total_cases) AS TopInfectionCount, MAX(total_cases/Population) * 100 AS PercentPoPInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY 4 DESC 

-- Nation with Highest Death Count Per Population Fitering Continental Grouping

SELECT Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC 

-- Conitental Analysis 

SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC 

-- Identifying Unknown Income Lable Within Location Death Table
SELECT location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL --AND location like '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT DISTINCT location
FROM PortfolioProject..CovidDeaths
WHERE CONTINENT IS NULL
GROUP BY location


-- Global Numbers

SELECT date, SUM(new_cases) AS WorldCasesPerDay, SUM(CAST(new_deaths AS INT)) AS WorldDeathsPerDay, (SUM(CAST(new_deaths AS INT)) / SUM(new_cases))*100 AS WorldMortality
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

---------------------------------------------------------

--Total Population Vs Vaccinations

SELECT DED.continent, DED.location, DED.date, DED.population, VAX.new_vaccinations, 
((SUM(CAST(VAX.new_vaccinations AS BIGINT)) OVER (PARTITION BY DED.location ORDER BY DED.location, DED.date))) AS RollingVacSum
--((RollingVacSum/population)*100) AS PercentNationVax
FROM PortfolioProject..CovidDeaths AS DED
JOIN PortfolioProject..CovidVaccines AS VAX
	ON DED.location = VAX.location
	AND DED.date = VAX.date
WHERE DED.continent IS NOT NULL AND DED.location LIKE '%State%'
ORDER BY 1,2,3

--USING CTE 

WITH PopVsVac (Continent, Location, Date, Population, NewVax, RollingVacSum)
AS (
SELECT DED.continent, DED.location, DED.date, DED.population, VAX.new_vaccinations, 
((SUM(CAST(VAX.new_vaccinations AS BIGINT)) OVER (PARTITION BY DED.location ORDER BY DED.location, DED.date))) AS RollingVacSum
--((RollingVacSum/population)*100) AS PercentNationVax
FROM PortfolioProject..CovidDeaths AS DED
JOIN PortfolioProject..CovidVaccines AS VAX
	ON DED.location = VAX.location
	AND DED.date = VAX.date
WHERE DED.continent IS NOT NULL AND DED.location LIKE '%States%'
)

SELECT *, ((RollingVacSum/population)*100) AS PercentNationVax
FROM PopVsVac

SELECT total_vaccinations 
FROM PortfolioProject..CovidVaccines
WHERE location LIKE '%State%'



-- Using Temp Table 

DROP TABLE IF EXISTS #PercentPopulationVaxxed
CREATE TABLE #PercentPopulationVaxxed
(Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaxxed
SELECT DED.continent, DED.location, DED.date, DED.population, VAX.new_vaccinations, 
((SUM(CAST(VAX.new_vaccinations AS BIGINT)) OVER (PARTITION BY DED.location ORDER BY DED.location, DED.date))) AS RollingVacSum
--((RollingVacSum/population)*100) AS PercentNationVax
FROM PortfolioProject..CovidDeaths AS DED
JOIN PortfolioProject..CovidVaccines AS VAX
	ON DED.location = VAX.location
	AND DED.date = VAX.date
WHERE DED.continent IS NOT NULL

SELECT *, ((RollingPeopleVaccinated/population)*100) AS PercentNationVax
FROM #PercentPopulationVaxxed
WHERE location LIKE '%State%'


-- Creating View for Future Visualizations 

CREATE VIEW PercentPopulationVaxxed AS
SELECT DED.continent, DED.location, DED.date, DED.population, VAX.new_vaccinations, 
((SUM(CAST(VAX.new_vaccinations AS BIGINT)) OVER (PARTITION BY DED.location ORDER BY DED.location, DED.date))) AS RollingVacSum
--((RollingVacSum/population)*100) AS PercentNationVax
FROM PortfolioProject..CovidDeaths AS DED
JOIN PortfolioProject..CovidVaccines AS VAX
	ON DED.location = VAX.location
	AND DED.date = VAX.date
WHERE DED.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaxxed