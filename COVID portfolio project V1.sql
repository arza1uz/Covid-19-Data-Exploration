/* =========================================================
   Covid-19 Data Exploration
   Purpose: Exploratory analysis & visualization-ready datasets
   ========================================================= */

-- Base tables overview (optional exploration)
-- SELECT * FROM [Portfolio_Project_1].dbo.CovidDeaths;
-- SELECT * FROM [Portfolio_Project_1].dbo.CovidVaccinations;

------------------------------------------------------------
-- 1. Core Dataset Selection
------------------------------------------------------------

-- Filter out aggregated regions (World, continents without data)
SELECT
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM [Portfolio_Project_1].dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

------------------------------------------------------------
-- 2. Case Fatality Rate Analysis
-- Likelihood of death after contracting COVID-19
------------------------------------------------------------

SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathRatePercentage
FROM [Portfolio_Project_1].dbo.CovidDeaths
WHERE continent IS NOT NULL
  AND location LIKE '%Mexico%'
ORDER BY date;

------------------------------------------------------------
-- 3. Infection Rate vs Population
-- Percentage of population infected
------------------------------------------------------------

SELECT
    location,
    date,
    total_cases,
    population,
    (total_cases / population) * 100 AS PercentPopulationInfected
FROM [Portfolio_Project_1].dbo.CovidDeaths
WHERE continent IS NOT NULL
  AND location LIKE '%Mexico%'
ORDER BY date;

------------------------------------------------------------
-- 4. Countries with Highest Infection Rate
------------------------------------------------------------

SELECT
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population) * 100) AS PercentPopulationInfected
FROM [Portfolio_Project_1].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

------------------------------------------------------------
-- 5. Countries with Highest Death Count
------------------------------------------------------------

SELECT
    location,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio_Project_1].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

------------------------------------------------------------
-- 6. Death Count by Continent
------------------------------------------------------------

SELECT
    continent,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio_Project_1].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

------------------------------------------------------------
-- 7. Global Daily Metrics
------------------------------------------------------------

SELECT
    date,
    SUM(new_cases) AS GlobalNewCases,
    SUM(CAST(new_deaths AS INT)) AS GlobalNewDeaths,
    SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS GlobalDeathRate
FROM [Portfolio_Project_1].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

------------------------------------------------------------
-- 8. Vaccination Progress Analysis
-- Rolling count of vaccinated population
------------------------------------------------------------

SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations))
        OVER (PARTITION BY dea.location ORDER BY dea.date)
        AS RollingPeopleVaccinated
FROM [Portfolio_Project_1].dbo.CovidDeaths dea
JOIN [Portfolio_Project_1].dbo.CovidVaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

------------------------------------------------------------
-- 9. Vaccination Rate using CTE
------------------------------------------------------------

WITH PopulationVsVaccination AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations))
            OVER (PARTITION BY dea.location ORDER BY dea.date)
            AS RollingPeopleVaccinated
    FROM [Portfolio_Project_1].dbo.CovidDeaths dea
    JOIN [Portfolio_Project_1].dbo.CovidVaccinations vac
        ON dea.location = vac.location
       AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT
    *,
    (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM PopulationVsVaccination;

------------------------------------------------------------
-- 10. Create View for Tableau Visualizations
------------------------------------------------------------

CREATE OR ALTER VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations))
        OVER (PARTITION BY dea.location ORDER BY dea.date)
        AS RollingPeopleVaccinated
FROM [Portfolio_Project_1].dbo.CovidDeaths dea
JOIN [Portfolio_Project_1].dbo.CovidVaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

------------------------------------------------------------
-- 11. Visualization Queries (Tableau)
------------------------------------------------------------

-- Viz 1: Global Summary
SELECT
    SUM(new_cases) AS TotalCases,
    SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
    SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage
FROM [Portfolio_Project_1].dbo.CovidDeaths
WHERE continent IS NOT NULL;

-- Viz 2: Death Count by Continent
SELECT
    location,
    SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio_Project_1].dbo.CovidDeaths
WHERE continent IS NULL
  AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Viz 3: Infection Rate by Country
SELECT
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population) * 100) AS PercentPopulationInfected
FROM [Portfolio_Project_1].dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;
