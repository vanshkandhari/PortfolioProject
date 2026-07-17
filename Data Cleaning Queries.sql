--Cleaning data using sql queries

select * from PortfolioProject..NashilleHousing

--Standardize date format

select SaleDateConverted, CONVERT(date,saledate)
from PortfolioProject..NashilleHousing

update PortfolioProject..NashilleHousing
set saledate = CONVERT(date,saledate)

Alter table PortfolioProject..NashilleHousing
add SaleDateConverted date;

update PortfolioProject..NashilleHousing
set SaleDateConverted = CONVERT(date,saledate)

--Populate Property Address data

select * 
from PortfolioProject..NashilleHousing
--where PropertyAddress is null
order by ParcelID

select Nas.ParcelID, Nas.PropertyAddress, Hou.ParcelID, Hou.PropertyAddress, ISNULL(Nas.PropertyAddress, Hou.PropertyAddress)
from PortfolioProject..NashilleHousing Nas 
join PortfolioProject..NashilleHousing Hou on
Nas.ParcelID = Hou.ParcelID
and Nas.[UniqueID ] <> Hou.[UniqueID ]
where Nas.PropertyAddress is null

update Nas
set PropertyAddress = ISNULL(Nas.PropertyAddress, Hou.PropertyAddress)
from PortfolioProject..NashilleHousing Nas 
join PortfolioProject..NashilleHousing Hou on
Nas.ParcelID = Hou.ParcelID
and Nas.[UniqueID ] <> Hou.[UniqueID ]
where Nas.PropertyAddress is null

--Breaking out Address into individual Columns 

select PropertyAddress 
from PortfolioProject..NashilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as Address ,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as City
from PortfolioProject..NashilleHousing

Alter table PortfolioProject..NashilleHousing
add Property_Address nvarchar(255);

update PortfolioProject..NashilleHousing
set Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

Alter table PortfolioProject..NashilleHousing
add City nvarchar(255);

update PortfolioProject..NashilleHousing
set City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))

select * from PortfolioProject..NashilleHousing


select OwnerAddress
from PortfolioProject..NashilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from PortfolioProject..NashilleHousing

Alter table PortfolioProject..NashilleHousing
add Owner_Address nvarchar(255);

update PortfolioProject..NashilleHousing
set Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

Alter table PortfolioProject..NashilleHousing
add OwnerCity nvarchar(255);

update PortfolioProject..NashilleHousing
set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

Alter table PortfolioProject..NashilleHousing
add OwnerState nvarchar(255);

update PortfolioProject..NashilleHousing
set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

select * from PortfolioProject..NashilleHousing

--Change Y and N to Yes and No in "Sold as vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant) as Count
from PortfolioProject..NashilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	END
from PortfolioProject..NashilleHousing

update PortfolioProject..NashilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	END

-- Remove Duplicates

with DuplicateCTE AS (
select *,
ROW_NUMBER() OVER(
partition by ParcelId, PropertyAddress, SaleDate, LegalReference, SalePrice
order by uniqueId) row_num

from PortfolioProject..NashilleHousing
)

select * from DuplicateCTE
where row_num > 1
order by Property_Address

--Delete  from DuplicateCTE
--where row_num > 1
--order by Property_Address

select * from PortfolioProject.dbo.NashilleHousing

--Delete unused Column

Alter table PortfolioProject..NashilleHousing
drop COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict