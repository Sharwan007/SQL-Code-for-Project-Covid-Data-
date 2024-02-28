--select *
--from PortfolioProjects..CovidDeaths$
--select *
--from PortfolioProjects..CovidVaccination

select location,total_cases,new_cases,total_deaths,population
from PortfolioProjects..CovidDeaths$
order by 1,2

select*
from PortfolioProjects..CovidDeaths$
where continent is not null
order by 3,4

--Looking total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths$
where location like '%states%'
where continent is not null
order by 1,2

select location,date,total_cases,population,(total_cases/population)*100 as CasesPercentage
from PortfolioProjects..CovidDeaths$
where location like '%states%'
order by 1,2


select location,population,date,max(total_cases) as HighestInfectionCount,max(total_cases/population)*100 as PercentagepopulationInfected
from PortfolioProjects..CovidDeaths$
--where location like '%states%'
where continent is not null
Group  by location,Population
order by PercentagepopulationInfected desc

select location,max(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths$
--where location like '%states%'
where continent is not null
Group  by location
order by TotalDeathCount desc

select location,max(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths$
--where location like '%states%'
where continent is not null
Group  by location
order by TotalDeathCount desc


select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

---Looking at total population vs Vaccination


SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVaci(contintent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVaci


---temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--- Creating View to store data for later visuallization

create view PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated
