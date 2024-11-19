SELECT *
FROM PortfolioProject.coviddeaths
WHERE continent is not NULL and location LIKE '%a'


-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.coviddeaths
where location like '%canada%'
order by 1,2

-- Looking at Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.coviddeaths
-- where location like '%canada%'
order by 1,2

-- Looking at Countires with Highest Infection Rate comared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.coviddeaths
Group By location, population 
order by PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.coviddeaths
WHERE continent is not NULL
Group By location 
order by TotalDeathCount DESC;


-- Breaking Down by Continent

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.coviddeaths
WHERE continent is NULL AND location NOT LIKE '%income%'
Group By location 
order by TotalDeathCount DESC;


-- Global Numbers by Date

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as signed)) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentageWorld 
FROM PortfolioProject.coviddeaths
where continent is not NULL AND location NOT LIKE '%income%'
GROUP BY date
order by 1,2


-- Global Numbers Total

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as signed)) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentageWorld 
FROM PortfolioProject.coviddeaths
where continent is not NULL AND location NOT LIKE '%income%'
order by 1,2


-- Looking at Total Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated, -- (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location
	
	
-- With CTE
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL AND dea.location NOT LIKE '%income%'
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac
WHERE Location LIKE '%canada%'
ORDER BY 2,3


-- Using Temp Table to perform Calculation on Partition By in previous query

-- Step 1: Creating a temporary table
DROP TEMPORARY TABLE IF EXISTS PopVsVac;

CREATE TEMPORARY TABLE PopVsVac AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject.coviddeaths dea
JOIN 
    PortfolioProject.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL 
    AND dea.location NOT LIKE '%income%';

-- Step 2: Query the temporary table
SELECT *, 
    (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM 
    PopVsVac
WHERE 
    Location LIKE '%canada%'
ORDER BY 
    Location, Date;


   
-- Creating View to Store Data for Later Visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 




