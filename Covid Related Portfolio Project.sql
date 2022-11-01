

--Selecting the data we are going to be using
Select location, date, total_cases, new_cases,total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total cases vs Total Deaths
--Probality of dying if you contract Covid in India
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percent
From PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2

--Looking at Total cases vs Population
--Population wise covid contraction

Select location, date, total_cases,population,(total_cases/population)*100 as Case_Percent
From PortfolioProject..CovidDeaths
--Where location like '%india%'
order by 1,2

--Highest Infection Rates compared to Population
Select location, population, MAX(total_cases) as Aggregate_total_cases , MAX((total_cases/population))*100 as Aggregate_Case_Percent
From PortfolioProject..CovidDeaths
Group by location , population 
order by  Aggregate_Case_Percent desc

--Showing Countries with Highest Death Count compared to population

Select location, population, MAX(cast(total_deaths as int)) as Aggregate_total_deaths
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location , population 
order by  Aggregate_total_deaths desc


--LETS BREAK THINGS DOWN BY CONTINENT

--Showing Continents with Highest death Count compared to population

Select continent, MAX(cast(total_deaths as int)) as Aggregate_total_deaths
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by  Aggregate_total_deaths desc


--Vaccination VS Population


Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
order by 2,3

--GLOBAL NUMBERS


Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Vacc_people_perday 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--Use CTE(A Temporary table, here it is named as PopvsVac)

With PopvsVac (Continent, Location, Date , Population, new_vaccinations, Vacc_people_perday)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Vacc_people_perday 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3(its invalid in views, inline functions, derived tables, subqueries, and common table expressions)
)
Select *, (Vacc_people_perday/Population)*100
From PopvsVac


--TEMP TABLE


drop table if exists #PercentPopVaccinated
Create Table #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Vacc_people_perday numeric,
)
Insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Vacc_people_perday 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location=vac.location
  and dea.date=vac.date
--where dea.continent is not null
--order by 1,2,3(its invalid in views, inline functions, derived tables, subqueries, and common table expressions)
Select *, (Vacc_people_perday/Population)*100
From #PercentPopVaccinated


--Creating view to store data forlater visualization

Create view PercentPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Vacc_people_perday 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3(its invalid in views, inline functions, derived tables, subqueries, and common table expressions)(it threw error in view when uncommented)

Select * 
From PercentPopVaccinated