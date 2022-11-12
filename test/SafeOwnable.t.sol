// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "../src/access/SafeOwnable.sol";

contract MockSafeOwnable is SafeOwnable {
    function restricted() public view onlyOwner {
        // do nothing
    }

    function restrictedPending() public view onlyPendingOwner {
        // do nothing
    }

    function opened() public view {
        // do nothing
    }
}

contract SafeOwnableTest is Test {
    ISafeOwnable mockSafeOwnable;

    address immutable DEV = address(this);
    address constant ALICE = address(0x1);
    address constant BOB = address(0x2);

    function setUp() public {
        mockSafeOwnable = ISafeOwnable(new MockSafeOwnable());
    }

    function testSetPendingOwner() public {
        vm.prank(DEV);
        mockSafeOwnable.setPendingOwner(ALICE);

        assertEq(mockSafeOwnable.pendingOwner(), ALICE);
    }

    function testSetPendingOwnerFail() public {
        vm.expectRevert(ISafeOwnable.SafeOwnable__OnlyOwner.selector);
        vm.prank(ALICE);
        mockSafeOwnable.setPendingOwner(ALICE);

        assertEq(mockSafeOwnable.pendingOwner(), address(0));
    }

    function testBecomeOwner() public {
        vm.prank(DEV);
        mockSafeOwnable.setPendingOwner(ALICE);

        vm.prank(ALICE);
        mockSafeOwnable.becomeOwner();

        assertEq(mockSafeOwnable.owner(), ALICE);
        assertEq(mockSafeOwnable.pendingOwner(), address(0));
    }

    function testBecomeOwnerFail() public {
        vm.prank(DEV);
        mockSafeOwnable.setPendingOwner(ALICE);

        vm.prank(BOB);

        vm.expectRevert(ISafeOwnable.SafeOwnable__OnlyPendingOwner.selector);
        mockSafeOwnable.becomeOwner();

        assertEq(mockSafeOwnable.owner(), DEV);
        assertEq(mockSafeOwnable.pendingOwner(), ALICE);
    }

    function testRestricted() public {
        vm.prank(DEV);
        MockSafeOwnable(address(mockSafeOwnable)).restricted();

        vm.prank(ALICE);

        vm.expectRevert(ISafeOwnable.SafeOwnable__OnlyOwner.selector);
        MockSafeOwnable(address(mockSafeOwnable)).restricted();
    }

    function testRestrictedPending() public {
        vm.prank(DEV);
        MockSafeOwnable(address(mockSafeOwnable)).setPendingOwner(ALICE);

        vm.prank(ALICE);
        MockSafeOwnable(address(mockSafeOwnable)).restrictedPending();

        vm.prank(BOB);

        vm.expectRevert(ISafeOwnable.SafeOwnable__OnlyPendingOwner.selector);
        MockSafeOwnable(address(mockSafeOwnable)).restrictedPending();
    }

    function testOpened() public {
        vm.prank(DEV);
        MockSafeOwnable(address(mockSafeOwnable)).opened();

        vm.prank(ALICE);
        MockSafeOwnable(address(mockSafeOwnable)).opened();
    }
}
