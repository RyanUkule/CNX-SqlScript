use CNX
GO
CREATE PROC usp_UpdateRemoteOrderMappingsFee
(
	@remoteOrderId bigint,
	@exchangeId int,
	@fee decimal(18,8)
)
AS
BEGIN
	IF (@exchangeId = 28)
	BEGIN
		UPDATE RemoteOrderMappings SET RemoteFee = @fee, UpdateDate = GETDATE() WHERE RemoteOrderId = @remoteOrderId and RemoteExchangeId = @exchangeId
	END
	ELSE
	BEGIN
		UPDATE RemoteOrderMappings SET RemoteFee = ISNULL(RemoteFee, 0)+ @fee, UpdateDate = GETDATE() WHERE RemoteOrderId = @remoteOrderId and RemoteExchangeId = @exchangeId
	END
END