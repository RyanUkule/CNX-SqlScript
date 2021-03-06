USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_ProcessTransactionv2]    Script Date: 2018/03/30 14:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_ProcessTransactionv2] 
@RemoteRequestGroupId int,
@BuyorderId int,
@SellorderId int,
@TransactionTypeId int,
@MatchPrice decimal(20,8),
@DealAmount decimal(20,8) = null,
@IsMatchRemote bit,
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
@SellOrderWantHash nvarchar(500),
@BuyOriginalwantHash nvarchar(500),
@BuyOriginalofferHash nvarchar(500),
@SellOriginalwantHash nvarchar(500),
@SellOriginalofferHash nvarchar(500)

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
	@Message varchar(1000), @assetType int, @where varchar(max), @orderStatusId int, @orderId_tmp int,
	@buyOrderStatusId int, @sellOrderStatusId int, @str_tmp varchar(1000),
	@buyofferHash nvarchar(500), @buywantHash nvarchar(500),@sellofferHash nvarchar(500),@sellwantHash nvarchar(500),@AdvanceTransactionId int,
	@buyOrderTypeid int,@sellOrderTypeId int, @wantAssetTypeId int, @offerAssetTypeId int

	Create table #logs
	(
		RMessage varchar(500)
	)

	if(@BuyorderId = @SellorderId)
	begin
		RAISERROR('Same Order in OneTransaction',12,1)
	end


	if(@IsMatchRemote = 1)
	begin
		select @buyOrderStatusId = Orderstatusid from OrderBook with (RowLock) where OrderId in (@BuyorderId,@SellorderId) and CustomerId <> 2
		if(@buyOrderStatusId <> 10 and @buyOrderStatusId <> 17 and @buyOrderStatusId <> 12)
		begin
			set @str_tmp = 'Remote Mapping LocalOrder is not correct, status is ' + convert(varchar(100),@buyOrderStatusId)
			RAISERROR(@str_tmp,12,1)
		end
	end
	else
		begin
		select @buyOrderStatusId = OrderStatusId from OrderBook with (RowLock) where OrderId = @BuyOrderId
		if(@buyOrderStatusId <> 1 and @buyOrderStatusId <> 2 and @buyOrderStatusId <> 17)
		begin
			set @str_tmp = 'Local execute BuyOrderStatusId is not correct, status is ' + convert(varchar(100),@buyOrderStatusId)
			RAISERROR(@str_tmp,12,1)
		end
		select @sellOrderStatusId = OrderStatusId from OrderBook with (RowLock) where OrderId = @SellOrderId
		if(@sellOrderStatusId <> 1 and @sellOrderStatusId <> 2  and @sellOrderStatusId <> 17)
		begin
		set @str_tmp = 'Local execute SellOrderStatusId is not correct, status is ' + convert(varchar(100),@sellOrderStatusId)
			RAISERROR(@str_tmp,12,1)
		end
	end
	

	SET @Message  = 'BuyOrderId-' + convert(nvarchar(100),@BuyorderId) +'-SellOrderId-' + convert(nvarchar(100),@SellOrderId) +'-TransactionType-'+convert(nvarchar(100),@TransactionTypeId) + '-MatchPrice-'+ convert(nvarchar(100),@MatchPrice) +'-IsmatchRemote-' + convert(nvarchar(100),@IsMatchRemote)
	if(@DealAmount is not null)
	begin
		set @Message = @Message + '-DealAmount-' + convert(nvarchar(100),@DealAmount) 
	end
	Insert into #logs values(@Message)
	select @Aavailable = quantity, @BuyCustomerId = customerId, @AOrderClassId= OrderClassId, @AssetTypeId = WantAssetTypeId,
	@wantAssetTypeId = WantAssetTypeId, @offerAssetTypeId = OfferAssetTypeId, @buyOrderTypeId = OrderTypeId,
	@assetType = case when WantAssetTypeId = 1 then OfferAssetTypeId else WantAssetTypeId end
	from orderbook with (nolock) where orderid = @BuyorderId
	select @Bavailable = quantity, @SellCustomerId = customerId, @BOrderClassId =OrderClassId 
	from orderbook with (nolock) where orderid = @SellorderId

	declare @symbol varchar(200), @buyTargetAssetType varchar(50), @buySourceAssetType varchar(50)

	select @buyTargetAssetType = Name from AssetType_lkp 
	where AssetTypeId = case when @buyOrderTypeId = 1 then @wantAssetTypeId else @offerAssetTypeId end
	select @buySourceAssetType = Name from AssetType_lkp 
	where AssetTypeId = case when @buyOrderTypeId = 2 then @wantAssetTypeId else @offerAssetTypeId end

	set @symbol = @buyTargetAssetType + '_' + @buySourceAssetType

	select @ACommissionRate =  Case @AOrderClassId 
	when 1 then t.TradingMakerCommission
	when 2 then t.TakeProfitCommission
	when 3 then t.StopLossCommision
	when 4 then t.TriggerCommission
	end
	from TradingPackages t with (nolock) inner join Customer c with (nolock)  on t.PackageUID = c.TradingPackageId
	where t.IsActive = 1 and c.CustomerId = @BuyCustomerId and t.Symbol = @symbol --and t.AssetTypeId = @assetType

	select @BCommissionRate =  Case @BOrderClassId 
	when 1 then t.TradingMakerCommission
	when 2 then t.TakeProfitCommission
	when 3 then t.StopLossCommision
	when 4 then t.TriggerCommission
	end
	from TradingPackages t with (nolock) inner join Customer c with (nolock)  on t.PackageUID = c.TradingPackageId
	where t.IsActive = 1 and c.CustomerId = @SellCustomerId and t.Symbol = @symbol --and t.AssetTypeId = @assetType

	if((select OriginalOrderId from orderbook with (nolock) where OrderId = @BuyorderId) is null)
	begin
		select @BuyOrderOriginalOrderId = @BuyOrderId
	end
	else
	begin
		select @BuyOrderOriginalOrderId = OriginalOrderId from orderbook with (nolock) where OrderId = @BuyorderId
	end
	set @Message = 'BuyOrderOriginalOrderId-' + convert(nvarchar(100),@BuyOrderOriginalOrderId)
	Insert into #logs values(@Message)

	if((select OriginalOrderId from orderbook with (nolock) where OrderId = @SellOrderId) is null)
	begin
		select @SellOrderOriginalOrderId = @SellOrderId
	end
	else
	begin
		select @SellOrderOriginalOrderId = OriginalOrderId from orderbook with (nolock) where OrderId = @SellOrderId
	end

	set @Message = 'SellOrderOriginalOrderId-' + convert(nvarchar(100),@SellOrderOriginalOrderId)
	Insert into #logs values(@Message)

	if(@IsMatchRemote = 0)
	begin
		if(@DealAmount is null or @DealAmount <= 0)
		begin
			set @Message = 'DealAmount is 0 or below 0'
			Insert into #logs values(@Message)
			--Internal Match
			if(@Aavailable = @Bavailable)
			begin
				set @Message = 'Aavailable = Bavailable = ' + convert(nvarchar(100),@Aavailable)
				Insert into #logs values(@Message)
				-- Create Transaction
				Insert into [Transaction](A_OrderId,A_Amount,A_Commission,B_OrderId,B_Amount,B_Commission,UpdateDate,InsertDate,SaveDate,TransactionTypeId)
				values
				(
					@BuyorderId,
					(@Aavailable * @MatchPrice) - (@Aavailable * @MatchPrice) * @BCommissionRate,
					(@Aavailable * @MatchPrice) * @BCommissionRate,
					@SellorderId,
					@Bavailable - @Bavailable * @ACommissionRate,
					@Bavailable * @ACommissionRate,
					getdate(),
					getdate(),
					getdate(),
					@TransactionTypeId
				)
				select @TransId = SCOPE_IDENTITY()

				select @AofferAmount = @Aavailable * @MatchPrice, @AwantAmount = @Bavailable - @Bavailable * @ACommissionRate,
				@BofferAmount = @Bavailable, @BwantAmount = (@Aavailable * @MatchPrice) - (@Aavailable * @MatchPrice) * @BCommissionRate

				--Update Order status
				set @Message = 'Update both buy and sell order status to Completed'
				Insert into #logs values(@Message)

				set @where = ' from orderbook with (nolock) where OrderId = ' + cast(@BuyOrderId as varchar(50)) 
				+ ' or OrderId = ' + cast(@SellOrderId as varchar(50))
				exec usp_CreateOrderStatusHistory 0, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, @where

				Update OrderBook with(RowLock) set OrderStatusId = 4, UpdateDate = getdate() where OrderId = @BuyOrderId
				Update OrderBook with(RowLock) set OrderStatusId = 4, UpdateDate = getdate() where OrderId = @SellOrderId
				select @FinalBuyOrderStatusId = 4 , @FinalSellOrderStatusId = 4
				set @DealAmount = @Aavailable
			end
			if(@Aavailable > @Bavailable)
			begin
				set @Message = 'Aavailable-' + convert(nvarchar(100),@Aavailable) + ' > Bavailable-' + convert(nvarchar(100),@Bavailable)
				Insert into #logs values(@Message)
				--select @ChildOrderStatusId = case when @TransactionTypeId = 1 then OrderStatusId else 2 end
				--from OrderBook with (nolock) where OrderId = @BuyOrderId
				--Create Transaction
				Insert into [Transaction](A_OrderId,A_Amount,A_Commission,B_OrderId,B_Amount,B_Commission,UpdateDate,InsertDate,SaveDate,TransactionTypeId)
				values
				(
					@BuyorderId,
					(@Bavailable * @MatchPrice) - (@Bavailable * @MatchPrice) * @BCommissionRate,
					(@Bavailable * @MatchPrice) * @BCommissionRate,
					@SellorderId,
					@Bavailable - @Bavailable * @ACommissionRate,
					@Bavailable * @ACommissionRate,
					getdate(),
					getdate(),
					getdate(),
					@TransactionTypeId
				)
				select @TransId = SCOPE_IDENTITY()
				
				-- Create Child Order
				select @FinalRemainAmount = @Aavailable - @Bavailable
	
				Insert into [dbo].[OrderBook]
			   ([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
				 select CustomerId,OrderTypeId,OfferAssetTypeId,WantAssetTypeId,@FinalRemainAmount,Price,
				 OrderStatusId,@BuyOrderOriginalOrderId,MarketOrder,ExpirationDate,TakeProfitOrderId,StopLossOrderId,GETDATE(),GETDATE(),getdate(),
				 RemoteExchangeId,RemoteExchangeOrderNumber,ParentOrderId,OrderClassId
				 from OrderBook with (nolock) where OrderId = @BuyOrderId
			   
				select @BuyOrderChildOrderId = SCOPE_IDENTITY()
				exec usp_CreateOrderStatusHistory @BuyOrderChildOrderId, 17, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null

				set @Message = 'Create Child Order for remain part-' + convert(nvarchar(100),@FinalRemainAmount)  + ' Child Buy OrderId-' + convert(nvarchar(100),@BuyOrderChildOrderId)
				Insert into #logs values(@Message)

				---- Update balance
				select 
				@AofferAmount = @Bavailable * @MatchPrice, 
				@AwantAmount = @Bavailable - @Bavailable * @ACommissionRate,
				@BofferAmount = @Bavailable, 
				@BwantAmount = (@Bavailable * @MatchPrice) - (@Bavailable * @MatchPrice) * @BCommissionRate
				
				set @Message = 'Update Sell Order Completed and Buy Order Paritly Completed'
				Insert into #logs values (@Message)

				exec usp_CreateOrderStatusHistory @SellOrderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null
				Update OrderBook  with(RowLock)  set OrderstatusId = 4, UpdateDate = getdate() where OrderId = @SellOrderId
				
				exec usp_CreateOrderStatusHistory @BuyOrderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null
				Update OrderBook with(RowLock)  set OrderstatusId = 4, UpdateDate = getdate() where OrderId = @BuyOrderId

				select @FinalBuyOrderStatusId = 3, @FinalSellOrderStatusId = 4
				set @DealAmount = @Bavailable
		end
			if(@Aavailable < @Bavailable)
			begin
				set @Message = 'Aavailable-' + convert(nvarchar(100),@Aavailable) + '< Bavailable-' + CONVERT(nvarchar(100),@Bavailable)
				Insert into #logs values (@Message)
				--select @ChildOrderStatusId = case when @TransactionTypeId = 2 then OrderStatusId else 2 end 
				--from OrderBook with (nolock) where OrderId = @SellOrderId
				--Create Transaction
				Insert into [Transaction](A_OrderId,A_Amount,A_Commission,B_OrderId,B_Amount,B_Commission,UpdateDate,InsertDate,SaveDate,TransactionTypeId)
				values
				(
					@BuyorderId,
					(@Aavailable * @MatchPrice) - (@Aavailable * @MatchPrice) * @BCommissionRate,
					(@Aavailable * @MatchPrice) * @BCommissionRate,
					@SellorderId,
					@Aavailable - @Aavailable * @ACommissionRate,
					@Aavailable * @ACommissionRate,
					getdate(),
					getdate(),
					getdate(),
					@TransactionTypeId
				)
				select @TransId = SCOPE_IDENTITY()

				-- Create Child Order
				select @FinalRemainAmount = @Bavailable - @Aavailable
				Insert into [dbo].[OrderBook]
			   ([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
				select CustomerId,OrderTypeId,OfferAssetTypeId,WantAssetTypeId,@FinalRemainAmount,Price,
				OrderStatusId,@SellOrderOriginalOrderId,MarketOrder,ExpirationDate,TakeProfitOrderId,StopLossOrderId,GETDATE(),GETDATE(),getdate(),
				RemoteExchangeId,RemoteExchangeOrderNumber,ParentOrderId,OrderClassId
				from OrderBook with (nolock) where OrderId = @SellOrderId

				select @SellOrderChildOrderId = SCOPE_IDENTITY()
				exec usp_CreateOrderStatusHistory @SellOrderChildOrderId, 17, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null

				set @Message = 'Create Child Order for remain part-' + convert(nvarchar(100),@FinalRemainAmount) + ' Child Sell OrderId-' + convert(nvarchar(100),@SellOrderChildOrderId)
				Insert into #logs values(@Message)
				-- Update balance
				select 
				@AofferAmount = (@Aavailable * @MatchPrice), 
				@AwantAmount = @Aavailable - @Aavailable * @ACommissionRate,
				@BofferAmount = @Aavailable, 
				@BwantAmount = (@Aavailable * @MatchPrice) - (@Aavailable * @MatchPrice) * @BCommissionRate
			
				set @Message = 'Update Sell Order Paritly Completed and Buy Order Completed'
				Insert into #logs values (@Message)

				exec usp_CreateOrderStatusHistory @SellOrderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null
				Update OrderBook with(RowLock)  set OrderstatusId = 4, UpdateDate = getdate() where OrderId = @SellOrderId
				
				exec usp_CreateOrderStatusHistory @BuyOrderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null
				Update OrderBook with(RowLock)  set OrderstatusId = 4, UpdateDate = getdate() where OrderId = @BuyOrderId

				select @FinalBuyOrderStatusId = 4, @FinalSellOrderStatusId = 3
				set @DealAmount = @Aavailable
			end
		end
		else
		begin
				set @Message = 'DealAmount is not null value-' + convert(nvarchar(100),@DealAmount)
				Insert into #logs values(@Message)
				--Part 2 Create Transaction between tow local
				Insert into [Transaction](A_OrderId,A_Amount,A_Commission,B_OrderId,B_Amount,B_Commission,UpdateDate,InsertDate,SaveDate,TransactionTypeId)
				values
				(
					@BuyorderId,
					(@DealAmount * @MatchPrice) - (@DealAmount * @MatchPrice) * @BCommissionRate,
					(@DealAmount * @MatchPrice) * @BCommissionRate,
					@SellorderId,
					@DealAmount - @DealAmount * @ACommissionRate,
					@DealAmount * @ACommissionRate,
					getdate(),
					getdate(),
					getdate(),
					@TransactionTypeId
				)
				select @TransId = SCOPE_IDENTITY()

				if(@DealAmount < @Aavailable)
				begin
					set @Message = 'DealAmount < Aavailable-' + convert(varchar(100),@Aavailable) 
					Insert into #logs values(@Message)
					Insert into [dbo].[OrderBook]
					([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
					select CustomerId,OrderTypeId,OfferAssetTypeId,WantAssetTypeId,@Aavailable - @DealAmount,Price,
					OrderStatusId,@BuyOrderOriginalOrderId,MarketOrder,ExpirationDate,TakeProfitOrderId,StopLossOrderId,GETDATE(),GETDATE(),getdate(),
					RemoteExchangeId,RemoteExchangeOrderNumber,ParentOrderId,OrderClassId
					from OrderBook with (nolock) where OrderId = @BuyOrderId
						 
					select @BuyOrderChildOrderId = scope_identity()
					select @orderStatusId = OrderStatusId from OrderBook with (nolock) where OrderId = @BuyOrderId

					exec usp_CreateOrderStatusHistory @BuyOrderChildOrderId, 17, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
					@transferCurrencyRate, @comment, null

					set @Message = 'Create Child Buy Order-' +Convert(nvarchar(100),@BuyOrderChildOrderId)
					insert into #logs values(@Message)

					set @FinalBuyOrderStatusId = 3
				end

				if(@DealAmount < @Bavailable)
				begin
					set @Message = 'DealAmount < Bavailable-' + convert(varchar(100),@Bavailable) 
					Insert into #logs values(@Message)
					Insert into [dbo].[OrderBook]
					([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
					select CustomerId,OrderTypeId,OfferAssetTypeId,WantAssetTypeId,@Bavailable - @DealAmount,Price,
					OrderStatusId,@SellOrderOriginalOrderId,MarketOrder,ExpirationDate,TakeProfitOrderId,StopLossOrderId,GETDATE(),GETDATE(),getdate(),
					RemoteExchangeId,RemoteExchangeOrderNumber,ParentOrderId,OrderClassId
					from OrderBook with (nolock) where OrderId = @SellorderId

					select @SellOrderChildOrderId = scope_identity()
					select @orderStatusId = OrderStatusId from OrderBook with (nolock) where OrderId = @BuyOrderId

					exec usp_CreateOrderStatusHistory @SellOrderChildOrderId, @orderStatusId, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
					@transferCurrencyRate, @comment, null

					set @Message = 'Create Child Sell Order-' +Convert(nvarchar(100),@SellOrderChildOrderId)
					insert into #logs values(@Message)

					set @FinalSellOrderStatusId = 3
				end

				select 
				@AofferAmount = (@DealAmount * @MatchPrice), 
				@AwantAmount = @DealAmount - @DealAmount * @ACommissionRate,
				@BofferAmount = @DealAmount, 
				@BwantAmount = (@DealAmount * @MatchPrice) * (1 - @BCommissionRate)
				set @Message = 'Update both orderstatus to Partial Completed'
				insert into #logs values (@Message)

				exec usp_CreateOrderStatusHistory @SellOrderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null
				exec usp_CreateOrderStatusHistory @BuyOrderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null

				Update OrderBook  with(RowLock) set OrderstatusId = 4, UpdateDate = getdate() where OrderId = @SellOrderId
				Update OrderBook  with(RowLock) set OrderstatusId = 4, UpdateDate = getdate() where OrderId = @BuyOrderId
				if(@FinalBuyOrderStatusId is null or @FinalBuyOrderStatusId <> 3)
				begin
					set @FinalBuyOrderStatusId = 4
				end

				if(@FinalSellOrderStatusId is null or @FinalSellOrderStatusId <> 3)
				begin
					set @FinalSellOrderStatusId = 4
				end
		end
	end
	Else
	begin
		set @Message = 'RemoteMatch'
		insert into #logs values (@Message)
		--Remote Match
		declare @RemoteAmount decimal(20,8), @RemoteOrderId int, @localOrderId int, @RemainAmount decimal(20,8),@Activeorderid int, @ActiveAmount decimal(20,8),@ActiveRemoteOrderId int,@newremoteorderId int,
		@localOrderOriginalOrderId int, @remoteOrderOriginalOrderId int
		select @RemoteOrderId = OrderId from orderbook o with(nolock)  inner join Customer c with(nolock) on o.customerId = c.customerId
		where (o.orderid = @BuyOrderId OR o.orderid = @SellOrderId) and c.Name = 'RemoteUser'
		select @RemoteAmount = [RequestAmount] from RemoteOrderMapping with (nolock) where RemoteOrderId = @RemoteOrderId and RemoteOrderMappingStatusId = 1
		if(@RemoteOrderId = @BuyorderId)
		begin
			select @localOrderId = @SellorderId
			select @localOrderOriginalOrderId = @SellOrderOriginalOrderId
			select @remoteOrderOriginalOrderId = @BuyOrderOriginalOrderId
		end
		else
		begin
			select @localOrderId = @BuyorderId
			select @localOrderOriginalOrderId = @BuyOrderOriginalOrderId
			select @remoteOrderOriginalOrderId = @SellOrderOriginalOrderId
		end
		set @Message = '@RemoteAmount:' + convert(nvarchar(100),@RemoteAmount) 
						+ '-@DealAmount:' + convert(nvarchar(100),@DealAmount) 
		Insert into #logs values(@Message)
		if(@DealAmount  = @RemoteAmount)
		begin
			Insert into [Transaction](A_OrderId,A_Amount,A_Commission,B_OrderId,B_Amount,B_Commission,UpdateDate,InsertDate,SaveDate,TransactionTypeId)
			values
			(
				@BuyorderId,
				(@RemoteAmount * @MatchPrice) - (@RemoteAmount * @MatchPrice) * @BCommissionRate,
				(@RemoteAmount * @MatchPrice) * @BCommissionRate,
				@SellorderId,
				@RemoteAmount - @RemoteAmount * @ACommissionRate,
				@RemoteAmount * @ACommissionRate,
				getdate(),
				getdate(),
				getdate(),
				@TransactionTypeId
			)
			select @TransId = SCOPE_IDENTITY()

			select @AofferAmount = @RemoteAmount * @MatchPrice
			select @AwantAmount = @RemoteAmount - @RemoteAmount * @ACommissionRate
			select @BofferAmount = @RemoteAmount
			select @BwantAmount = (@RemoteAmount * @MatchPrice) - (@RemoteAmount * @MatchPrice) * @BCommissionRate

			Update RemoteOrderMapping with(RowLock) set RemoteOrderMappingStatusId = 2, UpdateDate = getdate() 
			where localOrderId = @localOrderId and RemoteOrderMappingStatusId in (1, 5) and RemoteRequestGroupId = @RemoteRequestGroupId
			select @FinalBuyOrderStatusId = 4,@FinalSellOrderStatusId = 4
		end
		else
		begin
			Insert into [Transaction](A_OrderId,A_Amount,A_Commission,B_OrderId,B_Amount,B_Commission,UpdateDate,InsertDate,
			SaveDate,TransactionTypeId)
			values
			(
				@BuyorderId,
				(@DealAmount * @MatchPrice) - (@DealAmount * @MatchPrice) * @BCommissionRate,
				(@DealAmount * @MatchPrice) * @BCommissionRate,
				@SellorderId,
				@DealAmount - @DealAmount * @ACommissionRate,
				@DealAmount * @ACommissionRate,
				getdate(),
				getdate(),
				getdate(),
				@TransactionTypeId
			)
			select @TransId = SCOPE_IDENTITY()

			select @ActiveAmount = @RemoteAmount - @DealAmount  
			from OrderBook with (nolock) where OrderId = @localOrderId

			set @Message = '@ActiveAmount:' + convert(nvarchar(100),@ActiveAmount)
			Insert into #logs values(@Message)

			select 
				@AofferAmount = (@DealAmount * @MatchPrice), 
				@AwantAmount = (@DealAmount - @DealAmount * @ACommissionRate),
				@BofferAmount = @DealAmount, 
				@BwantAmount = (@DealAmount * @MatchPrice) - (@DealAmount * @MatchPrice) * @BCommissionRate
			
				Update RemoteOrderMapping with(RowLock)  set RemoteOrderMappingStatusId = 2, UpdateDate = getdate() 
				where localOrderId = @localOrderId and RemoteOrderMappingStatusId in (1, 5) and RemoteRequestGroupId = @RemoteRequestGroupId

			if(@ActiveAmount > 0)
			begin
				set @Message = 'Inset Into OrderBook, Quantity > 0 Quantity:' + convert(nvarchar(100),@ActiveAmount)
				Insert into #logs values(@Message)

				Insert into [dbo].[OrderBook]
				([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],[OrderStatusId],[OriginalOrderId],
				[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],[RemoteExchangeId] ,
				[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
				select CustomerId,OrderTypeId,OfferAssetTypeId,WantAssetTypeId,@ActiveAmount,Price,
				OrderStatusId,@localOrderOriginalOrderId,MarketOrder,ExpirationDate,TakeProfitOrderId,StopLossOrderId,GETDATE(),GETDATE(),getdate(),
				RemoteExchangeId,RemoteExchangeOrderNumber,ParentOrderId,OrderClassId
				from OrderBook with (nolock) where OrderId = @localOrderId
				select @Activeorderid = SCOPE_IDENTITY()
				exec usp_CreateOrderStatusHistory @Activeorderid, 10, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null

				select @mappingId = RemoteOrderMappingId from RemoteOrderMapping where localOrderId = @localOrderId
				Insert into RemoteOrderMapping (RemoteExchangeId,LocalOrderId,RemoteOrderId,IsMarketOrder,RequestPrice,RequestAmount,
				RemoteOrderPrice,OrderTypeId, AssetTypeId,RemoteRequestGroupId,RemoteOrderMappingStatusId, InsertDate, UpdateDate)
				select RemoteExchangeId,LocalOrderId,RemoteOrderId,IsMarketOrder,RequestPrice,@DealAmount,RemoteOrderPrice,OrderTypeId,
				AssetTypeId,RemoteRequestGroupId,RemoteOrderMappingStatusId, InsertDate, UpdateDate 
				from RemoteOrderMapping with (nolock) where RemoteOrderMappingId = @mappingId
				--delete from RemoteOrderMapping where RemoteOrderMappingId = @mappingId
				Update RemoteOrderMapping set RemoteOrderMappingStatusId = 4, UpdateDate = GETDATE() where RemoteOrderMappingId = @mappingId

				Insert into [dbo].[OrderBook]
				([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],[OrderStatusId],[OriginalOrderId],
				[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],[RemoteExchangeId] ,
				[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
				select CustomerId,OrderTypeId,OfferAssetTypeId,WantAssetTypeId,@ActiveAmount,Price,
				OrderStatusId,OriginalOrderId,MarketOrder,ExpirationDate,TakeProfitOrderId,StopLossOrderId,GETDATE(),GETDATE(),getdate(),
				RemoteExchangeId,RemoteExchangeOrderNumber,ParentOrderId,OrderClassId
				from OrderBook with (nolock) where OrderId = @RemoteOrderId

				select @newremoteorderId = SCOPE_IDENTITY()


				Insert into RemoteOrderMapping (RemoteExchangeId,LocalOrderId,RemoteOrderId,IsMarketOrder,RequestPrice,RequestAmount,
				RemoteOrderPrice,OrderTypeId, AssetTypeId,RemoteRequestGroupId,RemoteOrderMappingStatusId, InsertDate, UpdateDate)
				select RemoteExchangeId,@Activeorderid,@newremoteorderId,IsMarketOrder,RequestPrice,@ActiveAmount,RemoteOrderPrice,OrderTypeId,
				AssetTypeId,RemoteRequestGroupId,1,getdate(),getdate() from RemoteOrderMapping with (nolock) where RemoteOrderMappingId = @mappingId

				exec usp_CreateOrderStatusHistory @localOrderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null
				Update OrderBook with(RowLock)  set OrderstatusId = 4, UpdateDate = getdate() where OrderId = @localOrderId
				
				exec usp_CreateOrderStatusHistory @RemoteOrderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null
				update OrderBook  with(RowLock)  set OrderStatusId = 4, UpdateDate = getdate() where OrderId = @RemoteOrderId

				if(@localOrderId = @BuyorderId)
				begin
					select @FinalBuyOrderStatusId = 3, @FinalSellOrderStatusId = 0, @FinalRemainAmount = @ActiveAmount
				end
				else
				begin
					select @FinalBuyOrderStatusId = 0, @FinalSellOrderStatusId = 3, @FinalRemainAmount = @ActiveAmount
				end
			end
			else
			begin
				exec usp_CreateOrderStatusHistory @localOrderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null
				exec usp_CreateOrderStatusHistory @RemoteOrderId, 4, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
				@transferCurrencyRate, @comment, null
				Update OrderBook with(RowLock)  set OrderstatusId = 4, UpdateDate = getdate() where OrderId = @localOrderId
				Update OrderBook with(RowLock)  set OrderstatusId = 4, UpdateDate = getdate() where OrderId = @RemoteOrderId
				
				if(@localOrderId = @BuyorderId)
				begin
					select @FinalBuyOrderStatusId = 4, @FinalSellOrderStatusId = 0, @FinalRemainAmount = @ActiveAmount
				end
				else
				begin
					select @FinalBuyOrderStatusId = 0, @FinalSellOrderStatusId = 4, @FinalRemainAmount = @ActiveAmount
				end
			end
		end
	end

	set @Message = 'Update Balance'
	Insert into #logs values(@Message)

	--UpdateBalance
	declare @ACurrentBalanceForAOffer decimal(20,8),@BCurrentBalanceForBOffer decimal(20,8),@ACurrentBalanceForAwant decimal(20,8),
			@BCurrentBalanceForBwant decimal(20,8), @updateDateForBuyNow datetime, @updateDateForSellNow datetime
	select @ACurrentBalanceForAOffer = Balance, @buyofferHash = [Hash] from AssetBalance with(nolock) where CustomerId = @BuyCustomerId and AssetTypeId = 1
	select @ACurrentBalanceForAwant = Balance, @buywantHash = [Hash] from AssetBalance with(nolock) where CustomerId = @BuyCustomerId and AssetTypeId = @AssetTypeId
	select @BCurrentBalanceForBOffer = Balance, @sellofferHash = [Hash] from AssetBalance with (nolock) where CustomerId = @SellCustomerId and AssetTypeId = @AssetTypeId
	select @BCurrentBalanceForBwant = Balance, @sellwantHash = [Hash] from AssetBalance with(nolock) where  CustomerId = @SellCustomerId and AssetTypeId = 1
	--select @updateDateForBuyNow = max(UpdateDate) from AssetBalance with(nolock) where CustomerId = @BuyCustomerId and (AssetTypeId = 1 or AssetTypeId = @AssetTypeId)
	--select @updateDateForSellNow = max(UpdateDate) from AssetBalance with(nolock) where CustomerId = @SellCustomerId and (AssetTypeId = 1 or AssetTypeId = @AssetTypeId)
	--if(@UpdateDate <= @updateDateForBuyNow or @UpdateDate <= @updateDateForSellNow)
	--begin
	--	RAISERROR('Date is not correct',12,1)
	--end
	--if(@BuyOriginalwantHash  <> @buywantHash or @BuyOriginalofferHash  <> @buyofferHash or @sellofferHash <> @SellOriginalofferHash  or @sellwantHash <> @SellOriginalwantHash )
	--begin
	--	RAISERROR('Hash is not correct',12,1)
	--end
	if(@ACurrentBalanceForAOffer >= @AofferAmount and @BCurrentBalanceForBOffer >= @BofferAmount)
	begin
		set @Message = 'BuyOrderCurrentCNYBalance-' + convert(nvarchar(100),@ACurrentBalanceForAOffer) + ' and OfferAmount-' +Convert(nvarchar(100),@AofferAmount) + 'FinalBalance-' + convert(nvarchar(100),@ACurrentBalanceForAOffer - @AofferAmount) 
		Insert into #logs values (@Message)
		print 'CNY BUY:'
		print '@AofferAmount'
		print @AofferAmount
		print '@UpdateDate'
		print @UpdateDate
		print '@BuyOrderOfferHash'
		print @BuyOrderOfferHash

		Update AssetBalance 
		set balance = balance - @AofferAmount, UpdateDate = @UpdateDate,[Hash] = @BuyOrderOfferHash
		where CustomerId = @BuyCustomerId and AssetTypeId = 1
		set @Message = 'BuyOrderCurrentBTCBalance-' +convert(nvarchar(100),@ACurrentBalanceForAwant) + 'and GetAmount-' + Convert(nvarchar(100),@AwantAmount) +'FinalBalance-'  + convert(nvarchar(100),@ACurrentBalanceForAwant + @AwantAmount)
		Insert into #logs values(@Message)

		print 'NOT CNY BUY:'
		print '@AwantAmount'
		print @AwantAmount
		print '@UpdateDate'
		print @UpdateDate
		print '@BuyOrderWantHash'
		print @BuyOrderWantHash

		Update AssetBalance 
		set Balance = Balance + @AwantAmount, UpdateDate = @UpdateDate,[Hash] = @BuyOrderWantHash
		where CustomerId = @BuyCustomerId and AssetTypeId = @AssetTypeId
		set @Message = 'SellOrderCurrentCNYBalance-' + convert(nvarchar(100),@BCurrentBalanceForBwant) + 'and GetAmount-' + convert(nvarchar(100),@BwantAmount) + 'FinalBalance-' + convert(nvarchar(100),@BCurrentBalanceForBwant +@BwantAmount)
		Insert into #logs values(@Message)

		Update CustomerOrder
		set AveragePrice = (isnull(AveragePrice,0) * isnull(CompletedAmount,0) + @AofferAmount) / (isnull(CompletedAmount,0) + @AwantAmount),
		CompletedAmount = isnull(CompletedAmount,0) + @AwantAmount
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
		where CustomerId = @SellCustomerId and AssetTypeId = 1
		set @Message = 'SellOrderCurrentBTCBalance-' + convert(nvarchar(100),@BCurrentBalanceForBOffer) + 'and OfferAmount-' + CONVERT(nvarchar(100),@BofferAmount) + 'FinalBalance-' + convert(nvarchar(100),@BCurrentBalanceForBOffer - @BofferAmount)
		Insert into #logs values (@Message)

		print 'NOT CNY SELL:'
		print '@BofferAmount'
		print @BofferAmount
		print '@UpdateDate'
		print @UpdateDate
		print '@SellOrderOfferHash'
		print @SellOrderOfferHash

		Update AssetBalance 
		set balance = balance - @BofferAmount, UpdateDate = @UpdateDate, [hash] = @SellOrderOfferHash
		where CustomerId = @SellCustomerId and AssetTypeId = @AssetTypeId

		Update CustomerOrder
		set AveragePrice = (isnull(AveragePrice,0) * isnull(CompletedAmount,0) + @BwantAmount) / (isnull(CompletedAmount,0) + @BofferAmount),
		CompletedAmount = isnull(CompletedAmount,0) + @BofferAmount
		where OrderId = @SellOrderOriginalOrderId

		Insert into AdvancedTransactionV1 (TransactionId, TransactionTypeId, A_OfferBalanceAfterTransaction,A_WantBalanceAfterTransaction,B_OfferBalanceAfterTransaction,B_WantBalanceAfterTransaction)
		values (@TransId, 1, @ACurrentBalanceForAOffer - @AofferAmount,@ACurrentBalanceForAwant + @AwantAmount,
		@BCurrentBalanceForBwant +@BwantAmount,@BCurrentBalanceForBOffer - @BofferAmount)
		set @AdvanceTransactionId=SCOPE_IDENTITY()
	end
	Else
	begin
		RAISERROR('not enough balance',16,1, 'not enough balance')
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
			insert into #logs values (@Message)
			set @FBID = 4
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

		select @SLslippage = Value from CustomerPreference with (nolock) where CustomerId = @BuyCustomerId and PreferenceId = 12

		set @Message = '@BuySonOrderId is not null and @BuySonOrderId > 0'
		Insert into #logs values (@Message)

		if(@StoplossPrice is not null and @StoplossPrice > 0 and @STIdOld is not null and @STIdOld > 0)
		begin
			set @Message = '@StoplossPrice is not null and @StoplossPrice > 0 and @STIdOld is not null and @STIdOld > 0'
			Insert into #logs values (@Message)
			set @Message = '@StoplossPrice: ' + convert(nvarchar(100), @StoplossPrice) + ' @STIdOld:' + convert(nvarchar(100), @STIdOld)
			Insert into #logs values (@Message)
			
			select @TotalAmount = isnull(sum(Quantity), 0) + @DealAmount from OrderBook with (nolock) 
			where (OrderId = @STIdOld or OriginalOrderId = @STIdOld) and OrderstatusId in (2, 7, 9, 14, 17)

			set @where = ' from orderbook with (nolock) where (OrderId = ' + cast(@STIdOld as varchar(50)) 
			+ ' or OriginalOrderId = ' + cast(@STIdOld as varchar(50)) + ') and [OrderStatusId] in (2, 7, 9, 14, 17)'
			exec usp_CreateOrderStatusHistory 0, 16, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
			@transferCurrencyRate, @comment, @where

			update OrderBook  with (RowLock)  set OrderStatusId = 16, UpdateDate = getdate() 
			where (OrderId = @STIdOld or OriginalOrderId = @STIdOld) and OrderStatusId in (2, 7, 9, 14, 17)

			set @Message = convert(nvarchar(100), @TotalAmount)
			Insert into #logs values (@Message)

			Insert into [dbo].[OrderBook]
			([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],
			[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],
			[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
			select CustomerId,2,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,round(@stoplossPrice * (1 - @SLslippage), 0),
			9,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
			RemoteExchangeId,RemoteExchangeOrderNumber,@STIdOld,3
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
			Insert into #logs values (@Message)
		end
		else
		begin
			--select @TotalAmount = quantity from OrderBook with (nolock) where OrderId = @BuyOrderOriginalOrderId 	
			select @TotalAmount = @DealAmount
			-- from Orderbook o with (nolock), RemoteOrderMapping m with (nolock)
			--where (o.OrderId = m.LocalOrderId or o.OrderId = m.RemoteOrderId) and o.OrderId = @BuyOrderId 

			if(@StoplossPrice is not null and @StoplossPrice > 0)
			begin
				Insert into [dbo].[OrderBook]
				([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],
				[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],
				[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
				select CustomerId,2,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,round(@stoplossPrice * (1 - @SLslippage), 0),
				9,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
				RemoteExchangeId,RemoteExchangeOrderNumber,null,3
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
			Insert into #logs values (@Message)
			set @Message = '@TakeProfitPrice: ' + convert(nvarchar(100), @TakeProfitPrice) + ' @TPIdOld:' + convert(nvarchar(100), @TPIdOld)
			Insert into #logs values (@Message)

			select @TotalAmount = isnull(sum(Quantity), 0) + @DealAmount from OrderBook with (nolock) 
			where (OrderId = @TPIdOld or OriginalOrderId = @TPIdOld) and OrderstatusId in (2, 7, 9, 14, 17)

			set @where = ' from orderbook with (nolock) where (OrderId = ' + cast(@TPIdOld as varchar(50)) 
			+ ' or OriginalOrderId = ' + cast(@TPIdOld as varchar(50)) + ') and [OrderStatusId] in (2, 7, 9, 14, 17)'
			exec usp_CreateOrderStatusHistory 0, 16, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
			@transferCurrencyRate, @comment, @where

			update OrderBook with(RowLock)  set OrderStatusId = 16, UpdateDate = getdate() 
			where (OrderId = @TPIdOld or OriginalOrderId = @TPIdOld) and OrderStatusId in (2, 7, 9, 14, 17)

			set @Message = convert(nvarchar(100), @TotalAmount)
			Insert into #logs values (@Message)

			Insert into [dbo].[OrderBook]
			([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],
			[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],
			[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
			select CustomerId,2,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,@TakeProfitPrice,
			2,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
			RemoteExchangeId,RemoteExchangeOrderNumber,@TPIdOld,2
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
			Insert into #logs values (@Message)
		end
		else
		begin
			--select @TotalAmount = quantity from OrderBook with (nolock) where OrderId = @BuyOrderOriginalOrderId 	
			select @TotalAmount = @DealAmount
			-- from Orderbook o with (nolock), RemoteOrderMapping m with (nolock)
			--where (o.OrderId = m.LocalOrderId or o.OrderId = m.RemoteOrderId) and o.OrderId = @BuyOrderId 

			if(@TakeProfitPrice is not null and @TakeProfitPrice > 0)
			begin
				Insert into [dbo].[OrderBook]
				([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
				select CustomerId,2,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,@TakeProfitPrice,
				2,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
				RemoteExchangeId,RemoteExchangeOrderNumber,null,2
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
			insert into #logs values (@Message)
			set @FSID = 4
		end
		--sell end
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

		select @SLslippage = Value from CustomerPreference with (nolock) where CustomerId = @SellCustomerId and PreferenceId = 12

		set @Message = '@SellSonOrderId is not null and @SellSonOrderId > 0'
		Insert into #logs values (@Message)

		if(@StoplossPrice is not null and @StoplossPrice > 0 and @STIdOld is not null and @STIdOld > 0)
		begin
			set @Message = '@StoplossPrice is not null and @StoplossPrice > 0 and @STIdOld is not null and @STIdOld > 0'
			Insert into #logs values (@Message)

			select @TotalAmount = isnull(sum(Quantity), 0) + @DealAmount from OrderBook with (nolock) 
			where (OrderId = @STIdOld or OriginalOrderId = @STIdOld) and OrderstatusId in (2, 7, 9, 14, 17)

			set @where = ' from orderbook with (nolock) where (OrderId = ' + cast(@STIdOld as varchar(50)) 
			+ ' or OriginalOrderId = ' + cast(@STIdOld as varchar(50)) + ') and [OrderStatusId] in (2, 7, 9, 14, 17)'
			exec usp_CreateOrderStatusHistory 0, 16, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
			@transferCurrencyRate, @comment, @where

			update OrderBook with(RowLock)  set OrderStatusId = 16, UpdateDate = getdate() 
			where (OrderId = @STIdOld or OriginalOrderId = @STIdOld) and OrderStatusId in (2, 7, 9, 14, 17)

			set @Message = convert(nvarchar(100), @TotalAmount)
			Insert into #logs values (@Message)

			Insert into [dbo].[OrderBook]
			([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],
			[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],
			[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
			select CustomerId,1,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,round(@stoplossPrice * (1 + @SLslippage), 0),
			9,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
			RemoteExchangeId,RemoteExchangeOrderNumber,@STIdOld,3
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
			Insert into #logs values (@Message)
		end
		else
		begin
			--select @TotalAmount = quantity from OrderBook with (nolock) where OrderId = @SellOrderOriginalOrderId
			select @TotalAmount = @DealAmount 
			--from Orderbook o with (nolock), RemoteOrderMapping m with (nolock)
			--where (o.OrderId = m.LocalOrderId or o.OrderId = m.RemoteOrderId) and o.OrderId = @SellOrderId 	

			if(@StoplossPrice is not null and @StoplossPrice > 0)
			begin
				Insert into [dbo].[OrderBook]
				([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],
				[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],
				[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
				select CustomerId,1,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,round(@stoplossPrice * (1 + @SLslippage), 0),
				9,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
				RemoteExchangeId,RemoteExchangeOrderNumber,null,3
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
			Insert into #logs values (@Message)

			select @TotalAmount = isnull(sum(Quantity), 0) + @DealAmount from OrderBook with (nolock) 
			where (OrderId = @TPIdOld or OriginalOrderId = @TPIdOld) and OrderstatusId in (2, 7, 9, 14, 17)

			set @where = ' from orderbook with (nolock) where (OrderId = ' + cast(@STIdOld as varchar(50)) 
			+ ' or OriginalOrderId = ' + cast(@STIdOld as varchar(50)) + ') and [OrderStatusId] in (2, 7, 9, 14, 17)'
			exec usp_CreateOrderStatusHistory 0, 16, @statusUpdatedBy, @updateReason, @exchangeId, @transferCurrencyType, 
			@transferCurrencyRate, @comment, @where

			update OrderBook with(RowLock)  set OrderStatusId = 16, UpdateDate = getdate() 
			where (OrderId = @TPIdOld or OriginalOrderId = @TPIdOld) and OrderStatusId in (2, 7, 9, 14, 17)

			set @Message = convert(nvarchar(100), @TotalAmount)
			Insert into #logs values (@Message)

			Insert into [dbo].[OrderBook]
			([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],
			[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],
			[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
			select CustomerId,1,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,@TakeProfitPrice,
			2,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
			RemoteExchangeId,RemoteExchangeOrderNumber,@TPIdOld,2
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
			Insert into #logs values (@Message)
		end
		else
		begin
			--select @TotalAmount = quantity from OrderBook with (nolock) where OrderId = @SellOrderOriginalOrderId 	
			select @TotalAmount = @DealAmount 
			--from Orderbook o with (nolock), RemoteOrderMapping m with (nolock)
			--where (o.OrderId = m.LocalOrderId or o.OrderId = m.RemoteOrderId) and o.OrderId = @SellOrderId 

			if(@TakeProfitPrice is not null and @TakeProfitPrice > 0)
			begin
				Insert into [dbo].[OrderBook]
				([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],
				[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],
				[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
				select CustomerId,1,WantAssetTypeId,OfferAssetTypeId,@TotalAmount,@TakeProfitPrice,
				2,null,0,'9999-12-31 23:59:59.997',null,null,GETDATE(),GETDATE(),getdate(),
				RemoteExchangeId,RemoteExchangeOrderNumber,null,2
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
			Insert into #logs values (@Message)

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
					[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
					select CustomerId,OrderTypeId,OfferAssetTypeId,WantAssetTypeId,@FinalRemainAmount,Price,
					OrderStatusId,OriginalOrderId,MarketOrder,ExpirationDate,TakeProfitOrderId,StopLossOrderId,GETDATE(),GETDATE(),getdate(),
					RemoteExchangeId,RemoteExchangeOrderNumber,ParentOrderId,OrderClassId
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
			Insert into #logs values (@Message)

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
					([CustomerId] ,[OrderTypeId] ,[OfferAssetTypeId] ,[WantAssetTypeId],[Quantity],[Price],[OrderStatusId],[OriginalOrderId],[MarketOrder],[ExpirationDate],[TakeProfitOrderId],[StopLossOrderId],[UpdateDate],[InsertDate],[SaveDate],[RemoteExchangeId] ,[RemoteExchangeOrderNumber],[ParentOrderId],[OrderClassId])
						select CustomerId,OrderTypeId,OfferAssetTypeId,WantAssetTypeId,@FinalRemainAmount,Price,
						OrderStatusId,OriginalOrderId,MarketOrder,ExpirationDate,TakeProfitOrderId,StopLossOrderId,GETDATE(),GETDATE(),getdate(),
						RemoteExchangeId,RemoteExchangeOrderNumber,ParentOrderId,OrderClassId
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

		SET @Message  = 'BuyOrderId-' + convert(nvarchar(100),@BuyorderId) +'-SellOrderId-' + convert(nvarchar(100),@SellOrderId) +'-TransactionType-'+convert(nvarchar(100),@TransactionTypeId) + '-MatchPrice-'+ convert(nvarchar(100),@MatchPrice) +'-IsmatchRemote-' + convert(nvarchar(100),@IsMatchRemote)
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


