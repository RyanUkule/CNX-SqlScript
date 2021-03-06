USE [blurbdb]
GO
/****** Object:  StoredProcedure [dbo].[usp_InsertBlurb]    Script Date: 2018/04/26 17:29:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InsertBlurb]
@categoryId int,
@description varchar(max),
@defaultText nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Insert into Blurb (CategoryId,[Description],DefaultText,InsertDate)
	values(@categoryId,@description,@defaultText,getdate())	

	select @@identity

END
