CREATE PROCEDURE usp_GetFirstOrderByCustomerId
(
	@customerId int
)
AS
BEGIN
	SELECT TOP 1 * FROM OrderBook WHERE CustomerId = @customerId AND OrderStatusId in (3, 4)
	ORDER BY UpdateDate
END

