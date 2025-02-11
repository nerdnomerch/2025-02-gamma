// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ShiftProperties.sol";
import "./PositionProperties.sol";
import "./WithdrawalProperties.sol";
import "./DepositProperties.sol";
import "./LiquidationProperties.sol";
import "./ADLProperties.sol";

contract Properties is
    ShiftProperties,
    PositionProperties,
    WithdrawalProperties,
    DepositProperties,
    LiquidationProperties,
    ADLProperties
{
    uint256 internal TEN_THOUSAND = 10_000;

    function gammaGeneralPostconditions(
        address vault,
        uint priceSeed
    ) internal {
        if (PerpetualVaultLens(vault).cancellationTriggered() == false) {
            //NOTE: assume successfull execution
            _invariant_GAMMA_03(vault);
            _invariant_GAMMA_04(vault);
            _invariant_GAMMA_05(vault);
            _invariant_GAMMA_06(vault, priceSeed);
            _invariant_GAMMA_09(vault);
            _invariant_GAMMA_10(vault);
        }
    }

    function _invariant_GAMMA_02(address vault) internal {
        fl.eq(
            states[1].vaultInfos[vault].totalShares,
            states[1].vaultInfos[vault].totalSharesCalculated,
            "GAMMA-2"
        );
    }
    function _invariant_GAMMA_03(address vault) internal {
        if (PerpetualVaultLens(vault).cancellationTriggered() == false) {
            VaultInfo storage vaultInfoBefore = states[0].vaultInfos[vault];
            VaultInfo storage vaultInfoAfter = states[1].vaultInfos[vault];

            uint256 vaultShareValueBefore = vaultInfoBefore.shareValue;
            //preventing false positives when value share % changes
            //from 1wei to 1e15 by introducing arbitrary low precision treshold
            if (
                vaultInfoBefore.vaultUSDCBalance +
                    vaultInfoBefore.collateralAmount >
                1e3
            ) {
                uint256 vaultShareValueAfter = vaultInfoAfter.shareValue;
                if (vaultShareValueAfter != 0) {
                    int256 vaultShareValueChangePercentage;
                    if (vaultShareValueBefore == 0) {
                        vaultShareValueChangePercentage = 0;
                    } else {
                        int256 difference = int256(vaultShareValueAfter) -
                            int256(vaultShareValueBefore);
                        if (
                            abs(difference) * 10000 < vaultShareValueBefore * 5
                        ) {
                            //gmx fees
                            // Change is less than 0.05%, consider it as no change
                            vaultShareValueChangePercentage = 0;
                        } else if (
                            vaultShareValueAfter >= vaultShareValueBefore
                        ) {
                            vaultShareValueChangePercentage = int256(
                                ((vaultShareValueAfter * 1e30) /
                                    vaultShareValueBefore) - 1e30
                            );
                        } else {
                            vaultShareValueChangePercentage = -int256(
                                ((vaultShareValueBefore * 1e30) /
                                    vaultShareValueAfter) - 1e30
                            );
                        }
                    }

                    uint256 userSharesChangedCount = 0;
                    for (uint i = 0; i < USERS.length; i++) {
                        address checkUser = USERS[i];
                        UserState storage userStateBefore = vaultInfoBefore
                            .userStates[checkUser];
                        UserState storage userStateAfter = vaultInfoAfter
                            .userStates[checkUser];
                        if (
                            userStateBefore.totalShares !=
                            userStateAfter.totalShares
                        ) {
                            userSharesChangedCount++;
                        }
                        if (
                            userStateBefore.totalShares > 0 &&
                            userStateAfter.totalShares > 0
                        ) {
                            int256 userShareValueChangePercentage;
                            if (userStateBefore.shareValue == 0) {
                                userShareValueChangePercentage = 0;
                            } else {
                                int256 difference = int256(
                                    userStateAfter.shareValue
                                ) - int256(userStateBefore.shareValue);
                                if (
                                    abs(difference) * 10000 <
                                    userStateBefore.shareValue * 5
                                ) {
                                    // Change is less than 0.05%, consider it as no change
                                    userShareValueChangePercentage = 0;
                                } else if (
                                    userStateAfter.shareValue >=
                                    userStateBefore.shareValue
                                ) {
                                    userShareValueChangePercentage = int256(
                                        ((userStateAfter.shareValue * 1e30) /
                                            userStateBefore.shareValue) - 1e30
                                    );
                                } else {
                                    userShareValueChangePercentage = -int256(
                                        ((userStateBefore.shareValue * 1e30) /
                                            userStateAfter.shareValue) - 1e30
                                    );
                                }
                            }

                            if (vaultShareValueChangePercentage > 1e28) {
                                //too small vault value change will not be seen on user share value change
                                eqPercentageDiff(
                                    uint256(userShareValueChangePercentage),
                                    uint256(vaultShareValueChangePercentage),
                                    3e27, // some presision tolerance
                                    "GAMMA-3"
                                );
                            }
                        }
                    }
                    fl.lte(
                        userSharesChangedCount,
                        1,
                        "GAMMA-3: Multiple users' shares changed unexpectedly"
                    );
                }
            }
        }
    }
    function _invariant_GAMMA_04(address vault) internal {
        if (PerpetualVaultLens(vault).cancellationTriggered() == false) {
            (PerpetualVault.NextActionSelector selector, ) = PerpetualVault(
                vault
            ).nextAction();
            selector == PerpetualVault.NextActionSelector.NO_ACTION;
            fl.t(
                selector == PerpetualVault.NextActionSelector.NO_ACTION,
                "GAMMA-4"
            );
        }
    }

    function _invariant_GAMMA_05(address vault) internal {
        //After all execution stages
        (, uint swappedData, uint remainingData) = PerpetualVaultLens(vault)
            .swapProgressData();
        fl.t(swappedData == 0 && remainingData == 0, "GAMMA-5");
    }

    function _invariant_GAMMA_06(address vault, uint priceSeed) internal {
        MarketPrices memory convertedPrices = getConvertedMarketPrices(
            vaultToMarket[vault],
            priceSeed
        );
        if (PerpetualVault(vault).curPositionKey() != bytes32(0)) {
            (, , uint256 sizeInUsd, , , , ) = PerpetualVaultLens(vault)
                .getPositionInfo(convertedPrices);

            fl.neq(sizeInUsd, 0, "GAMMA-06");
        }
    }

    function _invariant_GAMMA_08(address vault, uint priceSeed) internal {
        MarketPrices memory convertedPrices = getConvertedMarketPrices(
            vaultToMarket[vault],
            priceSeed
        );
        if (PerpetualVault(vault).curPositionKey() != bytes32(0)) {
            (, , uint256 sizeInUsd, , , , ) = PerpetualVaultLens(vault)
                .getPositionInfo(convertedPrices);

            if (sizeInUsd != 0) {
                fl.t(!PerpetualVault(vault).positionIsClosed(), "GAMMA-08");
            }
        }
    }

    function _invariant_GAMMA_09(address vault) internal {
        fl.t(uint(PerpetualVault(vault).flow()) == 0, "GAMMA-09");
    }

    function _invariant_GAMMA_10(address vault) internal {
        fl.t(PerpetualVaultLens(vault)._getGMXLock() == false, "GAMMA-10");
    }

    function invariantDoesNotSilentRevert(bytes memory returnData) internal {
        fl.gte(returnData.length, 4, "GLOBAL-1 Should not silent revert");
        revert(toHexString(returnData));
    }

    function _invariant_GAMMA_12(address vault, address user) internal {
        if (!PerpetualVaultLens(vault).cancellationTriggered() == false) {
            fl.gt(
                states[1].vaultInfos[vault].userStates[user].totalShares,
                states[0].vaultInfos[vault].userStates[user].totalShares,
                "GAMMA-12: If user deposits they will get a non-zero amount of shares"
            );
        }
    }

    function isLongOneLeverage(
        bool _isLong,
        uint256 _leverage
    ) internal returns (bool) {
        return _isLong && _leverage == TEN_THOUSAND;
    }
}
