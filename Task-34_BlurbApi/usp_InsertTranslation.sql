USE [blurbdb]
GO
/****** Object:  StoredProcedure [dbo].[usp_InsertTranslation]    Script Date: 2018/04/26 17:30:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InsertTranslation]
@blurbId int,
@cultureId int,
@languageCode varchar(10),
@text nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Insert into Translation (BlurbId,[CultureId],LanguageCode,[Text],InsertDate)
	values(@blurbId,@cultureId,@languageCode,@text,GETDATE())

	select @@identity
END
