// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "../src/access/PendingOwnable.sol";

contract MockPendingOwnable is PendingOwnable {
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

contract PendingOwnableTest is Test {
    IPendingOwnable mockPendingOwnable;

    address immutable DEV = address(this);
    address constant ALICE = address(0x1);
    address constant BOB = address(0x2);

    function setUp() public {
        mockPendingOwnable = IPendingOwnable(new MockPendingOwnable());
    }

    function testSetPendingOwner() public {
        vm.prank(DEV);
        mockPendingOwnable.setPendingOwner(ALICE);

        assertEq(mockPendingOwnable.pendingOwner(), ALICE);
    }

    function testSetPendingOwnerFail() public {
        vm.expectRevert(IPendingOwnable.PendingOwnable__OnlyOwner.selector);
        vm.prank(ALICE);
        mockPendingOwnable.setPendingOwner(ALICE);

        assertEq(mockPendingOwnable.pendingOwner(), address(0));
    }

    function testBecomeOwner() public {
        vm.prank(DEV);
        mockPendingOwnable.setPendingOwner(ALICE);

        vm.prank(ALICE);
        mockPendingOwnable.becomeOwner();

        assertEq(mockPendingOwnable.owner(), ALICE);
        assertEq(mockPendingOwnable.pendingOwner(), address(0));
    }

    function testBecomeOwnerFail() public {
        vm.prank(DEV);
        mockPendingOwnable.setPendingOwner(ALICE);

        vm.prank(BOB);

        vm.expectRevert(IPendingOwnable.PendingOwnable__OnlyPendingOwner.selector);
        mockPendingOwnable.becomeOwner();

        assertEq(mockPendingOwnable.owner(), DEV);
        assertEq(mockPendingOwnable.pendingOwner(), ALICE);
    }

    function testRestricted() public {
        vm.prank(DEV);
        MockPendingOwnable(address(mockPendingOwnable)).restricted();

        vm.prank(ALICE);

        vm.expectRevert(IPendingOwnable.PendingOwnable__OnlyOwner.selector);
        MockPendingOwnable(address(mockPendingOwnable)).restricted();
    }

    function testRestrictedPending() public {
        vm.prank(DEV);
        MockPendingOwnable(address(mockPendingOwnable)).setPendingOwner(ALICE);

        vm.prank(ALICE);
        MockPendingOwnable(address(mockPendingOwnable)).restrictedPending();

        vm.prank(BOB);

        vm.expectRevert(IPendingOwnable.PendingOwnable__OnlyPendingOwner.selector);
        MockPendingOwnable(address(mockPendingOwnable)).restrictedPending();
    }

    function testOpened() public {
        vm.prank(DEV);
        MockPendingOwnable(address(mockPendingOwnable)).opened();

        vm.prank(ALICE);
        MockPendingOwnable(address(mockPendingOwnable)).opened();
    }
}
