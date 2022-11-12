// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IPendingOwnable {
    error PendingOwnable__OnlyOwner();
    error PendingOwnable__OnlyPendingOwner();

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event PendingOwnerSet(address indexed owner, address indexed pendingOwner);

    function owner() external view returns (address);

    function pendingOwner() external view returns (address);

    function setPendingOwner(address newPendingOwner) external;

    function becomeOwner() external;
}
