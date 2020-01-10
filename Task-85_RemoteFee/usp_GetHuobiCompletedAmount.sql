use CNX
GO
CREATE PROC usp_GetHuobiCompletedAmount
(
	@startTime DATETIME,
	@endTime DATETIME
)
AS
BEGIN
	SELECT orderId as OrderId, remoteOrderId as RemoteOrderId, RemoteExecuteQuantity, remoteExecutePrice as RemoteExecutePrice, OrderTypeId, OfferAssetTypeId, WantAssetTypeId
	FROM RemoteOrderMappings 
	WHERE RemoteExchangeId = 28 and RemoteExecuteQuantity is not null and RemoteExecuteQuantity > 0 and UpdateDate >= @startTime and UpdateDate < @endTime
END