use CNX
--Add AssetType_lkp
	-- INSERT INTO AssetType_lkp values('DASH', '', 1, '{CacheName:''DASHActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:0.02,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)
	-- INSERT INTO AssetType_lkp values('ZRX', '', 1, '{CacheName:''ZRXActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:6.0,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)
	-- INSERT INTO AssetType_lkp values('FUN', '', 1, '{CacheName:''FUNActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:76.0,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)
	-- INSERT INTO AssetType_lkp values('TNB', '', 1, '{CacheName:''TNBActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:70.0,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)
	-- INSERT INTO AssetType_lkp values('ETP', '', 1, '{CacheName:''ETPActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:4.0,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)


--Add balance for Users
exec usp_AddAssetBalanceForCustomer 16
exec usp_AddAssetBalanceForCustomer 17
exec usp_AddAssetBalanceForCustomer 18
exec usp_AddAssetBalanceForCustomer 19
exec usp_AddAssetBalanceForCustomer 20

--****** 1. DASH *****
	--Add ExchangeSetting
	--DRG_DASH
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 1, 16
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_DASH'
			ELSE 'BFX_DASH'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_DASH', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'DRG_ZEC' and ExchangeId in (16, 18)

	--USDT_DASH
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 0, 16
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_USDT_DASH'
			ELSE 'BFX_USDT_DASH'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_DASH', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_ZEC' and ExchangeId in (16, 18)

	--BTC_DASH
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 4, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_DASH'
			ELSE 'BFX_BTC_DASH'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_DASH', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)

--****** 2. ZRX *****
	--Add ExchangeSetting
	--DRG_ZRX
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 3, 17
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_ZRX'
			ELSE 'BFX_ZRX'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_ZRX', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'DRG_ZEC' and ExchangeId in (16, 18)

	--USDT_ZRX
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 2, 17
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_USDT_ZRX'
			ELSE 'BFX_USDT_ZRX'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_ZRX', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_ZEC' and ExchangeId in (16, 18)

	--BTC_ZRX
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 6, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_ZRX'
			ELSE 'BFX_BTC_ZRX'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_ZRX', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)
	
--****** 3. FUN *****
	--Add ExchangeSetting
	--DRG_FUN
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 4, 18
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_FUN'
			ELSE 'BFX_FUN'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_FUN', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'DRG_ZEC' and ExchangeId in (16, 18)

	--USDT_FUN
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 3, 18
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_USDT_FUN'
			ELSE 'BFX_USDT_FUN'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_FUN', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_ZEC' and ExchangeId in (16, 18)

	--BTC_FUN
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 7, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_FUN'
			ELSE 'BFX_BTC_FUN'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_FUN', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)
	
--****** 4. TNB *****
	--Add ExchangeSetting
	--DRG_TNB
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 4, 19
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_TNB'
			ELSE 'BFX_TNB'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_TNB', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'DRG_ZEC' and ExchangeId in (16, 18)

	--USDT_TNB
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 3, 19
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_USDT_TNB'
			ELSE 'BFX_USDT_TNB'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_TNB', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_ZEC' and ExchangeId in (16, 18)

	--BTC_TNB
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 7, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_TNB'
			ELSE 'BFX_BTC_TNB'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_TNB', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)

--****** 5. ETP *****
	--Add ExchangeSetting
	--DRG_ETP
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 3, 20
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_ETP'
			ELSE 'BFX_ETP'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_ETP', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'DRG_ZEC' and ExchangeId in (16, 18)

	--USDT_ETP
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 2, 20
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_USDT_ETP'
			ELSE 'BFX_USDT_ETP'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_ETP', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_ZEC' and ExchangeId in (16, 18)

	--BTC_ETP
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 6, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_ETP'
			ELSE 'BFX_BTC_ETP'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_ETP', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)
	
	