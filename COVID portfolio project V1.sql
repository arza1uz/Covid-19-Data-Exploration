--select *
--from [CovidDeaths]
--order by 3,4
--where continent is not null
--select *
--from [CovidVaccinations]
--order by 3,4

--Select the data we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio_Project_1].dbo.CovidDeaths
where continent is not null
order by 1,2

--looking at the total cases vs total deaths
--shows the likelihood of dying if you contract covid-19 in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
from [Portfolio_Project_1].dbo.CovidDeaths
where continent is not null and like '%Mexico%'
order by 1,2

--looking at the total cases vs population
--shows what percentage of population got covid-19
Select location, date, total_cases, population, (total_cases/population)*100 as contagion
from [Portfolio_Project_1].dbo.CovidDeaths
where continent is not null and location like '%Mexico%'
order by 1,2

--Countries with highest infection rate
Select location, population,max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentPopulationInfected
from [Portfolio_Project_1].dbo.CovidDeaths
where continent is not null
--where location like '%Mexico%'
group by population, location
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
Select Location, max(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio_Project_1].dbo.CovidDeaths
where continent is not null
--where location like '%Mexico%'
group by Location
order by TotalDeathCount desc

--Showing the continents with the highest death count per population

Select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio_Project_1].dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--global numbers

Select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathRate
from [Portfolio_Project_1].dbo.CovidDeaths
where continent is not null
group by date
order by 1,2



--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (bigint,vac.new_vaccinations))over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio_Project_1].dbo.CovidDeaths as dea
join [Portfolio_Project_1].dbo.CovidVaccinations as vac
	on
	dea.location = vac.location
	and dea.date=vac.date
	where dea.continent is not null
order by 1,2,3

--Use CTE
with PopvsVac (Continent, location,date, population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (bigint,vac.new_vaccinations))over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio_Project_1].dbo.CovidDeaths as dea
join [Portfolio_Project_1].dbo.CovidVaccinations as vac
	on
	dea.location = vac.location
	and dea.date=vac.date
	where dea.continent is not null
--order by 1,2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Using temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollinPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (bigint,vac.new_vaccinations))over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio_Project_1].dbo.CovidDeaths as dea
join [Portfolio_Project_1].dbo.CovidVaccinations as vac
	on
	dea.location = vac.location
	and dea.date=vac.date
	--where dea.continent is not null
--order by 1,2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--Creating View to store data for visualizations
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (bigint,vac.new_vaccinations))over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio_Project_1].dbo.CovidDeaths as dea
join [Portfolio_Project_1].dbo.CovidVaccinations as vac
	on
	dea.location = vac.location
	and dea.date=vac.date
	where dea.continent is not null
--order by 1,2,3


select *
from PercentPopulationVaccinated


--Vizualizations for Tableau Dashboard


--Viz 1: Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio_Project_1].dbo.CovidDeaths
--Where location like '%Mexico%'
where continent is not null 
--Group By date
order by 1,2

--Viz 2: Total Death Count per Continet
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Portfolio_Project_1].dbo.CovidDeaths
--Where location like '%Mexico%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


--Viz 3: Total Infection by Country
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio_Project_1].dbo.CovidDeaths
--Where location like '%Mexico%'
Group by Location, Population
order by PercentPopulationInfected desc


--Viz 4: Percent Population Infected
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio_Project_1].dbo.CovidDeaths
--Where location like '%Mexico%'
Group by Location, Population, date
order by PercentPopulationInfected desc
