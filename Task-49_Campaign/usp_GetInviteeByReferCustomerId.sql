USE CNX
GO
CREATE PROCEDURE usp_GetInviteeByReferCustomerId
(
	@referCustomerId int
)
AS
BEGIN
	SELECT * FROM Invitation WHERE ReferCustomerId = @referCustomerId
END