USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_CancelOrder]    Script Date: 2018/11/28 17:28:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  Nameless   
-- Email:           
-- Create date:     
-- Modify date: 2017-01-05 17:42:16
-- Description: usp_CancelOrder    
-- =============================================  
ALTER PROCEDURE [dbo].[usp_CancelOrder]
@OrderId INT,
@datetimenew DATETIME,
@OrderStatusId INT,
@statusUpdatedBy INT, --服务名，需求名
@updateReason NVARCHAR(500), --需求的子进度
@exchangeId INT = NULL,	--mapping后才需要
@transferCurrencyType NVARCHAR(200) = NULL, 
@transferCurrencyRate DECIMAL(18, 8) = NULL, 
@comment nvarchar(500) = NULL --特殊参数，trigger的MarketPrice
AS
BEGIN
	DECLARE @where VARCHAR(MAX)	
	BEGIN
		--还原FrozenBalance
		declare @offerAssetTypeId int, @marketOrder bit, @orderTypeId int, @price decimal(18, 8), @quantity decimal(18, 8), @customerId int,
		@sourceOrderStatusId int
		select 
		@offerAssetTypeId = OfferAssetTypeId, @marketOrder = MarketOrder, 
		@orderTypeId = OrderTypeId, @price = Price, @quantity = Quantity, @customerId = CustomerId, @sourceOrderStatusId = OrderStatusId
		from OrderBook with (nolock) where (OrderId = @orderId or OriginalOrderId = @orderId) and OrderStatusId not in (4, 5, 7, 11, 16)

		SET @where = 'from orderbook with (nolock) where ([OriginalOrderId] = ' + CAST(@OrderId AS VARCHAR(50)) 
			+' or ParentOrderId = ' + CAST(@OrderId AS VARCHAR(50)) + ' or OrderId = ' + CAST(@OrderId AS VARCHAR(50)) + ') and [OrderStatusId] not in (4, 5, 11, 12, 16)';
		EXEC usp_CreateOrderStatusHistory 0, @OrderStatusId, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType,@transferCurrencyRate, @comment, @where;
		UPDATE [OrderBook] 
		SET [OrderStatusId] = @OrderStatusId, UpdateDate = GETDATE() 
		WHERE ([OriginalOrderId] = @OrderId OR OrderId = @OrderId or ParentOrderId=@OrderId ) AND [OrderStatusId] NOT IN (4, 5, 11, 16)

		if(@orderStatusId = 5 and @sourceOrderStatusId in (2, 12))
		begin
			if(@marketorder = 1 and @orderTypeId = 1)
			begin
				update AssetBalance set FrozenBalance = FrozenBalance - @price where CustomerId = @customerId and AssetTypeId = @offerAssetTypeId

				insert into [Log] 
				select getdate(), '', '', convert(nvarchar(100),@customerId), 'FrozenBalance:' + convert(nvarchar(100),isnull(-@price, 0)), null, 'CancelOrder', @orderid
			end
			else if (@marketorder = 0 and @orderTypeId = 1)
			begin
				update AssetBalance set FrozenBalance = FrozenBalance - @price * @quantity where CustomerId = @customerId and AssetTypeId = @offerAssetTypeId

				insert into [Log] 
			select getdate(), '', '', convert(nvarchar(100),@customerId), 'FrozenBalance:' + convert(nvarchar(100),isnull(- @price * @quantity, 0)), null, 'CancelOrder', @orderid
			end
			else if(@orderTypeId = 2)
			begin
				update AssetBalance set FrozenBalance = FrozenBalance - @quantity where CustomerId = @customerId and AssetTypeId = @offerAssetTypeId

				insert into [Log] 
			select getdate(), '', '', convert(nvarchar(100),@customerId), 'FrozenBalance:' + convert(nvarchar(100),isnull(-@quantity, 0)), null, 'CancelOrder', @orderid
			end
		end

	END
	SELECT CustomerId, [OrderStatusId] FROM CustomerOrder with (nolock) WHERE OrderId = @OrderId
END










