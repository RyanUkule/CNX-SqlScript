USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateOrderStatus]    Script Date: 2018/11/28 19:55:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_UpdateOrderStatus]
@orderId int,
@statusId int,
@statusUpdatedBy int, --服务名，需求名
@updateReason nvarchar(500), --需求的子进度
@exchangeId int = null,	--mapping后才需要
@transferCurrencyType nvarchar(200) = null, 
@transferCurrencyRate decimal(18, 8) = null, 
@comment nvarchar(500) = null, --特殊参数，trigger的MarketPrice
@isTakeOrder bit = null

AS
BEGIN
	declare @offerAssetTypeId int, @marketOrder bit, @orderTypeId int, @price decimal(18, 8), @quantity decimal(18, 8), @customerId int,@sourceOrderStatusId int
	select 
		@offerAssetTypeId = OfferAssetTypeId, @marketOrder = MarketOrder, 
		@orderTypeId = OrderTypeId, @price = Price, @quantity = Quantity, @customerId = CustomerId, @sourceOrderStatusId = OrderStatusId
	from OrderBook with (nolock) where (OrderId = @orderId or OriginalOrderId = @orderId) and OrderStatusId not in (4, 5, 11, 16)

    --Update OrderBook set orderstatusId = @statusId where ( OrderId = @orderId  or ParentOrderId=@orderId) and orderstatusId not in (4,5,16)
	if(@statusId = 2 and @isTakeOrder is not null)
	begin
		Update OrderBook set orderstatusId = @statusId, IsTakeOrder = @isTakeOrder 
		where (OrderId = @orderId or ParentOrderId=@orderId) and orderstatusId not in (4,5,16)
	end
	else
	begin
		Update OrderBook set orderstatusId = @statusId where  ( OrderId = @orderId  or OriginalOrderId =@orderId) and orderstatusId not in (4,5,16)
	end

	if(@statusId in (2))
	begin
		if(@marketorder = 1 and @orderTypeId = 1)
		begin
			update AssetBalance set FrozenBalance = FrozenBalance + @price where CustomerId = @customerId and AssetTypeId = @offerAssetTypeId

			insert into [Log] 
			select getdate(), '', '', convert(nvarchar(100),@customerId), 'FrozenBalance:' + convert(nvarchar(100),isnull(@price, 0)), null, 'UpdateOrderStatus', @orderid
		end
		else if (@marketorder = 0 and @orderTypeId = 1)
		begin
			update AssetBalance set FrozenBalance = FrozenBalance + @price * @quantity where CustomerId = @customerId and AssetTypeId = @offerAssetTypeId

			insert into [Log] 
			select getdate(), '', '', convert(nvarchar(100),@customerId), 'FrozenBalance:' + convert(nvarchar(100),isnull(@price * @quantity, 0)), null, 'UpdateOrderStatus', @orderid
		end
		else if(@orderTypeId = 2)
		begin
			update AssetBalance set FrozenBalance = FrozenBalance + @quantity where CustomerId = @customerId and AssetTypeId = @offerAssetTypeId
			
			insert into [Log] 
			select getdate(), '', '', convert(nvarchar(100),@customerId), 'FrozenBalance:' + convert(nvarchar(100),isnull(@quantity, 0)), null, 'UpdateOrderStatus', @orderid
		end
	end
	if(@statusId in (4, 5, 7, 11) and @sourceOrderStatusId not in (7))
	begin
		if(@marketorder = 1 and @orderTypeId = 1)
		begin
			update AssetBalance set FrozenBalance = FrozenBalance - @price where CustomerId = @customerId and AssetTypeId = @offerAssetTypeId

			insert into [Log] 
			select getdate(), '', '', convert(nvarchar(100),@customerId), 'FrozenBalance:' + convert(nvarchar(100),isnull(-@price, 0)), null, 'UpdateOrderStatus', @orderid
		end
		else if (@marketorder = 0 and @orderTypeId = 1)
		begin
			update AssetBalance set FrozenBalance = FrozenBalance - @price * @quantity where CustomerId = @customerId and AssetTypeId = @offerAssetTypeId

			insert into [Log] 
			select getdate(), '', '', convert(nvarchar(100),@customerId), 'FrozenBalance:' + convert(nvarchar(100),isnull(- @price * @quantity, 0)), null, 'UpdateOrderStatus', @orderid
		end
		else if(@orderTypeId = 2)
		begin
			update AssetBalance set FrozenBalance = FrozenBalance - @quantity where CustomerId = @customerId and AssetTypeId = @offerAssetTypeId

			insert into [Log] 
			select getdate(), '', '', convert(nvarchar(100),@customerId), 'FrozenBalance:' + convert(nvarchar(100),isnull(-@quantity, 0)), null, 'UpdateOrderStatus', @orderid
		end
	end

	exec usp_CreateOrderStatusHistory @orderId, @statusId, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
	@transferCurrencyRate, @comment, null

	select CustomerId, OrderStatusId from OrderBook where ( OrderId = @orderId  or OriginalOrderId=@orderId) and orderstatusId not in (4,5,16)
END




