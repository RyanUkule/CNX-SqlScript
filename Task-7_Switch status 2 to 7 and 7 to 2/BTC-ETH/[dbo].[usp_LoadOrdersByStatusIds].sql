USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_LoadOrdersByStatusIds]    Script Date: 2017/06/14 12:57:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================= 
-- Author:  Nameless   
-- Email:           
-- Create date:     
-- Modify date: 2017-2-27 12:20:46 
-- Description: usp_LoadOrdersByStatusIds    
-- ============================================= 
ALTER PROCEDURE [dbo].[usp_LoadOrdersByStatusIds]    
@customerId INT,    
@assetTypeId_A INT, 
@assetTypeId_B INT = 1,  
@orderstatuslist XML,
@orderType VARCHAR(10),  
@orderstatusId INT      
AS    
BEGIN    
	/* OrderBook状态集合*/  
	DECLARE @Ids TABLE ([Id] INT);
	INSERT INTO @Ids([Id])					
	SELECT X.C.value('Id[1]','int') AS Id  
	FROM @orderstatuslist.nodes('Root/Parameter') AS X(C);

	/* CustomerOrder状态集合*/ 
	DECLARE @CustomerOrderStatusId TABLE ([Id] INT);
    IF(@orderstatusId=110)--Open
	BEGIN
		INSERT INTO @CustomerOrderStatusId(Id) VALUES(2),(3),(4),(5),(7),(9),(12),(17),(18);
	END
	ELSE IF(@orderstatusId=0)--All
	BEGIN
		INSERT INTO @CustomerOrderStatusId(Id) VALUES (2),(3),(4),(5),(7),(8),(9),(10),(11),(12),(13),(14),(17),(18);
	END
	ELSE 
	BEGIN
		INSERT INTO @CustomerOrderStatusId(Id) VALUES(@orderstatusId);
	END
 
	DECLARE @TopCount INT;  
	SELECT @TopCount=(CASE WHEN @orderstatusId=110 THEN 99999999 ELSE 50 END); 
	DECLARE  @displayPrice DECIMAL(18,4), @originalorderId INT, @orderTypeId INT, @marketOrder INT, @orderClassId INT;
    
	IF(@orderType <> 'All')    
	BEGIN    
		 SELECT @orderTypeId = CASE WHEN @orderType = 'Buy' THEN 1 WHEN @orderType = 'Sell' THEN 2 ELSE NULL END      
		 SELECT @marketOrder = CASE WHEN @orderType = 'M' THEN 1 ELSE 0 END      
		 SELECT @orderClassId = CASE WHEN @orderType IN ('Buy','Sell') THEN 1   
									 WHEN @orderType = 'TP' THEN 2    
									 WHEN @orderType = 'SL' THEN 3 
									 WHEN @orderType = 'TR' THEN 4 END    
	END    
 
	IF(@orderstatusId <> 110)    
	BEGIN    
		SELECT TOP (@TopCount)    
				 O.InsertDate
				 ,CO.OrderId
				 ,[Type] = CASE WHEN O.OrderClassId = 1 THEN T.Name    
							    WHEN O.OrderClassId = 2 THEN 'TP' + T.Name    
								WHEN O.OrderClassId = 3 AND (o.OrderStatusId IN (9,14)) THEN 'SL' + T.Name    
								WHEN O.OrderClassId = 4 THEN 'TR' + T.Name ELSE T.Name END
				 ,Quantity=CASE WHEN EXISTS (SELECT ob.Quantity FROM OrderBook ob WITH (NOLOCK) WHERE CO.OrderId =ob.ParentOrderId AND ob.ParentOrderId IS NOT NULL AND ob.OriginalOrderId IS NULL) THEN (SELECT TOP 1 ob.Quantity FROM OrderBook ob WITH (NOLOCK) WHERE CO.OrderId = ob.ParentOrderId  AND ob.OriginalOrderId IS NULL ORDER BY ob.UpdateDate DESC)
								ELSE (SELECT MAX(ob.Quantity) FROM OrderBook ob WITH (NOLOCK) WHERE CO.OrderId = ob.OrderId AND ob.OriginalOrderId IS NULL) 
							    END
				 ,dbo.ShowDisplayPrice(CO.OrderId) AS Price
				 ,S.Name AS [Orderstatus]
				 ,CO.OrderStatusId
				 ,O.MarketOrder
				 ,Linheight = CASE WHEN DATEDIFF(ss,O.UpdateDate,GETDATE())<30 THEN 1 ELSE 0 END
				 ,CompletedAmount = (CO.CompletedAmount * CO.AveragePrice)
				 ,OrderBookStatusId=CASE WHEN O.OrderStatusId IN (2,7) THEN 1 ELSE 0 END 
				 ,BaseOrderId=(SELECT DISTINCT(OrderId) 
							   FROM OrderBook WITH (NOLOCK) 
							   WHERE O.OrderId IN (StopLossOrderId ,TakeProfitOrderId))
				 ,A.Notified
				 ,O.OrderClassId
				 ,O.OfferAssetTypeId
				 ,O.WantAssetTypeId
		FROM CustomerOrder CO WITH(NOLOCK)    
				INNER JOIN OrderBook O WITH (NOLOCK) ON CO.OrderId = CASE 
				WHEN O.ParentOrderId IS NULL THEN 
					(CASE WHEN O.OriginalOrderId IS NULL THEN O.OrderId 
					ELSE O.OriginalOrderId END)
				ELSE O.ParentOrderId END      		
			    LEFT JOIN AdvancedOrderProperties A WITH (NOLOCK) ON o.orderId = a.orderId     
			    INNER JOIN OrderType_lkp T WITH (NOLOCK) ON o.orderTypeId = T.OrderTypeId   
				LEFT JOIN OrderStatus_lkp S WITH (NOLOCK) ON CO.orderstatusId = S.OrderStatusId    
		WHERE EXISTS (SELECT Id FROM @CustomerOrderStatusId WHERE Id = CO.OrderStatusId)
			    AND EXISTS (SELECT Id FROM @Ids WHERE O.OrderStatusId = Id)    
				AND o.CustomerId = @customerId    
				AND @assetTypeId_A IN (o.[WantAssetTypeId] ,o.offerAssetTypeId)  
				AND @assetTypeId_B IN (o.[WantAssetTypeId] ,o.offerAssetTypeId) 
				AND o.OrderStatusId <>6    
				AND (O.OrderTypeId=@orderTypeId OR @orderTypeId IS NULL)
				AND (O.MarketOrder=@marketOrder OR @marketOrder IS NULL)    
				AND (O.OrderClassId=@orderClassId OR @orderClassId IS NULL)  
				AND O.OrderId=(SELECT TOP 1(ob.OrderId) 
							   FROM OrderBook ob WITH (NOLOCK)  
							   WHERE CO.OrderId IN(ob.OriginalOrderId,ob.ParentOrderId,ob.OrderId) ORDER BY ob.InsertDate DESC,ob.OrderId DESC)    
		ORDER BY InsertDate DESC    
	END    
	ELSE    
	BEGIN    
		SELECT TOP (@TopCount) O.InsertDate
				 ,CO.OrderId
				 ,[Type] = CASE WHEN O.OrderClassId = 1 THEN T.Name    
				 				WHEN O.OrderClassId = 2 THEN 'TP' + T.Name    
				 				WHEN O.OrderClassId = 3 AND (o.OrderStatusId IN (9,14)) THEN 'SL' + T.Name    
				 				WHEN O.OrderClassId = 4 THEN 'TR' + T.Name ELSE T.Name END
				 ,Quantity=CASE WHEN EXISTS (SELECT ob.Quantity FROM OrderBook ob WITH (NOLOCK) WHERE CO.OrderId =ob.ParentOrderId AND ob.ParentOrderId IS NOT NULL AND ob.OriginalOrderId IS NULL) THEN (SELECT TOP 1 ob.Quantity FROM OrderBook ob WITH (NOLOCK) WHERE CO.OrderId = ob.ParentOrderId  AND ob.OriginalOrderId IS NULL ORDER BY ob.UpdateDate DESC)
								ELSE (SELECT MAX(ob.Quantity) FROM OrderBook ob WITH (NOLOCK) WHERE CO.OrderId = ob.OrderId AND ob.OriginalOrderId IS NULL) 
							    END 
				 ,dbo.ShowDisplayPrice(CO.OrderId) AS Price
				 ,S.Name AS [Orderstatus]
				 ,CO.OrderStatusId
				 ,O.MarketOrder
				 ,Linheight = CASE WHEN DATEDIFF(ss,O.UpdateDate,GETDATE())<30 THEN 1 ELSE 0 END	
				 ,CompletedAmount = (CO.CompletedAmount * CO.AveragePrice)
				 ,CASE WHEN O.OrderStatusId IN (2,7) THEN 1 ELSE 0 END OrderBookStatusId
				 ,BaseOrderId=(SELECT DISTINCT(OrderId) 
							   FROM OrderBook WITH (NOLOCK) 
							   WHERE O.OrderId IN (StopLossOrderId,TakeProfitOrderId))
				 ,A.Notified
				 ,O.OrderClassId
				 ,O.OfferAssetTypeId
				 ,O.WantAssetTypeId 
		FROM CustomerOrder CO WITH(NOLOCK)       
				INNER JOIN OrderBook O WITH (NOLOCK) ON CO.OrderId = CASE 
				WHEN O.ParentOrderId IS NULL THEN 
					(CASE WHEN O.OriginalOrderId IS NULL THEN O.OrderId 
					ELSE O.OriginalOrderId END)
				ELSE O.ParentOrderId END     
				LEFT JOIN AdvancedOrderProperties A WITH (NOLOCK) ON o.orderId = a.orderId    
				INNER JOIN OrderType_lkp T WITH (NOLOCK) ON o.orderTypeId = T.OrderTypeId   
				LEFT JOIN OrderStatus_lkp S WITH (NOLOCK) ON CO.orderstatusId = S.OrderStatusId     
		WHERE EXISTS (SELECT Id FROM @CustomerOrderStatusId WHERE Id = CO.OrderStatusId)
			    AND EXISTS (SELECT Id FROM @Ids WHERE O.OrderStatusId = Id)     
				AND O.CustomerId = @customerId 
				AND (@assetTypeId_A IN(o.[WantAssetTypeId],o.offerAssetTypeId))
				AND (@assetTypeId_B IN (o.[WantAssetTypeId] ,o.offerAssetTypeId))
				AND (O.OrderTypeId=@orderTypeId OR @orderTypeId IS NULL)    
				AND (O.MarketOrder=@marketOrder OR @marketOrder IS NULL)
				AND (O.OrderClassId=@orderClassId OR @orderClassId IS NULL) 
				AND O.OrderId=(SELECT TOP 1(ob.OrderId) 
							   FROM OrderBook ob WITH (NOLOCK)  
							   WHERE CO.OrderId IN(ob.OriginalOrderId,ob.ParentOrderId,ob.OrderId) ORDER BY ob.InsertDate DESC,ob.OrderId DESC)     
				AND (CO.OrderStatusId NOT IN (4,5) OR ((CO.OrderStatusId IN (4,5) AND (DATEDIFF(SECOND, o.UpdateDate,GETDATE())<30))))    
		ORDER BY O.InsertDate DESC    
	END    
END 


