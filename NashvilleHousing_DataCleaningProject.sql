select *
from PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------

-- standardize date format

select SaleDateConverted, convert(Date, SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = convert(Date, SaleDate)

alter table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate)


----------------------------------------------------------------------------------------------


-- Populate property address data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
   on a.ParcelID = b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
   on a.ParcelID = b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


----------------------------------------------------------------------------------------------


-- Breaking out address into indivisual columns (address, city, state)

select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from PortfolioProject..NashvilleHousing

select OwnerAddress
from PortfolioProject..NashvilleHousing

select PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)



----------------------------------------------------------------------------------------------


-- change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
     WHEN SoldAsVacant ='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
     WHEN SoldAsVacant ='N' THEN 'No'
	 ELSE SoldAsVacant
	 END



----------------------------------------------------------------------------------------------


-- remove duplicates
WITH RowNumCTE AS (
select *,
       ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY UniqueID) row_num

from PortfolioProject..NashvilleHousing)
-- order by ParcelID

select *
from RowNumCTE
where row_num >1
--order by PropertyAddress



----------------------------------------------------------------------------------------------


-- delete unused columns

select *
from PortfolioProject..NashvilleHousing


alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

