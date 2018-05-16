use CNX
GO
--TradingPackage
--OMG
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
	case when AssetTypeId = 0 
		then 0
		else 23
	end as AssetTypeId,
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
	REPLACE(Symbol,'TNB', 'OMG'),
	TakeProfitCommission,
	TakeProfitReminder,
	TextResourceId,
	TradingMakerCommission,
	TradingTakerCommission,
	TriggerCommission,
	TriggerOrder,
	WithdrawalCommission
from tradingpackages where symbol like '%TNB%'

--RCN
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
	case when AssetTypeId = 0 
		then 0
		else 24
	end as AssetTypeId,
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
	REPLACE(Symbol,'TNB', 'RCN'),
	TakeProfitCommission,
	TakeProfitReminder,
	TextResourceId,
	TradingMakerCommission,
	TradingTakerCommission,
	TriggerCommission,
	TriggerOrder,
	WithdrawalCommission
from tradingpackages where symbol like '%TNB%'

--XRP
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
	case when AssetTypeId = 0 
		then 0
		else 25
	end as AssetTypeId,
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
	REPLACE(Symbol,'TNB', 'XRP'),
	TakeProfitCommission,
	TakeProfitReminder,
	TextResourceId,
	TradingMakerCommission,
	TradingTakerCommission,
	TriggerCommission,
	TriggerOrder,
	WithdrawalCommission
from tradingpackages where symbol like '%TNB%'


--EOS
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
	case when AssetTypeId = 0 
		then 0
		else 26
	end as AssetTypeId,
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
	REPLACE(Symbol,'TNB', 'EOS'),
	TakeProfitCommission,
	TakeProfitReminder,
	TextResourceId,
	TradingMakerCommission,
	TradingTakerCommission,
	TriggerCommission,
	TriggerOrder,
	WithdrawalCommission
from tradingpackages where symbol like '%TNB%'

--SPK
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
	case when AssetTypeId = 0 
		then 0
		else 27
	end as AssetTypeId,
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
	REPLACE(Symbol,'TNB', 'SPK'),
	TakeProfitCommission,
	TakeProfitReminder,
	TextResourceId,
	TradingMakerCommission,
	TradingTakerCommission,
	TriggerCommission,
	TriggerOrder,
	WithdrawalCommission
from tradingpackages where symbol like '%TNB%'

--WAX
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
	case when AssetTypeId = 0 
		then 0
		else 28
	end as AssetTypeId,
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
	REPLACE(Symbol,'TNB', 'WAX'),
	TakeProfitCommission,
	TakeProfitReminder,
	TextResourceId,
	TradingMakerCommission,
	TradingTakerCommission,
	TriggerCommission,
	TriggerOrder,
	WithdrawalCommission
from tradingpackages where symbol like '%TNB%'