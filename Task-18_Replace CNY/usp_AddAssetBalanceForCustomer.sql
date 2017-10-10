USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_AddAssetBalanceForCustomer]    Script Date: 2017/09/30 10:04:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_AddAssetBalanceForCustomer]
(
	@AssetTypeId int
)
AS
BEGIN
	declare @customerId int, @balance decimal(18,8), @voucherId varchar(30), @issuedBalance decimal(18,8) = 0
--ϵͳ�˺�
insert into AssetBalance(CustomerId, AssetTypeId, Balance, FrozenBalance, UpdateDate, InsertDate, SaveDate, Locked, [Hash])
			select 2, @AssetTypeId, 9999999999, 0, getdate(), getdate(), getdate(), 0, ''

declare Asset_cursor cursor static for 

select CustomerId
from AssetBalance with (nolock)
group by CustomerId
--��ʼ�α�ѭ��
open Asset_cursor  
fetch next from Asset_cursor into @customerId
while @@FETCH_STATUS = 0  
begin 
	begin try 
	begin tran
		--select @balance = Balance from AssetBalance with (nolock) where CustomerId = @customerId and AssetTypeId = 2
		--ϵͳ�˺����
		--select @issuedBalance = Balance from AssetBalance with (nolock) where CustomerId = 2 and AssetTypeId = 10

		if(not exists(select CustomerId from AssetBalance with (nolock) where CustomerId = @customerId and AssetTypeId = @AssetTypeId))
		begin
			insert into AssetBalance(CustomerId, AssetTypeId, Balance, FrozenBalance, UpdateDate, InsertDate, SaveDate, Locked, [Hash])
			select @customerId, @AssetTypeId, 0, 0, getdate(), getdate(), getdate(), 0, ''
		end

		--if(@balance > 0)
		--begin
		--	update AssetBalance set balance = balance - @balance where AssetTypeId = 9 and customerid = 2

		--	set @voucherId = substring(convert(varchar(36), newid()), 0, 30)

		--	Insert into Voucher(VoucherId, RedemptionCodeHash, Value, IssuedByCustomerId, IsRedeemed, RedeemedByCustomerId, 
		--		IsCanceled, AssetTypeId, UpdateDate, InsertDate, SaveDate, Note, CampaignId)
		--	values(@voucherId, '', @balance, 2, 1, @customerId, 
		--		0, 9, GETDATE(), GETDATE(), GETDATE(),N'BTC�ֲ�BCC', 0)

		--	insert into AdvancedTransaction([VoucherId], [TransactionType], [A_CNYBalance], [A_Balance], [B_CNYBalance], [B_Balance])
		--	values(@voucherId, 'Voucher', 0, @issuedBalance - @balance, 0, @balance)
		--end
	commit tran     
	end try
	begin	catch 
		print ERROR_MESSAGE()
		print 'CustomerId:'+ convert(varchar(10),@customerId)
		print 'Balance:'+ convert(varchar(18),@balance)
		print '--------------------------------------------------------'
	end catch

fetch next from Asset_cursor into @customerId
end

deallocate  Asset_cursor
END

