CREATE PROCEDURE usp_GetTransferRequestByCustomerId
(
	@customerId int,
	@requestTypeName varchar(50) = null,
	@requestStatusId int = null
)
AS
BEGIN
	IF(@requestTypeName IS NOT NULL)
	BEGIN
		SELECT * FROM TransferRequest WITH(NOLOCK)
		WHERE CustomerId = @customerId
		AND RequestTypeId IN (SELECT RequestTypeId FROM RequestType_lkp WHERE Name LIKE '%' + @requestTypeName + '%')
		AND RequestStatusId = (CASE WHEN @requestStatusId IS NULL THEN RequestStatusId ELSE @requestStatusId END)
	END
	ELSE
	BEGIN
		SELECT * FROM TransferRequest WITH(NOLOCK)
		WHERE CustomerId = @customerId
		AND RequestStatusId = (CASE WHEN @requestStatusId IS NULL THEN RequestStatusId ELSE @requestStatusId END)
	END
END