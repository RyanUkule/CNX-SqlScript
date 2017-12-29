USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetVoucherByCustomerId]    Script Date: 2017/12/29 15:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_GetVoucherByCustomerId]
@CustomerId int,
@IsRedeemed bit,
@IsCanceled bit,
@skip int,
@take int
AS
BEGIN
	declare @countcurrent int, @offset int
	if(@IsRedeemed is null)
	begin
		select @countcurrent = count(*) from Voucher with (nolock) 
		where [IssuedByCustomerId] = @CustomerId 
		and [IsCanceled] = case when @IsCanceled is null then [IsCanceled] else @IsCanceled end
		and [IsRedeemed] = case when @IsRedeemed is null then [IsRedeemed] else @IsRedeemed end

		set @offset = case when @countcurrent < (@skip + @take) then (@countcurrent-@skip) else @take end
		select * from 
		(
			select top (@offset) * from 
			(
				select top (@take + @skip) 
				[VoucherId],
				[RedemptionCodeHash], 
				[Value],
				[Note],
				[IssuedByCustomerId], 
				[IsRedeemed], [IsCanceled], [AssetTypeId], [InsertDate], [UpdateDate], [AllowRedeemDate]
				from Voucher with (nolock) 
				where [IssuedByCustomerId] = @CustomerId 
				and [IsCanceled] = case when @IsCanceled is null then [IsCanceled] else @IsCanceled end
				and [IsRedeemed] = case when @IsRedeemed is null then [IsRedeemed] else @IsRedeemed end
				Order by UpdateDate desc
			)
			x order by UpdateDate asc
		)
		y order by UpdateDate desc 
	end
	else
	begin
		select @countcurrent = count(*) from Voucher with (nolock) 
		where [RedeemedByCustomerId] = @CustomerId 
		and [IsCanceled] = case when @IsCanceled is null then [IsCanceled] else @IsCanceled end
		and [IsRedeemed] = case when @IsRedeemed is null then [IsRedeemed] else @IsRedeemed end

		set @offset = case when @countcurrent < (@skip + @take) then (@countcurrent-@skip) else @take end
		select * from 
		(
			select top (@offset) * from 
			(
				select top (@take + @skip) 
				[VoucherId], [RedemptionCodeHash], [Value],[Note] [RedeemedByCustomerId], [IsRedeemed], [IsCanceled], [AssetTypeId], [UpdateDate], [AllowRedeemDate]
				from Voucher with (nolock) 
				where [RedeemedByCustomerId] = @CustomerId 
				and [IsCanceled] = case when @IsCanceled is null then [IsCanceled] else @IsCanceled end
				and [IsRedeemed] = case when @IsRedeemed is null then [IsRedeemed] else @IsRedeemed end
				Order by UpdateDate desc
			)
			x order by UpdateDate asc
		)
		y order by UpdateDate desc 
	end

	select @countcurrent
END
