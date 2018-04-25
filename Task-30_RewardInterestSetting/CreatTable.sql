use CNX
GO
alter table RewardInterestSetting
DROP COLUMN LastRunningTime
GO

alter table RewardInterestSetting
add CalculateInterval bigint not null default 1440 --默认值为24小时

GO
CREATE TABLE BalanceHistoryOfEachDay
(
	Id int identity(1, 1) primary key,
	RewardInterestSettingId int not null,
	CustomerId int not null,
	AssetTypeId int not null,
	Balance decimal(38, 8) not null,
	Date datetime not null
)
GO
CREATE TABLE RewardInterestHistory
(
  Id int primary key identity(1, 1),
  RewardInterestSettingId int not null,
  Rate decimal(38, 8) not null,
  TotalCustomerCount int not null,
  TotalBaseBalance decimal(38, 8) not null,
  TotalInterest decimal(38, 8) not null,
  LastRunningTime datetime not null
)

USE [cnx]
GO

If(object_id('RewardTransaction') is not null)
	drop table RewardTransaction
GO
CREATE TABLE [dbo].[RewardTransaction](
	[RewardTransactionId] [int] IDENTITY(1,1) NOT NULL,
	[RewardInterestSettingId] int NULL,
	[CustomerId] [int] NOT NULL,
	[RewardTypeId] [int] NOT NULL,
	[AssetTypeId] [int] NOT NULL,
	[Comment] [nvarchar](500) NULL,
	[BaseBalance] [decimal](38, 8) NOT NULL,
	[Rate] [decimal](38, 8) NULL,
	[Amount] [decimal](38, 8) NOT NULL,
	[RewardDate] [datetime] NOT NULL
) ON [PRIMARY]
