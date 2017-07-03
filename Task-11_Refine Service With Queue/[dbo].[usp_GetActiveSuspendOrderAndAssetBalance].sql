USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetActiveSuspendOrderAndAssetBalance]    Script Date: 2017/07/03 16:48:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_GetActiveSuspendOrderAndAssetBalance]
AS
BEGIN
	SELECT 
		o.OrderId,
		CustomerId,
		o.OrderTypeId,
		o.OfferAssetTypeId,
		o.WantAssetTypeId,
		o.Quantity,
		Price,
		OrderStatusId,
		MarketOrder,
		ISNULL(r.ExecutePrice, Price) ExecutePrice,
		SaveDate
	INTO #t_validOrder
	FROM OrderBook o WITH(NOLOCK)
	LEFT JOIN RemoteOrderMappings r WITH(NOLOCK)
	ON o.OrderId = r.OrderId
	WHERE (OrderStatusId = 2 OR OrderStatusId = 7) AND CustomerId <> 2 AND (r.RemoteOrderMappingStatusId in (6,7,8,12) OR r.RemoteOrderMappingStatusId IS NULL);

	SELECT 
		OrderId,
		CustomerId,
		OrderTypeId,
		OfferAssetTypeId,
		WantAssetTypeId,
		Quantity,
		Price,
		OrderStatusId,
		MarketOrder,
		ExecutePrice,
		SaveDate
	 FROM #t_validOrder;

	SELECT
		CustomerId,
		AssetTypeId,
		Balance,
		FrozenBalance
	FROM AssetBalance WITH(NOLOCK)
	WHERE CustomerId IN (SELECT CustomerId FROM #t_validOrder)

	DROP TABLE #t_validOrder;
END;