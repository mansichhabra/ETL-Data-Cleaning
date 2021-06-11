--Cleaning Data In SQL Queries
select * 
from PortfolioProject.dbo.NashvilleHousing

--Standardize date format
select SaleDate, convert(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject..NashvilleHousing
set SaleDate = convert(date, SaleDate)

Alter Table PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

update PortfolioProject..NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing
----------------------------------------------------------
--Populate property Address Data

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
--where PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------
--Breaking out address into individual columns (Address,City,State)

select PropertyAddress,PropertySplitAddress,PropertySplitCity
from PortfolioProject.dbo.NashvilleHousing

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
       SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as city

from PortfolioProject.dbo.NashvilleHousing

select SUBSTRING(PropertyAddress,2,CHARINDEX(',',PropertyAddress)) as city
from PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

select PARSENAME(replace(OwnerAddress,',','.'),3) as address,
PARSENAME(replace(OwnerAddress,',','.'),2) as city,
PARSENAME(replace(OwnerAddress,',','.'),1) as state
from PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);


update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

update PortfolioProject..NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

	select OwnerAddress,OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
	from PortfolioProject.dbo.NashvilleHousing
-----------------------------------------------------------------------
--Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct SoldAsVacant, COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' Then 'YES'
     when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 End
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'YES'
     when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 End

------------------------------------------------------------
--Remove Duplicates

with RowNumCTE As(
select *,
ROW_NUMBER() over(partition by PARCELID, 
							   PropertyAddress, 
							   SalePrice, 
							   SaleDate, 
							   legalReference
							   order by uniqueID)Row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select * from RowNumCTE
where row_num >1
order by PropertyAddress
---------------------------------------------------------
--Delete unused Columns

select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column owneraddress, taxdistrict,propertyaddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column saledate