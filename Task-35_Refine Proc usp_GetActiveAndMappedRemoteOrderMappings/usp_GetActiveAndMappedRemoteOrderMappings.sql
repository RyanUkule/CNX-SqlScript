USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetActiveAndMappedRemoteOrderMappings]    Script Date: 2018/04/27 10:53:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_GetActiveAndMappedRemoteOrderMappings]
AS
BEGIN
	SELECT r.OrderId,
		   r.[RemoteOrderMappingsId],
		   r.[ExecutePrice],
		   r.[Quantity],
		   r.[RemoteExchangeId],
		   r.[RemoteOrderId],
		   r.[RemoteExecutePrice],
		   r.[RemoteExecuteQuantity],
		   r.[OrderTypeId],
		   r.[OfferAssetTypeId],
		   r.[WantAssetTypeId],
		   r.[RemoteOrderMappingStatusId],
		   r.[Message],
		   r.[Retry],
		   r.[InsertDate],
		   r.[UpdateDate],
		   o.[OrderStatusId],
		   o.[OriginalOrderId]
	INTO #tmp_Order
	FROM RemoteOrderMappings r WITH(NOLOCK)
	INNER JOIN OrderBook o WITH(NOLOCK) ON r.OrderId = o.OrderId
	WHERE r.RemoteOrderMappingStatusId = 8 
		AND r.RemoteExchangeId IS NOT NULL
		AND r.RemoteOrderId IS NOT NULL
		AND r.RemoteOrderId > 0
		AND r.Quantity > 0
		AND r.ExecutePrice > 0

	SELECT t.OrderId,
		   t.[RemoteOrderMappingsId],
		   t.[ExecutePrice],
		   t.[Quantity],
		   t.[RemoteExchangeId],
		   t.[RemoteOrderId],
		   t.[RemoteExecutePrice],
		   t.[RemoteExecuteQuantity],
		   t.[OrderTypeId],
		   t.[OfferAssetTypeId],
		   t.[WantAssetTypeId],
		   t.[RemoteOrderMappingStatusId],
		   t.[Message],
		   t.[Retry],
		   t.[InsertDate],
		   t.[UpdateDate],
		   t.[OrderStatusId]
	FROM (SELECT * FROM #tmp_Order WHERE OriginalOrderId IS NOT NULL) t 
	INNER JOIN OrderBook o WITH(NOLOCK) ON t.OriginalOrderId = o.OriginalOrderId
	WHERE O.OrderStatusId = 2 and t.OrderStatusId = 2
	UNION
	SELECT 
		   t.OrderId,
		   t.[RemoteOrderMappingsId],
		   t.[ExecutePrice],
		   t.[Quantity],
		   t.[RemoteExchangeId],
		   t.[RemoteOrderId],
		   t.[RemoteExecutePrice],
		   t.[RemoteExecuteQuantity],
		   t.[OrderTypeId],
		   t.[OfferAssetTypeId],
		   t.[WantAssetTypeId],
		   t.[RemoteOrderMappingStatusId],
		   t.[Message],
		   t.[Retry],
		   t.[InsertDate],
		   t.[UpdateDate],
		   t.[OrderStatusId]
	FROM  #tmp_Order t 
	WHERE t.OrderStatusId = 2 and OriginalOrderId IS NULL
END