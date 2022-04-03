-- Data Cleaning / ETL

-- check dataset
select *
from [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]

-- 1. standardize SaleDate format
-- check the original and convered format
select SaleDate, CONVERT(date, SaleDate) standardizedsaledate
from [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]

/*
update [Nashville Housing]
set SaleDate = CONVERT(date, SaleDate)
*/

-- directly convert the column SaleDate format to date
alter table [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
alter column SaleDate date


-- 2. populate Property Address data
-- find references for null values of PropertyAddress: when ParcelIDs are the same, PropertyAddress should be the same too
select *
from [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
-- where PropertyAddress is null
where ParcelID = '025 07 0 031.00'
order by UniqueID

-- SELF JOIN - use ParcelID as reference point to populate null values
update nh1
set PropertyAddress = ISNULL(nh1.PropertyAddress, nh2.PropertyAddress)
from [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing] nh1
join [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing] nh2
on nh1.ParcelID = nh2.ParcelID
and nh1.[UniqueID ] <> nh2.[UniqueID ]
where nh1.PropertyAddress is null

-- check if all null values have been populated
select nh1.PropertyAddress
from [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing] nh1
join [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing] nh2
on nh1.ParcelID = nh2.ParcelID
and nh1.[UniqueID ] <> nh2.[UniqueID ]
where nh1.PropertyAddress is null


-- 3. separate out PropertyAddress column to individual columns: street, city
select PropertyAddress, 
	substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) propertystreet, 
	substring(PropertyAddress, charindex(',', PropertyAddress)+2, len(PropertyAddress)-charindex(',', PropertyAddress)) propertycity
from [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]

-- create another 2 columns for street and city to replace the PropertyAddress column
alter table [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
add propertystreet nvarchar(255)

update [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
set propertystreet = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
add propertycity nvarchar(255)

update [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
set propertycity = substring(PropertyAddress, charindex(',', PropertyAddress)+2, len(PropertyAddress)-charindex(',', PropertyAddress))

-- check the updated table
select *
from [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]


-- 4. separate our the OwnerAddress column to individual columns: street, city, state
select OwnerAddress,
	PARSENAME(replace(OwnerAddress, ', ', '.'), 3) ownerstreet,
	PARSENAME(replace(OwnerAddress, ', ', '.'), 2) ownercity,
	PARSENAME(replace(OwnerAddress, ', ', '.'), 1) ownerstate
from [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]

alter table [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
add ownerstreet nvarchar(255)

update [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
set ownerstreet = PARSENAME(replace(OwnerAddress, ', ', '.'), 3)

alter table [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
add ownercity nvarchar(255)

update [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
set ownercity = PARSENAME(replace(OwnerAddress, ', ', '.'), 2)

alter table [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
add ownerstate nvarchar(255)

update [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
set ownerstate = PARSENAME(replace(OwnerAddress, ', ', '.'), 1)

-- check the updated table
select *
from [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]


-- 5. update SoldAsVacant column to a consistant format - Y & N to Yes & No
select distinct(SoldAsVacant), count(SoldAsVacant)
from [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
group by SoldAsVacant

update [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
set SoldAsVacant = 
	case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

-- check the updated table
select *
from [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]


-- 6. check if there're duplicate rows and delete
with cte1 as
(
select *,
ROW_NUMBER() over (partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference, OwnerName, OwnerAddress order by UniqueID) rownum
from [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
)
/*
select distinct(rownum), count(rownum)
from cte1
group by rownum
*/
delete
from cte1
where rownum = 2


-- 7. delete columns that not useful
alter table [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
drop column PropertyAddress, OwnerAddress, TaxDistrict

alter table [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]
drop column TaxDistrict

-- check the updated table
select *
from [Portfolio Project 2 - Data Cleaning].dbo.[NashvilleHousing]