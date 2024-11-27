-- Cleaning Data

SELECT *
FROM Nashville_Housing_Data


-- Standardize Date Format

SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %d, %Y') AS ConvertedDate
FROM Nashville_Housing_Data;

UPDATE Nashville_Housing_Data 
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y')


-- Populate Property Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing_Data a
JOIN Nashville_Housing_Data b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
	
UPDATE Nashville_Housing_Data a
JOIN Nashville_Housing_Data b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Nashville_Housing_Data


SELECT
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, CHAR_LENGTH(PropertyAddress)) AS City
FROM Nashville_Housing_Data;


ALTER TABLE Nashville_Housing_Data 
Add PropertySplitAddress varchar(255);

UPDATE Nashville_Housing_Data 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1)

ALTER TABLE Nashville_Housing_Data 
Add PropertySplitCity varchar(255);

UPDATE Nashville_Housing_Data 
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, CHAR_LENGTH(PropertyAddress))



SELECT OwnerAddress
From Nashville_Housing_Data

SELECT
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Street,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS City,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1) AS State
FROM Nashville_Housing_Data;


ALTER TABLE Nashville_Housing_Data 
Add OwnerSplitAddress varchar(255);

UPDATE Nashville_Housing_Data 
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1)

ALTER TABLE Nashville_Housing_Data 
Add OwnerSplitCity varchar(255);

UPDATE Nashville_Housing_Data 
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)

ALTER TABLE Nashville_Housing_Data 
Add OwnerSplitState varchar(255);

UPDATE Nashville_Housing_Data 
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1)



-- Change Y and N to Yes and No in "Sold as Vacant" feild

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville_Housing_Data
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM Nashville_Housing_Data

UPDATE Nashville_Housing_Data
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
	
	
-- Remove Duplicates

WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM Nashville_Housing_Data
)
DELETE FROM Nashville_Housing_Data
WHERE UniqueID IN (
    SELECT UniqueID
    FROM RowNumCTE
    WHERE row_num > 1
);



-- Delete Unused Columns


SELECT *
FROM Nashville_Housing_Data

ALTER TABLE Nashville_Housing_Data
DROP COLUMN SaleDate,
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

