
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Type


---CHECKING DATA
Select *
FROM PortofolioProjects..CovidDeaths
Order by 3,4

select * 
from PortofolioProjects..CovidVaccinations
order by 3,4

--Select data that we are going to be used
Select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProjects..CovidDeaths
order by 1,2 

-- Looking at total cases vs total deaths 
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProjects..CovidDeaths
where location LIKE '%Indonesia%'
and continent is not null
order by 1,2

-- Looking at total cases vs population 
-- Shows what percentage of population got covid 

Select location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortofolioProjects..CovidDeaths
--where location LIKE '%Indonesia%'
order by 1,2


-- Looking at country with highest infection rate compared to population 
Select location,population, MAX(total_cases) as HighestInfectionCount ,MAX(total_cases/population)*100 as  PercentPopulationInfected
from PortofolioProjects..CovidDeaths
Group by location, population
order by  PercentPopulationInfected desc


-- Looking at Country with highest  Death Count per Population

Select location,Max(cast(Total_deaths as int)) as TotalDeathCount
from PortofolioProjects..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- Break things by continent 

Select continent ,Max(cast(Total_deaths as int)) as TotalDeathCount
from PortofolioProjects..CovidDeaths
where continent is not null
Group by continent 
order by TotalDeathCount desc

-- Showing the continent with highest death count 
Select continent ,Max(cast(Total_deaths as int)) as TotalDeathCount
from PortofolioProjects..CovidDeaths
where continent is not null
Group by continent 
order by TotalDeathCount desc

-- GLOBAL NUMBERS 
Select  date, sum(new_cases) AS TotalCases , sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int)) /sum(new_cases)*100  as DeathPercentage
FROM PortofolioProjects..CovidDeaths
where continent is not null
Group by date
order by 1,2


-- Looking at total population vs vacinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated 
--,(rollingpeoplevaccinated/population)*100 
from PortofolioProjects..CovidDeaths dea
Join PortofolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
Order by 2,3 

-- USE CTE

With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProjects..CovidDeaths dea
Join PortofolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP Table

create table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--,(rollingpeoplevaccinated/population)*100 
from PortofolioProjects..CovidDeaths dea
Join PortofolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
--where dea.continent is not null
--Order by 2,3

select *, (RollingPeopleVaccinated/population)* 100
From #PercentPopulationVaccinated

-- TEMP Table
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProjects..CovidDeaths dea
Join PortofolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 


-- Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProjects..CovidDeaths dea
Join PortofolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated