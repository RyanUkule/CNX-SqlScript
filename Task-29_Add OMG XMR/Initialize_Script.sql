use CNX
--Add AssetType_lkp
INSERT INTO AssetType_lkp values('OMG', '', 1, '{CacheName:''OMGActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:1,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)
INSERT INTO AssetType_lkp values('RCN', '', 1, '{CacheName:''RCNActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:0.06,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)
-- INSERT INTO AssetType_lkp values('XMR', '', 1, '{CacheName:''XMRActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:0.06,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)
INSERT INTO AssetType_lkp values('XRP', '', 1, '{CacheName:''XRPActiveOrder'',MOASPreferenceId:31,SLASPreferenceId:32,FloatMarketPrice:0.08,LimitAmount:1,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}', null, null)

	
--Add balance for Users
exec usp_AddAssetBalanceForCustomer 23
exec usp_AddAssetBalanceForCustomer 24
-- exec usp_AddAssetBalanceForCustomer 25
exec usp_AddAssetBalanceForCustomer 25

--****** 1. OMG *****
	--Add ExchangeSetting
	--DRG_OMG
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 3, 23
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_OMG'
			ELSE 'BFX_OMG'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_OMG', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'DRG_ETC' and ExchangeId in (16, 18)

	--USDT_OMG
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 2, 23
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_USDT_OMG'
			ELSE 'BFX_USDT_OMG'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_OMG', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_ETC' and ExchangeId in (16, 18)

	--BTC_OMG
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 5, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_OMG'
			ELSE 'BFX_BTC_OMG'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_OMG', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)
	
--****** 2. RCN *****
	--Add ExchangeSetting
	--DRG_RCN
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 4, 24
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_RCN'
			ELSE 'BFX_RCN'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_RCN', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'DRG_ZEC' and ExchangeId in (16, 18)

	--USDT_RCN
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 4, 24
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_USDT_RCN'
			ELSE 'BFX_USDT_RCN'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_RCN', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_ZEC' and ExchangeId in (16, 18)

	--BTC_RCN
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 7, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_RCN'
			ELSE 'BFX_BTC_RCN'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_RCN', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)

-- --****** 3. XMR *****
	-- --Add ExchangeSetting
	-- --DRG_XMR
	-- INSERT INTO ExchangeSetting
	-- SELECT 	
		-- ExchangeId, 1, 25
		-- ,CASE WHEN ExchangeId = 16
			-- THEN 'CNX_XMR'
			-- ELSE 'BFX_XMR'
		 -- END AS SettingName
		-- ,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		-- , BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_XMR', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		-- ,CASE WHEN ExchangeId = 16
			-- THEN 20
			-- ELSE null
		 -- END MinOrderQuantity
	-- FROM ExchangeSetting
	-- WHERE Symbol = 'DRG_ZEC' and ExchangeId in (16, 18)

	-- --USDT_XMR
	-- INSERT INTO ExchangeSetting
	-- SELECT 
		-- ExchangeId, 0, 25
		-- ,CASE WHEN ExchangeId = 16
			-- THEN 'CNX_USDT_XMR'
			-- ELSE 'BFX_USDT_XMR'
		 -- END AS SettingName
		-- ,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		-- , BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_XMR', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		-- ,CASE WHEN ExchangeId = 16
			-- THEN 20
			-- ELSE null
		 -- END MinOrderQuantity
	-- FROM ExchangeSetting
	-- WHERE Symbol = 'USDT_ZEC' and ExchangeId in (16, 18)

	-- --BTC_XMR
	-- INSERT INTO ExchangeSetting
	-- SELECT 
		-- ExchangeId, 4, 0
		-- ,CASE WHEN ExchangeId = 16
			-- THEN 'CNX_BTC_XMR'
			-- ELSE 'BFX_BTC_XMR'
		 -- END AS SettingName
		-- ,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		-- , BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_XMR', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		-- ,CASE WHEN ExchangeId = 16
			-- THEN 20
			-- ELSE null
		 -- END MinOrderQuantity
	-- FROM ExchangeSetting
	-- WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)
	
--****** 4. XRP *****
	--Add ExchangeSetting
	--DRG_XRP
	INSERT INTO ExchangeSetting
	SELECT 	
		ExchangeId, 4, 25
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_XRP'
			ELSE 'BFX_XRP'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'DRG_XRP', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'DRG_ZEC' and ExchangeId in (16, 18)

	--USDT_XRP
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 3, 25
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_USDT_XRP'
			ELSE 'BFX_USDT_XRP'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_XRP', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'USDT_ZEC' and ExchangeId in (16, 18)

	--BTC_XRP
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 7, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_XRP'
			ELSE 'BFX_BTC_XRP'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_XRP', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)
	
--/**********
--	 BTC
--***********/	

-- 1. BTC-ETC
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 7, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_ETC'
			ELSE 'BFX_BTC_ETC'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_ETC', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)

-- 2. BTC-LTC
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 7, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_LTC'
			ELSE 'BFX_BTC_LTC'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_LTC', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)
-- 3. BTC-BTG
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 7, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_BTG'
			ELSE 'BFX_BTC_BTG'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_BTG', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)

-- 4. BTC-ZEC
	INSERT INTO ExchangeSetting
	SELECT 
		ExchangeId, 7, 0
		,CASE WHEN ExchangeId = 16
			THEN 'CNX_BTC_ZEC'
			ELSE 'BFX_BTC_ZEC'
		 END AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'BTC_ZEC', QuantityDigit, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume
		,CASE WHEN ExchangeId = 16
			THEN 20
			ELSE null
		 END MinOrderQuantity
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_BCC' and ExchangeId in (16, 18)




	