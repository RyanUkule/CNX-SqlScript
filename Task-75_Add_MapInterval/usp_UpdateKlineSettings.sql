USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateKlineSettings]    Script Date: 2019/07/18 14:53:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[usp_UpdateKlineSettings]
@klineSettingId int,
--@tradingSettingId int = null,
@exchangeId int = null,
@remoteSymbol nvarchar(20) = null,
@minTradeVolume decimal(4, 1) = null,
@maxTradeVolume decimal(4, 1) = null,
@mapChance decimal(4, 1) = null,
@roundVolumeChance int = null,
@digitsInterval nvarchar(10) = null,
@referklineSettingId int = null,
@isActive bit = null
as 
begin    
	update KlineSettings
	set
	--TradingSettingId = case when @tradingSettingId is null then TradingSettingId else @tradingSettingId end,
	ExchangeId = case when @exchangeId is null then ExchangeId else @exchangeId end,
	RemoteSymbol = case when @remoteSymbol is null then RemoteSymbol else @remoteSymbol end,
	MinTradeVolume = case when @minTradeVolume is null then MinTradeVolume else @minTradeVolume end,
	MaxTradeVolume = case when @maxTradeVolume is null then MaxTradeVolume else @maxTradeVolume end,
	MapChance = case when @mapChance is null then MapChance else @mapChance end,
	RoundVolumeChance = case when @roundVolumeChance is null then RoundVolumeChance else @roundVolumeChance end,
	DigitsInterval = case when @digitsInterval is null then DigitsInterval else @digitsInterval end,
	ReferKlineSettingid = case when @referklineSettingId is null then ReferKlineSettingid else @referklineSettingId end,
	IsActive = case when @isActive is null then IsActive else @isActive end,
	UpdateDate = getdate()
	where KlineSettingId = @klineSettingId
end