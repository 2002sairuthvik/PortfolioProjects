/*
Data Cleaning
*/

select SaleDateConverted, CONVERT(date,SaleDate)
from Portfolioprojects.dbo.NashvilleHousing


update NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

--Drop SaleDateCoverted
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


------------------------------------------------------

--Populate Property Address Data

select PropertyAddress
from Portfolioprojects.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress , b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolioprojects..NashvilleHousing a
join Portfolioprojects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL



update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolioprojects..NashvilleHousing a
join Portfolioprojects..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

-----------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from Portfolioprojects..NashvilleHousing


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from Portfolioprojects..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from Portfolioprojects..NashvilleHousing




select OwnerAddress
from Portfolioprojects..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Portfolioprojects..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from Portfolioprojects..NashvilleHousing

-----------------------------------------------------------------------------

--Change from Y and N to Yes and No in "Sold as Vacant" field
select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from Portfolioprojects..NashvilleHousing
Group by SoldAsVacant
Order by 2



select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   END		 
from Portfolioprojects..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   END	

----------------------------------------------------------------


--Remove Duplicates 

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress, 
	SalePrice, 
	SaleDate ,
	LegalReference
	ORDER BY 
		UniqueID
		) row_num
from Portfolioprojects..NashvilleHousing
)
--DELETE used to delete duplicates
select *
from RowNumCTE
where row_num>1


--order by PropertyAddress

--------------------------------------------------------------------

--Delete Unused Columns	
select *
from Portfolioprojects..NashvilleHousing


ALTER TABLE Portfolioprojects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolioprojects..NashvilleHousing
DROP COLUMN SaleDate
