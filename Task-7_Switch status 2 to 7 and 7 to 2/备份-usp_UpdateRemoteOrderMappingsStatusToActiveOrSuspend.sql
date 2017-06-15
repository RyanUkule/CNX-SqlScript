USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateRemoteOrderMappingsStatusToActiveOrSuspend]    Script Date: 2017/06/01 17:21:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_UpdateRemoteOrderMappingsStatusToActiveOrSuspend]
@activeOrderIds xml,
@suspendOrderIds xml
AS
BEGIN
	DECLARE @t_activeOrderId TABLE
	(
		OrderId INT
	);
	DECLARE @t_suspendOrderId TABLE
	(
		OrderId INT
	);

	INSERT INTO @t_activeOrderId(OrderId)
	SELECT X.C.value('Id[1]', 'INT') AS OrderId
	FROM @activeOrderIds.nodes('Root/Parameter') AS X(C)

	INSERT INTO @t_suspendOrderId(OrderId)
	SELECT X.C.value('Id[1]', 'INT') AS OrderId
	FROM @suspendOrderIds.nodes('Root/Parameter') AS X(C)
	
	--Insert a record in RemoteOrderMappings for orders that switch from 'Suspend' to 'Active'
	INSERT INTO RemoteOrderMappings(OrderId, ExecutePrice, Quantity, OrderTypeId, OfferAssetTypeId, WantAssetTypeId, RemoteOrderMappingStatusId
		, InsertDate, UpdateDate)
	SELECT OrderId, Price, Quantity, OrderTypeId, OfferAssetTypeId, WantAssetTypeId, 7, GETDATE(), GETDATE()
	FROM OrderBook WITH (NOLOCK)
	WHERE OrderId in (SELECT OrderId FROM @t_activeOrderId);

	UPDATE RemoteOrderMappings SET [RemoteOrderMappingStatusId] = 12 , [Message]='close',UpdateDate=GETDATE()
	WHERE OrderId in (SELECT OrderId FROM @t_suspendOrderId) and [RemoteOrderMappingStatusId]  not in  (9,11,13,14,15,17)
END