use CNX
GO
CREATE PROC usp_GetZBTradeHistory
(
	@startTime DATETIME,
	@endTime DATETIME
)
AS
BEGIN
	SELECT r.orderId as OrderId, r.remoteOrderId as RemoteOrderId, r.RemoteExecuteQuantity, r.remoteExecutePrice as RemoteExecutePrice, r.OrderTypeId, r.OfferAssetTypeId, r.WantAssetTypeId, B_Amount * USDTPrice as Fee
    FROM orderbook o
        inner join remoteOrderMappings r on r.orderId = o.orderId
        inner join [transaction] t on o.orderId = t.a_orderId
    WHERE t.transactionTypeId = 1 and r.remoteExchangeId = 25 and t.InsertDate >= @startTime and t.insertDate < @endTime
UNION
    SELECT r.orderId, r.remoteOrderId, r.RemoteExecuteQuantity, r.remoteExecutePrice, r.OrderTypeId, r.OfferAssetTypeId, r.WantAssetTypeId, B_Amount * USDTPrice as Fee
    FROM orderbook o
        inner join remoteOrderMappings r on r.orderId = o.orderId
        inner join [transaction] t on o.orderId = t.b_orderId
    WHERE t.transactionTypeId = 1 and r.remoteExchangeId = 25 and t.InsertDate >= @startTime and t.insertDate < @endTime
END