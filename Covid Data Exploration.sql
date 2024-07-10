--SELECT * FROM CovidDeaths$ order by 3,4

-- Select Data that we are going to be starting with
Select location,date,total_cases,new_cases,total_deaths,population from CovidDeaths$

-- Shows likelihood of dying if you contract covid in your country

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage from CovidDeaths$
Where location LIKE '%YOUR COUNTRY%' order by date

-- Shows what percentage of population infected with Covid

Select location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected from CovidDeaths$
Where location LIKE '%YOUR COUNTRY%' order by date

-- Countries with Highest Infection Rate compared to Population

Select location,MAX(total_cases) as HighestInfectionCount,population,MAX((total_cases/population))*100 as PercentPopulationInfected from CovidDeaths$
group by location,population 
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
Select location,MAX(cast(total_deaths as int)) as TotaltDeathCount from CovidDeaths$
where continent is not null
group by location 
order by TotaltDeathCount desc

-- Showing contintents with the highest death count per population
Select continent,MAX(cast(total_deaths as int)) as TotaltDeathCount from CovidDeaths$
where continent is not null
group by continent 
order by TotaltDeathCount desc


 --GLOBAL NUMBERS
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage from CovidDeaths$

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query
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

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated  as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


