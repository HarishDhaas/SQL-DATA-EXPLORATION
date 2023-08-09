SELECT location,date,total_cases,new_cases,total_deaths,new_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

--Checking total cases vs total deaths in India
select location,cast(date as date)as Date,total_cases,total_deaths,round((total_deaths/total_cases)*100,2) as Death_Percentage_in_India
from CovidDeaths
where location = 'India' and total_deaths is not null 
order by 1,2

--Checking total cases vs total population
select location,cast(date as date)as Date,total_cases,population,round((total_cases /population)*100,2) as Infectionrate_Percentage
from CovidDeaths
where location in ('India') 
order by 1,2

--Checking countries with max infection rate

select location,max(total_cases)as total_case,population,round(max((total_cases) /population)*100,2) as max_Infectionrate_Percentage
from CovidDeaths
where (total_cases) /population is not null and continent is not null
group by  location,population
order by max_Infectionrate_Percentage desc

--Checking countries with highest death rate wrt population
select location,population,max(cast(total_deaths as int)) as total_death,round(max(cast(total_deaths as int)/population),5)*100 as max_deathrate_Percentage
from CovidDeaths
where cast(total_deaths as int)/population is not null and continent is not null
group by location,population
order by max_deathrate_Percentage desc	

--Checking continents with highest deaths
select continent,max(cast(total_deaths as int)) as max_death
from CovidDeaths
where continent is not null
group by continent
order by max_death desc

--GLOBAL NUMBERS OF DEATH RATE
select sum(new_cases) as 'total cases',sum(cast(new_deaths as int))as 'total deaths',
round(sum(cast(new_deaths as int))/sum(new_cases),4)*100 as death_percentage
from CovidDeaths
where continent is not null

--CHECKING TOTAL VACCINATED PEOPLE
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
FROM CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3

--USING CTE
WITH PERVAC(continent,location,date,population,new_vaccinations,Rolling_People_Vaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
FROM CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
)

select*,round((Rolling_People_Vaccinated/population)*100,5)
from PERVAC

--USING TEMP TABLE
DROP table IF EXISTS #Percentage_Vaccinated
CREATE TABLE #Percentage_Vaccinated (
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #Percentage_Vaccinated 
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
FROM CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3

select*,(Rolling_People_Vaccinated/population)*100 as 'percentage vaccinated'
from #Percentage_Vaccinated

--CREATE VIEW TO STORE DATA FOR VISUALIZATION IN TABLEU
CREATE VIEW NO_OF_PEOPLE_VACCINATED AS
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
FROM CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null













