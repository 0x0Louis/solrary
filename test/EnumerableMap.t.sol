// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "../src/structs/EnumerableMap.sol";

contract AddressToUint96MapTest is Test {
    using EnumerableMap for EnumerableMap.AddressToUint96Map;

    EnumerableMap.AddressToUint96Map internal _map;

    function testAdd() external {
        address a = address(0x1);
        uint96 v = 1;

        _map.add(a, v);

        (address key, uint96 value) = _map.at(0);
        assertEq(key, a);
        assertEq(value, v);

        assertEq(_map.contains(a), true);
        assertEq(_map.get(a), v);
        assertEq(_map.length(), 1);
    }

    function testRemove() external {
        address a = address(0x1);
        uint96 v = 1;

        _map.add(a, v);
        _map.remove(a);

        assertEq(_map.contains(a), false);
        assertEq(_map.get(a), 0);
        assertEq(_map.length(), 0);
    }

    function testUpdate() external {
        address a = address(0x1);
        uint96 v = 1;

        _map.add(a, v);
        _map.update(a, 2);

        (address key, uint96 value) = _map.at(0);
        assertEq(key, a);
        assertEq(value, 2);

        assertEq(_map.contains(a), true);
        assertEq(_map.get(a), 2);
        assertEq(_map.length(), 1);
    }

    function testAddMultiple() external {
        address a = address(0x1);
        uint96 v = 1;

        address b = address(0x2);
        uint96 w = 2;

        _map.add(a, v);
        _map.add(b, w);

        (address key, uint96 value) = _map.at(0);
        assertEq(key, a);
        assertEq(value, v);

        (key, value) = _map.at(1);
        assertEq(key, b);
        assertEq(value, w);

        assertEq(_map.contains(a), true);
        assertEq(_map.get(a), v);
        assertEq(_map.contains(b), true);
        assertEq(_map.get(b), w);
        assertEq(_map.length(), 2);
    }

    function testRemoveMultiple() external {
        address a = address(0x1);
        uint96 v = 1;

        address b = address(0x2);
        uint96 w = 2;

        _map.add(a, v);
        _map.add(b, w);
        _map.remove(a);
        _map.remove(b);

        assertEq(_map.contains(a), false);
        assertEq(_map.get(a), 0);
        assertEq(_map.contains(b), false);
        assertEq(_map.get(b), 0);
        assertEq(_map.length(), 0);
    }

    function testUpdateMultiple() external {
        address a = address(0x1);
        uint96 v = 1;

        address b = address(0x2);
        uint96 w = 2;

        _map.add(a, v);
        _map.add(b, w);
        _map.update(a, 3);
        _map.update(b, 4);

        (address key, uint96 value) = _map.at(0);
        assertEq(key, a);
        assertEq(value, 3);

        (key, value) = _map.at(1);
        assertEq(key, b);
        assertEq(value, 4);

        assertEq(_map.contains(a), true);
        assertEq(_map.get(a), 3);
        assertEq(_map.contains(b), true);
        assertEq(_map.get(b), 4);
        assertEq(_map.length(), 2);
    }

    function testAddAndRemoveMultiple() external {
        address a = address(0x1);
        uint96 v = 1;

        address b = address(0x2);
        uint96 w = 2;

        address c = address(0x3);
        uint96 x = 3;

        address d = address(0x4);
        uint96 y = 4;

        _map.add(a, v);
        _map.add(b, w);
        _map.add(c, x);
        _map.add(d, y);
        _map.remove(a);
        _map.remove(b);
        _map.remove(c);
        _map.remove(d);

        assertEq(_map.contains(a), false);
        assertEq(_map.get(a), 0);
        assertEq(_map.contains(b), false);
        assertEq(_map.get(b), 0);
        assertEq(_map.contains(c), false);
        assertEq(_map.get(c), 0);
        assertEq(_map.contains(d), false);
        assertEq(_map.get(d), 0);
        assertEq(_map.length(), 0);
    }

    function testUpdateAndRemoveMultiple() external {
        address a = address(0x1);
        uint96 v = 1;

        address b = address(0x2);
        uint96 w = 2;

        address c = address(0x3);
        uint96 x = 3;

        address d = address(0x4);
        uint96 y = 4;

        _map.add(a, v);
        _map.add(b, w);
        _map.add(c, x);
        _map.add(d, y);
        _map.update(a, 5);
        _map.update(b, 6);
        _map.update(c, 7);
        _map.update(d, 8);
        _map.remove(a);
        _map.remove(b);
        _map.remove(c);
        _map.remove(d);

        assertEq(_map.contains(a), false);
        assertEq(_map.get(a), 0);
        assertEq(_map.contains(b), false);
        assertEq(_map.get(b), 0);
        assertEq(_map.contains(c), false);
        assertEq(_map.get(c), 0);
        assertEq(_map.contains(d), false);
        assertEq(_map.get(d), 0);
        assertEq(_map.length(), 0);
    }

    function testAddAndRemoveMultipleInReverse() external {
        address a = address(0x1);
        uint96 v = 1;

        address b = address(0x2);
        uint96 w = 2;

        address c = address(0x3);
        uint96 x = 3;

        address d = address(0x4);
        uint96 y = 4;

        _map.add(a, v);
        _map.add(b, w);
        _map.add(c, x);
        _map.add(d, y);
        _map.remove(d);
        _map.remove(c);
        _map.remove(b);
        _map.remove(a);

        assertEq(_map.contains(a), false);
        assertEq(_map.get(a), 0);
        assertEq(_map.contains(b), false);
        assertEq(_map.get(b), 0);
        assertEq(_map.contains(c), false);
        assertEq(_map.get(c), 0);
        assertEq(_map.contains(d), false);
        assertEq(_map.get(d), 0);
        assertEq(_map.length(), 0);
    }

    function testUpdateAndRemoveMultipleInReverse() external {
        address a = address(0x1);
        uint96 v = 1;

        address b = address(0x2);
        uint96 w = 2;

        address c = address(0x3);
        uint96 x = 3;

        address d = address(0x4);
        uint96 y = 4;

        _map.add(a, v);
        _map.add(b, w);
        _map.add(c, x);
        _map.add(d, y);
        _map.update(d, 8);
        _map.update(c, 7);
        _map.update(b, 6);
        _map.update(a, 5);
        _map.remove(d);
        _map.remove(c);
        _map.remove(b);
        _map.remove(a);

        assertEq(_map.contains(a), false);
        assertEq(_map.get(a), 0);
        assertEq(_map.contains(b), false);
        assertEq(_map.get(b), 0);
        assertEq(_map.contains(c), false);
        assertEq(_map.get(c), 0);
        assertEq(_map.contains(d), false);
        assertEq(_map.get(d), 0);
        assertEq(_map.length(), 0);
    }

    function testAddAndRemovePartial() external {
        address a = address(0x1);
        uint96 v = 1;

        address b = address(0x2);
        uint96 w = 2;

        address c = address(0x3);
        uint96 x = 3;

        address d = address(0x4);
        uint96 y = 4;

        _map.add(a, v);
        _map.add(b, w);
        _map.add(c, x);
        _map.add(d, y);
        _map.remove(a);
        _map.remove(c);

        assertEq(_map.contains(a), false);
        assertEq(_map.get(a), 0);
        assertEq(_map.contains(b), true);
        assertEq(_map.get(b), 2);
        assertEq(_map.contains(c), false);
        assertEq(_map.get(c), 0);
        assertEq(_map.contains(d), true);
        assertEq(_map.get(d), 4);
        assertEq(_map.length(), 2);
    }

    function testUpdateAndRemovePartial() external {
        address a = address(0x1);
        uint96 v = 1;

        address b = address(0x2);
        uint96 w = 2;

        address c = address(0x3);
        uint96 x = 3;

        address d = address(0x4);
        uint96 y = 4;

        _map.add(a, v);
        _map.add(b, w);
        _map.add(c, x);
        _map.add(d, y);
        _map.update(a, 5);
        _map.update(b, 6);
        _map.update(c, 7);
        _map.update(d, 8);
        _map.remove(a);
        _map.remove(c);

        assertEq(_map.contains(a), false);
        assertEq(_map.get(a), 0);
        assertEq(_map.contains(b), true);
        assertEq(_map.get(b), 6);
        assertEq(_map.contains(c), false);
        assertEq(_map.get(c), 0);
        assertEq(_map.contains(d), true);
        assertEq(_map.get(d), 8);
        assertEq(_map.length(), 2);
    }
}
