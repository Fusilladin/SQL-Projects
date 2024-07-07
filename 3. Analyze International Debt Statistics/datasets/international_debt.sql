-- Create Table: international_debt
-- This table stores information about international debt for various countries

CREATE TABLE international_debt
(
  country_name VARCHAR(50) NOT NULL,  -- Name of the country
  country_code VARCHAR(10) NOT NULL,  -- ISO country code (assuming standard code length)
  indicator_name TEXT NOT NULL,       -- Name of the debt indicator
  indicator_code TEXT NOT NULL,       -- Code for the debt indicator
  debt NUMERIC(18, 2) NOT NULL,       -- Debt amount with precision to handle large values and cents
  CONSTRAINT pk_international_debt PRIMARY KEY (country_code, indicator_code)  -- Composite primary key
);

-- Add indexes for better query performance
CREATE INDEX idx_country_name ON international_debt(country_name);
CREATE INDEX idx_indicator_name ON international_debt(indicator_name);

-- Note: Ensure the CSV file path is correct and accessible by the database system

-- Copy data from CSV file into the international_debt table
\copy international_debt (country_name, country_code, indicator_name, indicator_code, debt)
FROM '/path/to/international_debt.csv' DELIMITER ',' CSV HEADER;

-- Validate the data import by checking the first few rows
SELECT * FROM international_debt LIMIT 10;
