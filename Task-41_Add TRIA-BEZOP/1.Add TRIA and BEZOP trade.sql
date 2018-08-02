-- use CNX
-- --Add AssetType_lkp
	 -- INSERT INTO AssetType_lkp values('TRIA', '', 1, '{CacheName:''TRIAActiveOrder'',TRIASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:5,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)

	 -- INSERT INTO AssetType_lkp values('BEZ', '', 1, '{CacheName:''BEZActiveOrder'',BEZSPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:5,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)
	 
	 -- INSERT INTO AssetType_lkp values('SLRM', '', 1, '{CacheName:''SLRMActiveOrder'',SLRMSPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:5,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)
-- --Add balance for Users
-- exec usp_AddAssetBalanceForCustomer 30
-- exec usp_AddAssetBalanceForCustomer 31
-- exec usp_AddAssetBalanceForCustomer 32

--****** 1. TRIA *****
	--Add ExchangeSetting
	--BTC_TRIA
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 6, 0
		,'CNX_BTC_TRIA' AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_TRIA', 2, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16)

--****** 2. BEZ *****
	--Add ExchangeSetting
	--BTC_BEZ
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 8, 0
		,'CNX_BTC_BEZ' AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_BEZ', 2, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16)
	
--****** 2. SLRM *****
	--Add ExchangeSetting
	--BTC_SLRM
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 7, 0
		,'CNX_BTC_SLRM' AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_SLRM', 2, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16)
	
--Update Configuration
 
update Configuration set Value = Value + ',' + 'BTC_TRIA,BTC_BEZ,BTC_SLRM'
where SettingId = 1051	
