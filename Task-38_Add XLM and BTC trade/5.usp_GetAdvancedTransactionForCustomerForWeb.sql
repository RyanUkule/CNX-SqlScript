USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetAdvancedTransactionForCustomerForWeb]    Script Date: 2018/05/17 16:01:07 ******/
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
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 1 THEN at.[A_OfferBalanceAfterTransaction]
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 1 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE NULL
           END
             AS 'CNY Balance',

           CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 2 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 2 THEN at.B_WantBalanceAfterTransaction
           ELSE null
           END
             AS 'BTC Balance',

           CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 5 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 5 THEN at.B_WantBalanceAfterTransaction
           ELSE null
           END
             AS 'ETH Balance',

           CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 6 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 6 THEN at.B_WantBalanceAfterTransaction
           ELSE null
           END
             AS 'ETC Balance',

           CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 7 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 7 THEN at.B_WantBalanceAfterTransaction
           ELSE null
           END
             AS 'SKY Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 8 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 8 THEN at.B_WantBalanceAfterTransaction
           ELSE null
           END
             AS 'SHL Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 9 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 9 THEN at.B_WantBalanceAfterTransaction
           ELSE null
           END
             AS 'BCC Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 10 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 10 THEN at.B_WantBalanceAfterTransaction
           ELSE null
           END
             AS 'ZEC Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 11 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 11 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'DRG Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 13 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 13 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'BTG Balance',
		   
		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 15 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 15 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'USDT Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 3 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 3 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'LTC Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 16 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 16 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'DASH Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 17 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 17 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'ZRX Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 18 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 18 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'FUN Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 19 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 19 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'TNB Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 20 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 20 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'ETP Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 21 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 21 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'UCASH Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 22 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 22 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'CCOIN Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 23 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 23 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'OMG Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 24 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 24 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'RCN Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 25 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 25 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'XRP Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 26 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 26 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'EOS Balance',

		   CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 28 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 28 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'WAX Balance',
			 CASE
           WHEN v.IssuedByCustomerId = @customerId AND v.AssetTypeId = 29 THEN at.A_WantBalanceAfterTransaction
           WHEN v.RedeemedByCustomerId = @customerId AND v.AssetTypeId = 29 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'XLM Balance',

           v.AssetTypeId as AssetTypeId,
		   v.AssetTypeId AS OfferAssetTypeId,
		   null AS WantAssetTypeId
		   --AssetType_lkp.Symbol QSymbol,
		   --null PSymbol

         FROM Voucher as v with (nolock)
           INNER JOIN AssetType_lkp with (nolock) ON v.AssetTypeId = AssetType_lkp.AssetTypeId
           INNER JOIN AdvancedTransactionV1 as at with (nolock) ON at.TransactionId = v.TransactionId and at.TransactionTypeId = 4

         -- customer filter
         WHERE (@filter = 'voucher' or @filter = 'all' or @filter is null or @filter = '')
			   AND (v.IssuedByCustomerId = @customerId or v.RedeemedByCustomerId = @customerId)
               -- startdate filter
               AND (v.UpdateDate >= @startdate OR @startdate IS NULL OR @startdate = '')
               -- enddate filter
               AND ( v.UpdateDate <= CONVERT(VARCHAR(50), DATEADD(ms,-3, DATEADD(dd, 1, @enddate)), 120)
                     OR @enddate IS NULL OR @enddate = '')
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
		   --tr.Amount AS [Quantity],
           case when tr.AssetTypeId = 1 then bt.TransactionAmount else tr.Amount end AS [Quantity],
           'N/A' AS [Amount],
           CONVERT(NVARCHAR(50), tr.Commision) AS [Commission],
		   'N/A' as [ExecutionPrice],
           CASE WHEN ba.AddressId IS NOT NULL THEN ba.AddressId
           WHEN bt.TransactionBank IS NOT NULL THEN bt.TransactionBank ELSE NULL END
             AS [Address],

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 1 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE NULL
           END
             AS 'CNY Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 2 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'BTC Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 5 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'ETH Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 6 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'ETC Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 7 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'SKY Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 8 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'SHL Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 9 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'BCC Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 10 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'ZEC Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 11 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'DRG Balance',
		   
		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 13 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'BTG Balance',
		   
		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 15 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'USDT Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 3 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'LTC Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 16 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'DASH Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 17 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'ZRX Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 18 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'FUN Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 19 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'TNB Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 20 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'ETP Balance',
		   
		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 21 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'UCASH Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 22 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'CCOIN Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 23 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'OMG Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 24 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'RCN Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 25 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'XRP Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 26 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'EOS Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 28 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'WAX Balance',

			  CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 29 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'XLM Balance',
           tr.AssetTypeId as AssetTypeId,
		   tr.AssetTypeId AS OfferAssetTypeId,
		   null AS WantAssetTypeId
		   --null QSymbol,
		   --null PSymbol

         FROM TransferRequest as tr with (nolock)
           INNER JOIN RequestType_lkp with (nolock) ON tr.RequestTypeId = RequestType_lkp.RequestTypeId
           INNER JOIN AdvancedTransactionV1 as at with (nolock) ON tr.RequestId = at.TransactionId and at.TransactionTypeId = 3
           LEFT JOIN BitcoinAddress ba WITH (NOLOCK) ON tr.BitcoinAddressId = ba.BitcoinAddressId
           LEFT JOIN BankTransaction bt WITH (NOLOCK) ON tr.BankTransactionId = bt.BankTransactionId
		   --LEFT JOIN AssetType_lkp atlQ with (nolock) ON tr.AssetTypeId = atlQ.AssetTypeId

         -- customer filter
         where (@filter = 'deposit' or @filter = ''  or @filter is null or @filter = '')
			   AND tr.CustomerId = @customerId
               -- startdate filter
               AND (tr.UpdateDate >= @startdate OR @startdate IS NULL OR @startdate = '')
               -- enddate filter
               AND ( tr.UpdateDate <= CONVERT(VARCHAR(50), DATEADD(ms,-3, DATEADD(dd, 1, @enddate)), 120)
                     OR @enddate IS NULL OR @enddate = '')
               -- assettype filter
               AND (tr.AssetTypeId = @assetTypeId OR @assetTypeId IS NULL)
               --and tr.RequestTypeId not in (1,5,8,10,12)
         UNION
         -- TRANSFER REQUESTS
         SELECT
           tr.UpdateDate AS [Time],
           CONVERT(NVARCHAR(50), tr.RequestId) AS [Id],
           RequestType_lkp.Name AS [Type],
           'N/A' AS [Pair],
           'N/A' AS [Order Price],
           --tr.Amount AS [Quantity],
		   case when tr.AssetTypeId = 1 then bt.TransactionAmount else tr.Amount end AS [Quantity],
           'N/A' AS [Amount],
           CONVERT(NVARCHAR(50), tr.Commision) AS [Commission],
		   'N/A' as [ExecutionPrice],
           CASE WHEN ba.AddressId IS NOT NULL THEN ba.AddressId
           WHEN bt.TransactionBank IS NOT NULL THEN bt.TransactionBank ELSE NULL END
             AS [Address],

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 1 THEN at.[A_WantBalanceAfterTransaction]
           ELSE NULL
           END
             AS 'CNY Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 2 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'BTC Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 5 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'ETH Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 6 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'ETC Balance',

           CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 7 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'SKY Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 8 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'SHL Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 9 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'BCC Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 10 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'ZEC Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 11 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'DRG Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 13 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'BTG Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 15 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'USDT Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 3 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'LTC Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 16 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'DASH Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 17 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'ZRX Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 18 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'FUN Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 19 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'TNB Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 20 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'ETP Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 21 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'UCASH Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 22 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'CCOIN Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 23 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'OMG Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 24 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'RCN Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 25 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'XRP Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 26 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'EOS Balance',

		   CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 28 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'WAX Balance',

			 CASE
           WHEN tr.CustomerId = @customerId AND tr.AssetTypeId = 29 THEN at.[A_WantBalanceAfterTransaction]
           ELSE null
           END
             AS 'XLM Balance',
           tr.AssetTypeId as AssetTypeId,
		   tr.AssetTypeId AS OfferAssetTypeId,
		   null AS WantAssetTypeId
		   --null QSymbol,
		   --null PSymbol

         FROM TransferRequest as tr with (nolock)
           INNER JOIN RequestType_lkp with (nolock) ON tr.RequestTypeId = RequestType_lkp.RequestTypeId
           INNER JOIN AdvancedTransactionV1 as at with (nolock) ON tr.RequestId = at.TransactionId and at.TransactionTypeId = 2
           LEFT JOIN BitcoinAddress ba WITH (NOLOCK) ON tr.BitcoinAddressId = ba.BitcoinAddressId
           LEFT JOIN BankTransaction bt WITH (NOLOCK) ON tr.BankTransactionId = bt.BankTransactionId
		   --LEFT JOIN AssetType_lkp atlQ with (nolock) ON tr.AssetTypeId = atlQ.AssetTypeId

         -- customer filter
         where (@filter = 'withdrawal' or @filter = ''  or @filter is null or @filter = '')
			   AND tr.CustomerId = @customerId
               -- startdate filter
               AND (tr.UpdateDate >= @startdate OR @startdate IS NULL OR @startdate = '')
               -- enddate filter
               AND ( tr.UpdateDate <= CONVERT(VARCHAR(50), DATEADD(ms,-3, DATEADD(dd, 1, @enddate)), 120)
                     OR @enddate IS NULL OR @enddate = '')
               -- assettype filter
               AND (tr.AssetTypeId = @assetTypeId OR @assetTypeId IS NULL)
               --and tr.RequestTypeId  in (1,5,8,10,12)
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
		   WHEN o.WantAssetTypeId = 2 AND o.OfferAssetTypeId = 1 THEN 'CNY/BTC'
		   WHEN o.WantAssetTypeId = 5 AND o.OfferAssetTypeId = 1 THEN 'CNY/ETH'
           WHEN o.WantAssetTypeId = 6 AND o.OfferAssetTypeId = 1 THEN 'CNY/ETC'
           WHEN o.WantAssetTypeId = 7 AND o.OfferAssetTypeId = 1 THEN 'CNY/SKY'
		   WHEN o.WantAssetTypeId = 9 AND o.OfferAssetTypeId = 1 THEN 'CNY/BCC'
		   WHEN o.WantAssetTypeId = 8 AND o.OfferAssetTypeId = 1 THEN 'CNY/SHL'
		   WHEN o.WantAssetTypeId = 10 AND o.OfferAssetTypeId = 1 THEN 'CNY/ZEC'
		   WHEN o.WantAssetTypeId = 11 AND o.OfferAssetTypeId = 1 THEN 'CNY/DRG'

		   WHEN o.WantAssetTypeId = 2 AND o.OfferAssetTypeId = 11 THEN 'DRG/BTC'
		   WHEN o.WantAssetTypeId = 3 AND o.OfferAssetTypeId = 11 THEN 'DRG/LTC'
		   WHEN o.WantAssetTypeId = 5 AND o.OfferAssetTypeId = 11 THEN 'DRG/ETH'
           WHEN o.WantAssetTypeId = 6 AND o.OfferAssetTypeId = 11 THEN 'DRG/ETC'
           WHEN o.WantAssetTypeId = 7 AND o.OfferAssetTypeId = 11 THEN 'DRG/SKY'
		   WHEN o.WantAssetTypeId = 9 AND o.OfferAssetTypeId = 11 THEN 'DRG/BCC'
		   WHEN o.WantAssetTypeId = 8 AND o.OfferAssetTypeId = 11 THEN 'DRG/SHL'
		   WHEN o.WantAssetTypeId = 10 AND o.OfferAssetTypeId = 11 THEN 'DRG/ZEC'
		   WHEN o.WantAssetTypeId = 13 AND o.OfferAssetTypeId = 11 THEN 'DRG/BTG'
		   WHEN o.WantAssetTypeId = 16 AND o.OfferAssetTypeId = 11 THEN 'DRG/DASH'
		   WHEN o.WantAssetTypeId = 17 AND o.OfferAssetTypeId = 11 THEN 'DRG/ZRX'
		   WHEN o.WantAssetTypeId = 18 AND o.OfferAssetTypeId = 11 THEN 'DRG/FUN'
		   WHEN o.WantAssetTypeId = 19 AND o.OfferAssetTypeId = 11 THEN 'DRG/TNB'
		   WHEN o.WantAssetTypeId = 20 AND o.OfferAssetTypeId = 11 THEN 'DRG/ETP'
		   WHEN o.WantAssetTypeId = 23 AND o.OfferAssetTypeId = 11 THEN 'DRG/OMG'
		   WHEN o.WantAssetTypeId = 24 AND o.OfferAssetTypeId = 11 THEN 'DRG/RCN'
		   WHEN o.WantAssetTypeId = 25 AND o.OfferAssetTypeId = 11 THEN 'DRG/XRP'
		   WHEN o.WantAssetTypeId = 26 AND o.OfferAssetTypeId = 11 THEN 'DRG/EOS'
		   WHEN o.WantAssetTypeId = 28 AND o.OfferAssetTypeId = 11 THEN 'DRG/WAX'
		   WHEN o.WantAssetTypeId = 29 AND o.OfferAssetTypeId = 11 THEN 'DRG/XLM'

		   WHEN o.WantAssetTypeId = 2 AND o.OfferAssetTypeId = 5 THEN 'ETH/BTC'
		   WHEN o.WantAssetTypeId = 7 AND o.OfferAssetTypeId = 2 THEN 'BTC/SKY'
		   WHEN o.WantAssetTypeId = 7 AND o.OfferAssetTypeId = 5 THEN 'ETH/SKY'
		   WHEN o.WantAssetTypeId = 9 AND o.OfferAssetTypeId = 2 THEN 'BTC/BCC'
		   WHEN o.WantAssetTypeId = 16 AND o.OfferAssetTypeId = 2 THEN 'BTC/DASH'
		   WHEN o.WantAssetTypeId = 17 AND o.OfferAssetTypeId = 2 THEN 'BTC/ZRX'
		   WHEN o.WantAssetTypeId = 18 AND o.OfferAssetTypeId = 2 THEN 'BTC/FUN'
		   WHEN o.WantAssetTypeId = 19 AND o.OfferAssetTypeId = 2 THEN 'BTC/TNB'
		   WHEN o.WantAssetTypeId = 20 AND o.OfferAssetTypeId = 2 THEN 'BTC/ETP'
		   WHEN o.WantAssetTypeId = 21 AND o.OfferAssetTypeId = 2 THEN 'BTC/UCASH'
		   WHEN o.WantAssetTypeId = 23 AND o.OfferAssetTypeId = 2 THEN 'BTC/OMG'
		   WHEN o.WantAssetTypeId = 24 AND o.OfferAssetTypeId = 2 THEN 'BTC/RCN'
		   WHEN o.WantAssetTypeId = 25 AND o.OfferAssetTypeId = 2 THEN 'BTC/XRP'
		   WHEN o.WantAssetTypeId = 26 AND o.OfferAssetTypeId = 2 THEN 'BTC/EOS'
		   WHEN o.WantAssetTypeId = 28 AND o.OfferAssetTypeId = 2 THEN 'BTC/WAX'
		   WHEN o.WantAssetTypeId = 29 AND o.OfferAssetTypeId = 2 THEN 'BTC/XLM'
		   WHEN o.WantAssetTypeId = 6 AND o.OfferAssetTypeId = 2 THEN 'BTC/ETC'
		   WHEN o.WantAssetTypeId = 3 AND o.OfferAssetTypeId = 2 THEN 'BTC/LTC'
		   WHEN o.WantAssetTypeId = 13 AND o.OfferAssetTypeId = 2 THEN 'BTC/BTG'
		   WHEN o.WantAssetTypeId = 10 AND o.OfferAssetTypeId = 2 THEN 'BTC/ZEC'

		   WHEN o.WantAssetTypeId = 12 AND o.OfferAssetTypeId = 2 THEN 'BTC/CABS'
		   WHEN o.WantAssetTypeId = 12 AND o.OfferAssetTypeId = 5 THEN 'ETH/CABS'
		   WHEN o.WantAssetTypeId = 12 AND o.OfferAssetTypeId = 6 THEN 'ETC/CABS'
		   WHEN o.WantAssetTypeId = 12 AND o.OfferAssetTypeId = 9 THEN 'BCC/CABS'
		   
		   WHEN o.WantAssetTypeId = 9 AND o.OfferAssetTypeId = 5 THEN 'ETH/BCC'
		   WHEN o.WantAssetTypeId = 5 AND o.OfferAssetTypeId = 2 THEN 'BTC/ETH'
		   WHEN o.WantAssetTypeId = 5 AND o.OfferAssetTypeId = 12 THEN 'CABS/ETH'
		   WHEN o.WantAssetTypeId = 5 AND o.OfferAssetTypeId = 14 THEN 'FCABS/ETH'

		   WHEN o.WantAssetTypeId = 2 AND o.OfferAssetTypeId = 15 THEN 'USDT/BTC'
		   WHEN o.WantAssetTypeId = 3 AND o.OfferAssetTypeId = 15 THEN 'USDT/LTC'
		   WHEN o.WantAssetTypeId = 5 AND o.OfferAssetTypeId = 15 THEN 'USDT/ETH'
           WHEN o.WantAssetTypeId = 6 AND o.OfferAssetTypeId = 15 THEN 'USDT/ETC'
		   WHEN o.WantAssetTypeId = 7 AND o.OfferAssetTypeId = 15 THEN 'USDT/SKY'
           WHEN o.WantAssetTypeId = 9 AND o.OfferAssetTypeId = 15 THEN 'USDT/BCC'
		   WHEN o.WantAssetTypeId = 10 AND o.OfferAssetTypeId = 15 THEN 'USDT/ZEC'
		   WHEN o.WantAssetTypeId = 11 AND o.OfferAssetTypeId = 15 THEN 'USDT/DRG'
		   WHEN o.WantAssetTypeId = 13 AND o.OfferAssetTypeId = 15 THEN 'USDT/BTG'
		   WHEN o.WantAssetTypeId = 16 AND o.OfferAssetTypeId = 15 THEN 'USDT/DASH'
		   WHEN o.WantAssetTypeId = 17 AND o.OfferAssetTypeId = 15 THEN 'USDT/ZRX'
		   WHEN o.WantAssetTypeId = 18 AND o.OfferAssetTypeId = 15 THEN 'USDT/FUN'
		   WHEN o.WantAssetTypeId = 19 AND o.OfferAssetTypeId = 15 THEN 'USDT/TNB'
		   WHEN o.WantAssetTypeId = 20 AND o.OfferAssetTypeId = 15 THEN 'USDT/ETP'
		   WHEN o.WantAssetTypeId = 21 AND o.OfferAssetTypeId = 15 THEN 'USDT/UCASH'
		   WHEN o.WantAssetTypeId = 22 AND o.OfferAssetTypeId = 15 THEN 'USDT/CCOIN'
		   WHEN o.WantAssetTypeId = 23 AND o.OfferAssetTypeId = 15 THEN 'USDT/OMG'
		   WHEN o.WantAssetTypeId = 24 AND o.OfferAssetTypeId = 15 THEN 'USDT/RCN'
		   WHEN o.WantAssetTypeId = 25 AND o.OfferAssetTypeId = 15 THEN 'USDT/XRP'
		   WHEN o.WantAssetTypeId = 26 AND o.OfferAssetTypeId = 15 THEN 'USDT/EOS'
		   WHEN o.WantAssetTypeId = 28 AND o.OfferAssetTypeId = 15 THEN 'USDT/WAX'
		   WHEN o.WantAssetTypeId = 29 AND o.OfferAssetTypeId = 15 THEN 'USDT/XLM'

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
					CONVERT(VARCHAR(50),  Convert(decimal(20,8),Convert(decimal(20,8),(t.A_Amount + t.A_Commission)) / Convert(decimal(20,8),(t.B_Amount + t.B_Commission))))
				END AS ExecutionPrice,
           'N/A' AS [Address],

           CASE 
		   WHEN o.WantAssetTypeId = 1 then at.A_WantBalanceAfterTransaction 
		   WHEN o.OfferAssetTypeId = 1 then at.[A_OfferBalanceAfterTransaction] 
		   end 
		     AS 'CNY Balance',

           CASE
           WHEN o.WantAssetTypeId = 2 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 2 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'BTC Balance',

           CASE
           WHEN o.WantAssetTypeId = 5 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 5 THEN at.[A_OfferBalanceAfterTransaction]
		   --when o.OfferAssetTypeId = 2 then at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'ETH Balance',

           CASE
           WHEN o.WantAssetTypeId = 6 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 6 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'ETC Balance',

           CASE
           WHEN o.WantAssetTypeId = 7 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 7 THEN at.[A_OfferBalanceAfterTransaction]
		   --when o.offerAssetTypeId = 2 then at.A_WantBalanceAfterTransaction
           ELSE null
           END
             AS 'SKY Balance',
		   
		   CASE
           WHEN o.WantAssetTypeId = 8 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 8 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'SHL Balance',

		   CASE
           WHEN o.WantAssetTypeId = 9 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 9 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'BCC Balance',

		   CASE
           WHEN o.WantAssetTypeId = 10 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 10 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'ZEC Balance',

		   CASE
           WHEN o.WantAssetTypeId = 11 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 11 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'DRG Balance',

		   CASE
           WHEN o.WantAssetTypeId = 13 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 13 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'BTG Balance',

		   CASE
           WHEN o.WantAssetTypeId = 15 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 15 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'USDT Balance',

		   CASE
           WHEN o.WantAssetTypeId = 3 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 3 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'LTC Balance',

		   CASE
           WHEN o.WantAssetTypeId = 16 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 16 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'DASH Balance',

		   CASE
           WHEN o.WantAssetTypeId = 17 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 17 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'ZRX Balance',

		   CASE
           WHEN o.WantAssetTypeId = 18 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 18 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'FUN Balance',

		   CASE
           WHEN o.WantAssetTypeId = 19 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 19 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'TNB Balance',

		   CASE
           WHEN o.WantAssetTypeId = 20 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 20 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'ETP Balance',
		   
		   CASE
           WHEN o.WantAssetTypeId = 21 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 21 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'UCASH Balance',

		   CASE
           WHEN o.WantAssetTypeId = 22 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 22 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'CCOIN Balance',

		   CASE
           WHEN o.WantAssetTypeId = 23 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 23 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'OMG Balance',

		   CASE
           WHEN o.WantAssetTypeId = 24 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 24 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'RCN Balance',

		   CASE
           WHEN o.WantAssetTypeId = 25 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 25 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'XRP Balance',

		   CASE
           WHEN o.WantAssetTypeId = 26 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 26 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'EOS Balance',

		   CASE
           WHEN o.WantAssetTypeId = 28 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 28 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'WAX Balance',

		   CASE
           WHEN o.WantAssetTypeId = 29 THEN at.A_WantBalanceAfterTransaction
		   WHEN o.OfferAssetTypeId = 29 THEN at.[A_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'XLM Balance',

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
           INNER JOIN AdvancedTransactionV1 as at with (nolock) on at.TransactionId = t.TransactionId AND at.TransactionTypeId = 1
           INNER JOIN OrderBook as o with (nolock) ON o.OrderId = t.A_OrderId
		   --LEFT JOIN AssetType_lkp atlQ WITH (NOLOCK) ON atlQ.AssetTypeId = o.WantAssetTypeId
		   --LEFT JOIN AssetType_lkp atlP WITH (NOLOCK) ON atlP.AssetTypeId = o.OfferAssetTypeId
         -- customer filter
         where (@filter = 'buy' or @filter = ''  or @filter is null or @filter = '')
			   AND o.CustomerId = @customerId
               -- startdate filter
               AND (t.UpdateDate >= @startdate OR @startdate IS NULL OR @startdate = '')
               -- enddate filter
               AND ( t.UpdateDate <= CONVERT(VARCHAR(50), DATEADD(ms,-3, DATEADD(dd, 1, @enddate)), 120)
                     OR @enddate IS NULL OR @enddate = '')
               -- assettype filter
			   AND (OfferAssetTypeId = @assetTypeId OR WantAssetTypeId = @assetTypeId OR @assetTypeId IS NULL)
				--AND (CASE WHEN o.WantAssetTypeId = 1 THEN o.OfferAssetTypeId WHEN o.WantAssetTypeId <> 1 THEN o.WantAssetTypeId END
			    --= @assetTypeId OR @assetTypeId IS NULL)

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
           WHEN o.OfferAssetTypeId = 5 AND o.WantAssetTypeId = 1 THEN 'CNY/ETH'
           WHEN o.OfferAssetTypeId = 6 AND o.WantAssetTypeId = 1 THEN 'CNY/ETC'
           WHEN o.OfferAssetTypeId = 7 AND o.WantAssetTypeId = 1 THEN 'CNY/SKY'
		   WHEN o.OfferAssetTypeId = 9 AND o.WantAssetTypeId = 1 THEN 'CNY/BCC'
		   WHEN o.OfferAssetTypeId = 8 AND o.WantAssetTypeId = 1 THEN 'CNY/SHL'
		   WHEN o.OfferAssetTypeId = 10 AND o.WantAssetTypeId = 1 THEN 'CNY/ZEC'
		   WHEN o.OfferAssetTypeId = 11 AND o.WantAssetTypeId = 1 THEN 'CNY/DRG'
		   
		   WHEN o.OfferAssetTypeId = 2 AND o.WantAssetTypeId = 11 THEN 'DRG/BTC'    
		   WHEN o.OfferAssetTypeId = 3 AND o.WantAssetTypeId = 11 THEN 'DRG/LTC'      
           WHEN o.OfferAssetTypeId = 5 AND o.WantAssetTypeId = 11 THEN 'DRG/ETH'
           WHEN o.OfferAssetTypeId = 6 AND o.WantAssetTypeId = 11 THEN 'DRG/ETC'
           WHEN o.OfferAssetTypeId = 7 AND o.WantAssetTypeId = 11 THEN 'DRG/SKY'
		   WHEN o.OfferAssetTypeId = 9 AND o.WantAssetTypeId = 11 THEN 'DRG/BCC'
		   WHEN o.OfferAssetTypeId = 8 AND o.WantAssetTypeId = 11 THEN 'DRG/SHL'
		   WHEN o.OfferAssetTypeId = 10 AND o.WantAssetTypeId = 11 THEN 'DRG/ZEC'
		   WHEN o.OfferAssetTypeId = 13 AND o.WantAssetTypeId = 11 THEN 'DRG/BTG'
		   WHEN o.OfferAssetTypeId = 16 AND o.WantAssetTypeId = 11 THEN 'DRG/DASH'
		   WHEN o.OfferAssetTypeId = 17 AND o.WantAssetTypeId = 11 THEN 'DRG/ZRX'
		   WHEN o.OfferAssetTypeId = 18 AND o.WantAssetTypeId = 11 THEN 'DRG/FUN'
		   WHEN o.OfferAssetTypeId = 19 AND o.WantAssetTypeId = 11 THEN 'DRG/TNB'
		   WHEN o.OfferAssetTypeId = 20 AND o.WantAssetTypeId = 11 THEN 'DRG/ETP'
		   WHEN o.OfferAssetTypeId = 23 AND o.WantAssetTypeId = 11 THEN 'DRG/OMG'
		   WHEN o.OfferAssetTypeId = 24 AND o.WantAssetTypeId = 11 THEN 'DRG/RCN'
		   WHEN o.OfferAssetTypeId = 25 AND o.WantAssetTypeId = 11 THEN 'DRG/XRP'
		   WHEN o.OfferAssetTypeId = 26 AND o.WantAssetTypeId = 11 THEN 'DRG/EOS'
		   WHEN o.OfferAssetTypeId = 28 AND o.WantAssetTypeId = 11 THEN 'DRG/WAX'
		   WHEN o.OfferAssetTypeId = 29 AND o.WantAssetTypeId = 11 THEN 'DRG/XLM'

		   WHEN o.OfferAssetTypeId = 2 AND o.WantAssetTypeId = 5 THEN 'ETH/BTC'
		   WHEN o.OfferAssetTypeId = 7 AND o.WantAssetTypeId = 5 THEN 'ETH/SKY'
		   WHEN o.OfferAssetTypeId = 7 AND o.WantAssetTypeId = 2 THEN 'BTC/SKY'
		   WHEN o.OfferAssetTypeId = 9 AND o.WantAssetTypeId = 2 THEN 'BTC/BCC'
		   WHEN o.OfferAssetTypeId = 16 AND o.WantAssetTypeId = 2 THEN 'BTC/DASH'
		   WHEN o.OfferAssetTypeId = 17 AND o.WantAssetTypeId = 2 THEN 'BTC/ZRX'
		   WHEN o.OfferAssetTypeId = 18 AND o.WantAssetTypeId = 2 THEN 'BTC/FUN'
		   WHEN o.OfferAssetTypeId = 19 AND o.WantAssetTypeId = 2 THEN 'BTC/TNB'
		   WHEN o.OfferAssetTypeId = 20 AND o.WantAssetTypeId = 2 THEN 'BTC/ETP'
		   WHEN o.OfferAssetTypeId = 21 AND o.WantAssetTypeId = 2 THEN 'BTC/UCASH'
		   WHEN o.OfferAssetTypeId = 23 AND o.WantAssetTypeId = 2 THEN 'BTC/OMG'
		   WHEN o.OfferAssetTypeId = 24 AND o.WantAssetTypeId = 2 THEN 'BTC/RCN'
		   WHEN o.OfferAssetTypeId = 25 AND o.WantAssetTypeId = 2 THEN 'BTC/XRP'
		   WHEN o.OfferAssetTypeId = 26 AND o.WantAssetTypeId = 2 THEN 'BTC/EOS'
		   WHEN o.OfferAssetTypeId = 28 AND o.WantAssetTypeId = 2 THEN 'BTC/WAX'
		   WHEN o.OfferAssetTypeId = 29 AND o.WantAssetTypeId = 2 THEN 'BTC/XLM'
		   WHEN o.OfferAssetTypeId = 6 AND o.WantAssetTypeId = 2 THEN 'BTC/ETC'
		   WHEN o.OfferAssetTypeId = 3 AND o.WantAssetTypeId = 2 THEN 'BTC/LTC'
		   WHEN o.OfferAssetTypeId = 13 AND o.WantAssetTypeId = 2 THEN 'BTC/BTG'
		   WHEN o.OfferAssetTypeId = 10 AND o.WantAssetTypeId = 2 THEN 'BTC/ZEC'

		   WHEN o.OfferAssetTypeId = 12 AND o.WantAssetTypeId = 2 THEN 'BTC/CABS'
		   WHEN o.OfferAssetTypeId = 12 AND o.WantAssetTypeId = 5 THEN 'ETH/CABS'
		   WHEN o.OfferAssetTypeId = 12 AND o.WantAssetTypeId = 6 THEN 'ETC/CABS'
		   WHEN o.OfferAssetTypeId = 12 AND o.WantAssetTypeId = 9 THEN 'BCC/CABS'

		   WHEN o.OfferAssetTypeId = 9 AND o.WantAssetTypeId = 5 THEN 'ETH/BCC'
		   WHEN o.OfferAssetTypeId = 5 AND o.WantAssetTypeId = 2 THEN 'BTC/ETH'
		   WHEN o.OfferAssetTypeId = 5 AND o.WantAssetTypeId = 12 THEN 'ETH/CABS'
		   WHEN o.OfferAssetTypeId = 5 AND o.WantAssetTypeId = 14 THEN 'ETH/FCABS'

		   WHEN o.OfferAssetTypeId = 2 AND o.WantAssetTypeId = 15 THEN 'USDT/BTC'
		   WHEN o.OfferAssetTypeId = 3 AND o.WantAssetTypeId = 15 THEN 'USDT/LTC'
		   WHEN o.OfferAssetTypeId = 5 AND o.WantAssetTypeId = 15 THEN 'USDT/ETH'
           WHEN o.OfferAssetTypeId = 6 AND o.WantAssetTypeId = 15 THEN 'USDT/ETC'
		   WHEN o.OfferAssetTypeId = 7 AND o.WantAssetTypeId = 15 THEN 'USDT/SKY'
           WHEN o.OfferAssetTypeId = 9 AND o.WantAssetTypeId = 15 THEN 'USDT/BCC'
		   WHEN o.OfferAssetTypeId = 10 AND o.WantAssetTypeId = 15 THEN 'USDT/ZEC'
		   WHEN o.OfferAssetTypeId = 11 AND o.WantAssetTypeId = 15 THEN 'USDT/DRG'
		   WHEN o.OfferAssetTypeId = 13 AND o.WantAssetTypeId = 15 THEN 'USDT/BTG'
		   WHEN o.OfferAssetTypeId = 16 AND o.WantAssetTypeId = 15 THEN 'USDT/DASH'
		   WHEN o.OfferAssetTypeId = 17 AND o.WantAssetTypeId = 15 THEN 'USDT/ZRX'
		   WHEN o.OfferAssetTypeId = 18 AND o.WantAssetTypeId = 15 THEN 'USDT/FUN'
		   WHEN o.OfferAssetTypeId = 19 AND o.WantAssetTypeId = 15 THEN 'USDT/TNB'
		   WHEN o.OfferAssetTypeId = 20 AND o.WantAssetTypeId = 15 THEN 'USDT/ETP'
		   WHEN o.OfferAssetTypeId = 21 AND o.WantAssetTypeId = 15 THEN 'USDT/UCASH'
		   WHEN o.OfferAssetTypeId = 22 AND o.WantAssetTypeId = 15 THEN 'USDT/CCOIN'
		   WHEN o.OfferAssetTypeId = 23 AND o.WantAssetTypeId = 15 THEN 'USDT/OMG'
		   WHEN o.OfferAssetTypeId = 24 AND o.WantAssetTypeId = 15 THEN 'USDT/RCN'
		   WHEN o.OfferAssetTypeId = 25 AND o.WantAssetTypeId = 15 THEN 'USDT/XRP'
		   WHEN o.OfferAssetTypeId = 26 AND o.WantAssetTypeId = 15 THEN 'USDT/EOS'
		   WHEN o.OfferAssetTypeId = 28 AND o.WantAssetTypeId = 15 THEN 'USDT/WAX'
		   WHEN o.OfferAssetTypeId = 29 AND o.WantAssetTypeId = 15 THEN 'USDT/XLM'

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
					CONVERT(VARCHAR(50),  Convert(decimal(20,8),Convert(decimal(20,8),(t.A_Amount + t.A_Commission)) / Convert(decimal(20,8),(t.B_Amount + t.B_Commission))))
				END AS ExecutionPrice,
           'N/A' AS [Address],

           CASE 
		   WHEN o.WantAssetTypeId = 1 then at.[B_OfferBalanceAfterTransaction] 
		   WHEN o.OfferAssetTypeId = 1 then at.B_WantBalanceAfterTransaction 
		   end 
		     AS 'CNY Balance',

           CASE
           WHEN o.OfferAssetTypeId = 2 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 2 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'BTC Balance',

           CASE
           WHEN o.OfferAssetTypeId = 5 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 5 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'ETH Balance',

           CASE
           WHEN o.OfferAssetTypeId = 6 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 6 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'ETC Balance',

           CASE
           WHEN o.OfferAssetTypeId = 7 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 7 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'SKY Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 8 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 8 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'SHL Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 9 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 9 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'BCC Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 10 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 10 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'ZEC Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 11 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 11 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'DEG Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 13 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 13 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'BTG Balance',
		   
		   CASE
           WHEN o.OfferAssetTypeId = 15 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 15 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'USDT Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 3 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 3 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'LTC Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 16 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 16 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'DASH Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 17 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 17 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'ZRX Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 18 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 18 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'FUN Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 19 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 19 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'TNB Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 20 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 20 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'ETP Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 21 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 21 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'UCASH Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 22 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 22 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'CCOIN Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 23 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 23 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'OMG Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 24 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 24 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'RCN Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 25 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 25 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'XRP Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 26 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 26 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'EOS Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 28 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 28 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'WAX Balance',

		   CASE
           WHEN o.OfferAssetTypeId = 29 THEN at.B_WantBalanceAfterTransaction
		   WHEN o.WantAssetTypeId = 29 THEN at.[B_OfferBalanceAfterTransaction]
           ELSE null
           END
             AS 'XLM Balance',

           CASE WHEN o.WantAssetTypeId = 1 THEN o.OfferAssetTypeId
           WHEN o.WantAssetTypeId <> 1 THEN o.WantAssetTypeId
           ELSE null
           END
             AS AssetTypeId,
			 
		   o.OfferAssetTypeId AS OfferAssetTypeId,
		   o.WantAssetTypeId AS WantAssetTypeId
		   --null QSymbol,
		   --null PSymbol

         FROM [Transaction] as t with (nolock)
           INNER JOIN AdvancedTransactionV1 as at with (nolock) on at.TransactionId = t.TransactionId AND at.TransactionTypeId = 1
           INNER JOIN OrderBook as o with (nolock) ON o.OrderId = t.B_OrderId
		   --LEFT JOIN AssetType_lkp atlQ WITH (NOLOCK) ON atlQ.AssetTypeId = o.WantAssetTypeId
		   --LEFT JOIN AssetType_lkp atlP WITH (NOLOCK) ON atlP.AssetTypeId = o.OfferAssetTypeId
         -- customer filter
         where (@filter = 'sell' or @filter = ''  or @filter is null or @filter = '')
			   AND o.CustomerId = @customerId
               -- startdate filter
               AND (t.UpdateDate >= @startdate OR @startdate IS NULL OR @startdate = '')
               -- enddate filter
               AND ( t.UpdateDate <= CONVERT(VARCHAR(50), DATEADD(ms,-3, DATEADD(dd, 1, @enddate)), 120)
                     OR @enddate IS NULL OR @enddate = '')
               -- assettype filter
			   AND (OfferAssetTypeId = @assetTypeId OR WantAssetTypeId = @assetTypeId OR @assetTypeId IS NULL)
				--AND (CASE WHEN o.WantAssetTypeId = 1 THEN o.OfferAssetTypeId WHEN o.WantAssetTypeId <> 1 THEN o.WantAssetTypeId END 
				--= @assetTypeId OR @assetTypeId IS NULL)

		 UNION
			--Interest
		 SELECT
           v.RewardDate AS [Time],
           Convert(varchar(30),v.RewardTransactionId) AS [Id],
           'Interest' AS [Type],
           AssetType_lkp.Name AS [Pair],
           'N/A' AS [Order Price],
           v.Amount AS [Quantity],
           'N/A' AS [Amount],
           'N/A' AS [Commission],
		   'N/A' as [ExecutionPrice],
           'N/A' AS [Address],

           CASE
           WHEN  v.AssetTypeId = 1 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'CNY Balance',

           CASE
           WHEN v.AssetTypeId = 2 THEN at.B_WantBalanceAfterTransaction
           ELSE null
           END
             AS 'BTC Balance',

           CASE
           WHEN v.AssetTypeId = 5 THEN at.B_WantBalanceAfterTransaction
           ELSE null
           END
             AS 'ETH Balance',

           CASE
           WHEN v.AssetTypeId = 6 THEN at.B_WantBalanceAfterTransaction
           ELSE null
           END
             AS 'ETC Balance',

           CASE
           WHEN v.AssetTypeId = 7 THEN at.B_WantBalanceAfterTransaction
           ELSE null
           END
             AS 'SKY Balance',

		   CASE
           WHEN v.AssetTypeId = 8 THEN at.B_WantBalanceAfterTransaction
           ELSE null
           END
             AS 'SHL Balance',

		   CASE
           WHEN v.AssetTypeId = 9 THEN at.B_WantBalanceAfterTransaction
           ELSE null
           END
             AS 'BCC Balance',

		   CASE
           WHEN v.AssetTypeId = 10 THEN at.B_WantBalanceAfterTransaction
           ELSE null
           END
             AS 'ZEC Balance',

		   CASE
           WHEN v.AssetTypeId = 11 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'DRG Balance',

		   CASE
           WHEN v.AssetTypeId = 13 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'BTG Balance',
		   
		   CASE
           WHEN v.AssetTypeId = 15 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'USDT Balance',

		   CASE
           WHEN v.AssetTypeId = 3 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'LTC Balance',

		   CASE
           WHEN v.AssetTypeId = 16 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'DASH Balance',

		   CASE
           WHEN v.AssetTypeId = 17 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'ZRX Balance',

		   CASE
           WHEN v.AssetTypeId = 18 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'FUN Balance',

		   CASE
           WHEN v.AssetTypeId = 19 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'TNB Balance',

		   CASE
           WHEN v.AssetTypeId = 20 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'ETP Balance',

		   CASE
           WHEN v.AssetTypeId = 21 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'UCASH Balance',

		   CASE
           WHEN v.AssetTypeId = 22 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'CCOIN Balance',

		   CASE
           WHEN v.AssetTypeId = 23 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'OMG Balance',

		   CASE
           WHEN v.AssetTypeId = 24 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'RCN Balance',

		   CASE
           WHEN v.AssetTypeId = 25 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'XRP Balance',

		   CASE
           WHEN v.AssetTypeId = 26 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'EOS Balance',

		   CASE
           WHEN v.AssetTypeId = 28 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'WAX Balance',

		   CASE
           WHEN v.AssetTypeId = 29 THEN at.B_WantBalanceAfterTransaction
           ELSE NULL
           END
             AS 'XLM Balance',
           v.AssetTypeId as AssetTypeId,
		   v.AssetTypeId AS OfferAssetTypeId,
		   null AS WantAssetTypeId

         FROM RewardTransaction as v with (nolock)
           INNER JOIN AssetType_lkp with (nolock) ON v.AssetTypeId = AssetType_lkp.AssetTypeId
           INNER JOIN AdvancedTransactionV1 as at with (nolock) ON at.TransactionId = v.RewardTransactionId and at.TransactionTypeId = 5

         -- customer filter
         WHERE (@filter = 'interest' or @filter = ''  or @filter is null or @filter = '')
			   AND (v.CustomerId = @customerId)
               -- startdate filter
               AND (v.RewardDate >= @startdate OR @startdate IS NULL OR @startdate = '')
               -- enddate filter
               AND ( v.RewardDate <= CONVERT(VARCHAR(50), DATEADD(ms,-3, DATEADD(dd, 1, @enddate)), 120)
                     OR @enddate IS NULL OR @enddate = '')
               AND (v.AssetTypeId = @assetTypeId OR @assetTypeId IS NULL)
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

