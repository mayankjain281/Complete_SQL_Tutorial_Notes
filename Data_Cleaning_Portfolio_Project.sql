/*

Cleaning Data using SQL Queries

*/

Select *
From Portfolio_project.dbo.nashvillehousing

-- Standardizing Date Format

--create new column
ALTER TABLE nashvillehousing
Add SaleDateConverted Date;

--update column with new value
Update nashvillehousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--code check
Select SaleDateConverted, CONVERT(Date, SaleDate)
From Portfolio_project.dbo.nashvillehousing


---------------------------------------------------------------------------------------------


--Populate Property Address Data

Select  *
From Portfolio_project.dbo.nashvillehousing
--Where PropertyAddress is NULL
order by ParcelID

--using inner join  to complete missing entries


Update a 
SET PropertyAddress =  ISNULL(a.propertyaddress, b.propertyaddress)
From Portfolio_project.dbo.nashvillehousing a
Join Portfolio_project.dbo.nashvillehousing b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--code check

Select  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.propertyaddress)
From Portfolio_project.dbo.nashvillehousing a
Join Portfolio_project.dbo.nashvillehousing b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------------------------

--Breaking our Address into indvidual columns (Address, City, State)

Select PropertyAddress
From Portfolio_project.dbo.nashvillehousing


--splitting the street details and city into separate columns

--concept
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)   Address, 
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address 
From Portfolio_project.dbo.nashvillehousing

--altering the table
ALTER TABLE nashvillehousing
Add PropertySplitAddress Nvarchar (255),
PropertySplitCity Nvarchar (255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) ,
 PropertySplitCity =SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--code check

Select *
From Portfolio_project.dbo.nashvillehousing

--Another technique to split string to be used on Owner Address

Select OwnerAddress
From Portfolio_project.dbo.nashvillehousing


Select
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)
From Portfolio_project.dbo.nashvillehousing

--altering the table
ALTER TABLE nashvillehousing
Add OwnerSplitAddress Nvarchar (255),
 OwnerSplitCity Nvarchar (255),
 OwnerSplitState Nvarchar (255);


UPDATE nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3),
 OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2),
 OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)


--Code check

Select *
From Portfolio_project.dbo.nashvillehousing

------------------------------------------------------------------------------------------------------------------------------

---Changing Y and N to Yes and No in "Sold as Vacant" column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_project.dbo.nashvillehousing
Group by SoldAsVacant

--technique

Select SoldAsVacant,
CASE   when SoldAsVacant = 'Y' THEN 'Yes'
		    when SoldAsVacant = 'N' THEN 'No' 
			ELSE  SoldAsVacant
			END
From Portfolio_project.dbo.nashvillehousing

--updating the table

Update nashvillehousing
SET SoldAsVacant = CASE   when SoldAsVacant = 'Y' THEN 'Yes'
		    when SoldAsVacant = 'N' THEN 'No' 
			ELSE  SoldAsVacant
			END

--Code check
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_project.dbo.nashvillehousing
Group by SoldAsVacant



------------------------------------------------------------------------------------------------------------
--Remove Duplicates

WITH RowNumCTE AS( 
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, 
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY
							UniqueID
							) as row_num
From Portfolio_project.dbo.nashvillehousing
)
DELETE
From RowNumCTE
Where row_num > 1


--Code Check

WITH RowNumCTE AS( 
Select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, 
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY
							UniqueID
							) as row_num
From Portfolio_project.dbo.nashvillehousing
)
Select *
From RowNumCTE
Where row_num > 1


----------------------------------------------------------------------------------------------------------------------------

--Delete Unsued Columns


Select *
From Portfolio_project.dbo.nashvillehousing


ALTER TABLE Portfolio_project.dbo.nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolio_project.dbo.nashvillehousing
DROP COLUMN SaleDate
