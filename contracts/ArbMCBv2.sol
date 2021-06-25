// SPDX-License-Identifier: GPL
pragma solidity 0.7.4;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

import {IArbSys, IArbToken} from "./IArbitrum.sol";

abstract contract L2ArbitrumMessenger {
    address internal constant arbsysAddr = address(100);

    event TxToL1(
        address indexed _from,
        address indexed _to,
        uint256 indexed _id,
        bytes _data
    );

    function sendTxToL1(
        uint256 _l1CallValue,
        address _from,
        address _to,
        bytes memory _data
    ) internal virtual returns (uint256) {
        uint256 _id = IArbSys(arbsysAddr).sendTxToL1{value: _l1CallValue}(
            _to,
            _data
        );
        emit TxToL1(_from, _to, _id, _data);
        return _id;
    }
}

contract ArbMCBv2 is
    Initializable,
    ContextUpgradeable,
    AccessControlUpgradeable,
    ERC20Upgradeable,
    L2ArbitrumMessenger,
    IArbToken
{
    using AddressUpgradeable for address;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address public l1Token;
    address public gateway;
    uint256 public tokenSupplyOnL1;

    event BridgeMint(address indexed account, uint256 amount);
    event BridgeBurn(address indexed account, uint256 amount);
    event L1EscrowMint(
        address indexed l1Token,
        uint256 indexed withdrawalId,
        uint256 amount
    );

    function initialize(
        string memory name_,
        string memory symbol_,
        address gateway_,
        address l1Token_,
        uint256 tokenSupplyOnL1_
    ) external initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
        __ERC20_init_unchained(name_, symbol_);

        __ArbMCBv2_init_unchained(gateway_, l1Token_, tokenSupplyOnL1_);
    }

    /**
     * @dev initialze addresses && roles
     */
    function __ArbMCBv2_init_unchained(
        address gateway_,
        address l1Token_,
        uint256 tokenSupplyOnL1_
    ) internal initializer {
        require(gateway_.isContract(), "gateway must be contract");
        require(l1Token_ != address(0), "l1Token must be non-zero address");

        gateway = gateway_;
        l1Token = l1Token_;
        tokenSupplyOnL1 = tokenSupplyOnL1_;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    modifier onlyGateway {
        require(msg.sender == gateway, "caller must be gateway");
        _;
    }

    /**
     * @notice Method for token bridge.
     */
    function bridgeMint(address account, uint256 amount)
        external
        override
        onlyGateway
    {
        _mint(account, amount);
        emit BridgeMint(account, amount);
    }

    /**
     * @notice Method for token bridge.
     */
    function bridgeBurn(address account, uint256 amount)
        external
        override
        onlyGateway
    {
        _burn(account, amount);
        emit BridgeBurn(account, amount);
    }

    /**
     * @notice Method for token bridge.
     */
    function l1Address() external view override returns (address) {
        return l1Token;
    }

    /**
     * @notice  Mint token on arb (l2), and send a cross-chain tx to mint the same amount token to gateway.
     */
    function mint(address to, uint256 amount) public virtual {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "must have minter role to mint"
        );
        _mint(to, amount);
        // mint to gateway on L1
        uint256 id = sendTxToL1(
            0,
            address(this),
            l1Token,
            _getOutboundCalldata(amount)
        );
        emit L1EscrowMint(l1Token, id, amount);
    }

    function _getOutboundCalldata(uint256 amount)
        internal
        pure
        virtual
        returns (bytes memory)
    {
        return abi.encodeWithSignature("escrowMint(uint256)", amount);
    }

    uint256[50] private __gap;
}
