Select *
From PortfolioProjects..CovidDeaths
Where continent is not null
order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in yout country
USE PortfolioProjects
ALTER TABLE CovidDeaths 
ALTER COLUMN total_cases float
ALTER TABLE CovidDeaths 
ALTER COLUMN total_deaths float
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


--Looking at Total Cases vs Population
--Show what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not null
order by 1,2


-- Looking at Countries with IHghest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Showing continents with the highest death count per population 

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not null
and new_cases != 0
Group By date
order by 1,2


--Looking at Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac(Continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From PopvsVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
USE PortfolioProjects
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3



Select *
From PercentPopulationVaccinated