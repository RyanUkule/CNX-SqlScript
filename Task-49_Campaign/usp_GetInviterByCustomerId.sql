USE CNX
GO
CREATE PROCEDURE usp_GetInviterByCustomerId
(
	@customerId int
)
AS
BEGIN
	SELECT * FROM Invitation WHERE CustomerId = @customerId
END