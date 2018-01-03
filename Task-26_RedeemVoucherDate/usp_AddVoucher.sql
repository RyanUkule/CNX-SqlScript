USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_AddVoucher]    Script Date: 2017/12/29 16:03:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_AddVoucher]
@VoucherId varchar(30),
@RedemptionCodeHash varchar(128),
@Value decimal(38,8),
@IssuedByCustomerId int,
@IsRedeemed bit,
@RedeemedByCustomerId int,
@IsCanceled bit,
@AssetTypeId int,
@note nvarchar(50) = null,
@CampaigmId int = null,
@AllowRedeemDate datetime
AS
BEGIN
	Insert into Voucher(VoucherId, RedemptionCodeHash, Value, IssuedByCustomerId, IsRedeemed, RedeemedByCustomerId, 
		IsCanceled, AssetTypeId, UpdateDate, InsertDate, SaveDate, Note, CampaignId, AllowRedeemDate)
	values(@VoucherId, @RedemptionCodeHash, @Value, @IssuedByCustomerId, @IsRedeemed, @RedeemedByCustomerId, 
		@IsCanceled, @AssetTypeId, GETDATE(), GETDATE(), GETDATE(),@note, @CampaigmId, @AllowRedeemDate)
END
