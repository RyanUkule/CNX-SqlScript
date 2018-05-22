use CNX
--Add AssetType_lkp
	 INSERT INTO AssetType_lkp values('XLM', '', 1, '{CacheName:''XLMActiveOrder'',XLMSPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:32,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)

--Add balance for Users
exec usp_AddAssetBalanceForCustomer 29

--****** 1. XLM *****
	--Add ExchangeSetting
	--DRG_XLM
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 5, 29
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_XLM'
			ELSE 'BFX_XLM'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_XLM', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'DRG_ZEC' and ExchangeId in (16, 18)

	--USDT_XLM
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 3, 29
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_USDT_XLM'
			ELSE 'BFX_USDT_XLM'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_XLM', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_ZEC' and ExchangeId in (16, 18)

	--BTC_XLM
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 7, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_XLM'
			ELSE 'BFX_BTC_XLM'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_XLM', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)


--/**********
--	 BTC
--***********/	

-- 1. BTC-ETC
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 6, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_ETC'
			ELSE 'BFX_BTC_ETC'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_ETC', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)

-- 2. BTC-LTC
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 5, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_LTC'
			ELSE 'BFX_BTC_LTC'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_LTC', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)
-- 3. BTC-BTG
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 5, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_BTG'
			ELSE 'BFX_BTC_BTG'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_BTG', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)

-- 4. BTC-ZEC
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 4, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_ZEC'
			ELSE 'BFX_BTC_ZEC'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_ZEC', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)
	
--Update Configuration
 
update Configuration set Value = Value + ',' + 'DRG_XLM,USDT_XLM,BTC_XLM,BTC_ETC,BTC_LTC,BTC_BTG,BTC_ZEC'
where SettingId = 1051	
