USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetAdvancedTransactionForCustomerForWeb]    Script Date: 2017/06/22 14:42:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_GetAdvancedTransactionForCustomerForWeb]
  @customerId INT,
  @assetTypeId INT = NULL,
  @startdate VARCHAR(50),
  @enddate VARCHAR(50),
  @filter NVARCHAR(50),
  @pageSize INT,
  @page INT

AS
BEGIN

  WITH PageNumbers AS(
      SELECT *,
        ROW_NUMBER() OVER(ORDER BY [Time] desc) ROWID
      FROM

        -- VOUCHERS
        (SELECT
           v.UpdateDate AS [Time],
           v.VoucherId AS [Id],
           'Voucher' AS [Type],
           AssetType_lkp.Name AS [Pair],
           'N/A' AS [Order Price],
           v.Value AS [Quantity],
           'N/A' AS [Amount],
           'N/A' AS [Commission],
		   'N/A' as [ExecutionPrice],
           'N/A' AS [Address],

           CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 1 THEN at.A_CNYBalance
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 1 THEN at.B_CNYBalance
           ELSE NULL
           END
             AS 'CNY Balance',

           CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 2 THEN at.A_Balance
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 2 THEN at.B_Balance
           ELSE null
           END
             AS 'BTC Balance',

           CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 5 THEN at.A_Balance
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 5 THEN at.B_Balance
           ELSE null
           END
             AS 'ETH Balance',

           CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 6 THEN at.A_Balance
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 6 THEN at.B_Balance
           ELSE null
           END
             AS 'ETC Balance',

           CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 7 THEN at.A_Balance
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 7 THEN at.B_Balance
           ELSE null
           END
             AS 'SKY Balance',
	   
		   v.AssetTypeId as AssetTypeId,
	   
           v.AssetTypeId AS OfferAssetTypeId,
		   null AS WantAssetTypeId
		   --AssetType_lkp.Symbol QSymbol,
		   --null PSymbol

         FROM Voucher as v with (nolock)
           INNER JOIN AssetType_lkp with (nolock) ON v.AssetTypeId = AssetType_lkp.AssetTypeId
           INNER JOIN AdvancedTransaction as at with (nolock) ON at.VoucherId = v.VoucherId

         -- customer filter
         WHERE (v.IssuedByCustomerId = @customerId or v.RedeemedByCustomerId = @customerId)
               -- startdate filter
               AND (v.UpdateDate >= @startdate OR @startdate IS NULL OR @startdate = '')
               -- enddate filter
               AND ( v.UpdateDate <= CONVERT(VARCHAR(50), DATEADD(ms,-3, DATEADD(dd, 1, @enddate)), 120)
                     OR @enddate IS NULL OR @enddate = '')
               -- generic filter
               AND (at.TransactionType LIKE ('%' + @filter + '%') OR @filter IS NULL OR @filter = '')
               -- assettype filter
               AND (v.AssetTypeId = @assetTypeId OR @assetTypeId IS NULL)

         UNION

         -- TRANSFER REQUESTS
         SELECT
           tr.UpdateDate AS [Time],
           CONVERT(NVARCHAR(50), tr.RequestId) AS [Id],
           RequestType_lkp.Name AS [Type],
           'N/A' AS [Pair],
           'N/A' AS [Order Price],
           tr.Amount AS [Quantity],
           'N/A' AS [Amount],
           CONVERT(NVARCHAR(50), tr.Commision) AS [Commission],
		   'N/A' as [ExecutionPrice],
           CASE WHEN ba.AddressId IS NOT NULL THEN ba.AddressId
           WHEN bt.TransactionBank IS NOT NULL THEN bt.TransactionBank ELSE NULL END
             AS [Address],

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 1 THEN at.A_CNYBalance
           ELSE NULL
           END
             AS 'CNY Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 2 THEN at.A_Balance
           ELSE null
           END
             AS 'BTC Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 5 THEN at.A_Balance
           ELSE null
           END
             AS 'ETH Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 6 THEN at.A_Balance
           ELSE null
           END
             AS 'ETC Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 7 THEN at.A_Balance
           ELSE null
           END
             AS 'SKY Balance',
	   
	       tr.AssetTypeId as AssetTypeId,
	   
           tr.AssetTypeId AS OfferAssetTypeId,
		   null AS WantAssetTypeId
		   --null QSymbol,
		   --null PSymbol

         FROM TransferRequest as tr with (nolock)
           INNER JOIN RequestType_lkp with (nolock) ON tr.RequestTypeId = RequestType_lkp.RequestTypeId
           INNER JOIN AdvancedTransaction as at with (nolock) ON tr.RequestId = at.TransferRequestId
           LEFT JOIN BitcoinAddress ba WITH (NOLOCK) ON tr.BitcoinAddressId = ba.BitcoinAddressId
           LEFT JOIN BankTransaction bt WITH (NOLOCK) ON tr.BankTransactionId = bt.BankTransactionId
		   --LEFT JOIN AssetType_lkp atlQ with (nolock) ON tr.AssetTypeId = atlQ.AssetTypeId

         -- customer filter
         where tr.CustomerId = @customerId
               -- startdate filter
               AND (tr.UpdateDate >= @startdate OR @startdate IS NULL OR @startdate = '')
               -- enddate filter
               AND ( tr.UpdateDate <= CONVERT(VARCHAR(50), DATEADD(ms,-3, DATEADD(dd, 1, @enddate)), 120)
                     OR @enddate IS NULL OR @enddate = '')
               -- generic filter
               AND (at.TransactionType LIKE ('%' + @filter + '%') OR @filter IS NULL OR @filter = '')
               -- assettype filter
               AND (tr.AssetTypeId = @assetTypeId OR @assetTypeId IS NULL)
               and tr.RequestTypeId not in (1,5,8,10,12)
         UNION
         -- TRANSFER REQUESTS
         SELECT
           tr.UpdateDate AS [Time],
           CONVERT(NVARCHAR(50), tr.RequestId) AS [Id],
           RequestType_lkp.Name AS [Type],
           'N/A' AS [Pair],
           'N/A' AS [Order Price],
           tr.Amount AS [Quantity],
           'N/A' AS [Amount],
           CONVERT(NVARCHAR(50), tr.Commision) AS [Commission],
		   'N/A' as [ExecutionPrice],
           CASE WHEN ba.AddressId IS NOT NULL THEN ba.AddressId
           WHEN bt.TransactionBank IS NOT NULL THEN bt.TransactionBank ELSE NULL END
             AS [Address],

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 1 THEN at.A_CNYBalance
           ELSE NULL
           END
             AS 'CNY Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 2 THEN at.A_CNYBalance
           ELSE null
           END
             AS 'BTC Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 5 THEN at.A_CNYBalance
           ELSE null
           END
             AS 'ETH Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 6 THEN at.A_CNYBalance
           ELSE null
           END
             AS 'ETC Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 7 THEN at.A_CNYBalance
           ELSE null
           END
             AS 'SKY Balance',
	   
	       tr.AssetTypeId as AssetTypeId,
	   
           tr.AssetTypeId AS OfferAssetTypeId,
		   null AS WantAssetTypeId
		   --null QSymbol,
		   --null PSymbol

         FROM TransferRequest as tr with (nolock)
           INNER JOIN RequestType_lkp with (nolock) ON tr.RequestTypeId = RequestType_lkp.RequestTypeId
           INNER JOIN AdvancedTransaction as at with (nolock) ON tr.RequestId = at.TransferRequestId
           LEFT JOIN BitcoinAddress ba WITH (NOLOCK) ON tr.BitcoinAddressId = ba.BitcoinAddressId
           LEFT JOIN BankTransaction bt WITH (NOLOCK) ON tr.BankTransactionId = bt.BankTransactionId
		   --LEFT JOIN AssetType_lkp atlQ with (nolock) ON tr.AssetTypeId = atlQ.AssetTypeId

         -- customer filter
         where tr.CustomerId = @customerId
               -- startdate filter
               AND (tr.UpdateDate >= @startdate OR @startdate IS NULL OR @startdate = '')
               -- enddate filter
               AND ( tr.UpdateDate <= CONVERT(VARCHAR(50), DATEADD(ms,-3, DATEADD(dd, 1, @enddate)), 120)
                     OR @enddate IS NULL OR @enddate = '')
               -- generic filter
               AND (at.TransactionType LIKE ('%' + @filter + '%') OR @filter IS NULL OR @filter = '')
               -- assettype filter
               AND (tr.AssetTypeId = @assetTypeId OR @assetTypeId IS NULL)
               and tr.RequestTypeId  in (1,5,8,10,12)
         UNION

         -------------------------------


         -- TRANSACTION BUY
         SELECT
           t.UpdateDate AS [Time],
           CONVERT(VARCHAR(50), o.OrderId) AS [Id],

           CASE
           when o.MarketOrder = 1 then 'Market Buy'
           ELSE 'Limit Buy' end AS [Type],

           CASE
		   WHEN o.WantAssetTypeId = 2 AND o.OfferAssetTypeId = 5 THEN 'ETH/BTC'
		   WHEN o.WantAssetTypeId = 2 AND o.OfferAssetTypeId = 1 THEN 'CNY/BTC'
		   WHEN o.WantAssetTypeId = 5 AND o.OfferAssetTypeId = 1 THEN 'CNY/ETH'
           WHEN o.WantAssetTypeId = 6 THEN 'CNY/ETC'
           WHEN o.WantAssetTypeId = 7 AND o.OfferAssetTypeId = 1 THEN 'CNY/SKY'
		   WHEN o.WantAssetTypeId = 7 AND o.OfferAssetTypeId = 5 THEN 'ETH/SKY'
           ELSE null
           END AS [Pair],

           CONVERT(VARCHAR(50), o.Price) AS [Order Price],
           --o.Quantity AS [Quantity],
		   (t.B_Amount + t.B_Commission) AS [Quantity],
           CONVERT(VARCHAR(50), t.A_Amount) AS [Amount],
           CONVERT(VARCHAR(50), t.B_Commission) AS [Commission],
		    
		   --
		   CASE WHEN (t.B_Amount + t.B_Commission) = 0 THEN '0'
				ELSE 
					CONVERT(VARCHAR(50), (t.A_Amount + t.A_Commission) / (t.B_Amount + t.B_Commission))
				END AS ExecutionPrice,
           'N/A' AS [Address],

           CASE WHEN o.OfferAssetTypeId = 1 then at.A_CNYBalance end AS 'CNY Balance',

           CASE
           WHEN o.WantAssetTypeId = 2 THEN at.A_Balance
           ELSE null
           END
             AS 'BTC Balance',

           CASE
           WHEN o.WantAssetTypeId = 5 THEN at.A_Balance
		   WHEN o.OfferAssetTypeId = 5 THEN at.A_CNYBalance
           ELSE null
           END
             AS 'ETH Balance',

           CASE
           WHEN o.WantAssetTypeId = 6 THEN at.A_Balance
           ELSE null
           END
             AS 'ETC Balance',

           CASE
           WHEN o.WantAssetTypeId = 7 THEN at.A_Balance
		   WHEN o.OfferAssetTypeId = 7 THEN at.A_CNYBalance
           ELSE null
           END
             AS 'SKY Balance',
	     
		   CASE
		   WHEN o.WantAssetTypeId = 1 THEN o.OfferAssetTypeId
           WHEN o.WantAssetTypeId <> 1 THEN o.WantAssetTypeId
           ELSE null
           END
             AS AssetTypeId,
	     
           o.OfferAssetTypeId AS OfferAssetTypeId,
		   o.WantAssetTypeId AS WantAssetTypeId
		   --null QSymbol,
		   --null PSymbol

         FROM [Transaction] as t with (nolock)
           INNER JOIN AdvancedTransaction as at with (nolock) on at.TransactionId = t.TransactionId
           INNER JOIN OrderBook as o with (nolock) ON o.OrderId = t.A_OrderId
		   --LEFT JOIN AssetType_lkp atlQ WITH (NOLOCK) ON atlQ.AssetTypeId = o.WantAssetTypeId
		   --LEFT JOIN AssetType_lkp atlP WITH (NOLOCK) ON atlP.AssetTypeId = o.OfferAssetTypeId
         -- customer filter
         where o.CustomerId = @customerId
               -- startdate filter
               AND (t.UpdateDate >= @startdate OR @startdate IS NULL OR @startdate = '')
               -- enddate filter
               AND ( t.UpdateDate <= CONVERT(VARCHAR(50), DATEADD(ms,-3, DATEADD(dd, 1, @enddate)), 120)
                     OR @enddate IS NULL OR @enddate = '')
               -- generic filter
               AND (at.TransactionType = 'Transaction' AND
                    (@filter = 'Buy' OR @filter IS NULL OR @filter = ''))
               -- assettype filter
               AND (CASE WHEN o.WantAssetTypeId = 1 THEN o.OfferAssetTypeId
                    WHEN o.WantAssetTypeId <> 1 THEN o.WantAssetTypeId
                    END = @assetTypeId OR @assetTypeId IS NULL)

         UNION


         -- TRANSACTION SELL
         SELECT
           t.UpdateDate AS [Time],
           CONVERT(VARCHAR(50), o.OrderId) AS [Id],

           CASE
           when o.MarketOrder = 1 then 'Market Sell'
           ELSE 'Limit Sell' end AS [Type],

           CASE
		   WHEN o.OfferAssetTypeId = 2 AND o.WantAssetTypeId = 1 THEN 'CNY/BTC'
           WHEN o.OfferAssetTypeId = 2 AND o.WantAssetTypeId = 5 THEN 'ETH/BTC'
           WHEN o.OfferAssetTypeId = 5 AND o.WantAssetTypeId = 1 THEN 'CNY/ETH'
           WHEN o.OfferAssetTypeId = 6 THEN 'CNY/ETC'
           WHEN o.OfferAssetTypeId = 7 AND o.WantAssetTypeId = 1 THEN 'CNY/SKY'
		   WHEN o.OfferAssetTypeId = 7 AND o.WantAssetTypeId = 5 THEN 'ETH/SKY'
           ELSE null
           END AS [Pair],
           CONVERT(VARCHAR(50), o.Price) AS [Order Price],
           --o.Quantity AS [Quantity],
           --CONVERT(VARCHAR(50), t.B_Amount) AS [Amount],
           --CONVERT(VARCHAR(50), t.B_Commission) AS [Commission],
		   (t.B_Amount + t.B_Commission) AS [Quantity],
           CONVERT(VARCHAR(50), t.A_Amount) AS [Amount],
           CONVERT(VARCHAR(50), t.A_Commission) AS [Commission],
		   CASE WHEN (t.B_Amount + t.B_Commission) = 0 THEN '0'
				ELSE 
					CONVERT(VARCHAR(50), (t.A_Amount + t.A_Commission) / (t.B_Amount + t.B_Commission)) 
				END AS ExecutionPrice,
           'N/A' AS [Address],

           CASE WHEN o.WantAssetTypeId = 1 then at.B_CNYBalance end AS 'CNY Balance',

           CASE
           WHEN o.OfferAssetTypeId = 2 and o.WantAssetTypeId = 1 THEN at.B_Balance
		   WHEN o.OfferAssetTypeId = 2 and o.WantAssetTypeId <> 1 THEN at.B_CNYBalance
           ELSE null
           END
             AS 'BTC Balance',

           CASE
           WHEN o.OfferAssetTypeId = 5 or WantAssetTypeId = 5 THEN at.B_Balance
           ELSE null
           END
             AS 'ETH Balance',

           CASE
           WHEN o.OfferAssetTypeId = 6 THEN at.B_Balance
           ELSE null
           END
             AS 'ETC Balance',

           CASE
           WHEN o.OfferAssetTypeId = 7 and o.WantAssetTypeId = 1 THEN at.B_Balance
		   WHEN o.OfferAssetTypeId = 7 and o.WantAssetTypeId <> 1 THEN at.B_CNYBalance
           ELSE null
           END
             AS 'SKY Balance',

	       CASE
		   WHEN o.WantAssetTypeId = 1 THEN o.OfferAssetTypeId
           WHEN o.WantAssetTypeId <> 1 THEN o.WantAssetTypeId
           ELSE null
           END
             AS AssetTypeId,

           o.OfferAssetTypeId AS OfferAssetTypeId,
		   o.WantAssetTypeId AS WantAssetTypeId
		   --null QSymbol,
		   --null PSymbol

         FROM [Transaction] as t with (nolock)
           INNER JOIN AdvancedTransaction as at with (nolock) on at.TransactionId = t.TransactionId
           INNER JOIN OrderBook as o with (nolock) ON o.OrderId = t.B_OrderId
		   --LEFT JOIN AssetType_lkp atlQ WITH (NOLOCK) ON atlQ.AssetTypeId = o.WantAssetTypeId
		   --LEFT JOIN AssetType_lkp atlP WITH (NOLOCK) ON atlP.AssetTypeId = o.OfferAssetTypeId
         -- customer filter
         where o.CustomerId = @customerId
               -- startdate filter
               AND (t.UpdateDate >= @startdate OR @startdate IS NULL OR @startdate = '')
               -- enddate filter
               AND ( t.UpdateDate <= CONVERT(VARCHAR(50), DATEADD(ms,-3, DATEADD(dd, 1, @enddate)), 120)
                     OR @enddate IS NULL OR @enddate = '')
               -- generic filter
               AND (at.TransactionType = 'Transaction' AND
                    (@filter = 'Sell' OR @filter IS NULL OR @filter = ''))
               -- assettype filter
               AND (CASE WHEN o.WantAssetTypeId = 1 THEN o.OfferAssetTypeId
                    WHEN o.WantAssetTypeId <> 1 THEN o.WantAssetTypeId
                    END = @assetTypeId OR @assetTypeId IS NULL)
		) as a)


  -- Create temporary table from result
  SELECT * INTO #temp FROM (SELECT * FROM PageNumbers) AS b

  CREATE INDEX index_RowId ON #temp(ROWID);

  -- Select result set
  SELECT * FROM #temp with (nolock)
  WHERE ROWID BETWEEN ((@page - 1) * @pageSize + 1)
  AND (@page * @pageSize)

  -- Count total rows
  SELECT count(*) FROM #temp with (nolock)

  -- Drop temporary table
  drop table #temp

END