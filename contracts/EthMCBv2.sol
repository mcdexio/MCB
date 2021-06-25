// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "@openzeppelin/contracts-ethereum-package/contracts/presets/ERC20PresetMinterPauser.sol";

import {ITokenGateway, IInbox, IBridge, IOutbox} from "./IArbitrum.sol";

import {MCB} from "./MCB.sol";

/**
 * @dev MCB token v2.0.0
 */
contract EthMCBv2 is MCB {
    using Address for address;

    address public inbox;
    address public gateway;
    address public l2Token;

    event RegisterTokenOnL2(
        address indexed gateway,
        address indexed l2Token,
        uint256 maxSubmissionCost,
        uint256 maxGas,
        uint256 gasPriceBid
    );
    event SetGateway(
        address indexed gateway,
        uint256 maxSubmissionCost,
        uint256 maxGas,
        uint256 gasPriceBid
    );
    event EscrowMint(address indexed minter, uint256 amount);

    function migrateToArb(
        address gateway_,
        address l2Token_,
        uint256 maxSubmissionCost1,
        uint256 maxSubmissionCost2,
        uint256 maxGas,
        uint256 gasPriceBid
    ) external payable {
        require(
            inbox == 0x0000000000000000000000000000000000000000,
            "already migrated"
        );
        require(gateway_.isContract(), "gateway must be contract");
        require(l2Token_ != address(0), "l1Token must be non-zero address");

        gateway = gateway_;
        l2Token = l2Token_;

        uint256 gas1 = maxSubmissionCost1 + maxGas * gasPriceBid;
        uint256 gas2 = maxSubmissionCost2 + maxGas * gasPriceBid;
        require(msg.value == gas1 + gas2, "overpay");

        // register token address to paring with arb-token.
        {
            bytes memory functionCallData = abi.encodeWithSignature(
                "registerTokenToL2(address,uint256,uint256,uint256)",
                l2Token,
                maxGas,
                gasPriceBid,
                maxSubmissionCost1
            );
            (bool success, ) = gateway.call{value: gas1}(functionCallData);
            require(success, "call registerTokenToL2 failed");
            emit RegisterTokenOnL2(
                gateway,
                l2Token,
                maxGas,
                gasPriceBid,
                maxSubmissionCost1
            );
        }

        // register token to gateway.
        {
            bytes memory functionCallData = abi.encodeWithSignature(
                "setGateway(address,uint256,uint256,uint256)",
                gateway,
                maxGas,
                gasPriceBid,
                maxSubmissionCost2
            );
            (bool success, ) = ITokenGateway(gateway).router().call{
                value: gas2
            }(functionCallData);
            require(success, "call setGateway failed");
            emit SetGateway(gateway, maxGas, gasPriceBid, maxSubmissionCost2);
        }
    }

    /**
     * @notice Mint tokens to gateway, so that tokens minted from L2 will be able to withdraw from arb->eth.
     */
    function escrowMint(uint256 amount) external virtual {
        address msgSender = _l2Sender();
        require(msgSender == l2Token, "sender must be l2 token");
        _mint(gateway, amount);
        emit EscrowMint(msgSender, amount);
    }

    function _l2Sender() internal view virtual returns (address) {
        IBridge bridge = IInbox(inbox).bridge();
        require(address(bridge) != address(0), "bridge is zero address");
        IOutbox outbox = IOutbox(bridge.activeOutbox());
        require(address(outbox) != address(0), "outbox is zero address");
        return outbox.l2ToL1Sender();
    }

    function proposal19() public virtual override {
        revert("removed");
    }

    uint256[50] private __gap;
}
