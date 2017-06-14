USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_loadOrderInfobyId]    Script Date: 2017/06/13 15:15:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  Nameless   
-- Email:           
-- Create date:     
-- Modify date: 2017-01-05 17:42:16
-- Description: usp_loadOrderInfobyId    
-- =============================================   
ALTER PROCEDURE [dbo].[usp_loadOrderInfobyId]   
	 @orderId INT  
AS  
BEGIN  
	DECLARE @TypeId INT, @OrginalOrderId INT,@StopLossId INT, @TakeProfitId INT, @Editable BIT ;	 
	SELECT @TypeId = OrderTypeId, @OrginalOrderId = OriginalOrderId, @StopLossId = StopLossOrderId, @TakeProfitId = TakeProfitOrderId 
	FROM orderbook WITH (NOLOCK) 
	WHERE OrderId = @orderId;
	IF(@OrginalOrderId IS NULL OR @OrginalOrderId < 0)  
	BEGIN  
		SET @OrginalOrderId = @orderId  
	END  
	  
	SELECT TOP 1
	   C.[OrderId]
	  ,o.[OrderTypeId]
	  ,CASE WHEN o.[WantAssetTypeId] = 1 THEN o.OfferAssetTypeId ELSE o.[WantAssetTypeId] END AssetTypeId  
      ,o.Quantity
      ,o.Price
      ,c.[OrderStatusId]  
      ,o.[MarketOrder]  
      ,o.[ExpirationDate]  
      ,o.[UpdateDate]
	  ,c.AveragePrice
	  ,c.CompletedAmount  
	  ,T.StopLossPrice  
      ,T.TakeProfitPrice  
      ,T.TriggerPrice  
      ,(SELECT TOP 1 TakeProfitOrderId 
		FROM OrderBook WITH (NOLOCK)   
		WHERE @orderid IN (OrderId ,OriginalOrderId) AND OrderStatusId = 4 ORDER BY UpdateDate DESC) TakeProfitOrderId  
	  ,(SELECT TOP 1 StopLossOrderId 
		FROM OrderBook WITH (NOLOCK)   
		WHERE @orderid IN (OrderId ,OriginalOrderId) AND OrderStatusId = 4 ORDER BY UpdateDate DESC) StopLossOrderId  
   --,ob.Orderid OriginalOrderId  
   ,(SELECT OrderId FROM OrderBook WHERE O.OrderId IN (TakeProfitOrderId,StopLossOrderId)) OriginalOrderId
   ,o.InsertDate  
   ,o.OrderClassId  
   ,at.NameBlurb AssetNameBlurb  
   ,at.AssetTypeId  
   ,at.Symbol  
  FROM [OrderBook] o WITH (NOLOCK)   
  LEFT JOIN CustomerOrder c WITH (NOLOCK) ON c.OrderId = CASE WHEN o.ParentOrderId IS NULL THEN o.OrderId ELSE o.ParentOrderId END  
  LEFT JOIN [AdvancedOrderProperties] T WITH (NOLOCK) ON o.OrderId = T.OrderId  
  LEFT JOIN [AssetType_lkp] at WITH (NOLOCK) 
		ON at.AssetTypeId IN (o.WantAssetTypeId ,o.OfferAssetTypeId) AND at.AssetTypeId <> 1  
  WHERE @orderId IN (o.OrderId,o.ParentOrderId) AND o.OriginalOrderId IS NULL
  ORDER BY o.UpdateDate DESC
  
  IF(@TypeId = 1)  
  BEGIN  
	SELECT SUM(A_Amount + A_Commission) AS ActuallyPay , SUM(B_Amount) AS ActuallyGet, SUM(B_Commission) AS TotalCommission  
	FROM [Transaction] WITH (NOLOCK)   
	WHERE A_OrderId = @OrginalOrderId OR A_OrderId IN (SELECT orderid 
													   FROM OrderBook WITH (NOLOCK) 
													   WHERE OriginalOrderId = @OrginalOrderId )  
  END  
  ELSE  
  BEGIN  
	SELECT SUM(B_Amount + B_Commission) AS ActuallyPay , SUM(A_Amount) AS ActuallyGet, SUM(A_Commission) AS TotalCommission  
	FROM [Transaction] WITH (NOLOCK)   
	WHERE B_OrderId = @OrginalOrderId OR B_OrderId IN (SELECT orderid 
													   FROM OrderBook WITH (NOLOCK) 
													   WHERE OriginalOrderId = @OrginalOrderId )  
  END  
  
--声明表和变量  
  DECLARE @order TABLE(HOrderStatusID INT,HOrderStatus VARCHAR(20),HInsertDate DATETIME)  
  DECLARE @OrderStatusId INT  
  DECLARE @OrderStatus VARCHAR(50)  
  DECLARE @InsertDate DATETIME  
  DECLARE @parentOrderId INT, @parentInsertDate DATETIME  
  
  SELECT @parentOrderId = ParentOrderId, @parentInsertDate = InsertDate 
  FROM OrderBook WITH (NOLOCK) 
  WHERE OrderId = @orderId;  

  IF(@parentOrderId IS NOT NULL)  
  BEGIN  
	INSERT INTO @order VALUES(15, 'Modify', @parentInsertDate)  
  END  
  
  INSERT INTO @order  
  SELECT osl.OrderstatusId AS HOrderStatusID  
		 ,Name AS HOrderStatus  
		 ,updatedate AS HInsertDate   
  FROM CustomerOrderStatusHistory COSH INNER JOIN OrderStatus_lkp osl on COSH.OrderStatusId = osl.OrderstatusId  
  WHERE COSH.OrderId = @orderId  
  ORDER BY updatedate DESC;
     
  SELECT * FROM @order ORDER BY HInsertDate;  
  SET @Editable = 1 
   
  IF (@stoplossId > 0)  
  BEGIN  
	IF NOT EXISTS(SELECT OrderId FROM orderbook WHERE @stoplossId IN (orderId,OriginalOrderId) AND orderstatusid NOT IN (4,6,10,11,5))  
	BEGIN  
	 SET @Editable = 0  
	END  
  END  
  
  IF(@TakeProfitId > 0)  
  BEGIN  
    IF NOT EXISTS(SELECT OrderId FROM orderbook WHERE @takeprofitId IN (orderId,OriginalOrderId) AND orderstatusid NOT IN (4,6,10,11,5))  
    BEGIN  
		SET @Editable = 0  
    END  
  END  
  SELECT @Editable    
END    
