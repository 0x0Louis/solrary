// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "forge-std/Test.sol";

import "../src/access/SafeAccessControlEnumerable.sol";

contract MockSafeAccessControlEnumerableTest is SafeAccessControlEnumerable {
    bytes32 public constant TEST_ROLE = keccak256("TEST_ROLE");

    function restricted() public view onlyRole(TEST_ROLE) {
        // do nothing
    }

    function restrictedOnlyOwner() public view onlyOwner {
        // do nothing
    }

    function restrictedOnlyOwnerOrRole() public view onlyOwnerOrRole(TEST_ROLE) {
        // do nothing
    }

    function opened() public view {
        // do nothing
    }
}

contract SafeAccessControlEnumerableTest is Test {
    ISafeAccessControlEnumerable mock;

    bytes32 public TEST_ROLE;
    bytes32 public DEFAULT_ADMIN_ROLE;

    address immutable DEV = address(this);
    address constant ALICE = address(0x1);

    function setUp() public {
        mock = ISafeAccessControlEnumerable(new MockSafeAccessControlEnumerableTest());

        TEST_ROLE = MockSafeAccessControlEnumerableTest(address(mock)).TEST_ROLE();
        DEFAULT_ADMIN_ROLE = mock.DEFAULT_ADMIN_ROLE();
    }

    function testGrantRole() public {
        vm.prank(DEV);
        mock.grantRole(TEST_ROLE, address(this));

        assertEq(mock.hasRole(TEST_ROLE, address(this)), true);
        assertEq(mock.getRoleMemberCount(TEST_ROLE), 1);
        assertEq(mock.getRoleMemberAt(TEST_ROLE, 0), address(this));
    }

    function testRevokeRole() public {
        vm.prank(DEV);
        mock.grantRole(TEST_ROLE, ALICE);
        mock.revokeRole(TEST_ROLE, ALICE);

        assertEq(mock.hasRole(TEST_ROLE, address(this)), false);
        assertEq(mock.getRoleMemberCount(TEST_ROLE), 0);
    }

    function testRenounceRole() public {
        vm.prank(DEV);
        mock.grantRole(TEST_ROLE, ALICE);

        vm.prank(ALICE);
        mock.renounceRole(TEST_ROLE);

        assertEq(mock.hasRole(TEST_ROLE, address(this)), false);
        assertEq(mock.getRoleMemberCount(TEST_ROLE), 0);
    }

    function testGrantRoleTwice() public {
        vm.startPrank(DEV);
        mock.grantRole(TEST_ROLE, ALICE);

        vm.expectRevert(
            abi.encodeWithSelector(
                ISafeAccessControlEnumerable.SafeAccessControlEnumerable__AccountAlreadyHasRole.selector,
                ALICE,
                TEST_ROLE
            )
        );
        mock.grantRole(TEST_ROLE, ALICE);
        vm.stopPrank();

        assertEq(mock.hasRole(TEST_ROLE, ALICE), true);
        assertEq(mock.getRoleMemberCount(TEST_ROLE), 1);
        assertEq(mock.getRoleMemberAt(TEST_ROLE, 0), ALICE);
    }

    function testRevokeRoleTwice() public {
        vm.startPrank(DEV);
        mock.grantRole(TEST_ROLE, ALICE);
        mock.revokeRole(TEST_ROLE, ALICE);

        vm.expectRevert(
            abi.encodeWithSelector(
                ISafeAccessControlEnumerable.SafeAccessControlEnumerable__AccountDoesNotHaveRole.selector,
                ALICE,
                TEST_ROLE
            )
        );
        mock.revokeRole(TEST_ROLE, ALICE);
        vm.stopPrank();

        assertEq(mock.hasRole(TEST_ROLE, ALICE), false);
        assertEq(mock.getRoleMemberCount(TEST_ROLE), 0);
    }

    function testRenounceRoleTwice() public {
        vm.prank(DEV);
        mock.grantRole(TEST_ROLE, ALICE);

        vm.startPrank(ALICE);
        mock.renounceRole(TEST_ROLE);

        vm.expectRevert(
            abi.encodeWithSelector(
                ISafeAccessControlEnumerable.SafeAccessControlEnumerable__AccountDoesNotHaveRole.selector,
                ALICE,
                TEST_ROLE
            )
        );
        mock.renounceRole(TEST_ROLE);
        vm.stopPrank();

        assertEq(mock.hasRole(TEST_ROLE, ALICE), false);
        assertEq(mock.getRoleMemberCount(TEST_ROLE), 0);
    }

    function testCallRestricted() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                ISafeAccessControlEnumerable.SafeAccessControlEnumerable__OnlyRole.selector,
                ALICE,
                TEST_ROLE
            )
        );
        vm.prank(ALICE);
        MockSafeAccessControlEnumerableTest(address(mock)).restricted();
    }

    function testCallRestrictedOnlyOwner() public {
        vm.expectRevert(ISafeOwnable.SafeOwnable__OnlyOwner.selector);
        vm.prank(ALICE);
        MockSafeAccessControlEnumerableTest(address(mock)).restrictedOnlyOwner();
    }

    function testCallRestrictedOnlyOwnerOrRole() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                ISafeAccessControlEnumerable.SafeAccessControlEnumerable__OnlyOwnerOrRole.selector,
                ALICE,
                TEST_ROLE
            )
        );
        vm.prank(ALICE);
        MockSafeAccessControlEnumerableTest(address(mock)).restrictedOnlyOwnerOrRole();
    }

    function testCallOpened() public {
        vm.prank(ALICE);
        MockSafeAccessControlEnumerableTest(address(mock)).opened();
    }
}
