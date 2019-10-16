--1. OrderSettings:
	INSERT INTO OrderSettings(Symbol, ExchangeId, RemoteSymbol, PriorityLevel, PriceDigits, QuantityDigits, MapSellOrder, MapBuyOrder, AllowImportRate
			, AllowFrozenRate, BuyMargin, SellMargin, QuantityPercentage, BuyRatio, SellRatio, BuyConvertRate, SellConvertRate, MapOrderOffset, PlaceOrderOffset, SecondOrderSymbol
			, Focus, FocusPercentage, IsActive, CreateDate, UpdateDate)
	VALUES ('USDT_HAIC', 16, '', 9, 3, 3, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, null, 5, 0.6, 1, GETDATE(), GETDATE())
	
--2. TradeSettings:
	DECLARE @TradingSettingId int
	INSERT INTO TradingSettings(PlatformId, Symbol, PriceDigits, QuantityDigits, AllowTrigger, AllowStopLoss, AllowTakeProfit, FeeAssetTypeId, MappingTypeId, MinTradeAmount
			, MinTradeAmountAssetTypeId, IsSuspend, IsActive, CreateDate, UpdateDate)
	VALUES(1, 'USDT_HAIC', 3, 3, 1, 1, 1, 15, 4, 15, 15, 0, 1, GETDATE(), GETDATE())

	SELECT @tradingSettingId = SCOPE_IDENTITY();

--3. TradingPackagesV1
	INSERT INTO tradingPackagesV1(PackageUID, TradingSettingId, TriggerCommission, StopLossCommission, TakeProfitCommission, TakerCommission, MakerCommission, IsActive, CreateDate, UpdateDate)
	SELECT PackageUID, @tradingSettingId, TriggerCommission, StopLossCommission, TakeProfitCommission, TakerCommission, MakerCommission, 1, GETDATE(), GETDATE()
	FROM tradingPackagesV1 p
	INNER JOIN tradingSettings t on  t.tradingSettingId = p.tradingSettingId
	WHERE Symbol = 'BTC_BEZ'
