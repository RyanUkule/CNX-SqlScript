
insert into AssetType_lkp values ('DRG', N'∂', 1 ,null, null, 200)

insert into tradingpackages
select PackageUId, 11, Name, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 'CNY_DRG'
from tradingpackages where AssetTypeId = 1 and IsActive = 1

--Add assetBalance of DRG for each customer
exec usp_AddAssetBalanceForCustomer 11

--Add exchangeSetting of DRG 
INSERT INTO ExchangeSetting 
SELECT ExchangeId, digits, AssetTypeId, SettingName, SellOrderMapping, BuyOrderMapping, MapOrderOffset,PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, Active, GETDATE(),BuyRatio,SellRatio,
	   BuyMargin, SellMargin, REPLACE(Symbol,'CNY', 'DRG'), QuantityDigit, BuyConvertRate, SellConvertRate
from ExchangeSetting where Symbol like 'CNY%' and Active = 1

--inactive CNY exchangeSettings
UPDATE ExchangeSetting
SET ACTIVE = 0
where Symbol like 'CNY%' and Active = 1

--Update Configuration "AllowCurrentcyConversion"
update Configuration set Value = 'DRG_BTC,DRG_ETH,DRG_ETC,DRG_SKY,DRG_BCC,BTC_BCC,BTC_SKY,ETH_BTC,ETH_SKY'
where Name = 'AllowCurrencyConversion'

