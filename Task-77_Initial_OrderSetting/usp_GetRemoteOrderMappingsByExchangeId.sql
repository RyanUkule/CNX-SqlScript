USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetRemoteOrderMappingsByExchangeId]    Script Date: 2019/08/05 11:11:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		cyx
-- Create date: 2017-2-14 11:04:32
-- Modify date: 2017-2-14 11:04:32
-- Description:	usp_GetRemoteOrderMappingsByOrderId
-- =============================================
ALTER PROCEDURE [dbo].[usp_GetRemoteOrderMappingsByExchangeId] 
@exchangeSettingId int,
@orderType int,
@assetTypeId_A int,
@assetTypeId_B int
AS
BEGIN
	SELECT 
		m.[RemoteOrderMappingsId]
		,m.[OrderId]
		,m.[ExecutePrice]
		,m.[Quantity]
		,m.[RemoteExchangeId]
		,m.[RemoteOrderId]
		,m.[RemoteExecutePrice]
		,m.[RemoteExecuteQuantity]
		,m.[OrderTypeId]
		,m.[OfferAssetTypeId]
		,m.[WantAssetTypeId]
		,m.[RemoteOrderMappingStatusId]
		,m.[Message]
		,m.[InsertDate]
		,m.[UpdateDate]
	FROM RemoteOrderMappings m WITH (NOLOCK) 
	inner join OrderBook o WITH(NOLOCK)  on m.OrderId = o.OrderId
	WHERE 
	(	
		(m.WantAssetTypeId = @assetTypeId_A and m.OfferAssetTypeId = @assetTypeId_B)
		or 
		(m.OfferAssetTypeId = @assetTypeId_A and m.WantAssetTypeId = @assetTypeId_B)
	)
	and m.RemoteExchangeId = 
	(select ExchangeId from ExchangeSetting with(nolock) where ExchangeSettingId = @exchangeSettingId)
	and O.OrderStatusId = 2 
	and m.RemoteOrderMappingStatusId in (7, 8, 19, 20)
	and O.OrderTypeId = case when @orderType = -1 then O.OrderTypeId else @orderType end
	and O.IsTakeOrder <> 1
END