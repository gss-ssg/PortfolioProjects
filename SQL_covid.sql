select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--lookig at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathprecentage
From PortfolioProject..CovidDeaths
where location like '%ndia%'
order by 1,2

--lookig at total cases vs population
--shows what percetage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as percentpopinfected
From PortfolioProject..CovidDeaths
where location like '%ndia%'
order by 1,2

--looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) AS highestinfectioncount, MAX((total_cases/population))*100 as percentpopinfected
From PortfolioProject..CovidDeaths
--where location like '%ndia%'
group by Location, population
order by 4 desc

--showing countries with highest death count per population

Select Location, MAX(cast(total_deaths AS int)) AS totaldeathcount
From PortfolioProject..CovidDeaths
--where location like '%ndia%'
where continent is not null
group by Location, population
order by 2 desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

--showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths AS int)) AS totaldeathcount
From PortfolioProject..CovidDeaths
--where location like '%ndia%'
where continent is not null
group by continent
order by 2 desc



-- GLOBAL NUMBERS

--shows global death percetage from day 1

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS Deathpercentage
From PortfolioProject..CovidDeaths
--where location like '%ndia%'
where continent is not null
group by date
order by 1,2

--shows total death percent around the world

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS Deathpercentage
From PortfolioProject..CovidDeaths
--where location like '%ndia%'
where continent is not null
--group by date
order by 1,2




-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From PopvsVac



-- TEMP TABLE



Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
-- order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVacc as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentPopulationVacc