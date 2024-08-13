Select * from CovidDeaths
Select * from CovidVaccinations

Select * from PortfolioProject..CovidDeaths
Order by 3,4

-- 1. Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- 2. Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

	-- All locations
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
Where continent is not null
order by 1,2

	-- Hungary
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
Where location like '%Hungary%' and continent is not null
order by 1,2

-- 3. Looking at the total cases vs population
-- Shows what % of population got Covid

	-- Hungary
Select location, date, total_cases,population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject..covidDeaths
Where location like '%Hungary%' and continent is not null
order by 1,2


-- 4. Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationInfected
from PortfolioProject..covidDeaths
Where continent is not null
Group By LOcation, Population
order by PercentPopulationInfected desc

-- 5. Showing the countries with Highest Death count

Select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..covidDeaths
Where continent is not null
Group By LOcation
order by TotalDeathCount desc

-- 6. Showing the countries with Highest Death rate per Population
Select location, population, MAX(total_deaths) as TotalDeathCount,
MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationDied
from PortfolioProject..covidDeaths
Where continent is not null
Group By LOcation, population
order by PercentPopulationDied desc

-- 7. Showing continents with the highest death count

Select continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..covidDeaths
Where continent is not null
Group By continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

-- 8. Daily total cases and deaths

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(CONVERT(float, new_deaths))/SUM(CONVERT(float, new_cases))*100 as DeathPercentage 
from PortfolioProject..covidDeaths
Where continent is not null
Group by date
order by 1,2

-- 9. All Total cases and deaths

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(CONVERT(float, new_deaths))/SUM(CONVERT(float, new_cases))*100 as DeathPercentage 
from PortfolioProject..covidDeaths
Where continent is not null
order by 1,2


-- 10. Looking at Total Population vs Vaccinations

-- Join two tables together
-- Do Rolling Count of daily vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, RollingPeopleVaccinated/Population*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create TAble #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, RollingPeopleVaccinated/Population*100
From #PercentPopulationVaccinated






-- Creating VIEWs to store data for Tableau visualizations

-- 1. Create View PercentPopulationInfected

Create View PercentPopulationInfected as
Select location, date, total_cases,population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
from PortfolioProject..covidDeaths
Where continent is not null

Select * from PercentPopulationInfected

Select * from PercentPopulationInfected
Where Location = 'Hungary'


-- 2. Create View GlobalPercentPopulationInfected

Create View GlobalPercentPopulationInfected as
Select date, SUM(total_cases) as globaltotal_cases, SUM(population) as globalpopulation
, (CONVERT(float, SUM(total_cases)) / NULLIF(CONVERT(float, SUM(population)), 0)) * 100 AS GlobalPercentPopulationInfected
from PortfolioProject..covidDeaths
Where continent is not null
Group by date

Select * from GlobalPercentPopulationInfected
Order by date


-- 3. Create View Deathpercentage

Create View DeathPercentage as
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
Where continent is not null

Select * from DeathPercentage 

Select *
From DeathPercentage
Where Location = 'Hungary'


-- 4. Create View GlobalDailyDeathPercentage

Create View GlobalDailyDeathPercentage as
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(CONVERT(float, new_deaths))/SUM(CONVERT(float, new_cases))*100 as DeathPercentage
from PortfolioProject..covidDeaths
Where continent is not null
Group by date

Select * from GlobalDailyDeathPercentage
Order by date


-- 5. Create View PercentpopulationsVaccinated

Create View PercentpopulationsVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select * From PercentpopulationsVaccinated


Select * From PercentpopulationsVaccinated
Where Location = 'Hungary'


-- 6. Create View RollingPeopleVaccinated

Create View RollingPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, 
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as RollingVaccinationPercentage 
from RollingPeopleVaccinated
Where location = 'Hungary'


-- 7. Create View GlobalDailyPeopleVaccinated

Create View GlobalDailyPeopleVaccinated as
Select dea.date, SUM(cast(vac.new_vaccinations as float)) as globalnewvaccinations, SUM(cast(dea.population as float)) as globalpopulation, 
(SUM(cast(vac.total_vaccinations as float)) / NULLIF(SUM(cast(dea.population as float)), 0)) * 100 AS GlobalDailyPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Group by dea.date

Select * from GlobalDailyPeopleVaccinated
Order by date


-- 8. Create View HighestInfectionRate

Create View HighestInfectionRate as
Select location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationInfected
from PortfolioProject..covidDeaths
Where continent is not null
Group By LOcation, Population

Select * from HighestInfectionRate
Order by PercentPopulationInfected desc


-- 9. Create View HighestDeathRate

Create View HighestDeathRate as
Select location, population, MAX(total_deaths) as TotalDeathCount,
MAX((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationDied
from PortfolioProject..covidDeaths
Where continent is not null
Group By LOcation, population

Select * from HighestDeathRate
Order by PercentPopulationDied desc


-- 10. Create View HighestVaccinationRate as of 4/30/3021

Create View HighestVaccinationRate as
Select dea.location, dea.population, SUM(cast(vac.new_vaccinations as float)) as total_vaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Group by dea.location, dea.population

Select *, (total_vaccinated/population)*100 as VaccinationRate 
from HighestVaccinationRate
Order by VaccinationRate desc


-- 11. Create View GlobalDeathPercentage as of 4/30/3021

Create View GlobalDeathPercentage as
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(CONVERT(float, new_deaths))/SUM(CONVERT(float, new_cases))*100 as DeathPercentage
from PortfolioProject..covidDeaths 
Where continent is not null

Select * from GlobalDeathPercentage













