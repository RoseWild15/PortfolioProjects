-- Data Cleaning Project

SELECT *
FROM layoffs; #Raw Data

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank values.
-- 4. Remove any columns/rows that aren't necessary.

CREATE TABLE layoffs_staging #Creating a duplicate table to process the data as to protect the raw data. 
LIKE layoffs; 

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs; 

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num  
FROM layoffs_staging;

#CTE to assign row numbers and filter for any that are greater than 1 aka a dupe.
WITH duplicate_cte AS  
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off,`date`, stage, 
country, funds_raised_millions) AS row_num  #Learnt that we need to partition by all columns not just the ones seen in the query above as that found rows that didn't need to be removed.
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Oda'; # Oda came up as duplicate but after checking it, its not a duplicate so we learnt to partition by all columns. 


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage, 
country, funds_raised_millions) AS row_num  
FROM layoffs_staging;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

# To recap the above, we created a staging table as to not work with the raw data. Created a CTE to assign row numbers and filter where the row number was greater than 1 (dupe)
# We then created a 3rd table as staging 2 (right click, copy to clipboard > create statement) and added the row_num column. We then inserted the staging data and deleted the rows that contained a row number greater than 1 giving us a table with no dupes.

-- Standardizing Data
SELECT *
FROM layoffs_staging2;

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'; 

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

SELECT * 
FROM layoffs_staging2
WHERE country LIKE 'United States%'; 

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`, 
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; 

SELECT *
FROM layoffs_staging2;

# A lot of standardizing, trimming spaces from company names, cleaning industry to not have multiple versions of the same thing like Crypto to be just Crypto as there was copies like "CryptoCurrency" which otherwise would appear seperately. 
# Fixing errors like "." at the end of United States, converting and setting date to use an actual date format.

-- 3. Null Values or Blank values.

SELECT * # Filtering to find rows that contained NULL in both columns.
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = ''; #Looking for NULLs and Blanks

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb'; #AirBnb had a blank value in one of their industry rows so was checking to see if we had that data which we did just in another row. 

SELECT * 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '') 
AND t2.industry IS NOT NULL; 

UPDATE layoffs_staging2 t1 # Updating the table using the self Join populating the NULL rows. 
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL; 

UPDATE layoffs_staging2 # When we tried to update earlier whilst it contained blanks it didn't work so we changed all blanks to NULLs. 
SET industry = NULL
WHERE industry = '';

-- 4. Remove columns 

SELECT *
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num; 

# Simply removing the row_num column that helped us sort the data to find duplicates earlier and also removed any rows that contained NULL in both total_laid_off and percentage_laid_off as they are of no use to us we cannot populate them.
