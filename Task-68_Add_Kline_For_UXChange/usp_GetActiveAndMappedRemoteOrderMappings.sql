USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetActiveAndMappedRemoteOrderMappings]    Script Date: 2019/05/21 15:09:10 ******/
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
	--INTO #tmp_Order
	FROM RemoteOrderMappings r WITH(NOLOCK)
	INNER JOIN OrderBook o WITH(NOLOCK) ON r.OrderId = o.OrderId
	WHERE r.RemoteOrderMappingStatusId = 8 
		AND r.RemoteExchangeId IS NOT NULL
		AND r.RemoteOrderId IS NOT NULL
		AND r.RemoteOrderId > 0
		AND r.Quantity > 0
		AND r.ExecutePrice > 0

	
	--SELECT t.OrderId,
	--	   t.[RemoteOrderMappingsId],
	--	   t.[ExecutePrice],
	--	   t.[Quantity],
	--	   t.[RemoteExchangeId],
	--	   t.[RemoteOrderId],
	--	   t.[RemoteExecutePrice],
	--	   t.[RemoteExecuteQuantity],
	--	   t.[OrderTypeId],
	--	   t.[OfferAssetTypeId],
	--	   t.[WantAssetTypeId],
	--	   t.[RemoteOrderMappingStatusId],
	--	   t.[Message],
	--	   t.[Retry],
	--	   t.[InsertDate],
	--	   t.[UpdateDate],
	--	   t.[OrderStatusId]
	--FROM (SELECT * FROM #tmp_Order WHERE OriginalOrderId IS NOT NULL) t 
	--INNER JOIN OrderBook o WITH(NOLOCK) ON t.OriginalOrderId = o.OriginalOrderId
	--WHERE O.OrderStatusId = 2		--查询状态为活跃的子单
	--UNION
	--SELECT 
	--	   t.OrderId,
	--	   t.[RemoteOrderMappingsId],
	--	   t.[ExecutePrice],
	--	   t.[Quantity],
	--	   t.[RemoteExchangeId],
	--	   t.[RemoteOrderId],
	--	   t.[RemoteExecutePrice],
	--	   t.[RemoteExecuteQuantity],
	--	   t.[OrderTypeId],
	--	   t.[OfferAssetTypeId],
	--	   t.[WantAssetTypeId],
	--	   t.[RemoteOrderMappingStatusId],
	--	   t.[Message],
	--	   t.[Retry],
	--	   t.[InsertDate],
	--	   t.[UpdateDate],
	--	   t.[OrderStatusId]
	--FROM  (select * from #tmp_Order WHERE  OriginalOrderId IS NULL ) t 
	--inner JOIN OrderBook o with(nolock) on o.OriginalOrderId = t.OrderId		--查询订单状态为活跃的子单
	--WHERE o.OrderStatusId = 2 
	--UNION
	--SELECT 
	--	   t.OrderId,
	--	   t.[RemoteOrderMappingsId],
	--	   t.[ExecutePrice],
	--	   t.[Quantity],
	--	   t.[RemoteExchangeId],
	--	   t.[RemoteOrderId],
	--	   t.[RemoteExecutePrice],
	--	   t.[RemoteExecuteQuantity],
	--	   t.[OrderTypeId],
	--	   t.[OfferAssetTypeId],
	--	   t.[WantAssetTypeId],
	--	   t.[RemoteOrderMappingStatusId],
	--	   t.[Message],
	--	   t.[Retry],
	--	   t.[InsertDate],
	--	   t.[UpdateDate],
	--	   t.[OrderStatusId]
	--FROM #tmp_Order t 
	----inner JOIN OrderBook o with(nolock) on o.OrderId = t.OrderId		--查询订单状态为活跃的子单
	--WHERE t.OrderStatusId = 2  and t.OriginalOrderId IS NULL

END


