USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetActiveAndMappedRemoteOrderMappings]    Script Date: 2017/06/14 18:24:29 ******/
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
		   o.[OrderTypeId],
		   r.[OfferAssetTypeId],
		   r.[WantAssetTypeId],
		   r.[RemoteOrderMappingStatusId],
		   r.[Message],
		   r.[Retry],
		   r.[InsertDate],
		   r.[UpdateDate]
	FROM RemoteOrderMappings r WITH(NOLOCK)
	INNER JOIN OrderBook o WITH(NOLOCK) ON r.OrderId = o.OrderId
	WHERE r.RemoteOrderMappingStatusId = 8 
		AND r.RemoteExchangeId IS NOT NULL
		AND r.RemoteOrderId IS NOT NULL
		AND r.Quantity > 0
		AND r.ExecutePrice > 0
		AND o.OrderStatusId = 2
END