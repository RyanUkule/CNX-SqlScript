USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_ProcessLocalTransaction_First]    Script Date: 2018/11/28 17:26:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_ProcessLocalTransaction_First] 
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
	@AofferAmount decimal(20,8),@AwantAmount decimal(20,8),
	@BofferAmount decimal(20,8),@BwantAmount decimal(20,8),
	@FinalBuyOrderStatusId int, @FinalSellOrderStatusId int, 
	@ErrorMessage varchar(500), @BuyOrderChildOrderId int,@SellOrderChildOrderId int,
	@BuyOrderOriginalOrderId int, @SellOrderOriginalOrderId int,@TransId int,
	@Message varchar(1000), @buyWantAssetType int, @buyOfferAssetType int, @sellWantAssetType int, @sellOfferAssetType int, 
	@where varchar(max), @orderStatusId int, @orderId_tmp int,
	@buyOrderStatusId int, @sellOrderStatusId int,
	@buyofferHash nvarchar(500), @buywantHash nvarchar(500),@sellofferHash nvarchar(500),@sellwantHash nvarchar(500),@AdvanceTransactionId int,
	@aIsTakeOrder bit, @bIsTakeOrder bit, @aMarketOrder bit, @bMarketOrder bit, @aPrice decimal(20, 8), @bPrice decimal(20, 8),
	@BuyCustomerOrderStatusId int, @SellCustomerOrderStatusId int, 
	@firstAssetTypeSymbol varchar(50), @secondAssetTypeSymbol varchar(50), @updateOrder bit, @flag bit = 1,
	@commissionAssetTypeId int, @extraCommission decimal(20, 8), @fundCommission decimal(20, 8), @managerCommission decimal(20, 8),
	@fundAccountId int, @accountManagerId int

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

	if(@aIsTakeOrder = 0 and @bIsTakeOrder = 0)
	begin
		if(@TransactionTypeId = 1)
		begin
			set @bIsTakeOrder = 1
		end
		else if(@TransactionTypeId = 2)
		begin
			set @aIsTakeOrder = 1
		end
	end

	select @ACommissionRate =  Case @AOrderClassId 
	when 1 then (case @aIsTakeOrder when 1 then t.TradingTakerCommission else t.TradingMakerCommission end) 
	when 2 then t.TakeProfitCommission 
	when 3 then t.StopLossCommision 
	when 4 then t.TriggerCommission 
	when 5 then (case @aIsTakeOrder when 1 then t.TradingTakerCommission else t.TradingMakerCommission end) 
	end 
	from TradingPackages t with (nolock) inner join Customer c with (nolock)  on t.PackageUID = c.TradingPackageId
	where c.CustomerId = @BuyCustomerId and t.Symbol = @firstAssetTypeSymbol + '_' + @secondAssetTypeSymbol

	select @BCommissionRate =  Case @BOrderClassId 
	when 1 then (case @bIsTakeOrder when 1 then t.TradingTakerCommission else t.TradingMakerCommission end)
	when 2 then t.TakeProfitCommission
	when 3 then t.StopLossCommision
	when 4 then t.TriggerCommission
	when 5 then (case @bIsTakeOrder when 1 then t.TradingTakerCommission else t.TradingMakerCommission end)
	end
	from TradingPackages t with (nolock) inner join Customer c with (nolock)  on t.PackageUID = c.TradingPackageId
	where c.CustomerId = @SellCustomerId and t.Symbol = @firstAssetTypeSymbol + '_' + @secondAssetTypeSymbol

	select top 1 @commissionAssetTypeId = CommissionAssetTypeId from ExchangeSetting with (nolock)
	where Symbol = @firstAssetTypeSymbol + '_' + @secondAssetTypeSymbol and Active = 1 order by RankLevel

	select @fundCommission = FundCommission, @managerCommission = ManagerCommission, @extraCommission = FundCommission + ManagerCommission,
	@fundAccountId = FundAccountId, @accountManagerId = AccountManagerId
	from SYNConfiguration with (nolock) where AssetTypeId = @buyWantAssetType


	set @Message = '@fundCommission:' + isnull(convert(nvarchar(20),@fundCommission), 'null')
		 + '@managerCommission:' + isnull(convert(nvarchar(20),@managerCommission), 'null')  + '@extraCommission:' + isnull(convert(nvarchar(20),@extraCommission), 'null')
		 + '@fundAccountId:' + isnull(convert(nvarchar(20),@fundAccountId), 'null')  + '@accountManagerId:' + isnull(convert(nvarchar(20),@accountManagerId), 'null')
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
			@AofferAmount = case when @commissionAssetTypeId = @buyOfferAssetType then @DealAmount * @MatchPrice * (1 + @ACommissionRate) else @DealAmount * @MatchPrice end, 
			@AwantAmount = case when @commissionAssetTypeId = @buyWantAssetType then @DealAmount * (1 - @ACommissionRate) else @DealAmount end,
			@BofferAmount = case when @commissionAssetTypeId = @buyWantAssetType then @DealAmount * (1 + @BCommissionRate) else @DealAmount end, 
			@BwantAmount = case when @commissionAssetTypeId = @buyOfferAssetType then @DealAmount * @MatchPrice * (1 - @BCommissionRate) else @DealAmount * @MatchPrice end 
			set @Message = 'Update both orderstatus to Completed'
			Insert into #logs values(@Message, getdate())

			set @Message = 'DealAmount is not null value-' + convert(nvarchar(100),@DealAmount)
			Insert into #logs values(@Message, getdate())

			Insert into [Transaction](A_OrderId,A_Amount,A_Commission,B_OrderId,B_Amount,B_Commission,UpdateDate,InsertDate,SaveDate,TransactionTypeId)
			values
			(
				@BuyorderId,
				@DealAmount * @MatchPrice,
				case when @commissionAssetTypeId = @buyOfferAssetType then @DealAmount * @MatchPrice * @ACommissionRate else @DealAmount * @ACommissionRate end,
				@SellorderId,
				@DealAmount,
				case when @commissionAssetTypeId = @buyOfferAssetType then @DealAmount * @MatchPrice * @BCommissionRate else @DealAmount * @BCommissionRate end,
				getdate(),
				getdate(),
				getdate(),
				@TransactionTypeId
			)
			select @TransId = SCOPE_IDENTITY()
			--交易Fee
			insert into TransactionFee(TransactionId, OrderId, TransactionFeeTypeId, TransactionFeeAssetTypeId, CustomerId, TransactionFee)
			select @TransId, @BuyorderId, 1, @commissionAssetTypeId, 2,
			case when @commissionAssetTypeId = @buyOfferAssetType then @DealAmount * @MatchPrice * @ACommissionRate else @DealAmount * @ACommissionRate end
			
			insert into TransactionFee(TransactionId, OrderId, TransactionFeeTypeId, TransactionFeeAssetTypeId, CustomerId, TransactionFee)
			select @TransId, @SellorderId, 1, @commissionAssetTypeId, 2,
			case when @commissionAssetTypeId = @buyOfferAssetType then @DealAmount * @MatchPrice * @BCommissionRate else @DealAmount * @BCommissionRate end
		end
		--OTC
		else if(@BOrderClassId = 5)
		begin
			declare @costPrice decimal(20,8), @exceptTradingCommissionAmount decimal(20,8)
			select 
			@costPrice = dbo.GetCCOINCostByCustomerId(@SellCustomerId, @MatchPrice),
			@AofferAmount = case when @commissionAssetTypeId = @buyOfferAssetType then @DealAmount * @MatchPrice * (1 + @ACommissionRate) else @DealAmount * @MatchPrice end, 
			@AwantAmount = case when @commissionAssetTypeId = @buyWantAssetType then @DealAmount * (1 - @ACommissionRate) else @DealAmount end,
			@BofferAmount = case when @commissionAssetTypeId = @buyWantAssetType then @DealAmount * (1 + @BCommissionRate) else @DealAmount end, 
			@BwantAmount = case when @commissionAssetTypeId = @buyOfferAssetType then @DealAmount * @MatchPrice * (1 - @BCommissionRate) else @DealAmount end
			
			declare @baseFee decimal(20, 8)
			set @baseFee = (@costPrice * @DealAmount - (@DealAmount * @MatchPrice * @BCommissionRate))

			set @Message = 'Update both orderstatus to Completed'
			Insert into #logs values(@Message, getdate())

			set @Message = 'DealAmount is not null value-' + convert(nvarchar(100),@DealAmount)
			Insert into #logs values(@Message, getdate())

			set @Message = 'CostPrice-' + isnull(convert(nvarchar(100),@costPrice), 'null') 
			    + ', @BCommissionRate:' + isnull(convert(nvarchar(20),@BCommissionRate), 'null')
				+ ', ACommissionRate-' + isnull(convert(nvarchar(100),@ACommissionRate), 'null')
			Insert into #logs values(@Message, getdate())

			Insert into [Transaction](A_OrderId,A_Amount,A_Commission,B_OrderId,B_Amount,B_Commission,UpdateDate,InsertDate,SaveDate,TransactionTypeId)
			values
			(
				@BuyorderId,
				@DealAmount * @MatchPrice,
				case when @commissionAssetTypeId = @buyOfferAssetType then @DealAmount * @MatchPrice * @ACommissionRate else @DealAmount * @ACommissionRate end,
				@SellorderId,
				@DealAmount,
				case when @TransactionTypeId = 1 then @DealAmount * @MatchPrice * @BCommissionRate 
					when @TransactionTypeId = 2 then case when @commissionAssetTypeId = @buyOfferAssetType then
					@DealAmount * @MatchPrice * @BCommissionRate + (case when @baseFee > 0 then @baseFee else 0 end) * @extraCommission
					else @DealAmount * @BCommissionRate + (case when @baseFee > 0 then @baseFee else 0 end) / @MatchPrice * @extraCommission end
				end,
				getdate(),
				getdate(),
				getdate(),
				@TransactionTypeId
			)
			select @TransId = SCOPE_IDENTITY()

			--交易Fee
			insert into TransactionFee(TransactionId, OrderId, TransactionFeeTypeId, TransactionFeeAssetTypeId, CustomerId, TransactionFee)
			select @TransId, @BuyorderId, 1, @commissionAssetTypeId, 2,
				case when @commissionAssetTypeId = @buyOfferAssetType 
				then @DealAmount * @MatchPrice * @ACommissionRate 
				else @DealAmount * @BCommissionRate end

			insert into TransactionFee(TransactionId, OrderId, TransactionFeeTypeId, TransactionFeeAssetTypeId, CustomerId, TransactionFee)
			select @TransId, @SellorderId, 1, @commissionAssetTypeId, 2,
				case when @commissionAssetTypeId = @buyOfferAssetType 
				then @DealAmount * @MatchPrice * @BCommissionRate 
				else @DealAmount * @BCommissionRate end

			--OTC订单只有卖单收手续费
			if(@TransactionTypeId = 2)
			begin
				declare @fundCommission_tmp decimal(20,8), @managerCommission_tmp decimal(20,8)
				--FundFee
				set @fundCommission_tmp = case when @commissionAssetTypeId = @buyOfferAssetType 
					then (case when @baseFee > 0 then @baseFee else 0 end) * @fundCommission 
					else (case when @baseFee > 0 then @baseFee else 0 end) / @MatchPrice * @fundCommission end

				insert into TransactionFee(TransactionId, OrderId, TransactionFeeTypeId, TransactionFeeAssetTypeId, CustomerId, TransactionFee)
				select @TransId, @SellorderId, 2, @commissionAssetTypeId, @fundAccountId, @fundCommission_tmp
					
				set @BwantAmount = @BwantAmount - @fundCommission_tmp
				
				--ManagerFee
				set @managerCommission_tmp = case when @commissionAssetTypeId = @buyOfferAssetType 
					then (case when @baseFee > 0 then @baseFee else 0 end) * @managerCommission 
					else (case when @baseFee > 0 then @baseFee else 0 end) / @MatchPrice * @managerCommission  end

				insert into TransactionFee(TransactionId, OrderId, TransactionFeeTypeId, TransactionFeeAssetTypeId, CustomerId, TransactionFee)
				select @TransId, @SellorderId, 3, @commissionAssetTypeId, @accountManagerId, @managerCommission_tmp

				set @BwantAmount = @BwantAmount - @managerCommission_tmp
			end
			--如果剩余量小于0.00000001，则不建子单
			if(@aMarketOrder = 1 and @aPrice - @MatchPrice * @DealAmount < 0.00000001)
			begin
				set @flag = 0
			end
		end

		if(@DealAmount < @Aavailable or (@aMarketOrder = 1 and @MatchPrice * @DealAmount < @aPrice and @flag = 1))
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

	if(@FinalBuyOrderStatusId = 4 and @BuyCustomerId <> 2)  --代表未分担，数量足够完成
	begin
		--if(not exists(select OrderId from OrderBook with (nolock) 
		--where (OrderId = @BuyOrderOriginalOrderId or OriginalOrderId = @BuyOrderOriginalOrderId) and OrderStatusId not in (4,5,16)))
		--begin
			--Update CustomerOrder set OrderStatusId = 4, UpdateDate = getdate() where OrderId = @BuyOrderOriginalOrderId
			set @BuyCustomerOrderStatusId = 4
		--end
		set @Message = 'Buy Order is Full Completed  Check TP and ST Price' + convert(nvarchar(100),@BuyOrderId)
		Insert into #logs values(@Message, getdate())
	end
	else if(@FinalBuyOrderStatusId = 3 and @BuyCustomerId <> 2)
	begin
		--if(exists(select OrderId from OrderBook with (nolock) 
		--where (OrderId = @BuyOrderOriginalOrderId or OriginalOrderId = @BuyOrderOriginalOrderId) and OrderStatusId in (4)))
		--begin
			--Update CustomerOrder set OrderStatusId = 3, UpdateDate = getdate() where OrderId = @BuyOrderOriginalOrderId
			set @BuyCustomerOrderStatusId = 3
		--end
		set @Message = 'Buy Order is Partial Completed' + convert(nvarchar(100),@BuyOrderId)
		Insert into #logs values(@Message, getdate())
	end
