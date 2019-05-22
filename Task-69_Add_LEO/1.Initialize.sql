use CNX
GO
--1. AssetType: UCAD
	SET identity_insert assetType_lkp ON
		 INSERT INTO AssetType_lkp (AssetTypeId, Name, Symbol, IsActive, Info, NameBlurb, Block, ReferAssetTypeId, Circulation)
		 values(48, 'LEO', '', 1, '{CacheName:''LEOActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:5,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', '22167',
		 null, null, null)
	SET identity_insert assetType_lkp OFF
	
	--Add balance for Users
	exec usp_AddAssetBalanceForCustomer 48
GO
--2. ExchangeSetting: 
	--USDT_LEO
	insert into exchangesetting (exchangeid, digits, assettypeid, settingname, sellordermapping, buyordermapping, maporderoffset, placeorderoffset
			, allowfrozenrate, allowimportrate, ranklevel, active, updatedate, buyratio, sellratio, buymargin, sellmargin, symbol, quantitydigit
			, buyconvertrate, sellconvertrate, minontradevolume, maxontradevolume, quantitypercentage, commissionassettypeid)
	select 
		case when ExchangeId = 16 
			then 16
			else 18 end as ExchangeId
		, 3, 48
		, case when ExchangeId = 16 
			then 'CNX_USDT_LEO'
			else 'BF_UST_LEO' end AS SettingName
		, sellordermapping, buyordermapping, maporderoffset, placeorderoffset, allowfrozenrate, allowimportrate, ranklevel, 1, getdate()
		, buyratio, sellratio, buymargin, sellmargin, 'USDT_LEO', 2, buyconvertrate, sellconvertrate, minontradevolume, maxontradevolume
		, quantitypercentage, 15
	from exchangesetting
	where symbol = 'USDT_ZEC'
	
	--BTC_LEO
	INSERT INTO ExchangeSetting (ExchangeId, digits, AssetTypeId, SettingName, SellORderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset
			, AllowFrozenRate, AllowImportRate, RankLevel, Active, UpdateDate, BuyRatio, SellRatio, BuyMargin, SellMargin, Symbol, QuantityDigit
			, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume, QuantityPercentage, CommissionAssetTypeId)
	SELECT 
		case when ExchangeId = 16 
			then 16
			else 18 end as ExchangeId
		, 7, 2
		, case when ExchangeId = 16 
			then 'CNX_BTC_LEO'
			else 'BF_BTC_LEO' end AS SettingName
		, SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_LEO', 2, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		, QuantityPercentage, 47
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_ZEC' and ExchangeId in (16, 18)
	
GO
--4.Configuration: AllowCurrencyConversion、TradingCurrency
	
	UPDATE Configuration SET Value = Value + ',BTC_LEO,USDT_LEO' WHERE Name = 'AllowCurrencyConversion'	
	UPDATE Configuration SET Value = Value + ',BTC_LEO,USDT_LEO' WHERE Name = 'TradingCurrency'
	
	UPDATE Configuration SET Value = 'BTC_SKY,PAX_SKY,USDT_SKY' WHERE Name = 'NoNeedMappingsSymbols'
	




