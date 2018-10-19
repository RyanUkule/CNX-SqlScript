CREATE PROCEDURE usp_GetOTCBuyOrderCountsByCustomerId
(
	@customerId int
)
AS
BEGIN
	SELECT COUNT(*) FROM Orderbook WHERE CustomerId = @customerId and OrderTypeId = 1 and WantAssetTypeId = 22 and orderstatusid = 4
END