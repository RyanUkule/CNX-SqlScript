use CNX
go
insert into ExchangeSetting
select ExchangeId, digits, AssetTypeId, 'BFX_CNY_ZEC',SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel,Active, GETDATE(), BuyRatio,SellRatio
	   , BuyMargin, SellMargin, 'CNY_ZEC', QuantityDigit, BuyConvertRate, SellConvertRate
from ExchangeSetting where ExchangeId = 18 and symbol = 'CNY_BCC'