Select *
From nashwellhousing

-------------------------------------------------------------------------

-- standaedize date format

Select SaleDateConverted, convert(date,saledate)
From nashwellhousing

Update nashwellhousing
SET SaleDate = convert(date,saledate);

Alter Table nashwellhousing
Add SaleDateConverted date;

update nashwellhousing
SET SaleDateConverted = convert(date, saleDate)


---------------------------------------------------------------------

--Populate Property Address data

Select *
from nashwellhousing
where PropertyAddress is null


--order by ParcelID

select a.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, 
ISNULL(A.PropertyAddress, b.PropertyAddress)
from nashwellhousing a
join nashwellhousing b 
	on a.ParcelID = B.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
	WHERE A.PropertyAddress IS NULL 

UPDATE a
SET PropertyAddress = ISNULL(A.PropertyAddress, b.PropertyAddress)
from nashwellhousing a
join nashwellhousing b 
	on a.ParcelID = B.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
	WHERE A.PropertyAddress IS NULL

--------------------------------------------------------------------------
--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) ,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PROPERTYADDRESS )) 
FROM nashwellhousing

ALTER TABLE NASHWELLHOUSING
ADD PROPERTYSPLITADDRESS NVARCHAR(255)

UPDATE nashwellhousing
SET
	PROPERTYSPLITADDRESS = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NASHWELLHOUSING
ADD PROPERTYSPLITCITY NVARCHAR(255)

UPDATE nashwellhousing
SET PROPERTYSPLITCITY = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PROPERTYADDRESS )) 



-------------------------------------------------------------------------
--LETS DO THIS WITH A EASY METHOD

SELECT 
	PARSENAME(REPLACE(OWNERADDRESS, ',', '.'),3),
	PARSENAME(REPLACE(OWNERADDRESS, ',', '.'),2),
	PARSENAME(REPLACE(OWNERADDRESS, ',', '.'),1)
FROM nashwellhousing

ALTER TABLE NASHWELLHOUSING
ADD OWNERPROPERTYADDRESS NVARCHAR(255)

UPDATE nashwellhousing
SET OWNERPROPERTYADDRESS = PARSENAME(REPLACE(OWNERADDRESS, ',', '.'),3)

ALTER TABLE NASHWELLHOUSING
ADD OWNERPROPERTYCITY NVARCHAR(255)

UPDATE nashwellhousing
SET OWNERPROPERTYCITY = PARSENAME(REPLACE(OWNERADDRESS, ',', '.'),2)

ALTER TABLE NASHWELLHOUSING
ADD OWNERPROPERTYCOUNTRY NVARCHAR(255)

UPDATE nashwellhousing
SET OWNERPROPERTYCOUNTRY = PARSENAME(REPLACE(OWNERADDRESS, ',', '.'),1)



---------------------------------------------------------------------------
--CHANGE Y AND N TO YES AND NO IN SOLD ADS VACANT
SELECT DISTINCT(SOLDASVACANT), COUNT(SOLDASVACANT)
FROM nashwellhousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SOLDASVACANT,
	CASE WHEN SOLDASVACANT = 'Y' THEN 'YES'
		WHEN SOLDASVACANT = 'N' THEN 'NO'
		ELSE SOLDASVACANT
		END

FROM nashwellhousing


UPDATE nashwellhousing
SET SoldAsVacant = CASE WHEN SOLDASVACANT = 'Y' THEN 'YES'
		WHEN SOLDASVACANT = 'N' THEN 'NO'
		ELSE SOLDASVACANT
		END

------------------------------------------------------------------------------
-- REMOVE DUPLICATES

SELECT * , 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) ROW_NUM

FROM nashwellhousing
order by ROW_NUM desc

--as we are not cant make operations on the table we made, thats why we have to 
--now use cte aur temp table to put the operations on the column we had made

 with RowNumCte AS( 
 SELECT * , 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
				 ) ROW_NUM

FROM nashwellhousing)
select * from RowNumCte 
where ROW_NUM > 1
 

--------------------------------------------------------------------------

--DELETE UNUSED COLUMNS

 

ALTER TABLE NASHWELLHOUSING
DROP COLUMN OWNERADDRESS, TAXDISTRICT, PROPERTYADDRESS

ALTER TABLE NASHWELLHOUSING
DROP COLUMN SALEDATE
















