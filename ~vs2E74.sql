select * 
from covidD1$
order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from covidD1$
order by 1,2

-- Shows what percentage got covid
select location, date, total_cases, Population, (total_cases/population)*100 as death_percentage
from covidD1$
where location like '%india%'
order by 1,2
  
--looking at countries with hightest infection rate compared to population
select location, population ,MAX(total_cases) as maximum_infection, max((total_cases/population))*100 as percentpopulationinfeected
from covidD1$
 -- where location like '%india%'
 group by location, population 
order by percentpopulationinfeected desc

--highest no of deaths accourding to the country
select location ,MAX(cast(total_deaths as int)) as maximum_deaths
from covidD1$
 -- where location like '%india%'
 where continent is null
 group by location 
order by maximum_deaths desc

--showing contintents with the highest death count per population
select continent ,MAX(cast(total_deaths as int)) as maximum_deaths
from covidD1$
 -- where location like '%india%'
 where continent is not null
 group by continent
order by maximum_deaths desc

--Global Number
select date, SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From covidD1$
where continent is not null
group by date
order by 1,2


-- Looking at total populaiton va vaccinations
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) 
over(partition by dea.location order by dea.location, dea.date)
from covidD1$ as dea
join ['covidvaccination 2$'] vac
on dea.location = vac.location
and dea.date = vac.date

where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac(continent, location, date , population, new_vaccinations, rollingpeoplevaccinated)
as (
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) 
over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from covidD1$ as dea
join ['covidvaccination 2$'] vac
on dea.location = vac.location
and dea.date = vac.date

where dea.continent is not null

)
select *, (rollingpeoplevaccinated/population) *100
from PopvsVac

--temp table
Drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) 
over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from covidD1$ as dea
join ['covidvaccination 2$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
select *, (rollingpeoplevaccinated/population) *100
from #percentpopulationvaccinated

--creating view to store date for later visulations

create view percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
	SUM(convert(bigint,vac.new_vaccinations)) 
	OVER(Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from covidD1$ as dea
join ['covidvaccination 2$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * 
From percentPopulationVaccinated



