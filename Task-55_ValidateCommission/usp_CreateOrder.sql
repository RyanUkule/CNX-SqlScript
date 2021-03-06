USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_CreateOrder]    Script Date: 2018/11/28 15:16:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_CreateOrder]    
@customerId INT,    
@orderTypeId INT,    
@offerAssetTypeId INT,    
@wantAssetTypeId INT,    
@quantity DECIMAL(18,8),    
@price DECIMAL(18,8),    
@orderstatusId INT,    
@originalOrderId INT = null,    
@marketorder BIT,    
@expiredDate DATETIME = null,    
@stoplossOrderId INT = null,    
@takeProfitOrderId INT = null,    
@remoteexchangeId INT = null,    
@remoteexchangeOrderNumber VARCHAR(50) = null,    
@parentOrderId INT = null,    
@orderClassId INT,    
@stoplossPrice DECIMAL(18,8) = null,    
@takeprofitPrice DECIMAL(18,8) = null,    
@triggerPrice DECIMAL(18,8) = null,    
@isAboveMarket BIT = null,    
@insertDate DATETIME = null,    
@saveDate DATETIME = null,    
@statusUpdatedBy INT, --服务名，需求名    
@updateReason NVARCHAR(500), --需求的子进度    
@transferCurrencyType NVARCHAR(200) = null,     
@transferCurrencyRate DECIMAL(18, 8) = null,     
@comment NVARCHAR(500) = null, --特殊参数，trigger的MarketPrice    
@isTakeOrder bit = null,
@cid NVARCHAR(128) = null,
@source NVARCHAR(128) = null,
@marketPrice NVARCHAR(50) = null
    