--------------------------------------------buyend---------------------------------------
	if(@FinalSellOrderStatusId = 4 and @SellCustomerId <> 2)
	begin
		--if(not exists(select OrderId from OrderBook with (nolock) 
		--where (OrderId = @SellOrderOriginalOrderId or OriginalOrderId = @SellOrderOriginalOrderId) and OrderStatusId not in (4,5,16)))
		--begin
			--Update CustomerOrder set OrderStatusId = 4, UpdateDate = getdate() where OrderId = @SellOrderOriginalOrderId
			set @SellCustomerOrderStatusId = 4
		--end
		set @Message = 'Sell Order is Full Completed  Check TP and ST Price' + convert(nvarchar(100),@SellorderId)
		Insert into #logs values(@Message, getdate())
	end
	else if(@FinalSellOrderStatusId = 3 and @SellCustomerId <> 2)
	begin
		--if(exists(select OrderId from OrderBook with (nolock) 
		--where (OrderId = @SellOrderOriginalOrderId or OriginalOrderId = @SellOrderOriginalOrderId) and OrderStatusId in (4)))
		--begin
			--Update CustomerOrder set OrderStatusId = 3, UpdateDate = getdate() where OrderId = @SellOrderOriginalOrderId
			set @SellCustomerOrderStatusId = 3
		--end
		set @Message = 'Sell Order is Partial Completed' + convert(nvarchar(100),@SellorderId)
		Insert into #logs values(@Message, getdate())
	end
