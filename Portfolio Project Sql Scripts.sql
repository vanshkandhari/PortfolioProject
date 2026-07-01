select * from PortfolioProject..CovidDeaths;

select * from PortfolioProject..CovidVaccinations;

-- Select Data that we are going to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths order by 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths where location like '%india%' order by 1,2; 

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date,population, total_cases, (total_cases/population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths 
where location like '%india%' 
order by 1,2; 

--Looking at the countries with highest infected rates compared to population

select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
--where location like '%india%' 
group by location,population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount  --use cast to convert nvarchar type to int.
from PortfolioProject..CovidDeaths 
--where location like '%india%' 
where continent is not null
group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount  --use cast to convert nvarchar type to int.
from PortfolioProject..CovidDeaths 
--where location like '%india%' 
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)* 100 
as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations,
(sum(convert(int,vac.New_Vaccinations)) over (Partition by dea.location order by dea.location, dea.date)) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea 
join PortfolioProject..CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations,
(sum(convert(int,vac.New_Vaccinations)) over (Partition by dea.location order by dea.location, dea.date)) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea 
join PortfolioProject..CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100  from PopVsVac order by 2,3

-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations,
(sum(convert(int,vac.New_Vaccinations)) over (Partition by dea.location order by dea.location, dea.date)) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea 
join PortfolioProject..CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/population)*100  from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccine as 
select dea.continent, dea.location, dea.date, dea.population, vac.New_Vaccinations,
(sum(convert(int,vac.New_Vaccinations)) over (Partition by dea.location order by dea.location, dea.date)) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths Dea 
join PortfolioProject..CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccine