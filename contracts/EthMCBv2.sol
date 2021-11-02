// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "@openzeppelin/contracts-ethereum-package/contracts/presets/ERC20PresetMinterPauser.sol";

import {IInbox, IBridge, IOutbox} from "./IArbitrum.sol";

import {MCB} from "./MCB.sol";

/**
 * @dev MCB token v2.0.0
 */
contract EthMCBv2 is MCB {
    using Address for address;

    uint256 public constant MAX_SUPPLY = 10_000_000 * 1e18;

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
    event Mint(address indexed recipient, uint256 amount);

    /**
     * @notice Mint tokens to gateway, so that tokens minted from L2 will be able to withdraw from arb->eth.
     */
    function escrowMint(uint256 amount) external virtual {
        address msgSender = _l2Sender();
        require(msgSender == l2Token, "sender must be l2 token");
        _mint(gateway, amount);
        emit EscrowMint(msgSender, amount);
    }

    function _mint(address to, uint256 amount) internal virtual override {
        super._mint(to, amount);
        require(totalSupply() <= MAX_SUPPLY, "max supply exceeded");
    }

    function _l2Sender() internal view virtual returns (address) {
        IBridge bridge = IInbox(inbox).bridge();
        require(address(bridge) != address(0), "bridge is zero address");
        IOutbox outbox = IOutbox(bridge.activeOutbox());
        require(address(outbox) != address(0), "outbox is zero address");
        return outbox.l2ToL1Sender();
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "insufficient balance for call"
        );
        require(target.isContract(), "call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    uint256[50] private __gap;
}
