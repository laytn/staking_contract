// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
// burn을 대신 할 수 있는 기능 추가, 플래시론 기능 추가, 일시정지 기능 추가, 스냅샷 기능 추가, 승인 트랜잭션 가스비 없는 기능 추가

contract BasicToken is ERC20, ERC20Burnable, ERC20Pausable, ERC20Permit, Ownable{

    uint256 public constant DEFAULT_AMOUNT = 100;
    uint256 public constant ADDITIONAL_AMOUNT = 1;
    uint256 public constant FARMING_AMOUNT = DEFAULT_AMOUNT * 10**18; // 100 Token

    address private stakeminter;

    constructor (string memory name, string memory symbol, uint256 supply) ERC20(name, symbol) ERC20Permit(name){
        _mint(msg.sender, supply * 1e18);
    }

    function setStakeminter(address minter) public onlyOwner{
        stakeminter = minter;
    }

    function stakemint(address to, uint256 num) public {
        require(msg.sender == stakeminter, "You are not eligible.");

        uint256 totalamount = (DEFAULT_AMOUNT + (ADDITIONAL_AMOUNT * num)) * 10**18;
        _mint(to, totalamount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
        require(!paused(), "ERC20Pausable: token transfer while paused");
    }

}