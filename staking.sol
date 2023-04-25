// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./BasicToken_stake.sol";
import "./BasicNFT.sol";

contract NftStaker {
    error NftStaker__LockUpAlreadyExists();
    error NftStaker__LockUpDoesNotExists();
    error NftStaker__LockUpHasNotMatured();
    
    BasicToken public basicToken;
    BasicNFT public basicNFT;

    uint256 public incentive;

    uint256 public constant LOCK_UP_DURATION = 10 minutes; 

    struct LockUp {
        uint40 lockedAt;
        address user; 
    }

    mapping (uint256 => LockUp) public tokenLockUp;

    uint256 public activeLockUpCount;

    event LockedUp(address indexed user, uint256 tokenId);
    event Unlocked(address indexed user, uint256 tokenId);


    constructor(address _tokenAddress, address _nftAddress) {
        basicToken = BasicToken(_tokenAddress);
        basicNFT = BasicNFT(_nftAddress);
    }

    function lockUp(uint256 tokenId) external {
        LockUp storage lock = tokenLockUp[tokenId];
        if (lock.lockedAt > 0) revert NftStaker__LockUpAlreadyExists();

        basicNFT.transferFrom(msg.sender, address(this), tokenId);
        lock.lockedAt = uint40(block.timestamp);
        lock.user = msg.sender;
        activeLockUpCount += 1;

        emit LockedUp(msg.sender, tokenId);
    }

    function unlock(uint256 tokenId) external {
        LockUp storage lock = tokenLockUp[tokenId];
        uint256 locktime = lock.lockedAt + LOCK_UP_DURATION;
        if (lock.lockedAt == 0) revert NftStaker__LockUpDoesNotExists();
        if (locktime >= block.timestamp) revert NftStaker__LockUpHasNotMatured();
        lock.lockedAt = 0;
        lock.user = address(0);
        activeLockUpCount -= 1;
        uint256 time = block.timestamp - locktime;
        incentive = time/1 minutes;

        basicNFT.transferFrom(address(this), msg.sender, tokenId);
        basicToken.stakemint(msg.sender, incentive);

        emit Unlocked(msg.sender, tokenId);
    }

    function lockUpExists(uint256 tokenId) external view returns(bool) {
        return tokenLockUp[tokenId].lockedAt > 0;
    }
}