AS    
BEGIN    
begin try
	begin tran
	 DECLARE @FinalOrderstatusId INT  
		 ,@UserBalance DECIMAL(18,8)  
			,@CompleteAmount DECIMAL(18,8)    
		 ,@CompletePrice DECIMAL(18,8)  
		 ,@TotalAmount DECIMAL(18,8)  
		 ,@TotalPrice DECIMAL(18,8)    

	 DECLARE @RequestAmount DECIMAL(18,8)=@quantity  
		 ,@RequestPrice DECIMAL(18,8)=@price    
	 SET @FinalOrderstatusId = @orderstatusId    
    
	declare @orderId int
	--SELECT @orderId=(SELECT TOP 1 OrderId + CAST(CEILING(RAND() * 50) AS INT) FROM OrderBook with(nolock) ORDER BY InsertDate DESC)

	--SET IDENTITY_INSERT OrderBook ON

	 INSERT INTO OrderBook(  
	 --OrderId,
	 [CustomerId]  
	 ,[OrderTypeId]  
	 ,[OfferAssetTypeId]  
	 ,[WantAssetTypeId]  
	 ,[Quantity]  
	 ,[Price]  
	 ,[OrderStatusId]  
	 ,[OriginalOrderId]    
	 ,[MarketOrder]    
	 ,[ExpirationDate]    
	 ,[TakeProfitOrderId]    
	 ,[StopLossOrderId]    
	 ,[UpdateDate]    
	 ,[InsertDate]    
	 ,[SaveDate]    
	 ,[RemoteExchangeId]    
	 ,[RemoteExchangeOrderNumber]    
	 ,[ParentOrderId]    
	 ,[OrderClassId],
	 IsTakeOrder)    
	 VALUES   
	 (
	 --@orderId,
	 @customerId  
	 ,@orderTypeId  
	 ,@offerAssetTypeId  
	 ,@wantAssetTypeId  
	 ,@quantity  
	 ,@price  
	 ,@FinalOrderstatusId  
	 ,@originalOrderId    
	 ,@marketorder  
	 ,@expiredDate  
	 ,@takeProfitOrderId  
	 ,@stoplossOrderId 
	 ,GETDATE()  
	 ,GETDATE()
	 ,GETDATE()  
	 ,@remoteexchangeId  
	 ,@remoteexchangeOrderNumber  
	 ,@parentOrderId  
	 ,@orderClassId
	 ,@isTakeOrder)  
      
	set @orderid = @@IDENTITY
	--SET IDENTITY_INSERT OrderBook OFF
   
	IF(@FinalOrderstatusId IN (1,8, 9, 10))
	BEGIN
		SET @FinalOrderstatusId = 2
	END

	IF(@originalorderid IS NULL AND @parentOrderId IS NULL AND @customerId <> 2)
	BEGIN
		INSERT INTO CustomerOrder(OrderId, CustomerId, OrderStatusId, UpdateDate,Cid,[Source])
		 VALUES (@OrderId, @customerId, @FinalOrderstatusId, GETDATE(),@cid,@source)

		if(@orderStatusId = 2)
		begin
			if(@marketorder = 1 and @orderTypeId = 1)
			begin
				update AssetBalance set FrozenBalance = FrozenBalance + @price, updatedate = getdate() 
				where CustomerId = @customerId and AssetTypeId = @offerAssetTypeId

				insert into [Log] 
				select getdate(), '', '', convert(nvarchar(100),@customerId), 'FrozenBalance:' + convert(nvarchar(100),isnull(@price, 0)), null, 'CreateOrder', @orderid
			end
			else if (@marketorder = 0 and @orderTypeId = 1)
			begin
				update AssetBalance set FrozenBalance = FrozenBalance + @price * @quantity, updatedate = getdate() 
				where CustomerId = @customerId and AssetTypeId = @offerAssetTypeId

				insert into [Log] 
				select getdate(), '', '', convert(nvarchar(100),@customerId), 'FrozenBalance:' + convert(nvarchar(100),isnull(@price * @quantity, 0)), null, 'CreateOrder', @orderid
			end
			else if(@orderTypeId = 2)
			begin
				update AssetBalance set FrozenBalance = FrozenBalance + @quantity, updatedate = getdate() 
				where CustomerId = @customerId and AssetTypeId = @offerAssetTypeId

				insert into [Log] 
				select getdate(), '', '', convert(nvarchar(100),@customerId), 'FrozenBalance:' + convert(nvarchar(100),isnull(@quantity, 0)), null, 'CreateOrder', @orderid
			end
		end
	END

	 --UPDATE CustomerOrder   
	 --SET [OrderStatusId]= CASE WHEN @FinalOrderStatusId = 7 THEN 7   
		--	 WHEN  @CompleteAmount>0 OR @CompletePrice>0 THEN 3   
		--	 WHEN @FinalOrderStatusId = 2 THEN 2 END     
	 --WHERE  [OrderId]=@parentOrderId AND [CustomerId]=@customerId    
   
	 set @comment = @comment + ' marketPrice:' + @marketPrice
	 EXEC usp_CreateOrderStatusHistory @OrderId, @FinalOrderstatusId, @statusUpdatedBy, @updateReason, @remoteexchangeId, @transferCurrencyType,@transferCurrencyRate, @comment, NULL    
     
	 IF((@stoplossPrice IS NOT NULL AND @stoplossPrice > 0) OR (@takeprofitPrice IS NOT NULL AND @takeprofitPrice > 0) OR (@triggerPrice IS NOT NULL AND @triggerPrice > 0 ))    
	 BEGIN    
	  IF(@stoplossPrice IS NULL)    
	  BEGIN    
		 SET @stoplossPrice = 0    
	  END    
    
	  IF(@takeprofitPrice IS NULL)    
	  BEGIN    
		 SET @takeprofitPrice = 0    
	  END    
    
	  IF(@triggerPrice IS NULL)    
	  BEGIN    
		 SET @triggerPrice = 0    
		 SET @isAboveMarket = NULL    
	  END    
	  INSERT INTO [dbo].[AdvancedOrderProperties](OrderId,StopLossPrice,TakeProfitPrice,TriggerPrice,TriggerPriceIsAboveCurrent)    
	  VALUES(@OrderId,@stoplossPrice,@takeprofitPrice,@triggerPrice,@isAboveMarket)    
	 END       
	 SELECT @OrderId OrderId
	commit tran     
end try
begin	catch 
	rollback tran
	throw 
end catch
END 
    
    
