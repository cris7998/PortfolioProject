--Confirm that the Databases I imported are appearing as intended
SELECT *
FROM PortfolioProject..CovidDeaths$
Order by 3,4

SELECT *
FROM PortfolioProject..CovidVacinations$
Order by 3,4

--Select Data that we are going to be Using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
Order By 1, 2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you were to contract Covid in the United States
Select location, date, total_cases, total_deaths, (Cast(total_deaths AS Numeric))/ Cast(total_cases AS Numeric)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
Order By 1, 2

--Looking at the Total Cases vs Population
--Shows what percentage of Population got Covid in the United States
Select location, date, population, total_cases, (Cast(total_cases AS Numeric))/ Cast(population AS Numeric)*100 AS CasePercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
Order By 1, 2

--Looking at Countries with Highest Infection Rate compared to Population
Select location, population, Max(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group By Location, population
Order By PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population
SELECT location, Max(cast(total_deaths as numeric)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount DESC

--Let's Break things down by Continent
SELECT continent, Max(cast(total_deaths as numeric)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount DESC

--Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as numeric)) as total_deaths, SUM(cast(new_deaths as numeric))/SUM(new_cases)*100 as DeathPercentages
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by date
Order by 1,2 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentages
From PortfolioProject..CovidDeaths$
Where continent is not null
--Group by date
Order by 1,2 

SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;

--Looing at Total Population vs Vaccinations
--Joining CovidDeaths and CovidVacinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVacinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
Order by 2, 3

--Use CTE
With PopvsVac (Continent, location, data, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVacinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100 as RollingVaccinationPercentage
From PopvsVac

--TEMP Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVacinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--Order by 2, 3

Select *, (RollingPeopleVaccinated/population)*100 as RollingVaccinationPercentage
From #PercentPopulationVaccinated

--Creating View to store data for last Visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVacinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 

Select *
From PercentPopulationVaccinated