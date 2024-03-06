select * 
from covid19..coviddeaths
order by 3,4

--select * 
--from covid19..covidvaccinations
--order by 3,4

-- Select the data that im gonna use
select location,date,total_cases,new_cases,total_deaths, population
from covid19..coviddeaths
order by 1,2

--total cases vs totaldeaths
select location,date,total_cases,total_deaths, 
(CONVERT(float, total_deaths) / CONVERT(float, total_cases))*100 as DeathPercentage
from covid19..coviddeaths
where location like '%Tunisia%'
order by 1,2


--looking at the total cases vs the population
--what percentage of population has gotten covid
select location,date,population,total_cases, 
(CONVERT(float, total_cases) /  population)*100 as PercentageOfPopulationInefected
from covid19..coviddeaths
where  location like '%Tunisia%'
order by 1,2

--looking at  countries with Highest infection rate compared to population
select location, population,max(total_cases) as highestinfectioncount  , 
MAX((CONVERT(float, total_cases)) / population) * 100 AS PercentageOfPopulationInfected
from covid19..coviddeaths
where continent is not null 
group by location,population 
order by PercentageOfPopulationInfected desc

-- showing countries with highest death count per population 
select location, population,max(cast(total_deaths as int)) as highestdeathcount  , 
MAX((CONVERT(float, total_deaths)) / population) * 100 AS PercentageOfPopulationdead
from covid19..coviddeaths
where continent is not null 
group by location,population 
order by PercentageOfPopulationdead desc   

--showing continents with the highest death count per population 
Select continent , max(cast(total_deaths as int )) as totalDeathcount
from covid19..coviddeaths
where continent is not  null
group by continent
order by totalDeathcount

--global numbers  
select  SUM(new_cases) as total_cases , sum(cast(new_deaths as int)) as totaldeaths,
sum(cast(new_deaths as int ))/sum(new_cases)*100 as deathPercentage
from covid19..coviddeaths
where continent is not nUll
order by 1,2
-- how many people in the world that are vaccinated 
--total population vs vaccinations 

with rollingPeaple as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float )) 
over (partition by dea.location order by dea.location,dea.date) as rollingPeapleVaccinated
from covid19..coviddeaths dea
JOIN covid19..covidvaccinations vac
    ON  dea.location=vac.location and
	 dea.date= vac.date
	 where dea.continent is not nUll
	 --order by 2,3
	 )
	 
	 select continent,location,date, population,new_vaccinations,rollingPeapleVaccinated,
	 (rollingPeapleVaccinated/population )*100 AS percentageVaccinated
	 from rollingPeaple
	 order by 2,3

	 --using temp table
	 drop table if exists  #percentPopulationVaccinated
	 create table #percentPopulationVaccinated
	 (
	 continent nvarchar(255),location nvarchar(255) , date  nvarchar(255)  , population float ,new_vaccination float,
	 rolling_ppl_vaccinated float )
	 insert into #percentPopulationVaccinated 
	 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float )) 
over (partition by dea.location order by dea.location,dea.date) as rollingPeapleVaccinated
from covid19..coviddeaths dea
JOIN covid19..covidvaccinations vac
    ON  dea.location=vac.location and
	 dea.date= vac.date
	 where dea.continent is not nUll

	  
	select *, (rolling_ppl_vaccinated/population)*100 AS percentageVaccinated
	from #percentPopulationVaccinated
	order by location , date;
	-- Creating View to store data for later visualizations

create view percentageVaccinatedVIEW as
	select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float )) 
over (partition by dea.location order by dea.location,dea.date) as rollingPeapleVaccinated
from covid19..coviddeaths dea
JOIN covid19..covidvaccinations vac
    ON  dea.location=vac.location and
	 dea.date= vac.date
	 where dea.continent is not nUll
  

  select * FROM  percentageVaccinatedVIEW