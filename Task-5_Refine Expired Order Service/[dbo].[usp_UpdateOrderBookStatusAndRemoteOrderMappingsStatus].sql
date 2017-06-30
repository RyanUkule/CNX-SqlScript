USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateOrderBookStatusAndRemoteOrderMappingsStatus]    Script Date: 2017/05/26 11:43:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_UpdateOrderBookStatusAndRemoteOrderMappingsStatus]
(
	@orderIds XML,
	@orderBookStatusId INT,
	@remoteOrderMappingsStatusId INT,
	@statusUpdatedBy INT, -- CustomerId, 0表示系统操作。
	@updateReason NVARCHAR(500), --服务名, 需求名
	@comment NVARCHAR(500) = null
)
AS
BEGIN
	DECLARE @where VARCHAR(MAX);
	DECLARE @t_OldOrderId TABLE
	(
		OrderId INT
	);
	DECLARE @t_OrderId TABLE
	(
		OrderId INT
	);

	INSERT INTO @t_OldOrderId
	SELECT X.C.value('Id[1]','INT') AS OrderId
	FROM @orderIds.nodes('Root/Parameter') AS X(C)
	
	INSERT INTO @t_OrderId
	SELECT OrderId 
	FROM OrderBook AS o
	INNER JOIN @t_OldOrderId AS t ON o.OrderId = t.OrderId
	WHERE OrderStatusId NOT IN (4, 5, 11, 16)

	UPDATE OrderBook SET OrderStatusId = @orderBookStatusId, UpdateDate = GETDATE()
	WHERE OrderId IN (SELECT OrderId FROM @t_OrderId)

	UPDATE CustomerOrder SET OrderStatusId = @orderBookStatusId, UpdateDate = GETDATE()
	WHERE OrderId IN (SELECT OrderId FROM @t_OrderId)

	declare @OrderIdsStr varchar(8000)
	set @OrderIdsStr = ''
	select @OrderIdsStr = @OrderIdsStr+','+rtrim(Id) from @t_OrderId
	set @OrderIdsStr = case when len(@OrderIdsStr)>0 then stuff(@OrderIdsStr,1,1,'') else @OrderIdsStr end
	
	SET @where = ' from orderbook with (nolock) where OrderId in ( ' + dbo.f_MosaicStrint(@OrderIdsStr)+ ' )';
	exec usp_CreateOrderStatusHistory 0, @orderBookStatusId, @statusUpdatedBy, @updateReason, NULL, NULL, 
	NULL, @comment, @where

	UPDATE RemoteOrderMappings 
	SET RemoteOrderMappingStatusId = @remoteOrderMappingsStatusId,
		[Message] = @updateReason,
		UpdateDate = GETDATE()
	WHERE OrderId IN (SELECT OrderId FROM @t_OrderId)
		AND RemoteOrderMappingStatusId NOT IN(2, 3, 4, 11, 12)
END