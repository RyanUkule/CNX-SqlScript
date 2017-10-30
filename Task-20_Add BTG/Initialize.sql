--Add ExchangeSetting
INSERT INTO ExchangeSetting
SELECT ExchangeId, Digits, 13, REPLACE(SettingName, 'BTC', 'BTG'), SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset
	  ,AllowFrozenRate, AllowImportRate, RankLevel, Active, GETDATE(), BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_BTG', QuantityDigit, BuyConvertRate, SellConvertRate
FROM exchangesetting 
WHERE active = 1 AND symbol = 'DRG_BTC'

-- Add AssetType_lkp 
UPDATE assettype_lkp SET Info = '{CacheName:'''',MOASPreferenceId:11,SLASPreferenceId:12,FloatMarketPrice:0.08,LimitAmount:0.01,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:0}'
WHERE AssetTypeId = 13

--Add AssetBalance 
INSERT INTO AssetBalance(CustomerId, AssetTypeId, Balance, FrozenBalance, UpdateDate, InsertDate, SaveDate, Locked, [Hash])
VALUES (2, 13, 0, 0, getdate(), getdate(), getdate(), 0, '')

--Add balance for each customer
INSERT INTO AssetBalance(CustomerId, AssetTypeId, Balance, FrozenBalance, UpdateDate, InsertDate, SaveDate, Locked, [Hash])
SELECT CustomerId, 13, 0, 0, getdate(), getdate(), getdate(), 0, ''
FROM AssetBalance
WHERE CustomerId not in (SELECT CustomerId FROM AssetBalance WITH(NOLOCK) WHERE AssetTypeId = 13)
GROUP BY customerid

INSERT INTO tradingpackages
SELECT PackageUId, 13, Name, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 'DRG_BTG'
FROM tradingpackages WHERE AssetTypeId = 2 AND IsActive = 1