--------------------------------------------sellend---------------------------------------
	--UpdateBalance
	declare @ACurrentBalanceForAOffer decimal(38,8),@BCurrentBalanceForBOffer decimal(38,8),@ACurrentBalanceForAwant decimal(38,8),
			@BCurrentBalanceForBwant decimal(38,8), @updateDateForBuyNow datetime, @updateDateForSellNow datetime
	select @ACurrentBalanceForAOffer = Balance, @buyofferHash = [Hash] from AssetBalance with(nolock) where CustomerId = @BuyCustomerId and AssetTypeId = @buyOfferAssetType
	select @ACurrentBalanceForAwant = Balance, @buywantHash = [Hash] from AssetBalance with(nolock) where CustomerId = @BuyCustomerId and AssetTypeId = @buyWantAssetType
	select @BCurrentBalanceForBOffer = Balance, @sellofferHash = [Hash] from AssetBalance with (nolock) where CustomerId = @SellCustomerId and AssetTypeId = @sellOfferAssetType
	select @BCurrentBalanceForBwant = Balance, @sellwantHash = [Hash] from AssetBalance with(nolock) where  CustomerId = @SellCustomerId and AssetTypeId = @sellWantAssetType

	--if(@ACurrentBalanceForAOffer >= @AofferAmount and @BCurrentBalanceForBOffer >= @BofferAmount)
	begin
		set @Message = 'BuyOrderCurrentCNYBalance-' + convert(nvarchar(100),@ACurrentBalanceForAOffer) + ' and OfferAmount-' +Convert(nvarchar(100),@AofferAmount) + 'FinalBalance-' + convert(nvarchar(100),@ACurrentBalanceForAOffer - @AofferAmount) 
		Insert into #logs values(@Message, getdate())
		Update AssetBalance 
		set balance = balance - @AofferAmount, 
		FrozenBalance = FrozenBalance - case when @aMarketOrder = 0 then convert(decimal(20,8), @aPrice * @DealAmount) else convert(decimal(20,8), @DealAmount * @MatchPrice) end, 
		UpdateDate = @UpdateDate,[Hash] = @BuyOrderOfferHash
		where CustomerId = @BuyCustomerId and AssetTypeId = @buyOfferAssetType

		insert into [Log] 
		select getdate(), '', '', convert(nvarchar(100),@BuyCustomerId), 'FrozenBalance:' + 
			convert(nvarchar(100), isnull(case when @aMarketOrder = 0 then convert(decimal(20,8), @aPrice * @DealAmount) else convert(decimal(20,8), 
			@DealAmount * @MatchPrice) end, 0)), null, 'ProcessTransaction', @BuyOrderId

		set @Message = 'BuyOrderCurrentBTCBalance-' +convert(nvarchar(100),@ACurrentBalanceForAwant) + 'and GetAmount-' + Convert(nvarchar(100),@AwantAmount) +'FinalBalance-'  + convert(nvarchar(100),@ACurrentBalanceForAwant + @AwantAmount)
		Insert into #logs values(@Message, getdate())
		Update AssetBalance 
		set Balance = Balance + @AwantAmount, UpdateDate = @UpdateDate,[Hash] = @BuyOrderWantHash
		where CustomerId = @BuyCustomerId and AssetTypeId = @buyWantAssetType

		Update CustomerOrder 
		set AveragePrice = (isnull(AveragePrice,0) * isnull(CompletedAmount,0) + convert(decimal(20,8), @DealAmount * @MatchPrice)) / (isnull(CompletedAmount,0) + @DealAmount),
		CompletedAmount = isnull(CompletedAmount,0) + @BofferAmount,
		OrderStatusId = @BuyCustomerOrderStatusId
		where OrderId = @BuyOrderOriginalOrderId

		set @Message = 'SellOrderCurrentCNYBalance-' + convert(nvarchar(100),@BCurrentBalanceForBwant) + 'and GetAmount-' + convert(nvarchar(100),@BwantAmount) + 'FinalBalance-' + convert(nvarchar(100),@BCurrentBalanceForBwant +@BwantAmount)
		Insert into #logs values(@Message, getdate())
		update AssetBalance 
		set Balance = Balance + @BwantAmount, UpdateDate = @UpdateDate, [Hash] = @SellOrderWantHash
		where CustomerId = @SellCustomerId and AssetTypeId = @sellWantAssetType

		set @Message = 'SellOrderCurrentBTCBalance-' + convert(nvarchar(100),@BCurrentBalanceForBOffer) + 'and OfferAmount-' + CONVERT(nvarchar(100),@BofferAmount) + 'FinalBalance-' + convert(nvarchar(100),@BCurrentBalanceForBOffer - @BofferAmount)
		Insert into #logs values(@Message, getdate())

		Update AssetBalance 
		set balance = balance - @BofferAmount, frozenbalance = frozenbalance - @BofferAmount, UpdateDate = @UpdateDate, [hash] = @SellOrderOfferHash
		where CustomerId = @SellCustomerId and AssetTypeId = @sellOfferAssetType

		insert into [Log] 
		select getdate(), '', '', convert(nvarchar(100),@SellCustomerId), 'FrozenBalance:' + 
			convert(nvarchar(100), isnull(case when @aMarketOrder = 0 then convert(decimal(20,8), @aPrice * @DealAmount) else convert(decimal(20,8), 
			@DealAmount * @MatchPrice) end, 0)), null, 'ProcessTransaction', @SellOrderId

		Update CustomerOrder 
		set AveragePrice = (isnull(AveragePrice,0) * isnull(CompletedAmount,0) + convert(decimal(20,8), @DealAmount * @MatchPrice)) / (isnull(CompletedAmount,0) + @DealAmount),
		CompletedAmount = isnull(CompletedAmount,0) + @BofferAmount, UpdateDate = getdate(),
		OrderStatusId = @SellCustomerOrderStatusId
		where OrderId = @SellOrderOriginalOrderId

		if(@TransactionTypeId = 2)
		begin
			--FundCustomer获得Commission
			declare @fundFee decimal(20,8), @fundAssetTypeId int
			select @fundFee = TransactionFee, @fundAssetTypeId = TransactionFeeAssetTypeId 
			from TransactionFee with (nolock) where TransactionId = @TransId and TransactionFeeTypeId = 2

			Update AssetBalance 
			set Balance = Balance + @fundFee
			where CustomerId = @fundAccountId and AssetTypeId = @fundAssetTypeId

			--ManagerCustomer获得Commission
			declare @managerFee decimal(20,8), @managerAssetTypeId int
			select @managerFee = TransactionFee, @managerAssetTypeId = TransactionFeeAssetTypeId 
			from TransactionFee with (nolock) where TransactionId = @TransId and TransactionFeeTypeId = 3

			Update AssetBalance 
			set Balance = Balance + @managerFee
			where CustomerId = @accountManagerId and AssetTypeId = @managerAssetTypeId

			set @Message = 'fundAccountId-' + convert(nvarchar(20),@fundAccountId) 
				+ 'and managerAssetTypeId-' + convert(nvarchar(20),@managerAssetTypeId) 
			Insert into #logs values(@Message, getdate())
		end
	end

	if(@updateOrder = 1)
	begin
		Update OrderBook with(RowLock) set OrderstatusId = 4, UpdateDate = getdate() where OrderId = @SellOrderId or OrderId = @BuyOrderId
	end
	if(@FinalBuyOrderStatusId = 4)
	begin
		exec usp_CreateOrderStatusHistory @BuyorderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
		@transferCurrencyRate, @comment, null
		Update OrderBook with (RowLock)  set OrderStatusId = 4, UpdateDate = getdate() where OrderId = @BuyorderId
	end
	if(@FinalSellOrderStatusId = 4)
	begin
		exec usp_CreateOrderStatusHistory @SellorderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
		@transferCurrencyRate, @comment, null
		Update OrderBook with(RowLock)  set OrderStatusId = 4, UpdateDate = getdate() where OrderId = @SellorderId
	end
