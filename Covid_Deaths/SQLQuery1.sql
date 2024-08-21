select *
from Portfolioprojects.dbo.CovidDeaths
where continent is not null
order by 3,4


--select *
--from Portfolioprojects.dbo.CovidVaccinations
--order by 3,4

-- select the data that we need to use --
select location , date, total_cases, new_cases, total_deaths, population
from Portfolioprojects..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases VS Total Deaths
-- Shows Likelihood of dying if you contact covied in your country
select location , date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from Portfolioprojects..CovidDeaths
where location like 'India'
and  continent is not null
order by 1,2

--Looking at the Total_Cases VS Population
--Shows what percentage of people got covid
select location , date, total_cases, population,(total_cases/population)*100 as Affected_People_Percent
from Portfolioprojects..CovidDeaths
where location like 'India'
and  continent is not null
order by 1,2

--Looking at the Countries with Highest Infection rate compared to Population
select location , population,MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
from Portfolioprojects..CovidDeaths

group by location,population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population
select location , Max(cast(Total_deaths as int)) as TotalDeaths 
from Portfolioprojects..CovidDeaths
where continent is not null
group by location
order by TotalDeaths desc

-- Let's Break Things Down By Continent
-- SHowing the Continents with Highest Death Count

select continent , Max(cast(Total_deaths as int)) as TotalDeaths 
from Portfolioprojects..CovidDeaths
where continent is not null
group by continent
order by TotalDeaths desc

-- GLOBAL NUMBERS
select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from Portfolioprojects..CovidDeaths
--where location like 'India'
where continent is not null
--group by date
order by 1,2 desc


--Looking at Total Population VS Total Vaccinations
select dea.continent , dea.location , dea.date, dea.population,vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations )) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

from Portfolioprojects..CovidDeaths dea
join Portfolioprojects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use CTE

with	PopvsVac (Continent,Location, Date , Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent , dea.location , dea.date, dea.population,vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations )) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

from Portfolioprojects..CovidDeaths dea
join Portfolioprojects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



--TEMP TABLE
DROP Table if exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
select dea.continent , dea.location , dea.date, dea.population,vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations )) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

from Portfolioprojects..CovidDeaths dea
join Portfolioprojects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPeopleVaccinated



-- Creating view to store data for further visualizations


Create View PercentofPeopleVaccinated as
select dea.continent , dea.location , dea.date, dea.population,vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations )) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

from Portfolioprojects..CovidDeaths dea
join Portfolioprojects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


























