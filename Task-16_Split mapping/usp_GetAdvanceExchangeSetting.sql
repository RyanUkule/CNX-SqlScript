USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetAdvanceExchangeSetting]    Script Date: 2017/09/07 15:41:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_GetAdvanceExchangeSetting]  
AS  
BEGIN 
	select 
		[AdvanceExchangeSettingId],
		[ExchangeSettingId],
		[BuyoffsetFormula],
		[SelloffsetFormula],
		[AllowTransfer]
		[TransferAssetTypeId]
	from [AdvanceExchangeSetting]
END
