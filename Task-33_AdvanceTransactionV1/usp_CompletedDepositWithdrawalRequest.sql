USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_CompletedDepositWithdrawalRequest]    Script Date: 2018/03/30 14:22:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[usp_CompletedDepositWithdrawalRequest] 
@CustomerId int,
@AssetTypeId int,
@TransferRequestTypeId int ,
@Amount decimal(22,8) ,
@TransferRequestId int,
@updateDate datetime,
@hash nvarchar(500), -- assetbalance hash
@oldhash nvarchar(500) = null,
@ConfiramtionCode nvarchar(200) = null,
@ApprovedCustomerId int = null
as 
begin
 begin tran
  begin try
	  declare @transbalance decimal(38,8),@CNYtransbalance decimal(38,8),@originalHash nvarchar(500),@commission decimal(18,8),@requeststatusId int, @pay decimal(38,8)

	  select @transbalance=balance, @originalHash = [hash] from AssetBalance with (nolock) where CustomerId = @CustomerId and AssetTypeId = @AssetTypeId

	  if(@originalHash = @oldhash or @oldhash is null)
	  begin
			  select @CNYtransbalance=balance from AssetBalance with (nolock) where CustomerId = @CustomerId and AssetTypeId = 1

			  select @commission= Commision,@requeststatusId= RequestStatusId, @pay= PayAmount from TransferRequest  with (nolock) where RequestId = @TransferRequestId

			  set @transbalance=case @TransferRequestTypeId when 1 then (@transbalance+@Amount)
															when 2 then (@transbalance - @Amount - @commission) 
															when 6 then (@transbalance + @Amount) 
															when 7 then (@transbalance - @Amount - @commission) 
															when 8 then (@transbalance + @Amount) 
															when 9 then (@transbalance - @Amount - @commission) 
															when 10 then (@transbalance + @Amount) 
															when 11 then (@transbalance - @Amount - @commission) 
															when 12 then (@transbalance + @Amount) 
															when 13 then (@transbalance - @Amount - @commission) 
															when 14 then (@transbalance + @Amount) 
															when 15 then (@transbalance - @Amount - @commission) 
															when 16 then (@transbalance + @Amount) 
															when 17 then (@transbalance - @Amount - @commission) 
															when 18 then (@transbalance + @Amount) 
															when 19 then (@transbalance - @Amount - @commission) 
															when 20 then (@transbalance + @Amount) 
															when 21 then (@transbalance - @Amount - @commission) 
															when 22 then (@transbalance + @Amount) 
															when 23 then (@transbalance - @Amount - @commission) 
															when 26 then (@transbalance + @Amount) 
															when 27 then (@transbalance - @Amount - @commission) 
															when 28 then (@transbalance + @Amount) 
															when 29 then (@transbalance - @Amount - @commission) 
															when 30 then (@transbalance + @Amount) 
															when 31 then (@transbalance - @Amount - @commission) 
															when 32 then (@transbalance + @Amount) 
															when 33 then (@transbalance - @Amount - @commission) 
															when 34 then (@transbalance + @Amount) 
															when 35 then (@transbalance - @Amount - @commission) 
															when 36 then (@transbalance + @Amount) 
															when 37 then (@transbalance - @Amount - @commission) 
															when 38 then (@transbalance + @Amount) 
															when 39 then (@transbalance - @Amount - @commission) 
															when 40 then (@transbalance + @Amount) 
															when 41 then (@transbalance - @Amount - @commission) 
															end

			   if(@transbalance>=0 and @requeststatusId <> 3)
			   begin 
				   if(@ConfiramtionCode is null)
					   begin
							update [TransferRequest] set [RequestStatusId]=3,UpdateDate=getdate() where [RequestId]=@TransferRequestId
					   end
				   else
					   begin
							update [TransferRequest] set 
							[RequestStatusId]=3,
							ConfirmationCode = @ConfiramtionCode,
							ApprovedCustomerId = @ApprovedCustomerId,
							UpdateDate=getdate() 
							where [RequestId]=@TransferRequestId
					   end   

				   Update AssetBalance set balance =@transbalance,FrozenBalance = FrozenBalance - @Amount - @commission, UpdateDate = @updateDate, [Hash] = @hash 																  
				   where CustomerId = @CustomerId and AssetTypeId = @AssetTypeId

				   Insert into AdvancedTransaction ([TransferRequestId], TransactionType,[A_CNYBalance],[A_Balance],[B_CNYBalance] ,[B_Balance])
						values (@TransferRequestId, case @TransferRequestTypeId 
																				when 1 then ('BTC Deposit')
																				when 2 then ('BTC Withdrawal')
																				when 6 then ('LTC Deposit')
																				when 7 then ('LTC Withdrawal')
																				when 8 then ('ETH Deposit') 
																				when 9 then ('ETH Withdrawal') 
																				when 10 then ('ETC Deposit')
																				when 11 then ('ETC Withdrawal') 
																				when 12 then ('SKY Deposit')
																				when 13 then ('SKY Withdrawal')
																				when 14 then ('SHELL Deposit')
																				when 15 then ('SHELL Withdrawal')
																				when 16 then ('BCC Deposit')
																				when 17 then ('BCC Withdrawal')
																				when 18 then ('ZEC Deposit')
																				when 19 then ('ZEC Withdrawal')
																				when 20 then ('DRG Deposit')
																				when 21 then ('DRG Withdrawal')
																				when 22 then ('CABS Deposit')
																				when 23 then ('CABS Withdrawal')
																				when 26 then ('FCABS Deposit')
																				when 27 then ('FCABS Withdrawal')
																				when 28 then ('USDT Deposit')
																				when 29 then ('USDT Withdrawal')
																				when 30 then ('DASH Deposit')
																				when 31 then ('DASH Withdrawal')
																				when 32 then ('ZRX Deposit')
																				when 33 then ('ZRX Withdrawal')
																				when 34 then ('FUN Deposit')
																				when 35 then ('FUN Withdrawal')
																				when 36 then ('TNB Deposit')
																				when 37 then ('TNB Withdrawal')
																				when 38 then ('ETP Deposit')
																				when 39 then ('ETP Withdrawal')
																				end, @CNYtransbalance, @transbalance,0,0)


				  --if(@TransferRequestTypeId in (2,9,11,13,15))
				  --begin
						--Update FeeFreeVolume  set Volume = Volume - (@Amount + @commission - isnull(@pay,0)),UpdateDate = GETDATE() where CustomerId = @CustomerId and AssetTypeId = @AssetTypeId
				  --end
				  --else
				  --begin
						--Update FeeFreeVolume  set Volume = Volume + @Amount + @commission ,UpdateDate = GETDATE() where CustomerId = @CustomerId and AssetTypeId = @AssetTypeId
				  --end
					
				  select 1 --交易成功
			 end 
			 else 
			 begin
				 select 2 --余额不足
			 end
	 end
	 else
	 begin
		select 3 -- hash is not correct
	 end
  commit tran     
end try
begin	catch 
		rollback tran		
		select 0 --交易出错
end catch
end