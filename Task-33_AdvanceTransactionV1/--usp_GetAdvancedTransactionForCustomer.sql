USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetAdvancedTransactionForCustomer]    Script Date: 2018/03/30 14:39:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  Nameless   
-- Email:           
-- Create date:     
-- Modify date: 2017-1-6 11:23:55
-- Description: usp_GetAdvancedTransactionForCustomer    
-- =============================================
ALTER PROCEDURE [dbo].[usp_GetAdvancedTransactionForCustomer]
	@customerId INT,
	@assetTypeId INT = NULL,
	@startdate VARCHAR(50),
	@enddate VARCHAR(50),
	@filter NVARCHAR(50),
	@skip INT,
	@take INT
AS
BEGIN
	SELECT 
			CASE WHEN t.UpdateDate IS NOT NULL THEN t.UpdateDate 
				 WHEN tr.UpdateDate IS NOT NULL THEN tr.UpdateDate 
				 WHEN v.UpdateDate IS NOT NULL THEN v.UpdateDate END 
				 AS   UpdateDate, 
			CASE WHEN at.VoucherId IS NOT NULL THEN at.VoucherId 
				 WHEN tr.RequestId IS NOT NULL THEN CONVERT(NVARCHAR(50), tr.RequestId)
				 ELSE CONVERT(NVARCHAR(50), o.OrderId) END 
				 AS   Id, 
			CASE WHEN o.OrderTypeId = 1 THEN 'Buy'
				 WHEN o.OrderTypeId = 2 THEN 'Sell'
				 ELSE at.TransactionType END 
				 AS   [Type], 
			CASE WHEN at.TransactionType = 'Transaction' 
			THEN (t.A_Amount + t.A_Commission)/case when (t.B_Amount + t.B_Commission) = 0 then 1 else (t.B_Amount + t.B_Commission) end END 
				 AS   OrderPrice,
			CASE WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 1 THEN at.A_CNYBalance 
				 WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 1 THEN at.B_CNYBalance 
				 WHEN o.OrderTypeId = 1 THEN at.A_CNYBalance
				 WHEN o.OrderTypeId = 2 THEN at.B_CNYBalance
				 WHEN tr.Amount IS NOT NULL THEN at.A_CNYBalance ELSE NULL END 
				 AS	  CNYBalance,
			CASE WHEN t.TransactionId IS NOT NULL THEN t.A_Amount
				 WHEN tr.Amount IS NOT NULL AND tr.AssetTypeId = 1 THEN tr.Amount 
				 WHEN v.Value IS NOT NULL AND v.AssetTypeId = 1 THEN v.Value END 
				 AS   CNYAmount,
			CASE WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId <> 1 THEN at.A_Balance 
				 WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId <> 1 THEN at.B_Balance 
				 WHEN o.OrderTypeId = 1 THEN at.A_Balance
				 WHEN o.OrderTypeId = 2 THEN at.B_Balance
				 WHEN tr.Amount IS NOT NULL AND tr.AssetTypeId <> 1 THEN at.A_Balance ELSE null END 
				 AS   BTCBalance,
			CASE WHEN t.TransactionId IS NOT NULL THEN t.B_Amount
				 WHEN tr.Amount IS NOT NULL AND tr.AssetTypeId <> 1 THEN tr.Amount 
				 WHEN v.Value IS NOT NULL AND v.AssetTypeId <> 1 THEN v.Value END 
				 AS   BTCAmount,
			CASE WHEN o.OrderTypeId = 1 THEN t.B_Commission 
			     WHEN o.OrderTypeId = 2 THEN t.A_Commission 
				 WHEN tr.RequestId is not null THEN tr.Commision
				 ELSE 0 END 
				 AS   Commission,
			CASE WHEN ba.AddressId IS NOT NULL THEN ba.AddressId 
				 WHEN bt.TransactionBank IS NOT NULL THEN bt.TransactionBank ELSE NULL END
				 AS   AddressId,
		    CASE WHEN v.[AssetTypeId] IS NOT NULL THEN v.[AssetTypeId]
				 WHEN tr.[AssetTypeId] IS NOT NULL THEN tr.[AssetTypeId]
				 WHEN o.OrderTypeId = 1 THEN o.[WantAssetTypeId]
				 WHEN o.OrderTypeId = 2 THEN o.[OfferAssetTypeId]
			     ELSE NULL END 
				 AS   AssetTypeId,
			CASE WHEN o.OrderTypeId = 2 THEN o.[WantAssetTypeId]
				 WHEN o.OrderTypeId = 1 THEN o.[OfferAssetTypeId]
			     ELSE NULL END 
				 AS   OppositeAssetTypeId,
			at.AdvanceTransactionId AS AdvanceTransactionId
		   -- CASE WHEN o.ParentOrderId IS NOT NULL THEN 1
			  --   ELSE 0 END 
				 --AS   HasSubOrder
		FROM AdvancedTransaction at WITH (NOLOCK) 
			LEFT JOIN [Transaction] t WITH (NOLOCK) ON at.TransactionId = t.TransactionId
			LEFT JOIN [TransferRequest] tr WITH (NOLOCK) ON at.TransferRequestId = tr.RequestId
			LEFT JOIN [Voucher] v WITH (NOLOCK) ON at.VoucherId = v.VoucherId 
			LEFT JOIN [OrderBook] o WITH (NOLOCK) ON  o.OrderId = t.A_OrderId
			LEFT JOIN BitcoinAddress ba WITH (NOLOCK) ON tr.BitcoinAddressId = ba.BitcoinAddressId
			LEFT JOIN BankTransaction bt WITH (NOLOCK) ON tr.BankTransactionId = bt.BankTransactionId
		WHERE @customerId IN (o.CustomerId,tr.CustomerId,v.IssuedByCustomerId,v.RedeemedByCustomerId) 
			AND (CASE WHEN t.UpdateDate IS NOT NULL THEN t.UpdateDate 
				 WHEN tr.UpdateDate IS NOT NULL THEN tr.UpdateDate 
				 WHEN v.UpdateDate IS NOT NULL THEN v.UpdateDate END >= @startdate OR @startdate IS NULL OR @startdate = '')
			AND (CASE WHEN t.UpdateDate IS NOT NULL THEN t.UpdateDate 
				 WHEN tr.UpdateDate IS NOT NULL THEN tr.UpdateDate 
				 WHEN v.UpdateDate IS NOT NULL THEN v.UpdateDate END <= CONVERT(VARCHAR(50), DATEADD(ms,-3, DATEADD(dd, 1, @enddate)), 120) 
				 OR @enddate IS NULL OR @enddate = '')
			AND ((at.TransactionType = 'Transaction' AND o.OrderTypeId = CASE WHEN @filter = 'Buy' THEN 1 WHEN @filter = 'Sell' THEN 2 END) 
			 OR at.TransactionType LIKE ('%' + @filter + '%') OR @filter IS NULL OR @filter = '')
			AND (CASE WHEN t.UpdateDate IS NOT NULL AND o.WantAssetTypeId = 1 THEN o.OfferAssetTypeId
				 WHEN t.UpdateDate IS NOT NULL AND o.WantAssetTypeId <> 1 THEN o.WantAssetTypeId
				 WHEN tr.UpdateDate IS NOT NULL THEN tr.AssetTypeId 
				 WHEN v.UpdateDate IS NOT NULL THEN v.AssetTypeId END = @assetTypeId OR @assetTypeId IS NULL)
		--ORDER BY UpdateDate DESC
		union 
		SELECT
			CASE WHEN t.UpdateDate IS NOT NULL THEN t.UpdateDate 
				 WHEN tr.UpdateDate IS NOT NULL THEN tr.UpdateDate 
				 WHEN v.UpdateDate IS NOT NULL THEN v.UpdateDate END 
				 AS   UpdateDate, 
			CASE WHEN at.VoucherId IS NOT NULL THEN at.VoucherId 
				 WHEN tr.RequestId IS NOT NULL THEN CONVERT(NVARCHAR(50), tr.RequestId)
				 ELSE CONVERT(NVARCHAR(50), o.OrderId) END 
				 AS   Id, 
			CASE WHEN o.OrderTypeId = 1 THEN 'Buy'
				 WHEN o.OrderTypeId = 2 THEN 'Sell'
				 ELSE at.TransactionType END 
				 AS   [Type], 
			CASE WHEN at.TransactionType = 'Transaction' 
			THEN (t.A_Amount + t.A_Commission)/case when (t.B_Amount + t.B_Commission) = 0 then 1 else (t.B_Amount + t.B_Commission) end END 
				 AS   OrderPrice,
			CASE WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 1 THEN at.A_CNYBalance 
				 WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 1 THEN at.B_CNYBalance 
				 WHEN o.OrderTypeId = 1 THEN at.A_CNYBalance
				 WHEN o.OrderTypeId = 2 THEN at.B_CNYBalance
				 WHEN tr.Amount IS NOT NULL THEN at.A_CNYBalance ELSE NULL END 
				 AS	  CNYBalance,
			CASE WHEN t.TransactionTypeId IS NOT NULL THEN t.A_Amount
				 WHEN tr.Amount IS NOT NULL AND tr.AssetTypeId = 1 THEN tr.Amount 
				 WHEN v.Value IS NOT NULL AND v.AssetTypeId = 1 THEN v.Value END 
				 AS   CNYAmount,
			CASE WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId <> 1 THEN at.A_Balance 
				 WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId <> 1 THEN at.B_Balance 
				 WHEN o.OrderTypeId = 1 THEN at.A_Balance
				 WHEN o.OrderTypeId = 2 THEN at.B_Balance
				 WHEN tr.Amount IS NOT NULL AND tr.AssetTypeId <> 1 THEN at.A_Balance ELSE null END 
				 AS   BTCBalance,
			CASE WHEN t.TransactionTypeId IS NOT NULL THEN t.B_Amount
				 WHEN tr.Amount IS NOT NULL AND tr.AssetTypeId <> 1 THEN tr.Amount 
				 WHEN v.Value IS NOT NULL AND v.AssetTypeId <> 1 THEN v.Value END 
				 AS   BTCAmount,
			CASE WHEN o.OrderTypeId = 1 THEN t.B_Commission 
			     WHEN o.OrderTypeId = 2 THEN t.A_Commission 
				 WHEN tr.RequestId is not null THEN tr.Commision
				 ELSE 0 END 
				 AS   Commission,
			CASE WHEN ba.AddressId IS NOT NULL THEN ba.AddressId 
				 WHEN bt.TransactionBank IS NOT NULL THEN bt.TransactionBank ELSE NULL END
				 AS   AddressId,
		    CASE WHEN v.[AssetTypeId] IS NOT NULL THEN v.[AssetTypeId]
				 WHEN tr.[AssetTypeId] IS NOT NULL THEN tr.[AssetTypeId]
				 WHEN o.OrderTypeId = 1 THEN o.[WantAssetTypeId]
				 WHEN o.OrderTypeId = 2 THEN o.[OfferAssetTypeId]
			     ELSE NULL END 
				 AS   AssetTypeId,
			CASE WHEN o.OrderTypeId = 2 THEN o.[WantAssetTypeId]
				 WHEN o.OrderTypeId = 1 THEN o.[OfferAssetTypeId]
			     ELSE NULL END 
				 AS   OppositeAssetTypeId,
			at.AdvanceTransactionId AS AdvanceTransactionId
		   -- CASE WHEN o.ParentOrderId IS NOT NULL THEN 1
			  --   ELSE 0 END 
				 --AS   HasSubOrder
		FROM AdvancedTransaction at WITH (NOLOCK) 
			LEFT JOIN [Transaction] t WITH (NOLOCK) ON at.TransactionId = t.TransactionId
			LEFT JOIN [TransferRequest] tr WITH (NOLOCK) ON at.TransferRequestId = tr.RequestId
			LEFT JOIN [Voucher] v WITH (NOLOCK) ON at.VoucherId = v.VoucherId 
			LEFT JOIN [OrderBook] o WITH (NOLOCK) ON  o.OrderId = t.B_OrderId
			LEFT JOIN BitcoinAddress ba WITH (NOLOCK) ON tr.BitcoinAddressId = ba.BitcoinAddressId
			LEFT JOIN BankTransaction bt WITH (NOLOCK) ON tr.BankTransactionId = bt.BankTransactionId
		WHERE @customerId IN (o.CustomerId,tr.CustomerId,v.IssuedByCustomerId,v.RedeemedByCustomerId) 
			AND (CASE WHEN t.UpdateDate IS NOT NULL THEN t.UpdateDate 
				 WHEN tr.UpdateDate IS NOT NULL THEN tr.UpdateDate 
				 WHEN v.UpdateDate IS NOT NULL THEN v.UpdateDate END >= @startdate OR @startdate IS NULL OR @startdate = '')
			AND (CASE WHEN t.UpdateDate IS NOT NULL THEN t.UpdateDate 
				 WHEN tr.UpdateDate IS NOT NULL THEN tr.UpdateDate 
				 WHEN v.UpdateDate IS NOT NULL THEN v.UpdateDate END <= CONVERT(VARCHAR(50), DATEADD(ms,-3, DATEADD(dd, 1, @enddate)), 120) 
				 OR @enddate IS NULL OR @enddate = '')
			AND ((at.TransactionType = 'Transaction' AND t.TransactionTypeId = CASE WHEN @filter = 'Buy' THEN 1 WHEN @filter = 'Sell' THEN 2 END) 
			 OR at.TransactionType LIKE ('%' + @filter + '%') OR @filter IS NULL OR @filter = '')
			AND (CASE WHEN t.UpdateDate IS NOT NULL AND o.WantAssetTypeId = 1 THEN o.OfferAssetTypeId
				 WHEN t.UpdateDate IS NOT NULL AND o.WantAssetTypeId <> 1 THEN o.WantAssetTypeId
				 WHEN tr.UpdateDate IS NOT NULL THEN tr.AssetTypeId 
				 WHEN v.UpdateDate IS NOT NULL THEN v.AssetTypeId END = @assetTypeId OR @assetTypeId IS NULL)
		ORDER BY UpdateDate DESC
		--ORDER BY AdvanceTransactionId DESC

		select 1000000
END

