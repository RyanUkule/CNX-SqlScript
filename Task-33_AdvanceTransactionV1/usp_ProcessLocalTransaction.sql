USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_ProcessLocalTransaction]    Script Date: 2018/03/30 14:51:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_ProcessLocalTransaction] 
@BuyorderId int,
@SellorderId int,
@TransactionTypeId int,
@MatchPrice decimal(20,8),
@DealAmount decimal(20,8) = null,
@statusUpdatedBy int, --服务名，需求名
@updateReason nvarchar(500), --需求的子进度
@exchangeId int = null,	--mapping后才需要
@transferCurrencyType nvarchar(200) = null,
@transferCurrencyRate decimal(20,8) = null,
@comment nvarchar(500) = null, --特殊参数，trigger的MarketPrice
@UpdateDate datetime,
@BuyOrderOfferHash nvarchar(500),
@BuyOrderWantHash nvarchar(500),
@SellOrderOfferHash nvarchar(500),
@SellOrderWantHash nvarchar(500)

AS
BEGIN
Set NOCOUNT ON;
SET XACT_ABORT ON;
begin try
begin tran
	declare @Aavailable decimal(20,8), @Bavailable decimal(20,8),
	@BuyCustomerId int, @SellCustomerId int,
	@ACommissionRate decimal(20,8), @BCommissionRate decimal(20,8),
	@AOrderClassId int , @BOrderClassId int,
	@AssetTypeId int,@ChildOrderStatusId int,
	@StopLossPrice decimal(20,8),@TakeProfitPrice decimal(20,8),@TotalAmount decimal(20,8),
	@AofferAmount decimal(20,8),@AwantAmount decimal(20,8),
	@BofferAmount decimal(20,8),@BwantAmount decimal(20,8),
	@FinalBuyOrderStatusId int, @FinalSellOrderStatusId int, @FinalRemainAmount decimal(20,8),
	@ErrorMessage varchar(500), @BuyOrderChildOrderId int,@SellOrderChildOrderId int,
	@BuyOrderOriginalOrderId int, @SellOrderOriginalOrderId int,@TransId int, @mappingId int,
	--@BuySonOrderId int, @SellSonOrderId int, 
	@Message varchar(1000), @buyWantAssetType int, @buyOfferAssetType int, @sellWantAssetType int, @sellOfferAssetType int, 
	@where varchar(max), @orderStatusId int, @orderId_tmp int,
	@buyOrderStatusId int, @sellOrderStatusId int,
	@buyofferHash nvarchar(500), @buywantHash nvarchar(500),@sellofferHash nvarchar(500),@sellwantHash nvarchar(500),@AdvanceTransactionId int,
	@aIsTakeOrder bit, @bIsTakeOrder bit, @aMarketOrder bit, @bMarketOrder bit, @aPrice decimal(20, 8), @bPrice decimal(20, 8),
	@firstAssetTypeSymbol varchar(50), @secondAssetTypeSymbol varchar(50), @updateOrder bit

	Create table #logs
	(
		RMessage varchar(500),
		InsertDate datetime
	)

	--LOCAL
	select @buyOrderStatusId = OrderStatusId from OrderBook with (RowLock) where OrderId = @BuyOrderId
	if(@buyOrderStatusId <> 1 and @buyOrderStatusId <> 2 and @buyOrderStatusId <> 17 and @buyOrderStatusId <> 12)
	begin
		RAISERROR('Local execute BuyOrderStatusId is not correct',12,1)
	end
	select @sellOrderStatusId = OrderStatusId from OrderBook with (RowLock) where OrderId = @SellOrderId
	if(@sellOrderStatusId <> 1 and @sellOrderStatusId <> 2  and @sellOrderStatusId <> 17 and @sellOrderStatusId <> 12)
	begin
		RAISERROR('Local execute SellOrderStatusId is not correct',12,1)
	end
	

	SET @Message  = 'BuyOrderId-' + convert(nvarchar(100),@BuyorderId) +'-SellOrderId-' + convert(nvarchar(100),@SellOrderId) +'-TransactionType-'+convert(nvarchar(100),@TransactionTypeId) + '-MatchPrice-'+ convert(nvarchar(100),@MatchPrice)
	if(@DealAmount is not null)
	begin
		set @Message = @Message + '-DealAmount-' + convert(nvarchar(100),@DealAmount) 
	end
	Insert into #logs values(@Message, getdate())

	select 
		@Aavailable = Quantity,
		@APrice = Price,
		@BuyCustomerId = CustomerId, 
		@AOrderClassId= OrderClassId, 
		@AssetTypeId = WantAssetTypeId, 
		@aIsTakeOrder = IsTakeOrder, 
		@buyWantAssetType = WantAssetTypeId,
		@buyOfferAssetType = OfferAssetTypeId,
		@aMarketOrder = MarketOrder
	from orderbook with (nolock) where orderid = @BuyorderId 

	select 
		@Bavailable = quantity, 
		@bPrice = Price,
		@SellCustomerId = customerId, 
		@BOrderClassId =OrderClassId, 
		@bIsTakeOrder = IsTakeOrder,
		@sellWantAssetType = WantAssetTypeId,
		@sellOfferAssetType = OfferAssetTypeId,
		@bMarketOrder = MarketOrder 
	from orderbook with (nolock) where orderid = @SellorderId 

	select @firstAssetTypeSymbol = Name from AssetType_lkp with (nolock) where AssetTypeId = @buyOfferAssetType
	select @secondAssetTypeSymbol = Name from AssetType_lkp with (nolock) where AssetTypeId = @buyWantAssetType

	--set @Message = convert(nvarchar(100),@buyOfferAssetType) + '_' + convert(nvarchar(100),@buyWantAssetType)
	--Insert into #logs values(@Message, getdate())

	--set @Message = @firstAssetTypeSymbol + '_' + @secondAssetTypeSymbol
	--Insert into #logs values(@Message, getdate()) 

	select @ACommissionRate =  Case @AOrderClassId 
	when 1 then (case @aIsTakeOrder when 1 then t.TradingTakerCommission else t.TradingMakerCommission end) 
	when 2 then t.TakeProfitCommission 
	when 3 then t.StopLossCommision 
	when 4 then t.TriggerCommission 
	when 5 then 0
	end 
	from TradingPackages t with (nolock) inner join Customer c with (nolock)  on t.PackageUID = c.TradingPackageId
	where c.CustomerId = @BuyCustomerId and t.Symbol = @firstAssetTypeSymbol + '_' + @secondAssetTypeSymbol

	select @BCommissionRate =  Case @BOrderClassId 
	when 1 then (case @bIsTakeOrder when 1 then t.TradingTakerCommission else t.TradingMakerCommission end)
	when 2 then t.TakeProfitCommission
	when 3 then t.StopLossCommision
	when 4 then t.TriggerCommission
	when 5 then t.TradingTakerCommission 
	end
	from TradingPackages t with (nolock) inner join Customer c with (nolock)  on t.PackageUID = c.TradingPackageId
	where c.CustomerId = @SellCustomerId and t.Symbol = @firstAssetTypeSymbol + '_' + @secondAssetTypeSymbol

	set @Message = '@BCommissionRate:' + convert(nvarchar(100),@BCommissionRate)
	Insert into #logs values(@Message, getdate())

	if((select OriginalOrderId from orderbook with (nolock) where OrderId = @BuyorderId) is null)
	begin
		select @BuyOrderOriginalOrderId = @BuyOrderId
	end
	else
	begin
		select @BuyOrderOriginalOrderId = OriginalOrderId from orderbook with (nolock) where OrderId = @BuyorderId
	end
	set @Message = 'BuyOrderOriginalOrderId-' + convert(nvarchar(100),@BuyOrderOriginalOrderId)
	Insert into #logs values(@Message, getdate())

	if((select OriginalOrderId from orderbook with (nolock) where OrderId = @SellOrderId) is null)
	begin
		select @SellOrderOriginalOrderId = @SellOrderId
	end
	else
	begin
		select @SellOrderOriginalOrderId = OriginalOrderId from orderbook with (nolock) where OrderId = @SellOrderId
	end

	set @Message = 'SellOrderOriginalOrderId-' + convert(nvarchar(100),@SellOrderOriginalOrderId)
	Insert into #logs values(@Message, getdate())

	--transaction
	begin
		--一般情况
		if(@BOrderClassId <> 5)
		begin
			select 
			@AofferAmount = (@DealAmount * @MatchPrice), 
			@AwantAmount = @DealAmount * (1 - @ACommissionRate),
			@BofferAmount = @DealAmount, 
			@BwantAmount = @AofferAmount * (1 - @BCommissionRate)
			set @Message = 'Update both orderstatus to Completed'
			Insert into #logs values(@Message, getdate())

			set @Message = 'DealAmount is not null value-' + convert(nvarchar(100),@DealAmount)
			Insert into #logs values(@Message, getdate())

			Insert into [Transaction](A_OrderId,A_Amount,A_Commission,B_OrderId,B_Amount,B_Commission,UpdateDate,InsertDate,SaveDate,TransactionTypeId)
			values
			(
				@BuyorderId,
				@AofferAmount * (1 - @BCommissionRate),
				@AofferAmount * @BCommissionRate,
				@SellorderId,
				@DealAmount * (1 - @ACommissionRate),
				@DealAmount * @ACommissionRate,
				getdate(),
				getdate(),
				getdate(),
				@TransactionTypeId
			)
			select @TransId = SCOPE_IDENTITY()
		end
		--OTC卖单
		else
		begin
			--@DealAmount * @MatchPrice - @DealAmount * (@MatchPrice - @costPrice) * @BCommissionRate
			declare @costPrice decimal(20,8)
			select 
			@costPrice = dbo.GetCCOINCostByCustomerId(@SellCustomerId, @MatchPrice),
			@AofferAmount = (@DealAmount * @MatchPrice), 
			@AwantAmount = @DealAmount * (1 - @ACommissionRate),
			@BofferAmount = @DealAmount, 
			@BwantAmount = @DealAmount * @MatchPrice - @DealAmount * @costPrice * @BCommissionRate
			set @Message = 'Update both orderstatus to Completed'
			Insert into #logs values(@Message, getdate())

			set @Message = 'DealAmount is not null value-' + convert(nvarchar(100),@DealAmount)
			Insert into #logs values(@Message, getdate())

			Insert into [Transaction](A_OrderId,A_Amount,A_Commission,B_OrderId,B_Amount,B_Commission,UpdateDate,InsertDate,SaveDate,TransactionTypeId)
			values
			(
				@BuyorderId,
				--@AofferAmount * (1 - @BCommissionRate),
				@DealAmount * @MatchPrice - @DealAmount * @costPrice * @BCommissionRate,
				--@AofferAmount * @BCommissionRate,
				@DealAmount * (@MatchPrice - @costPrice) * @BCommissionRate,
				@SellorderId,
				@DealAmount * (1 - @ACommissionRate),
				@DealAmount * @ACommissionRate,
				getdate(),
				getdate(),
				getdate(),
				@TransactionTypeId
			)
			select @TransId = SCOPE_IDENTITY()
		end

		if(@DealAmount < @Aavailable or (@aMarketOrder = 1 and @MatchPrice * @DealAmount < @aPrice))
		begin
			set @Message = 'DealAmount < Aavailable-' + convert(varchar(100),@Aavailable) 
			Insert into #logs values(@Message, getdate())
			Insert into [dbo].[OrderBook]
			([CustomerId],[OrderTypeId],[OfferAssetTypeId],[WantAssetTypeId],[Quantity],[Price],[OrderStatusId],[OriginalOrderId],[MarketOrder],
			[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],[RemoteExchangeId] ,[RemoteExchangeOrderNumber],
			[ParentOrderId],[OrderClassId],IsTakeorder)
			select CustomerId,OrderTypeId,OfferAssetTypeId,WantAssetTypeId,
			case when @aMarketOrder = 0 or OrderTypeId = 2 then @Aavailable - @DealAmount else 0 end,
			case when @aMarketOrder = 1 and OrderTypeId = 1 then @aPrice - @MatchPrice * @DealAmount else Price end,
			OrderStatusId,@BuyOrderOriginalOrderId,MarketOrder,ExpirationDate,TakeProfitOrderId,StopLossOrderId,GETDATE(),GETDATE(),getdate(),
			RemoteExchangeId,RemoteExchangeOrderNumber,ParentOrderId,OrderClassId,IsTakeorder
			from OrderBook with (nolock) where OrderId = @BuyOrderId
						 
			select @BuyOrderChildOrderId = scope_identity()
			select @orderStatusId = OrderStatusId from OrderBook with (nolock) where OrderId = @BuyOrderId

			exec usp_CreateOrderStatusHistory @BuyOrderChildOrderId, 17, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
			@transferCurrencyRate, @comment, null

			set @Message = 'Create Child Buy Order-' +Convert(nvarchar(100),@BuyOrderChildOrderId)
			Insert into #logs values(@Message, getdate())

			set @FinalBuyOrderStatusId = 3
		end

		if(@DealAmount < @Bavailable or (@bMarketOrder = 1 and @MatchPrice * @DealAmount < @bPrice))
		begin
			set @Message = 'DealAmount < Bavailable-' + convert(varchar(100),@Bavailable) 
			Insert into #logs values(@Message, getdate())
			Insert into [dbo].[OrderBook]
			([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],[OrderStatusId],[OriginalOrderId],[MarketOrder],
			[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],[RemoteExchangeId] ,[RemoteExchangeOrderNumber],
			[ParentOrderId],[OrderClassId],IsTakeorder)
			select CustomerId,OrderTypeId,OfferAssetTypeId,WantAssetTypeId,
			case when @bMarketOrder = 0 or OrderTypeId = 2 then @Bavailable - @DealAmount else 0 end,
			case when @bMarketOrder = 1 and OrderTypeId = 1 then @bPrice - @MatchPrice * @DealAmount else Price end,
			OrderStatusId,@SellOrderOriginalOrderId,MarketOrder,ExpirationDate,TakeProfitOrderId,StopLossOrderId,GETDATE(),GETDATE(),getdate(),
			RemoteExchangeId,RemoteExchangeOrderNumber,ParentOrderId,OrderClassId,IsTakeorder
			from OrderBook with (nolock) where OrderId = @SellorderId

			select @SellOrderChildOrderId = scope_identity()
			select @orderStatusId = OrderStatusId from OrderBook with (nolock) where OrderId = @BuyOrderId

			exec usp_CreateOrderStatusHistory @SellOrderChildOrderId, @orderStatusId, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
			@transferCurrencyRate, @comment, null

			set @Message = 'Create Child Sell Order-' +Convert(nvarchar(100),@SellOrderChildOrderId)
			Insert into #logs values(@Message, getdate())

			set @FinalSellOrderStatusId = 3
		end

		exec usp_CreateOrderStatusHistory @SellOrderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
		@transferCurrencyRate, @comment, null
		exec usp_CreateOrderStatusHistory @BuyOrderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
		@transferCurrencyRate, @comment, null

		set @updateOrder = 1

		if(@FinalBuyOrderStatusId is null or @FinalBuyOrderStatusId <> 3)
		begin
			set @FinalBuyOrderStatusId = 4
		end

		if(@FinalSellOrderStatusId is null or @FinalSellOrderStatusId <> 3)
		begin
			set @FinalSellOrderStatusId = 4
		end
	end

	set @Message = 'Update Balance'
	Insert into #logs values(@Message, getdate())

	--UpdateBalance
	declare @ACurrentBalanceForAOffer decimal(38,8),@BCurrentBalanceForBOffer decimal(38,8),@ACurrentBalanceForAwant decimal(38,8),
			@BCurrentBalanceForBwant decimal(38,8), @updateDateForBuyNow datetime, @updateDateForSellNow datetime
	select @ACurrentBalanceForAOffer = Balance, @buyofferHash = [Hash] from AssetBalance with(nolock) where CustomerId = @BuyCustomerId and AssetTypeId = @buyOfferAssetType
	select @ACurrentBalanceForAwant = Balance, @buywantHash = [Hash] from AssetBalance with(nolock) where CustomerId = @BuyCustomerId and AssetTypeId = @buyWantAssetType
	select @BCurrentBalanceForBOffer = Balance, @sellofferHash = [Hash] from AssetBalance with (nolock) where CustomerId = @SellCustomerId and AssetTypeId = @sellOfferAssetType
	select @BCurrentBalanceForBwant = Balance, @sellwantHash = [Hash] from AssetBalance with(nolock) where  CustomerId = @SellCustomerId and AssetTypeId = @sellWantAssetType

	if(@ACurrentBalanceForAOffer >= @AofferAmount and @BCurrentBalanceForBOffer >= @BofferAmount)
	begin
		set @Message = 'BuyOrderCurrentCNYBalance-' + convert(nvarchar(100),@ACurrentBalanceForAOffer) + ' and OfferAmount-' +Convert(nvarchar(100),@AofferAmount) + 'FinalBalance-' + convert(nvarchar(100),@ACurrentBalanceForAOffer - @AofferAmount) 
		Insert into #logs values(@Message, getdate())
		print 'CNY BUY:'
		print '@AofferAmount'
		print @AofferAmount
		print '@UpdateDate'
		print @UpdateDate
		print '@BuyOrderOfferHash'
		print @BuyOrderOfferHash

		Update AssetBalance 
		set balance = balance - @AofferAmount, UpdateDate = @UpdateDate,[Hash] = @BuyOrderOfferHash
		where CustomerId = @BuyCustomerId and AssetTypeId = @buyOfferAssetType
		set @Message = 'BuyOrderCurrentBTCBalance-' +convert(nvarchar(100),@ACurrentBalanceForAwant) + 'and GetAmount-' + Convert(nvarchar(100),@AwantAmount) +'FinalBalance-'  + convert(nvarchar(100),@ACurrentBalanceForAwant + @AwantAmount)
		Insert into #logs values(@Message, getdate())

		print 'NOT CNY BUY:'
		print '@AwantAmount'
		print @AwantAmount
		print '@UpdateDate'
		print @UpdateDate
		print '@BuyOrderWantHash'
		print @BuyOrderWantHash

		Update AssetBalance 
		set Balance = Balance + @AwantAmount, UpdateDate = @UpdateDate,[Hash] = @BuyOrderWantHash
		where CustomerId = @BuyCustomerId and AssetTypeId = @buyWantAssetType
		set @Message = 'SellOrderCurrentCNYBalance-' + convert(nvarchar(100),@BCurrentBalanceForBwant) + 'and GetAmount-' + convert(nvarchar(100),@BwantAmount) + 'FinalBalance-' + convert(nvarchar(100),@BCurrentBalanceForBwant +@BwantAmount)
		Insert into #logs values(@Message, getdate())

		Update CustomerOrder
		set AveragePrice = (isnull(AveragePrice,0) * isnull(CompletedAmount,0) + @AofferAmount) / (isnull(CompletedAmount,0) + @BofferAmount),
		CompletedAmount = isnull(CompletedAmount,0) + @BofferAmount
		where OrderId = @BuyOrderOriginalOrderId

		print 'CNY SELL:'
		print '@BwantAmount'
		print @BwantAmount
		print '@UpdateDate'
		print @UpdateDate
		print '@SellOrderWantHash'
		print @SellOrderWantHash

		update AssetBalance 
		set Balance = Balance + @BwantAmount, UpdateDate = @UpdateDate, [Hash] = @SellOrderWantHash
		where CustomerId = @SellCustomerId and AssetTypeId = @sellWantAssetType
		set @Message = 'SellOrderCurrentBTCBalance-' + convert(nvarchar(100),@BCurrentBalanceForBOffer) + 'and OfferAmount-' + CONVERT(nvarchar(100),@BofferAmount) + 'FinalBalance-' + convert(nvarchar(100),@BCurrentBalanceForBOffer - @BofferAmount)
		Insert into #logs values(@Message, getdate())

		print 'NOT CNY SELL:'
		print '@BofferAmount'
		print @BofferAmount
		print '@UpdateDate'
		print @UpdateDate
		print '@SellOrderOfferHash'
		print @SellOrderOfferHash

		Update AssetBalance 
		set balance = balance - @BofferAmount, UpdateDate = @UpdateDate, [hash] = @SellOrderOfferHash
		where CustomerId = @SellCustomerId and AssetTypeId = @sellOfferAssetType

		Update CustomerOrder
		set AveragePrice = (isnull(AveragePrice,0) * isnull(CompletedAmount,0) + @AofferAmount) / (isnull(CompletedAmount,0) + @BofferAmount),
		CompletedAmount = isnull(CompletedAmount,0) + @BofferAmount
		where OrderId = @SellOrderOriginalOrderId

		--Insert into AdvancedTransaction (TransactionId, TransactionType, A_CNYBalance,A_Balance,B_CNYBalance,B_Balance)
		--values (@TransId, 'Transaction', @ACurrentBalanceForAOffer - @AofferAmount,@ACurrentBalanceForAwant + @AwantAmount,
		--@BCurrentBalanceForBwant +@BwantAmount,@BCurrentBalanceForBOffer - @BofferAmount)

		Insert into AdvancedTransactionV1 ([TransactionId], [TransactionTypeId], [TransactionNote],[A_OfferBalanceAfterTransaction],
		[B_OfferBalanceAfterTransaction],[A_WantBalanceAfterTransaction],[B_WantBalanceAfterTransaction])
		values (@TransId, 1, null, @ACurrentBalanceForAOffer - @AofferAmount,@ACurrentBalanceForAwant + @AwantAmount,
		@BCurrentBalanceForBwant +@BwantAmount,@BCurrentBalanceForBOffer - @BofferAmount)

		set @AdvanceTransactionId=SCOPE_IDENTITY()
	end
	Else
	begin
		RAISERROR('not enough balance',16,1, 'not enough balance')
	end

	if(@updateOrder = 1)
	begin
		Update OrderBook  with(RowLock)  set OrderstatusId = 4, UpdateDate = getdate() where OrderId = @SellOrderId or OrderId = @BuyOrderId
	end

	--AdvancedOrder
	begin
	declare @FBID int, @FSID int --买单卖单对应的订单整体最后状态
	--Create ST and TP Order For localOrder
	declare @STId int ,@TPId int, @STIdOld int, @TPIdOld int, @SLslippage decimal(18, 4)
	if(@FinalBuyOrderStatusId = 4)  --代表未分担，数量足够完成
	begin

		exec usp_CreateOrderStatusHistory @BuyorderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
		@transferCurrencyRate, @comment, null
		Update OrderBook with (RowLock)  set OrderStatusId = 4, UpdateDate = getdate() where OrderId = @BuyorderId

		if(@BuyCustomerId <> 2)
		begin
			if(not exists(select OrderId from OrderBook with (nolock) 
			where (OrderId = @BuyOrderOriginalOrderId or OriginalOrderId = @BuyOrderOriginalOrderId) and OrderStatusId not in (4,5,16)))
			begin
				Update CustomerOrder set OrderStatusId = 4, UpdateDate = getdate() where OrderId = @BuyOrderOriginalOrderId
			end
			set @Message = 'Buy Order is Full Completed  Check TP and ST Price' + convert(nvarchar(100),@BuyOrderId)
			Insert into #logs values(@Message, getdate())
			set @FBID = 4
		end
	end
	else if(@FinalBuyOrderStatusId = 3)
	begin
		if(@BuyCustomerId <> 2)
		begin
			if(exists(select OrderId from OrderBook with (nolock) 
			where (OrderId = @BuyOrderOriginalOrderId or OriginalOrderId = @BuyOrderOriginalOrderId) and OrderStatusId in (4)))
			begin
				Update CustomerOrder set OrderStatusId = 3, UpdateDate = getdate() where OrderId = @BuyOrderOriginalOrderId
			end
			set @Message = 'Buy Order is Partial Completed' + convert(nvarchar(100),@BuyOrderId)
			Insert into #logs values(@Message, getdate())
		end
	end

	if(@BuyCustomerId <> 2)
	begin
		select @StoplossPrice = StopLossPrice,@TakeProfitPrice = TakeProfitPrice from AdvancedOrderProperties with (nolock) 
		where OrderId = @BuyOrderOriginalOrderId

		select @STIdOld = OrderId from OrderBook with (nolock) where orderId in
		(select StopLossOrderId from OrderBook o with (nolock) where (o.OrderId = @BuyOrderOriginalOrderId or OriginalOrderId = @BuyOrderOriginalOrderId))
		and OrderStatusId in (2, 7, 9, 14, 17)

		select @TPIdOld = OrderId from OrderBook with (nolock) where orderId in
		(select TakeProfitOrderId from OrderBook o with (nolock) where (o.OrderId = @BuyOrderOriginalOrderId or OriginalOrderId = @BuyOrderOriginalOrderId))
		and OrderStatusId in (2, 7, 9, 14, 17)

		select @SLslippage = Value from CustomerPreference with (nolock) where CustomerId = @BuyCustomerId and PreferenceId = dbo.ShowPreferenceId(@BuyorderId)

		set @Message = '@BuySonOrderId is not null and @BuySonOrderId > 0, @SLslippage:' + convert(nvarchar(20), isnull(@SLslippage, 0))
		Insert into #logs values(@Message, getdate())
		if(@StoplossPrice is not null and @StoplossPrice > 0 and @STIdOld is not null and @STIdOld > 0)
		begin
			set @Message = '@StoplossPrice is not null and @StoplossPrice > 0 and @STIdOld is not null and @STIdOld > 0'
			Insert into #logs values(@Message, getdate())
			set @Message = '@StoplossPrice: ' + convert(nvarchar(100), @StoplossPrice) + ' @STIdOld:' + convert(nvarchar(100), @STIdOld)
			Insert into #logs values(@Message, getdate())
			
			select @TotalAmount = isnull(sum(Quantity), 0) + @DealAmount from OrderBook with (nolock) 
			where (OrderId = @STIdOld or OriginalOrderId = @STIdOld) and OrderstatusId in (2, 7, 9, 14, 17)

			set @where = ' from orderbook with (nolock) where (OrderId = ' + cast(@STIdOld as varchar(50)) 
			+ ' or OriginalOrderId = ' + cast(@STIdOld as varchar(50)) + ') and [OrderStatusId] in (2, 7, 9, 14, 17)'
			exec usp_CreateOrderStatusHistory 0, 16, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
			@transferCurrencyRate, @comment, @where

			update OrderBook  with (RowLock)  set OrderStatusId = 16, UpdateDate = getdate() 
			where (OrderId = @STIdOld or OriginalOrderId = @STIdOld) and OrderStatusId in (2, 7, 9, 14, 17)

			set @Message = convert(nvarchar(100), @TotalAmount)
			Insert into #logs values(@Message, getdate())

			Insert into [dbo].[OrderBook]
			([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],
			[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],
			[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId],IsTakeorder)
			select CustomerId,2,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,round(@stoplossPrice * (1 - @SLslippage), 0),
			9,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
			RemoteExchangeId,RemoteExchangeOrderNumber,@STIdOld,3,IsTakeorder
			from OrderBook with (nolock) where OrderId = @BuyOrderId

			select @STId = SCOPE_IDENTITY()

			-----Add by Steven  2017-1-6
			Insert into CustomerOrder(OrderId,CustomerId,OrderStatusId,UpdateDate)
			select @STId,CustomerId,9,GETDATE()
			from OrderBook with (nolock) where OrderId = @BuyOrderId
			-----End add

			exec usp_CreateOrderStatusHistory @STId, 9, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
			@transferCurrencyRate, @comment, null

			Update Orderbook with (RowLock)  set StopLossOrderId = @STId, UpdateDate = getdate() where OrderId = @BuyOrderId

			set @Message = ' @STId:' + convert(nvarchar(100), @STId) 
			Insert into #logs values(@Message, getdate())
		end
		else
		begin
			select @TotalAmount = @DealAmount

			if(@StoplossPrice is not null and @StoplossPrice > 0)
			begin
				set @Message = '@StoplossPrice: ' + convert(nvarchar(100), @StoplossPrice) + ', ' + convert(nvarchar(100), round(@stoplossPrice * (1 - @SLslippage), 0))
				Insert into #logs values(@Message, getdate())
				Insert into [dbo].[OrderBook]
				([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],
				[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],
				[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId],IsTakeorder)
				select CustomerId,2,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,round(@stoplossPrice * (1 - @SLslippage), 0),
				9,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
				RemoteExchangeId,RemoteExchangeOrderNumber,null,3,IsTakeorder
				from OrderBook with (nolock) where OrderId = @BuyOrderId

				select @STId = SCOPE_IDENTITY()
				exec usp_CreateOrderStatusHistory @STId, 9, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null

				-----Add by Steven  2017-1-6
				Insert into CustomerOrder(OrderId,CustomerId,OrderStatusId,UpdateDate)
				select @STId,CustomerId,9,GETDATE()
				from OrderBook with (nolock) where OrderId = @BuyOrderId
				-----End add

				Update Orderbook with(RowLock)  set StopLossOrderId = @STId, UpdateDate = getdate() where OrderId = @BuyOrderId
			end
		end
		if(@TakeProfitPrice is not null and @TakeProfitPrice > 0 and @TPIdOld is not null and @TPIdOld > 0)
		begin
			set @Message = '(@TakeProfitPrice is not null and @TakeProfitPrice > 0 and @TPIdOld is not null and @TPIdOld > 0'
			Insert into #logs values(@Message, getdate())
			set @Message = '@TakeProfitPrice: ' + convert(nvarchar(100), @TakeProfitPrice) + ' @TPIdOld:' + convert(nvarchar(100), @TPIdOld)
			Insert into #logs values(@Message, getdate())

			select @TotalAmount = isnull(sum(Quantity), 0) + @DealAmount from OrderBook with (nolock) 
			where (OrderId = @TPIdOld or OriginalOrderId = @TPIdOld) and OrderstatusId in (2, 7, 9, 14, 17)

			set @where = ' from orderbook with (nolock) where (OrderId = ' + cast(@TPIdOld as varchar(50)) 
			+ ' or OriginalOrderId = ' + cast(@TPIdOld as varchar(50)) + ') and [OrderStatusId] in (2, 7, 9, 14, 17)'
			exec usp_CreateOrderStatusHistory 0, 16, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
			@transferCurrencyRate, @comment, @where

			update OrderBook with(RowLock)  set OrderStatusId = 16, UpdateDate = getdate() 
			where (OrderId = @TPIdOld or OriginalOrderId = @TPIdOld) and OrderStatusId in (2, 7, 9, 14, 17)

			set @Message = convert(nvarchar(100), @TotalAmount)
			Insert into #logs values(@Message, getdate())

			Insert into [dbo].[OrderBook]
			([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],
			[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],
			[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId],IsTakeorder)
			select CustomerId,2,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,@TakeProfitPrice,
			2,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
			RemoteExchangeId,RemoteExchangeOrderNumber,@TPIdOld,2,IsTakeorder
			from OrderBook with (nolock) where OrderId = @BuyOrderId

			select @TPId = SCOPE_IDENTITY()
			exec usp_CreateOrderStatusHistory @TPId, 2, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
			@transferCurrencyRate, @comment, null

			-----Add by Steven  2017-1-6
			Insert into CustomerOrder(OrderId,CustomerId,OrderStatusId,UpdateDate)
			select @TPId,CustomerId,2,GETDATE()
			from OrderBook with (nolock) where OrderId = @BuyOrderId
			-----End add

			Update Orderbook with(RowLock)  set TakeProfitOrderId = @TPId, UpdateDate = getdate() where OrderId = @BuyOrderId

			set @Message = ' @TPId:' + convert(nvarchar(100), @TPId) 
			Insert into #logs values(@Message, getdate())
		end
		else
		begin
			select @TotalAmount = @DealAmount

			if(@TakeProfitPrice is not null and @TakeProfitPrice > 0)
			begin
				set @Message = '@TakeProfitPrice: ' + convert(nvarchar(100), @TakeProfitPrice)
				Insert into #logs values(@Message, getdate())

				Insert into [dbo].[OrderBook]
				([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId],IsTakeorder)
				select CustomerId,2,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,@TakeProfitPrice,
				2,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
				RemoteExchangeId,RemoteExchangeOrderNumber,null,2,IsTakeorder
				from OrderBook with (nolock) where OrderId = @BuyOrderId
				select @TPId = SCOPE_IDENTITY()
				exec usp_CreateOrderStatusHistory @TPId, 2, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null

				-----Add by Steven  2017-1-6
				Insert into CustomerOrder(OrderId,CustomerId,OrderStatusId,UpdateDate)
				select @TPId,CustomerId,2,GETDATE()
				from OrderBook with (nolock) where OrderId = @BuyOrderId
				-----End add

				Update OrderBook with(RowLock)  set TakeProfitOrderId = @TPId, UpdateDate = getdate() where OrderId = @BuyOrderId
			end
		end
	end

	--buyend
	if(@FinalSellOrderStatusId = 4)
	begin
		exec usp_CreateOrderStatusHistory @SellorderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
		@transferCurrencyRate, @comment, null
		Update OrderBook with(RowLock)  set OrderStatusId = 4, UpdateDate = getdate() where OrderId = @SellorderId

		if(@SellCustomerId <> 2)
		begin
			if(not exists(select OrderId from OrderBook with (nolock) 
			where (OrderId = @SellOrderOriginalOrderId or OriginalOrderId = @SellOrderOriginalOrderId) and OrderStatusId not in (4,5,16)))
			begin
				Update CustomerOrder set OrderStatusId = 4, UpdateDate = getdate() where OrderId = @SellOrderOriginalOrderId
			end
			set @Message = 'Sell Order is Full Completed  Check TP and ST Price' + convert(nvarchar(100),@SellorderId)
			Insert into #logs values(@Message, getdate())
			set @FSID = 4
		end
		--sell end
	end
	else if(@FinalSellOrderStatusId = 3)
	begin
		if(@SellCustomerId <> 2)
		begin
			if(exists(select OrderId from OrderBook with (nolock) 
			where (OrderId = @SellOrderOriginalOrderId or OriginalOrderId = @SellOrderOriginalOrderId) and OrderStatusId in (4)))
			begin
				Update CustomerOrder set OrderStatusId = 3, UpdateDate = getdate() where OrderId = @SellOrderOriginalOrderId
			end
			set @Message = 'Sell Order is Partial Completed' + convert(nvarchar(100),@SellorderId)
			Insert into #logs values(@Message, getdate())
		end
	end

	--清空临时数据
	set @StoplossPrice = null 
	set @STIdOld = null
	set @TPIdOld = null
	set @SLslippage = null
	set @TotalAmount = null

	if(@SellCustomerId <> 2)
	begin
		select @StoplossPrice = StopLossPrice,@TakeProfitPrice = TakeProfitPrice from AdvancedOrderProperties with (nolock) 
		where OrderId = @SellOrderOriginalOrderId

		select @STIdOld = OrderId from OrderBook with (nolock) where orderId in
		(select StopLossOrderId from OrderBook o with (nolock) where (o.OrderId = @SellOrderOriginalOrderId or OriginalOrderId = @SellOrderOriginalOrderId))
		and OrderStatusId in (2, 7, 9, 14, 17)

		select @TPIdOld = OrderId from OrderBook with (nolock) where orderId in
		(select TakeProfitOrderId from OrderBook o with (nolock) where (o.OrderId = @SellOrderOriginalOrderId or OriginalOrderId = @SellOrderOriginalOrderId))
		and OrderStatusId in (2, 7, 9, 14, 17)

		select @SLslippage = Value from CustomerPreference with (nolock) where CustomerId = @SellCustomerId and PreferenceId = dbo.ShowPreferenceId(@SellorderId)

		set @Message = '@SellSonOrderId is not null and @SellSonOrderId > 0'
		Insert into #logs values(@Message, getdate())

		if(@StoplossPrice is not null and @StoplossPrice > 0 and @STIdOld is not null and @STIdOld > 0)
		begin
			set @Message = '@StoplossPrice is not null and @StoplossPrice > 0 and @STIdOld is not null and @STIdOld > 0'
			Insert into #logs values(@Message, getdate())

			select @TotalAmount = isnull(sum(Quantity), 0) + @DealAmount from OrderBook with (nolock) 
			where (OrderId = @STIdOld or OriginalOrderId = @STIdOld) and OrderstatusId in (2, 7, 9, 14, 17)

			set @where = ' from orderbook with (nolock) where (OrderId = ' + cast(@STIdOld as varchar(50)) 
			+ ' or OriginalOrderId = ' + cast(@STIdOld as varchar(50)) + ') and [OrderStatusId] in (2, 7, 9, 14, 17)'
			exec usp_CreateOrderStatusHistory 0, 16, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
			@transferCurrencyRate, @comment, @where

			update OrderBook with(RowLock)  set OrderStatusId = 16, UpdateDate = getdate() 
			where (OrderId = @STIdOld or OriginalOrderId = @STIdOld) and OrderStatusId in (2, 7, 9, 14, 17)

			set @Message = convert(nvarchar(100), @TotalAmount)
			Insert into #logs values(@Message, getdate())

			Insert into [dbo].[OrderBook]
			([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],
			[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],
			[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId],IsTakeorder)
			select CustomerId,1,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,round(@stoplossPrice * (1 + @SLslippage), 0),
			9,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
			RemoteExchangeId,RemoteExchangeOrderNumber,@STIdOld,3,IsTakeorder
			from OrderBook with (nolock) where OrderId = @SellOrderId

			select @STId = SCOPE_IDENTITY()
			exec usp_CreateOrderStatusHistory @STId, 9, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
			@transferCurrencyRate, @comment, null

			-----Add by Steven  2017-1-6
			Insert into CustomerOrder(OrderId,CustomerId,OrderStatusId,UpdateDate)
			select @STId,CustomerId,9,GETDATE()
			from OrderBook with (nolock) where OrderId = @SellOrderId
			-----End add

			Update Orderbook  with(RowLock) set StopLossOrderId = @STId, UpdateDate = getdate() where OrderId = @SellOrderId

			set @Message = ' @STId:' + convert(nvarchar(100), @STId) 
			Insert into #logs values(@Message, getdate())
		end
		else
		begin
			select @TotalAmount = @DealAmount 

			if(@StoplossPrice is not null and @StoplossPrice > 0)
			begin
				Insert into [dbo].[OrderBook]
				([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],
				[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],
				[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId],IsTakeorder)
				select CustomerId,1,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,round(@stoplossPrice * (1 + @SLslippage), 0),
				9,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
				RemoteExchangeId,RemoteExchangeOrderNumber,null,3,IsTakeorder
				from OrderBook with (nolock) where OrderId = @SellOrderId

				select @STId = SCOPE_IDENTITY()
				exec usp_CreateOrderStatusHistory @STId, 9, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null

				-----Add by Steven  2017-1-6
				Insert into CustomerOrder(OrderId,CustomerId,OrderStatusId,UpdateDate)
				select @STId,CustomerId,9,GETDATE()
				from OrderBook with (nolock) where OrderId = @SellOrderId
				-----End add

				Update Orderbook with(RowLock)  set StopLossOrderId = @STId, UpdateDate = getdate() where OrderId = @SellOrderId
			end
		end
		if(@TakeProfitPrice is not null and @TakeProfitPrice > 0 and @TPIdOld is not null and @TPIdOld > 0)
		begin
			set @Message = '@StoplossPrice is not null and @StoplossPrice > 0 and @TPIdOld is not null and @TPIdOld > 0'
			Insert into #logs values(@Message, getdate())

			select @TotalAmount = isnull(sum(Quantity), 0) + @DealAmount from OrderBook with (nolock) 
			where (OrderId = @TPIdOld or OriginalOrderId = @TPIdOld) and OrderstatusId in (2, 7, 9, 14, 17)

			set @where = ' from orderbook with (nolock) where (OrderId = ' + cast(@STIdOld as varchar(50)) 
			+ ' or OriginalOrderId = ' + cast(@STIdOld as varchar(50)) + ') and [OrderStatusId] in (2, 7, 9, 14, 17)'
			exec usp_CreateOrderStatusHistory 0, 16, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
			@transferCurrencyRate, @comment, @where

			update OrderBook with(RowLock)  set OrderStatusId = 16, UpdateDate = getdate() 
			where (OrderId = @TPIdOld or OriginalOrderId = @TPIdOld) and OrderStatusId in (2, 7, 9, 14, 17)

			set @Message = convert(nvarchar(100), @TotalAmount)
			Insert into #logs values(@Message, getdate())

			Insert into [dbo].[OrderBook]
			([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],
			[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],
			[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId],IsTakeorder)
			select CustomerId,1,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,@TakeProfitPrice,
			2,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
			RemoteExchangeId,RemoteExchangeOrderNumber,@TPIdOld,2,IsTakeorder
			from OrderBook with (nolock) where OrderId = @SellOrderId

			select @TPId = SCOPE_IDENTITY()
			exec usp_CreateOrderStatusHistory @TPId, 2, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
			@transferCurrencyRate, @comment, null

			-----Add by Steven  2017-1-6
			Insert into CustomerOrder(OrderId,CustomerId,OrderStatusId,UpdateDate)
			select @TPId,CustomerId,2,GETDATE()
			from OrderBook with (nolock) where OrderId = @SellOrderId
			-----End add

			Update Orderbook with(RowLock)  set TakeProfitOrderId = @TPId, UpdateDate = getdate() where OrderId = @SellOrderId

			set @Message = ' @TPId:' + convert(nvarchar(100), @TPId) 
			Insert into #logs values(@Message, getdate())
		end
		else
		begin
			select @TotalAmount = @DealAmount 

			if(@TakeProfitPrice is not null and @TakeProfitPrice > 0)
			begin
				Insert into [dbo].[OrderBook]
				([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],
				[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],
				[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId],IsTakeorder)
				select CustomerId,1,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,@TakeProfitPrice,
				2,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
				RemoteExchangeId,RemoteExchangeOrderNumber,null,2,IsTakeorder
				from OrderBook with (nolock) where OrderId = @SellOrderId

				select @TPId = SCOPE_IDENTITY()
				exec usp_CreateOrderStatusHistory @TPId, 2, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null

				-----Add by Steven  2017-1-6
				Insert into CustomerOrder(OrderId,CustomerId,OrderStatusId,UpdateDate)
				select @TPId,CustomerId,2,GETDATE()
				from OrderBook with (nolock) where OrderId = @SellOrderId
				-----End add


				Update OrderBook with(RowLock)  set TakeProfitOrderId = @TPId, UpdateDate = getdate() where OrderId = @SellOrderId
			end
		end
	end

	--Order is ST or TP 	
	declare @ParentOrderId int, @AnotherPairOrderId int
	if(@FBID  <> 0)
	begin
		select @ParentOrderId = OrderId from orderbook with (nolock) where StopLossOrderId = @BuyorderId or TakeProfitOrderId = @BuyorderId
		if(@ParentOrderId is null)
		begin
			select @ParentOrderId = OrderId from orderbook with (nolock) where 
			StopLossOrderId = (select OriginalOrderId from OrderBook with (nolock) where OrderId = @BuyorderId) 
			or TakeProfitOrderId = (select OriginalOrderId from OrderBook with (nolock) where OrderId = @BuyorderId)		
		end

		if (@ParentOrderId is not null and @ParentOrderId > 0)
		begin
			set @Message = '@FSID @ParentOrderId is not null'
			Insert into #logs values(@Message, getdate())

			if(@AOrderClassId = 2)
			begin
				select @AnotherPairOrderId = StopLossOrderId from Orderbook with(nolock) where OrderId = @ParentOrderId
			end
			Else
			begin
				select @AnotherPairOrderId = TakeProfitOrderId from Orderbook with(nolock) where OrderId = @ParentOrderId
			end
			if(@AnotherPairOrderId is not null and @AnotherPairOrderId > 0)
			begin
				exec usp_CreateOrderStatusHistory @AnotherPairOrderId, 5, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null

				Update OrderBook with(RowLock)  set OrderStatusId = 5, UpdateDate = getdate() where OrderId = @AnotherPairOrderId

				if(@FinalBuyOrderStatusId = 3)
				begin
					Insert into [dbo].[OrderBook]
					([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],
					[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],
					[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId],IsTakeorder)
					select CustomerId,OrderTypeId,OfferAssetTypeId,WantAssetTypeId,@FinalRemainAmount,Price,
					OrderStatusId,OriginalOrderId,MarketOrder,ExpirationDate,TakeProfitOrderId,StopLossOrderId,GETDATE(),GETDATE(),getdate(),
					RemoteExchangeId,RemoteExchangeOrderNumber,ParentOrderId,OrderClassId,IsTakeorder
					from OrderBook with (nolock) where OrderId = @AnotherPairOrderId
					
					select @orderId_tmp = SCOPE_IDENTITY()
					select @orderStatusId = OrderStatusId from OrderBook with (nolock) where OrderId = @AnotherPairOrderId

					exec usp_CreateOrderStatusHistory @orderId_tmp, @orderStatusId, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
					@transferCurrencyRate, @comment, null
				end
			end
		end
	end
	if(@FSID  <> 0)
	begin
		select @ParentOrderId = OrderId from orderbook with (nolock) where StopLossOrderId = @SellorderId or TakeProfitOrderId = @SellorderId
		if (@ParentOrderId is not null and @ParentOrderId > 0)
		begin
			set @Message = '@FSID @ParentOrderId is not null'
			Insert into #logs values(@Message, getdate())

			if(@BOrderClassId = 2)
			begin
				select @AnotherPairOrderId = StopLossOrderId from Orderbook with(nolock) where OrderId = @ParentOrderId
			end
			Else
			begin
				select @AnotherPairOrderId = TakeProfitOrderId from Orderbook with(nolock) where OrderId = @ParentOrderId
			end
			if(@AnotherPairOrderId is not null and @AnotherPairOrderId > 0)
			begin
				exec usp_CreateOrderStatusHistory @AnotherPairOrderId, 5, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null

				Update OrderBook with(RowLock)  set OrderStatusId = 5, UpdateDate = getdate() where OrderId = @AnotherPairOrderId

				if(@FinalBuyOrderStatusId = 3)
				begin
					Insert into [dbo].[OrderBook]
					([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId],IsTakeorder)
						select CustomerId,OrderTypeId,OfferAssetTypeId,WantAssetTypeId,@FinalRemainAmount,Price,
						OrderStatusId,OriginalOrderId,MarketOrder,ExpirationDate,TakeProfitOrderId,StopLossOrderId,GETDATE(),GETDATE(),getdate(),
						RemoteExchangeId,RemoteExchangeOrderNumber,ParentOrderId,OrderClassId,IsTakeorder
						from OrderBook with (nolock) where OrderId = @AnotherPairOrderId

					select @orderId_tmp = SCOPE_IDENTITY()
					select @orderStatusId = OrderStatusId from OrderBook with (nolock) where OrderId = @AnotherPairOrderId

					exec usp_CreateOrderStatusHistory @orderId_tmp, @orderStatusId, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
					@transferCurrencyRate, @comment, null
				end
			end
		end
	end
	end
	if(@BuyOrderChildOrderId is null or @BuyOrderChildOrderId <= 0)
	begin
		set @BuyOrderChildOrderId = 0
	end
	if(@SellOrderChildOrderId is null or @SellOrderChildOrderId <= 0)
	begin
		set @SellOrderChildOrderId = 0
	end

	select @ErrorMessage,@BuyOrderChildOrderId,@SellOrderChildOrderId

	Insert into TransactionHistory ([Timestamp],BuyOrderId,SellOrderId,SPName,HistoryMessage)
	select Getdate(),@BuyOrderId,@SellOrderId,'usp_ProcessTransactionv2',RMessage from #logs with (nolock)

	select AdvanceTransactionId,TransactionId,A_OfferBalanceAfterTransaction,A_WantBalanceAfterTransaction,B_OfferBalanceAfterTransaction,B_WantBalanceAfterTransaction 
	from AdvancedTransactionV1 with(nolock)
	where AdvanceTransactionId=@AdvanceTransactionId
	if(@TransactionTypeId =1)
	begin
		select OrderId,OrderStatusId from orderbook where orderid=@BuyorderId
	end
	else
	begin
		select OrderId,OrderStatusId from orderbook where orderid=@SellorderId
	end
	
	drop table #logs
	commit tran     
end try
begin	catch 
		rollback tran

		SET @Message  = 'BuyOrderId-' + convert(nvarchar(100),@BuyorderId) +'-SellOrderId-' + convert(nvarchar(100),@SellOrderId) +'-TransactionType-'+convert(nvarchar(100),@TransactionTypeId) + '-MatchPrice-'+ convert(nvarchar(100),@MatchPrice)
		if(@DealAmount is not null)
		begin
			set @Message = @Message + '-DealAmount-' + convert(nvarchar(100),@DealAmount) 
		end

		Insert into TransactionHistory ([Timestamp],BuyOrderId,SellOrderId,SPName,HistoryMessage)
		select Getdate(),@BuyOrderId,@SellOrderId,'usp_ProcessTransactionv2',@Message

		Insert into TransactionHistory ([Timestamp],BuyOrderId,SellOrderId,SPName,HistoryMessage)
		select Getdate(),@BuyOrderId,@SellOrderId,'usp_ProcessTransactionv2',ERROR_MESSAGE()
		throw 
end catch
END


