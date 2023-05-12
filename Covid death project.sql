/*
SELECT TOP(10) *
FROM CovidVaccinations;*/

-- 1st-Jan-2020 To 30th-April-2021
SELECT MIN(date) as Date
FROM CovidDeaths;

-- Let us look at top(10) Countries affected by this pandemic
SELECT TOP 10 
    location,
    sum(population) AS population,
    SUM(CONVERT(bigint, total_cases)) AS total_cases,
    SUM(CONVERT(bigint, total_deaths)) AS total_deaths
FROM 
    CovidDeaths
Where location NOT IN ('world','Asia','Africa','North America','South America','Antarctica','Europe','Oceania','European Union')

GROUP BY 
    location,
    continent,population
ORDER BY 
    total_cases DESC;

/*SELECT DISTINCT location
FROM CovidDeaths
WHERE location='oceania';*/

-- At this stage, we'll have to select data for our analysis.
SELECT location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2;

-- Looking at death rate (Total Death vs Total Cases) in Nigeria
SELECT location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as '% Death'
FROM CovidDeaths
WHERE location = 'Nigeria' and continent is not null
ORDER BY 1,2;

-- Looking at Total cases vs Population
-- Shows the % Population infected by Codid.

SELECT location,
	date,
	population,total_cases,
	(total_cases/population)*100 as '% Population'
FROM CovidDeaths
WHERE location = 'Nigeria' and continent is not null
ORDER BY 1,2;

-- Country with the highest infection rate in terms of population
SELECT location,
	population,MAX(total_cases) as HighestInfectionCount,
	max((total_cases/population)*100 )as '% PopulationInfected'
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population 
ORDER BY 4 DESC;


-- Let us deep dive by continent.
SELECT continent,
	MAX(cast (total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Country with the highest Death Count
-- Nigeria is 84th with 2063 Death count

SELECT location,
	MAX(cast (total_deaths as int)) as HighestDeathCount
	-- max((total_cases/population)*100 )as '% PopulationInfected'
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null  -- and location= 'Nigeria'
GROUP BY location, population 
ORDER BY 2 DESC;


--Let us see the Continent with the Highest Death Count
SELECT continent,location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent,location
ORDER BY TotalDeathCount DESC;

-- Global Cases of Covid
SELECT date, SUM(new_cases) as Total_New_Cases,
	SUM(cast(new_deaths as int)) as Total_New_Deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Rate
FROM covidPortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2; 


-- Looking at Total polpulation vs Total Vaccinations
SELECT cde.continent,cde.location,cde.population,cva.new_vaccinations,
	SUM(CONVERT(int,cva.new_vaccinations)) 
	OVER (partition by cde.location 
	ORDER BY cde.location,
		cde.Date) As PeopleVaccinated
FROM CovidDeaths cde
JOIN covidPortfolioProject..CovidVaccinations cva
	ON cde.location = cva.location
	and cde.date = cva.date
WHERE cde.continent is not null -- and cde.location= 'Nigeria '
ORDER BY 2,3;

-- Using CTE
with popvsVac(Continent, Location, Date, Popluation, New_vaccinations, PeopleVaccinated)
As
(
SELECT cde.continent,cde.location,cde.date,cde.population,cva.new_vaccinations,
	SUM(CONVERT(int,cva.new_vaccinations)) 
	OVER (partition by cde.location 
	ORDER BY cde.location,
		cde.Date) As PeopleVaccinated
FROM CovidDeaths cde
JOIN covidPortfolioProject..CovidVaccinations cva
	ON cde.location = cva.location
	and cde.date = cva.date
WHERE cde.continent is not null -- and cde.location= 'Nigeria '
-- ORDER BY 2,3
)

SELECT *, (PeopleVaccinated/Popluation)*100 as PercentPeopleVAccinated
FROM popvsVac
ORDER BY Continent;


-- TEMP TABLE

DROP TABLE if exists #PercentPeopleVaccinated

CREATE TABLE #PercentPeopleVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	peoplevaccinated numeric
)

INSERT INTO #PercentPeopleVaccinated
SELECT cde.continent,cde.location,cde.date,cde.population,cva.new_vaccinations,
	SUM(CONVERT(int,cva.new_vaccinations)) 
	OVER (partition by cde.location 
	ORDER BY cde.location,
		cde.Date) As PeopleVaccinated
FROM CovidDeaths cde
JOIN covidPortfolioProject..CovidVaccinations cva
	ON cde.location = cva.location
	and cde.date = cva.date
WHERE cde.continent is not null -- and cde.location= 'Nigeria '

SELECT *, (PeopleVaccinated/ Population)*100 as PercentPeopleVAccinated 
FROM #PercentPeopleVaccinated 


-- Let us try to extract data for Africa since we want to narrow down our analysis to Africa

SELECT cd.location, cd.date, cd.total_cases, cd.total_deaths, cv.people_vaccinated, cd.population
FROM CovidDeaths cd
JOIN CovidVaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent = 'Africa' AND cd.total_deaths IS NOT NULL AND cv.people_vaccinated IS NOT NULL AND cd.population IS NOT NULL
GROUP BY cd.location, cd.date, cd.total_cases, cd.total_deaths, cv.people_vaccinated, cd.population
ORDER BY cd.location, cd.date;