-----------------------------------------------------------------------------------------------------------------------
	select 
	@ErrorMessage,
	case when @BuyOrderChildOrderId is null or @BuyOrderChildOrderId <= 0 then 0 else @BuyOrderChildOrderId end,
	case when @SellOrderChildOrderId is null or @SellOrderChildOrderId <= 0 then 0 else @SellOrderChildOrderId end

	Insert into TransactionHistory ([Timestamp],BuyOrderId,SellOrderId,SPName,HistoryMessage)
	select InsertDate,@BuyOrderId,@SellOrderId,'usp_ProcessTransactionv2',RMessage from #logs with (nolock)

	if(@TransactionTypeId = 1)
	begin
		select OrderId,OrderStatusId from orderbook where orderid = @BuyOrderId
	end
	else
	begin
		select OrderId,OrderStatusId from orderbook where orderid = @SellorderId
	end

	select 
	@TransId as TransactionId,
	@DealAmount as DealAmount,

	@BuyCustomerId as BuyCustomerId, 
	@ACurrentBalanceForAOffer - @AofferAmount as AOfferAmount, 
	@ACurrentBalanceForAwant + @AwantAmount as AWantAmount, 
	@BuyOrderOriginalOrderId as BuyOrderOriginalOrderId, 
	@BuyOrderId as BuyOrderId, 
	@FinalBuyOrderStatusId as BuyStatusId, 
	@AOrderClassId as AOrderClassId, 
	@BuyCustomerOrderStatusId as BuyCustomerOrderStatusId, 
	@Aavailable - @DealAmount as BuyRestAmount,

	@SellCustomerId as SellCustomerId, 
	@BCurrentBalanceForBwant +@BwantAmount as BOfferAmount, 
	@BCurrentBalanceForBOffer - @BofferAmount as BWantAmount, 
	@SellOrderOriginalOrderId as SellOrderOriginalOrderId, 
	@SellOrderId as SellOrderId, 
	@FinalSellOrderStatusId as SellStatusId, 
	@BOrderClassId as BOrderClassId, 
	@SellCustomerOrderStatusId as SellCustomerOrderStatusId, 
	@Bavailable - @DealAmount as SellRestAmount

	drop table #logs
	commit tran     
end try
begin catch 
	rollback tran

	--set @Message  = 'BuyOrderId-' + convert(nvarchar(100),@BuyorderId) +'-SellOrderId-' + convert(nvarchar(100),@SellOrderId) +'-TransactionType-'+convert(nvarchar(100),@TransactionTypeId) + '-MatchPrice-'+ convert(nvarchar(100),@MatchPrice)
	--if(@DealAmount is not null)
	--begin
	--	set @Message = @Message + '-DealAmount-' + convert(nvarchar(100),@DealAmount) 
	--end

	Insert into TransactionHistory ([Timestamp],BuyOrderId,SellOrderId,SPName,HistoryMessage)
	select Getdate(),@BuyOrderId,@SellOrderId,'usp_ProcessTransactionv2',@Message

	Insert into TransactionHistory ([Timestamp],BuyOrderId,SellOrderId,SPName,HistoryMessage)
	select Getdate(),@BuyOrderId,@SellOrderId,'usp_ProcessTransactionv2 Error Message',ERROR_MESSAGE()
	throw 
end catch
END


