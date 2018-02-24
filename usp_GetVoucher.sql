USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetVoucher]    Script Date: 2018/02/24 14:05:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_GetVoucher]
@customerId int = null,
@assetTypeId int = null,
@isRedeemed bit = null,
@amount decimal(18, 2) = null,
@startDate datetime = null,
@endDate datetime = null,
@skip int,
@take int
AS
BEGIN
	declare @countcurrent int, @offset int

	if(@isRedeemed is null or @isRedeemed = 0)
	begin
		select @countcurrent = count(*) 
		from Voucher v with (nolock)
		where v.IsCanceled = 0
		--and (v.IsRedeemed = @isRedeemed or @isRedeemed is null)
		and v.Value = case when @amount is null then v.Value else @amount end
		and v.InsertDate >= case when @startDate is null then v.InsertDate else @startDate end
		and v.InsertDate <= case when @endDate is null then v.InsertDate else @endDate end
		and (v.IssuedByCustomerId = @customerId or @customerId is null)
		and (v.AssetTypeId = @assetTypeId or @assetTypeId is null)

		set @offset = case when @countcurrent < (@skip + @take) then (@countcurrent-@skip) else @take end

		select * from 
		(
			select top (@offset) * from 
			(
				select top (@take + @skip) 
				v.VoucherId
				,v.Value Amount
				,at.Name
				,v.InsertDate
				,v.UpdateDate 
				,v.IsRedeemed 
				,v.IssuedByCustomerId
				,v.Note
				from Voucher v with (nolock)
					left join AssetType_lkp at on v.AssetTypeId = at.AssetTypeId
				where v.IsCanceled = 0
				--and (v.IsRedeemed = @isRedeemed or @isRedeemed is null)
				and v.Value = case when @amount is null then v.Value else @amount end
				and v.InsertDate >= case when @startDate is null then v.InsertDate else @startDate end
				and v.InsertDate <= case when @endDate is null then v.InsertDate else @endDate end
				and (v.IssuedByCustomerId = @customerId or @customerId is null)
				and (v.AssetTypeId = @assetTypeId or @assetTypeId is null)
				Order By InsertDate desc
			)
			a order by InsertDate asc
		)
		b order by InsertDate desc 
	end
	else
	begin
		select @countcurrent = count(*) 
		from Voucher v with (nolock)
		left join AssetType_lkp at on v.AssetTypeId = at.AssetTypeId
		where 
		(v.IsRedeemed = @isRedeemed or @isRedeemed is null)
		and v.Value = case when @amount is null then v.Value else @amount end
		and v.InsertDate >= case when @startDate is null then v.InsertDate else @startDate end
		and v.InsertDate <= case when @endDate is null then v.InsertDate else @endDate end
		and (v.RedeemedByCustomerId = @customerId or @customerId is null)
		and (v.AssetTypeId = @assetTypeId or @assetTypeId is null)

		set @offset = case when @countcurrent < (@skip + @take) then (@countcurrent-@skip) else @take end

		select * from 
		(
			select top (@offset) * from 
			(
				select top (@take + @skip) 
				v.VoucherId
				,v.Value Amount
				,at.Name
				,v.InsertDate
				,v.UpdateDate 
				,v.IsRedeemed 
				,v.IssuedByCustomerId
				,v.Note
				from Voucher v with (nolock)
				left join AssetType_lkp at on v.AssetTypeId = at.AssetTypeId
				where 
				(v.IsRedeemed = @isRedeemed or @isRedeemed is null)
				and v.Value = case when @amount is null then v.Value else @amount end
				and v.UpdateDate >= case when @startDate is null then v.UpdateDate else @startDate end
				and v.UpdateDate <= case when @endDate is null then v.UpdateDate else @endDate end
				and (v.RedeemedByCustomerId = @customerId or @customerId is null)
				and (v.AssetTypeId = @assetTypeId or @assetTypeId is null)
				Order By UpdateDate desc
			)
			a order by UpdateDate asc
		)
		b order by UpdateDate desc 
	end

	select @countcurrent
END
