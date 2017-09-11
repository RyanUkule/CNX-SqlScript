USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_TransferMapping]    Script Date: 2017/09/06 16:51:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*************************
Author: Ryan.Han
Create Date: 2017/09/06
**************************/
CREATE PROCEDURE [dbo].[usp_TransferMapping]
(
	@mappingId INT,
	@newExecutePrice DECIMAL(18, 8),
	@offerAssetTypeId INT,
	@wantAssetTypeId INT
)
AS
BEGIN
	DECLARE @newMappingId INT
	
	--Insert a new mapping
	INSERT INTO RemoteOrderMappings(OrderId, ExecutePrice, Quantity,RemoteExchangeId, OrderTypeId, OfferAssetTypeId, WantAssetTypeId, RemoteOrdermappingStatusId, InsertDate, UpdateDate)
	SELECT OrderId, @newExecutePrice, Quantity,RemoteExchangeId, OrderTypeId, @offerAssetTypeId, @wantAssetTypeId, RemoteOrdermappingStatusId, GETDATE(), GETDATE()
	FROM RemoteOrderMappings

	SELECT @newMappingId = SCOPE_IDENTITY()

	--Abort old mapping
	UPDATE RemoteOrderMappings SET RemoteOrderMappingStatusId = 4 WHERE RemoteOrderMappingsId = @mappingId

	SELECT 
		RemoteOrderMappingsId,
		OrderId, 
		ExecutePrice, 
		Quantity,
		SubmitPrice,
		RemoteExchangeId, 
		RemoteOrderId,
		RemoteExecutePrice,
		RemoteExecuteQuantity,
		RemoteExecuteOverQuantity,
		RemoteFee,
		OrderTypeId, 
		OfferAssetTypeId, 
		WantAssetTypeId, 
		RemoteOrdermappingStatusId, 
		Message,
		Retry,
		InsertDate, 
		UpdateDate,
		ConvertOrderId
	FROM RemoteOrderMappings
	WHERE RemoteOrderMappingsId = @newMappingId

END