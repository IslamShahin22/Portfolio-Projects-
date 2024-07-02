/*

Cleaning Data in SQL Queries

*/

select *
from Potofolio_project..NashvilleHousing
--where PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE Potofolio_project..NashvilleHousing
ADD SaleDateConverted Date

UPDATE Potofolio_project..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

--ALTER TABLE Potofolio_project..NashvilleHousing
--DROP COLUMN SaleDateComverted

Select saledateconverted
from Potofolio_project..NashvilleHousing


-- If it doesn't Update properly
Select *
from Potofolio_project..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Potofolio_project..NashvilleHousing as a
join Potofolio_project..NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Potofolio_project..NashvilleHousing as a
join Potofolio_project..NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
from Potofolio_project..NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
from Potofolio_project..NashvilleHousing


ALTER TABLE Potofolio_project..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE Potofolio_project..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)



ALTER TABLE Potofolio_project..NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE Potofolio_project..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
select owneraddress
from Potofolio_project..NashvilleHousing



select 
PARSENAME(REPLACE(Owneraddress, ',','.'), 3),
PARSENAME(REPLACE(Owneraddress, ',','.'), 2),
PARSENAME(REPLACE(Owneraddress, ',','.'), 1)
from Potofolio_project..NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------


ALTER TABLE Potofolio_project..NashvilleHousing
ADD OwnerSplitAdress Nvarchar(255)

UPDATE Potofolio_project..NashvilleHousing
SET OwnerSplitAdress = PARSENAME(REPLACE(Owneraddress, ',','.'), 3)



ALTER TABLE Potofolio_project..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE Potofolio_project..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(Owneraddress, ',','.'), 2)


ALTER TABLE Potofolio_project..NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE Potofolio_project..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(Owneraddress, ',','.'), 1)





-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(soldAsVacant), count(soldAsVacant)
from Potofolio_project..NashvilleHousing
group by soldAsVacant



select soldAsVacant, CASE when soldAsVacant = 'Y' THEN 'Yes' 
						  when soldAsVacant ='N' THEN 'NO'
						  ELSE soldAsVacant
						  END 
from Potofolio_project..NashvilleHousing

UPDATE Potofolio_project..NashvilleHousing
SET soldAsVacant =  CASE when soldAsVacant = 'Y' THEN 'Yes' 
						  when soldAsVacant ='N' THEN 'NO'
						  ELSE soldAsVacant
						  END 






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Potofolio_project..NashvilleHousing
--order by ParcelID
)



delete 
from RowNumCTE
where row_num >1



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From Potofolio_project..NashvilleHousing


ALTER TABLE Potofolio_project..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate