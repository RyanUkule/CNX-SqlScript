USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_CommissionStatistic]    Script Date: 2018/05/16 15:43:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[usp_CommissionStatistic]
(
	@startDate datetime,
	@endDate datetime
)
AS
BEGIN
	---------------------------------
	--******** Trade benefit *******
	---------------------------------
	 select 
		case when Symbol = 'DRG'
			then 'USDT'
			else Symbol
		end Symbol
		, case Symbol 
				when 'DRG' then 15
				when 'BTC' then 2
		  end AssetTypeId
		, sum(
		case when OrderTypeId = 1 
			then L_Price * L_Amount - R_Price * R_Amount
			else R_Price * R_Amount - L_Price * L_Amount
		end
		) Diff
		into #t_Trade
	 from (select OrderId
				, case when Symbol like '%15%'
						then 'DRG'
						else Symbol
				  end Symbol
				, OrderTypeId
				, case when Symbol <> 'DRG'
						then L_Price
						else L_Price / 0.0649
				  end L_Price
				, L_Amount
				, case when Symbol <> 'DRG' 
						then  R_Price
						else R_Price / 0.0649
				  end R_Price
				, R_Amount 
			 from (select 
						OrderId
						,Symbol
						,OrderTypeId
						, OfferAssetTypeId
						, WantAssetTypeId
						,L_Price
						,L_Amount
						,case when Symbol = 'DRG'
							then case when message like '%(Id:%' 
									then RemoteExecutePrice / 6.7 * 0.0649	-- 先换回USDT 再换为DRG
									else RemoteExecutePrice * 0.067  --/ USDT换算为DRG
								 end
							else
								case when Message like '%(Id:%'
									then RemoteExecutePrice / 6.8  -- 去掉GetOrderInfo 时多算的Rate
									else RemoteExecutePrice 
								end
						end R_Price
						,R_Amount
						,SubmitPrice
						,RemoteExecutePrice
						,Message
					from 
						(select o.OrderId, 
							case when o.OfferAssetTypeId = 11 or o.WantAssetTypeId =11  then 'DRG'
										else case when (o.OfferAssetTypeId = 2 or o.WantAssetTypeId = 2) and (o.OfferAssetTypeId <> 15 and o.WantAssetTypeId <> 15) then 'BTC'
											else convert(varchar(3), o.OfferAssetTypeId) + '-' + convert(varchar(3), o.WantAssetTypeId) end
								end as Symbol
							, r.OrderTypeId
							, r.OfferAssetTypeId
							, r.WantAssetTypeId
							, AveragePrice L_Price
							, CompletedAmount L_Amount
							,r.RemoteExecuteQuantity R_Amount
							,r.ExecutePrice
							,r.SubmitPrice
							,r.RemoteExecutePrice
							,r.Message
						from CustomerOrder c with (nolock)
						inner join OrderBook o with (nolock) on c.OrderId = o.OrderId
						inner join RemoteOrderMappings r  with (nolock) on o.OrderId = r.OrderId 
						where r.updatedate between @startDate and @endDate
							  and c.OrderStatusId = 4 and r.RemoteOrderMappingStatusId = 2
							  and r.RemoteExchangeId = 18
							  and r.RemoteExecuteQuantity = c.CompletedAmount
					) tmp 
			) summary
		) a
		group by Symbol

	--------------------------
	--***** Commission *****
	--------------------------
	 select 
		assetType.Name, result.WantAssetTypeId AssetTypeId, result.commission
		into #t_Commission
	 from 
	 (
		 select WantAssetTypeId, sum(commission) commission from
		 (
			 select 
				 o.orderid
				 , t.B_Commission commission
				 , o.WantAssetTypeId
				 , o.OrderTypeId
				 , o.CustomerId
				 , o.UpdateDate
			 from OrderBook o with (nolock)
			 inner join [Transaction] t with (nolock) on o.OrderId = t.A_OrderId
			 inner join Customer c with (nolock) on c.CustomerId = o.CustomerId
			 where o.updatedate between @startDate and @endDate
				and o.CustomerId <> 2
				and o.CustomerId <> 10
				and c.IsTestAccount = 0
			 union
			 select 
				o.orderid
				, t.A_Commission commission
				, o.WantAssetTypeId
				, o.OrderTypeId
				, o.CustomerId
				,o.UpdateDate
			 from OrderBook o with (nolock)
			 inner join [Transaction] t  with (nolock) on o.OrderId = t.B_OrderId
			 inner join Customer c with (nolock) on c.CustomerId = o.CustomerId
			 where o.updatedate between @startDate and @endDate
				 and o.CustomerId <> 2
				 and o.CustomerId <> 10
				 and c.IsTestAccount = 0
		 ) summary
		 group by WantAssetTypeId
	 ) result
	 inner join AssetType_lkp assetType on result.WantAssetTypeId = assetType.AssetTypeId
	 order by result.WantAssetTypeId

	 -------------------------------
	 --******** Withdrawal, Deposit **********
	 -------------------------------
	 select 
		assetType.Name, t.AssetTypeId, sum(t.Commision) commission
		into #t_Withdrawal_Deposit
	 from TransferRequest t
	 inner join AssetType_lkp assetType on assetType.AssetTypeId = t.AssetTypeId
	 where InsertDate between @startDate and @endDate
		and RequestStatusId = 3
	 group by assetType.Name, t.AssetTypeId
	 order by t.AssetTypeId
 
	 print 'Trade:'
	 select Symbol, Diff as Commission from #t_Trade
	 print 'Commission:'
	 select Name Symbol, Commission from #t_Commission
	 print 'Withdrawal_Deposit:'
	 select Name Symbol, Commission  from #t_Withdrawal_Deposit

	 print 'Total:'
	 select 
		Symbol, sum(commission) as Commission
	 from
	 (
		 select 
			Symbol, AssettypeId, Diff commission
		 from #t_Trade
		 union all
		 select
		   Name Symbol, AssettypeId, commission
		 from #t_Commission
		 union all
		 select 
			Name Symbol, AssettypeId, commission 
		 from #t_Withdrawal_Deposit 
	 ) summary
	 group by Symbol, AssetTypeId
	 order by AssetTypeId

 END