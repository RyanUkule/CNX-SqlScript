 USE CNX 
 INSERT INTO AssetType_lkp values ('USDT', '$', 1, '{CacheName:'''',MOASPreferenceId:0,SLASPreferenceId:0,FloatMarketPrice:1,LimitAmount:0.01,Model:1,Focus:0,FocusPercentage:0, LimitPriceDigit:0,MinBlock:1,BlockRequest:0}', null, null)
 
 UPDATE AssetType_lkp set Info = '{CacheName:''ETCActiveOrder'',MOASPreferenceId:33,SLASPreferenceId:34,FloatMarketPrice:0.08,LimitAmount:1,Model:2,Focus:5,FocusPercentage:0.6,MinBlock:1,BlockRequest:50}'
 WHERE AssetTypeId = 6
 
 --1. USDT_BTC
 INSERT INTO ExchangeSetting 
 SELECT ExchangeId, -1, AssetTypeId
		, CASE ExchangeId 
			WHEN 16 THEN 'CNX_USDT_BTC'
			WHEN 18 THEN 'Bitfinex_USDT_BTC'
		  END
		, SellOrderMapping, BuyOrderMapping, 0, 0
		, CASE ExchangeId 
			WHEN 16 THEN 1
			WHEN 18 THEN 0.6
		  END AllowFrozenRate
		, CASE ExchangeId 
			WHEN 16 THEN 1
			WHEN 18 THEN 0.8
		  END AllowImportRate
		, RankLevel, 1, GETDATE()
		, CASE ExchangeId 
			WHEN 16 THEN 0
			WHEN 18 THEN 0.001
		  END BuyRatio
		, CASE ExchangeId 
			WHEN 16 THEN 0
			WHEN 18 THEN 0.001
		  END SellRatio
		, BuyMargin, SellMargin, REPLACE(Symbol, 'DRG', 'USDT'), QuantityDigit, 1, 1
 FROM ExchangeSetting
 WHERE Symbol = 'DRG_BTC' AND ExchangeId in (16, 18)
 
 --2. USDT_BCC
 INSERT INTO ExchangeSetting 
 SELECT ExchangeId, 0, AssetTypeId
		, CASE ExchangeId 
			WHEN 16 THEN 'CNX_USDT_BCC'
			WHEN 18 THEN 'Bitfinex_USDT_BCC'
		  END
		, SellOrderMapping, BuyOrderMapping, 0, 0
		, CASE ExchangeId 
			WHEN 16 THEN 1
			WHEN 18 THEN 0.6
		  END AllowFrozenRate
		, CASE ExchangeId 
			WHEN 16 THEN 1
			WHEN 18 THEN 0.8
		  END AllowImportRate
		, RankLevel, 1, GETDATE()
		, CASE ExchangeId 
			WHEN 16 THEN 0
			WHEN 18 THEN 0.001
		  END BuyRatio
		, CASE ExchangeId 
			WHEN 16 THEN 0
			WHEN 18 THEN 0.001
		  END SellRatio
		, BuyMargin, SellMargin, REPLACE(Symbol, 'DRG', 'USDT'), QuantityDigit, 1, 1
 FROM ExchangeSetting
 WHERE Symbol = 'DRG_BCC' AND ExchangeId in (16, 18)
 
 --3. USDT_BTG
 INSERT INTO ExchangeSetting 
 SELECT ExchangeId, 1, AssetTypeId
		, CASE ExchangeId 
			WHEN 16 THEN 'CNX_USDT_BTG'
			WHEN 18 THEN 'Bitfinex_USDT_BTG'
		  END
		, SellOrderMapping, BuyOrderMapping, 0, 0
		, CASE ExchangeId 
			WHEN 16 THEN 1
			WHEN 18 THEN 0.6
		  END AllowFrozenRate
		, CASE ExchangeId 
			WHEN 16 THEN 1
			WHEN 18 THEN 0.8
		  END AllowImportRate
		, RankLevel, 1, GETDATE()
		, CASE ExchangeId 
			WHEN 16 THEN 0
			WHEN 18 THEN 0.001
		  END BuyRatio
		, CASE ExchangeId 
			WHEN 16 THEN 0
			WHEN 18 THEN 0.001
		  END SellRatio
		, BuyMargin, SellMargin, REPLACE(Symbol, 'DRG', 'USDT'), QuantityDigit, 1, 1
 FROM ExchangeSetting
 WHERE Symbol = 'DRG_BTG' AND ExchangeId in (16, 18)
 
 --4. USDT_ETH
 INSERT INTO ExchangeSetting 
 SELECT ExchangeId, 1, AssetTypeId
		, CASE ExchangeId 
			WHEN 16 THEN 'CNX_USDT_ETH'
			WHEN 18 THEN 'Bitfinex_USDT_ETH'
		  END
		, SellOrderMapping, BuyOrderMapping, 0, 0
		, CASE ExchangeId 
			WHEN 16 THEN 1
			WHEN 18 THEN 0.6
		  END AllowFrozenRate
		, CASE ExchangeId 
			WHEN 16 THEN 1
			WHEN 18 THEN 0.8
		  END AllowImportRate
		, RankLevel, 1, GETDATE()
		, CASE ExchangeId 
			WHEN 16 THEN 0
			WHEN 18 THEN 0.001
		  END BuyRatio
		, CASE ExchangeId 
			WHEN 16 THEN 0
			WHEN 18 THEN 0.001
		  END SellRatio
		, BuyMargin, SellMargin, REPLACE(Symbol, 'DRG', 'USDT'), QuantityDigit, 1, 1
 FROM ExchangeSetting
 WHERE Symbol = 'DRG_ETH' AND ExchangeId in (16, 18)
 
 --5. USDT_ETC
 INSERT INTO ExchangeSetting 
 SELECT ExchangeId, 2, AssetTypeId
		, CASE ExchangeId 
			WHEN 16 THEN 'CNX_USDT_ETC'
			WHEN 18 THEN 'Bitfinex_USDT_ETC'
		  END
		, SellOrderMapping, BuyOrderMapping, 0, 0
		, CASE ExchangeId 
			WHEN 16 THEN 1
			WHEN 18 THEN 0.6
		  END AllowFrozenRate
		, CASE ExchangeId 
			WHEN 16 THEN 1
			WHEN 18 THEN 0.8
		  END AllowImportRate
		, RankLevel, 1, GETDATE()
		, CASE ExchangeId 
			WHEN 16 THEN 0
			WHEN 18 THEN 0.001
		  END BuyRatio
		, CASE ExchangeId 
			WHEN 16 THEN 0
			WHEN 18 THEN 0.001
		  END SellRatio
		, BuyMargin, SellMargin, REPLACE(Symbol, 'DRG', 'USDT'), QuantityDigit, 1, 1
 FROM ExchangeSetting
 WHERE Symbol = 'DRG_ETC' AND ExchangeId in (16, 18)
 
 -- --6. USDT_ZEC
 -- INSERT INTO ExchangeSetting 
 -- SELECT ExchangeId, 0, AssetTypeId
		-- , CASE ExchangeId 
			-- WHEN 16 THEN 'CNX_USDT_ZEC'
			-- WHEN 18 THEN 'Bitfinex_USDT_ZEC'
		  -- END
		-- , SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE(), BuyRatio, SellRatio
		-- , BuyMargin, SellMargin, REPLACE(Symbol, 'DRG', 'USDT'), QuantityDigit, 1, 1
 -- FROM ExchangeSetting
 -- WHERE Symbol = 'DRG_ZEC' AND ExchangeId in (16, 18)
 
 --7. BTC_ETH
 INSERT INTO ExchangeSetting 
 SELECT ExchangeId, 3, AssetTypeId, SettingName
		, SellOrderMapping, BuyOrderMapping, 0, 0
		, CASE ExchangeId 
			WHEN 16 THEN 1
			WHEN 18 THEN 0.6
		  END AllowFrozenRate
		, CASE ExchangeId 
			WHEN 16 THEN 1
			WHEN 18 THEN 0.8
		  END AllowImportRate
		, RankLevel, 1, GETDATE()
		, CASE ExchangeId 
			WHEN 16 THEN 0
			WHEN 18 THEN 0.001
		  END BuyRatio
		, CASE ExchangeId 
			WHEN 16 THEN 0
			WHEN 18 THEN 0.001
		  END SellRatio
	    , BuyMargin, SellMargin, 'BTC_ETH', 2, 1, 1
 FROM ExchangeSetting
 WHERE Symbol = 'ETH_BTC' AND ExchangeId in (16, 18)
 
 -- --8. BTC_ETC
 -- INSERT INTO ExchangeSetting 
 -- SELECT ExchangeId, 5, AssetTypeId, REPLACE(SettingName,'ETH','ETC')
		-- , SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE(), BuyRatio, SellRatio
		-- , BuyMargin, SellMargin, 'BTC_ETC', QuantityDigit, 1, 1
 -- FROM ExchangeSetting
 -- WHERE Symbol = 'ETH_BTC' AND ExchangeId in (16, 18)
 
 -- -- --9. BTC_ZEC
 -- INSERT INTO ExchangeSetting 
 -- SELECT ExchangeId, 3, AssetTypeId, REPLACE(SettingName,'ETH','ZEC')
		-- , SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE(), BuyRatio, SellRatio
		-- , BuyMargin, SellMargin, 'BTC_ZEC', QuantityDigit, 1, 1
 -- FROM ExchangeSetting
 -- WHERE Symbol = 'ETH_BTC' AND ExchangeId in (16, 18)
 
 -- --10. USDT_LTC
  -- INSERT INTO ExchangeSetting 
  -- SELECT ExchangeId, 1, 3
		-- , CASE ExchangeId 
			-- WHEN 16 THEN 'CNX_USDT_LTC'
			-- WHEN 18 THEN 'Bitfinex_USDT_LTC'
		  -- END
		-- , SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE(), BuyRatio, SellRatio
		-- , BuyMargin, SellMargin, 'USDT_LTC', QuantityDigit, 1, 1
 -- FROM ExchangeSetting
 -- WHERE Symbol = 'DRG_ZEC' AND ExchangeId in (16, 18)
 
--11. USDT_SKY
 INSERT INTO ExchangeSetting 
 SELECT 16, 1, 7, 'CNX_USDT_SKY'
		, SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE(), 0, 0
		, BuyMargin, SellMargin, 'USDT_SKY', QuantityDigit, 0.01, 0.01
 FROM ExchangeSetting
 WHERE Symbol = 'DRG_SKY'
 
 --12. USDT_DRG
 INSERT INTO ExchangeSetting 
 SELECT 16, 1, 15, 'CNX_USDT'
		, SellOrderMapping, BuyOrderMapping, 0, 0
		, CASE ExchangeId 
			WHEN 16 THEN 1
			WHEN 18 THEN 0.6
		  END AllowFrozenRate
		, CASE ExchangeId 
			WHEN 16 THEN 1
			WHEN 18 THEN 0.8
		  END AllowImportRate
		, RankLevel, 1, GETDATE()
		, CASE ExchangeId 
			WHEN 16 THEN 0
			WHEN 18 THEN 0.001
		  END BuyRatio
		, CASE ExchangeId 
			WHEN 16 THEN 0
			WHEN 18 THEN 0.001
		  END SellRatio
		, BuyMargin, SellMargin, 'USDT_DRG', QuantityDigit, 1, 1
 FROM ExchangeSetting
 WHERE Symbol = 'DRG_BTG' and exchangeid = 16
 
 
 -- --13. DRG_LTC
 -- INSERT INTO ExchangeSetting 
 -- SELECT 16, 0, 3, 'CNX_LTC'
		-- , SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE(), BuyRatio, SellRatio
		-- , BuyMargin, SellMargin, 'DRG_LTC', QuantityDigit, 1, 1
 -- FROM ExchangeSetting
 -- WHERE Symbol = 'DRG_SKY' and exchangeid = 16
 
 -- --14. DRG_ZEC
 -- INSERT INTO ExchangeSetting 
 -- SELECT 16, 1, 10, 'CNX_ZEC'
		-- , SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE(), BuyRatio, SellRatio
		-- , BuyMargin, SellMargin, 'DRG_ZEC', QuantityDigit, 1, 1
 -- FROM ExchangeSetting
 -- WHERE Symbol = 'DRG_SKY' and exchangeid = 16
 
 -- --============
 
 -- --15.BTC_LTC
 -- INSERT INTO ExchangeSetting 
 -- SELECT ExchangeId, 5, 3, REPLACE(SettingName, 'BCC', 'LTC')
		-- , SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, RankLevel, 1, GETDATE(), BuyRatio, SellRatio
		-- , BuyMargin, SellMargin, REPLACE(Symbol, 'BCC', 'LTC'), QuantityDigit, 1, 1
 -- FROM ExchangeSetting
 -- WHERE Symbol = 'BTC_BCC' and ExchangeId in (16,18)
 
 
 