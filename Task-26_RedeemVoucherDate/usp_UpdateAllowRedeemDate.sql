use CNX
GO
CREATE PROCEDURE usp_UpdateAllowRedeemDate
(
	@VoucherId varchar(30),
	@AllowRedeemDate datetime
)
AS
BEGIN
	UPDATE Voucher SET AllowRedeemDate = @AllowRedeemDate WHERE VoucherId = @VoucherId
END