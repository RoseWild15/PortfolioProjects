-- Exploratory Data Analysis 

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off) # Highest amount & percentage laid off
FROM layoffs_staging2;

SELECT * # Looking at companies that laid off 100% of their employees aka bankruptcy. 
FROM layoffs_staging2
WHERE percentage_laid_off = 1 
ORDER BY funds_raised_millions DESC; 

SELECT COUNT(company)  # Total amount of companies that laid off 100% of their employees aka bankruptcy. 
FROM layoffs_staging2
WHERE percentage_laid_off = 1 
ORDER BY funds_raised_millions DESC; 

SELECT company, SUM(total_laid_off) # Looking at which companies had the most layoffs.
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;  

SELECT MIN(`date`), MAX(`date`) # Looking at when the layoffs began and end/latest date. So began in 2020 and last record is 2023. 
FROM layoffs_staging2; 

SELECT industry, SUM(total_laid_off) # Looking at which industries had the most layoffs.
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC; 

SELECT country, SUM(total_laid_off) # Looking at which countries laid off the most people. 
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC; 

SELECT YEAR(`date`), SUM(total_laid_off) # Looking at how many were laid off each year.
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC; 

SELECT stage, SUM(total_laid_off) # Looking at the various stages of companies and how many were laid off.
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC; 

SELECT company, SUM(percentage_laid_off) # Useless, we don't have the data of how big the companies are. 
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC; 

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) #Looking at layoffs per month. 
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC; 

WITH Rolling_Total AS 
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

# Rolling Total of Total Laid Off by Month. 

SELECT company, YEAR(`date`), SUM(total_laid_off) # Looking at the total of layoffs of each company by year. 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;  

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER( PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5; 

# Created a multi-CTE to first look at the total of layoffs of each company by year, assign them a rank and filter that ranking column to find the top 5 companies with the most layoffs per year. 

WITH Industry_Year (industry,  years, total_laid_off) AS
(
SELECT industry, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY industry, YEAR(`date`)
), Industry_Year_Rank AS
(SELECT *, DENSE_RANK() OVER( PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Industry_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Industry_Year_Rank
WHERE ranking <= 1; 

# Looking at which Industries had the most layoffs per year. 

WITH Industry_Year (industry, country,  years, total_laid_off) AS
(
SELECT industry, country, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY industry, country, YEAR(`date`)
), Industry_Year_Rank AS
(SELECT *, DENSE_RANK() OVER( PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Industry_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Industry_Year_Rank
WHERE ranking <= 5; 

# Same as above but now looking at the top 5 countries & industries that had the most layoffs
# In which it is very clear that the United States had the most by far. 

WITH Industry_Country AS (
    SELECT industry, country, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY industry, country
),
Ranked AS (
    SELECT *,
    DENSE_RANK() OVER(PARTITION BY country ORDER BY total_laid_off DESC) AS ranking
    FROM Industry_Country
)
SELECT *
FROM Ranked
WHERE ranking <= 3
AND country = 'United Kingdom';

# Top 3 Industries affected by layoffs in the United Kingdom.

WITH Industry_Country AS (
SELECT industry, country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY industry, country
)
SELECT 
uk.industry, 
uk.total_laid_off AS uk_layoffs,
us.total_laid_off AS us_layoffs
FROM Industry_Country uk
JOIN Industry_Country us
    ON uk.industry = us.industry
WHERE uk.country = 'United Kingdom'
AND us.country = 'United States';

# CTE/self join used to compare United Kingdom & United States layoffs, which could be adapted to compare any two countries with a few tweaks.