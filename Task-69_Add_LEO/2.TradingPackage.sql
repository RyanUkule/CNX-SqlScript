use CNX
GO
--TradingPackage
--1.USDT_LEO
insert into tradingpackages(
	AssetTypeId,
	BtcTransferConfirmations,
	DepositCommission,
	DepositCommissionChargeLimit,
	IsActive,
	MarginInterest,
	MarginRatio,
	MinWithdrawalCommission,
	Name,
	PackageUID,
	StopLossCommision,
	StopLossWarning,
	Symbol,
	TakeProfitCommission,
	TakeProfitReminder,
	TextResourceId,
	TradingMakerCommission,
	TradingTakerCommission,
	TriggerCommission,
	TriggerOrder,
	WithdrawalCommission
)
select 
	48,
	BtcTransferConfirmations,
	0,
	DepositCommissionChargeLimit,
	IsActive,
	MarginInterest,
	MarginRatio,
	0,
	Name,
	PackageUID,
	0,
	StopLossWarning,
	'USDT_LEO',
	0,
	TakeProfitReminder,
	TextResourceId,
	0,
	0,
	0,
	TriggerOrder,
	0
from tradingpackages where symbol = 'BTC_TNB'

--2. BTC_LEO
insert into tradingpackages(
	AssetTypeId,
	BtcTransferConfirmations,
	DepositCommission,
	DepositCommissionChargeLimit,
	IsActive,
	MarginInterest,
	MarginRatio,
	MinWithdrawalCommission,
	Name,
	PackageUID,
	StopLossCommision,
	StopLossWarning,
	Symbol,
	TakeProfitCommission,
	TakeProfitReminder,
	TextResourceId,
	TradingMakerCommission,
	TradingTakerCommission,
	TriggerCommission,
	TriggerOrder,
	WithdrawalCommission
)
select 
	48,
	BtcTransferConfirmations,
	0,
	DepositCommissionChargeLimit,
	IsActive,
	MarginInterest,
	MarginRatio,
	0,
	Name,
	PackageUID,
	0,
	StopLossWarning,
	'BTC_LEO',
	0,
	TakeProfitReminder,
	TextResourceId,
	0,
	0,
	0,
	TriggerOrder,
	0
from tradingpackages where symbol = 'BTC_TNB'



