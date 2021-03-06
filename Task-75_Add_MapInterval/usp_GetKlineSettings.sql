USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetKlineSettings]    Script Date: 2019/07/18 14:50:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[usp_GetKlineSettings]
@platformId int = null,
@symbol nvarchar(20) = null,
@exchangeId int = null,
@isActive bit = null
as 
begin    
	select 
		k.KlineSettingId, 
		p.PlatformName,
		k.ExchangeId,
		T.Symbol as LocalSymbol,
		k.RemoteSymbol as RemoteSymbol,
		k.MinTradeVolume,
		k.MaxTradeVolume,
		k.MapChance,
		k.RoundVolumeChance,
		k.DigitsInterval,
		k.IsActive,
		k.CreateDate,
		k.UpdateDate
	from KlineSettings k with (nolock)
	inner join TradingSettings t with (nolock) on k.TradingSettingId = t.TradingSettingId
	inner join Platform_lkp p with (nolock) on t.PlatformId = p.PlatformId
	where
	(t.PlatformId = @platformId or @platformId is null)
	and (t.Symbol = @symbol or @symbol is null or @symbol = '' or t.Symbol like ('%' + @symbol + '%'))
	and (k.ExchangeId = @exchangeId or @exchangeId is null)
	and (k.IsActive = @isActive or @isActive is null)
end