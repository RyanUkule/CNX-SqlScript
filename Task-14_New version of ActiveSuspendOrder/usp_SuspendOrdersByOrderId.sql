USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_SuspendOrdersByOrderId]    Script Date: 2017/08/24 17:44:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/************************
Author: Ryan.Han
Create Date: 2017-08-24
************************/
CREATE PROCEDURE [dbo].[usp_SuspendOrdersByOrderId]
@suspend xml,
@statusUpdatedBy int, --CustomerId
@updateReason nvarchar(500), 
@exchangeId int = null,	
@transferCurrencyType nvarchar(200) = null, 
@transferCurrencyRate decimal(18, 8) = null, 
@comment nvarchar(500) = null
AS
BEGIN
	DECLARE @where VARCHAR(MAX)
	DECLARE @suspends TABLE
	(
		[Id] INT
	)

	INSERT INTO @suspends([Id])
	SELECT X.C.value('Id[1]','int') AS Id
	FROM @suspend.nodes('Root/Parameter') AS X(C)
	
	SELECT * FROM @suspends

	BEGIN
		DECLARE @count7 INT

		SELECT @count7 = COUNT(*) FROM OrderBook WITH (NOLOCK) WHERE OrderId IN (SELECT Id FROM @suspends) AND (OrderStatusId = 2)
		
		IF(@count7 > 0)
		BEGIN
			SET @where = ' from orderbook with (nolock) where OrderId in ( ' + dbo.f_MosaicStrint(@suspend)
			+ ' ) and OrderStatusId = 2 '

			EXEC usp_CreateOrderStatusHistory 0, 7, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
			@transferCurrencyRate, @comment, @where

			UPDATE OrderBook SET orderstatusid = 7, UpdateDate = GETDATE() WHERE OrderId IN (SELECT Id FROM @suspends) AND OrderStatusId = 2

			UPDATE CustomerOrder SET orderstatusid = 7, UpdateDate = GETDATE()
			WHERE OrderId IN (SELECT Id FROM @suspends) AND (OrderStatusId = 2 OR OrderStatusId = 3)
		END
	END
END
