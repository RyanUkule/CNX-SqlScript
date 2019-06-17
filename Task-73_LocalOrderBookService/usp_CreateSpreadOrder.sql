USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_CreateSpreadOrder]    Script Date: 2019/06/17 14:10:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_CreateSpreadOrder]
	@customerId INT,    
	@orderTypeId INT,    
	@offerAssetTypeId INT,    
	@wantAssetTypeId INT,    
	@priceQuantityPair xml,   
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
	@isTakeOrder bit = null,
	@cid NVARCHAR(128) = null,
	@source NVARCHAR(128) = null,
	@needCreateMappings bit = null
AS    
BEGIN    
	BEGIN TRY
		BEGIN TRAN
			DECLARE @TotalUsedBalance DECIMAL(38,8) = 0
					,@price DECIMAL(18, 8)
					,@quantity DECIMAL(18, 8)
					,@index INT = 0
					,@offerAssetTypeName varchar(50)
					,@wantAssetTypeName varchar(50)
					,@symbol varchar(101)
					,@exchangeSettingCount int
					,@existNoMappingsSymbol int
					
			DECLARE @t_priceQuantityPair TABLE
			(
				Price DECIMAL(18, 8),
				Quantity DECIMAL(18, 8)
			)

			--新建的OrderId
			CREATE TABLE #t_orderId
			(
				OrderId INT
			)

			--判断是否可以创建mapping
			IF(@needCreateMappings = 1)
			BEGIN
				--生成Symbol -- begin
				SELECT @offerAssetTypeName = Name FROM AssetType_lkp WHERE AssetTypeId = @offerAssetTypeId
				SELECT @wantAssetTypeName = Name FROM AssetType_lkp WHERE AssetTypeId = @wantAssetTypeId
				IF(@orderTypeId = 1)
				BEGIN
					SET @symbol = @offerAssetTypeName + '_' + @wantAssetTypeName
				END
				ELSE
				BEGIN
					SET @symbol = @wantAssetTypeName + '_' + @offerAssetTypeName
				END
				--生成Symbol -- end

				SELECT @exchangeSettingCount = count(*) FROM ExchangeSetting WHERE Symbol = @symbol and Active = 1 and ExchangeId <> 16
				SELECT @existNoMappingsSymbol = count(*) FROM Configuration WHERE settingId = 1068 and value like '%' + @symbol + '%'

				IF(@exchangeSettingCount > 0 and @existNoMappingsSymbol = 0)
				BEGIN
					SET @needCreateMappings = 1
				END
				ELSE
				BEGIN
					SET @needCreateMappings = 0
				END
			END
			
			INSERT INTO @t_priceQuantityPair(Price, Quantity)
			SELECT X.C.value('Key[1]', 'DECIMAL(18, 8)') AS Price
				  ,X.C.value('Value[1]', 'DECIMAL(18, 8)') AS Quantity
			FROM @priceQuantityPair.nodes('Root/Parameter') AS X(C)
    
			DECLARE cursor_pair CURSOR
			FOR SELECT Price, Quantity FROM @t_priceQuantityPair

			--quantity
			OPEN cursor_pair
			FETCH next FROM cursor_pair into @price, @quantity

			WHILE @@FETCH_STATUS = 0
			BEGIN
				DECLARE @orderId INT
				SELECT @orderId=(SELECT TOP 1 OrderId + CAST(CEILING(RAND() * 50) AS INT) FROM OrderBook with(nolock) ORDER BY InsertDate DESC)

				--Frozen Balance
				IF @orderTypeId = 1
				BEGIN
					SET @TotalUsedBalance = @TotalUsedBalance + @price * @quantity
				END
				ELSE
				BEGIN
					SET @TotalUsedBalance = @TotalUsedBalance + @quantity
				END

				--Create order
				SET IDENTITY_INSERT OrderBook ON
			
				INSERT INTO OrderBook(
				 OrderId
				 ,[CustomerId]  
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
				VALUES(
				 @orderId
				 ,@customerId  
				 ,@orderTypeId  
				 ,@offerAssetTypeId  
				 ,@wantAssetTypeId  
				 ,@quantity  
				 ,@price  
				 ,@orderstatusId 
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
				
				SET IDENTITY_INSERT OrderBook OFF
   
				IF(@originalorderid IS NULL AND @parentOrderId IS NULL AND @customerId <> 2)
				BEGIN
					INSERT INTO CustomerOrder(OrderId, CustomerId, OrderStatusId, UpdateDate,Cid,[Source])
					 VALUES (@OrderId, @customerId, @orderstatusId, GETDATE(),@cid,@source)
				END

				EXEC usp_CreateOrderStatusHistory @OrderId, @orderstatusId, @customerId, @source, @remoteexchangeId, null,null, 'Create spread order.', NULL

				--Insert RemoteOrderMappings
				IF(@needCreateMappings = 1)
				BEGIN
					INSERT INTO RemoteOrderMappings(OrderId,ExecutePrice,Quantity,RemoteExchangeId,RemoteOrderId,RemoteExecutePrice,RemoteExecuteQuantity,OrderTypeId,OfferAssetTypeId,WantAssetTypeId,RemoteOrderMappingStatusId,[Message],InsertDate,UpdateDate) 
					VALUES (@orderId, @price, @quantity, null, null, null,null, @orderTypeId, @offerAssetTypeId, @wantAssetTypeId, 7, null, GETDATE(), GETDATE())
				END

				INSERT INTO #t_orderId VALUES(@orderId)

				SET @index = @index + 1
				FETCH next FROM cursor_pair into @price, @quantity
			END
			CLOSE cursor_pair
			DEALLOCATE cursor_pair

			--insert into [Log] values(getdate(), '', '', '-1000','SpreadOrder finished','', 'SpreadOrder', -1000)

			--Update Frozen Balance
			UPDATE AssetBalance SET FrozenBalance = FrozenBalance + @TotalUsedBalance WHERE CustomerId = @customerId AND AssetTypeId = @offerAssetTypeId

			SELECT * FROM #t_orderId

			SELECT RemoteOrderMappingsId,r.OrderId,ExecutePrice,Quantity,SubmitPrice,RemoteExchangeId,RemoteOrderId,RemoteExecutePrice,RemoteExecuteQuantity,OrderTypeId,OfferAssetTypeId,WantAssetTypeId,RemoteOrderMappingStatusId,[Message],InsertDate,UpdateDate
			FROM RemoteOrderMappings r with(nolock)
			INNER JOIN #t_orderId t ON r.OrderId = t.OrderId

		COMMIT TRAN  
	END TRY
	BEGIN CATCH
		--ROLLBACK TRAN
		THROW
	END CATCH
END 