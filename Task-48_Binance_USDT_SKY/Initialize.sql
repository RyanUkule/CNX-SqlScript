USE CNX
GO
--Binance USDT_SKY
	INSERT INTO ExchangeSetting
	SELECT 
		30, 1, 7
		,'Binance_USDT_SKY' AS SettingName
		,SellOrderMapping, BuyOrderMapping, MapOrderOffset, PlaceOrderOffset, AllowFrozenRate, AllowImportRate, 0, 1, GETDATE()
		, BuyRatio, SellRatio, BuyMargin, SellMargin, 'USDT_SKY', 2, BuyConvertRate, SellConvertRate, MinOnTradeVolume, MaxOnTradeVolume, 1
	FROM ExchangeSetting
	WHERE Symbol = 'BTC_SKY' and ExchangeId = 30
	
--Configuration
	UPDATE Configuration set Value = Value + ',USDT_SKY' where SettingId = 1068
	
	INSERT INTO Configuration values('TransferTradeCustomerId', 9750, 'System customerId for transfer trade. such as USDT_SKY for binance.', null, GETDATE(), GETDATE(), GETDATE())