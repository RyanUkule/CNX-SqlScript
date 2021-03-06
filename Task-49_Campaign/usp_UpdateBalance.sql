USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateBalance]    Script Date: 2018/10/09 11:33:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_UpdateBalance]
@CustomerId int,
@AssetTypeId int,
@Balance decimal(38,8),
@FrozenBalance decimal(38,8),
@updateDate datetime,
@Locked bit,
@Hash nvarchar(500),
@lastHash nvarchar(500)
AS
BEGIN
	if(exists(select * from AssetBalance where CustomerId = @CustomerId and AssetTypeId = @AssetTypeId and [Hash] = @lastHash))
	begin
		update AssetBalance set Balance = @Balance, FrozenBalance = @FrozenBalance,Locked = @Locked,UpdateDate = @updateDate, [Hash] = @Hash 
		where CustomerId = @CustomerId and AssetTypeId = @AssetTypeId
	end
	else
	begin
		select -1
	end
END




