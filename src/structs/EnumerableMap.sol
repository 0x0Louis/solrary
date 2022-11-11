// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Enumerable Map
 * @author 0x0Louis
 * @notice Implements a simple enumerable map that maps keys to values.
 * @dev This library is very close to the EnumerableMap library from OpenZeppelin.
 * The main difference is that this library use only one storage slot to store the
 * keys and values while the OpenZeppelin library uses two storage slots.
 *
 * Enumerable maps have the folowing properties:
 *
 * - Elements are added, removed, updated, checked for existence and returned in constant time (O(1)).
 * - Elements are enumerated in linear time (O(n)). Enumeration is not guaranteed to be in any particular order.
 *
 * Usage:
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.AddressToUint96Map;
 *
 *    // Declare a map state variable
 *     EnumerableMap.AddressToUint96Map private _map;
 * ```
 *
 * Currently, only address keys to uint96 values are supported.
 */
library EnumerableMap {
    struct EnumerableMapping {
        bytes32[] _entries;
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @notice Returns the value at the given index.
     * @param self The enumerable mapping to query.
     * @param index The index.
     * @return value The value at the given index.
     */
    function _at(EnumerableMapping storage self, uint256 index) private view returns (bytes32 value) {
        value = self._entries[index];
    }

    /**
     * @notice Returns the value associated with the given key.
     * @dev Returns 0 if the key is not in the enumerable mapping. Use `contains` to check for existence.
     * @param self The enumerable mapping to query.
     * @param key The key.
     * @return value The value associated with the given key.
     */
    function _get(EnumerableMapping storage self, bytes32 key) private view returns (bytes32 value) {
        uint256 index = self._indexes[key];
        if (index == 0) return bytes12(0);

        value = _at(self, index - 1);
    }

    /**
     * @notice Returns true if the enumerable mapping contains the given key.
     * @param self The enumerable mapping to query.
     * @param key The key.
     * @return True if the given key is in the enumerable mapping.
     */
    function _contains(EnumerableMapping storage self, bytes32 key) private view returns (bool) {
        return self._indexes[key] != 0;
    }

    /**
     * @notice Returns the number of elements in the enumerable mapping.
     * @param self The enumerable mapping to query.
     * @return The number of elements in the enumerable mapping.
     */
    function _length(EnumerableMapping storage self) private view returns (uint256) {
        return self._entries.length;
    }

    /**
     * @notice Adds the given key and value to the enumerable mapping.
     * @param self The enumerable mapping to update.
     * @param offset The offset to add to the key.
     * @param key The key to add.
     * @param value The value associated with the key.
     * @return True if the key was added to the enumerable mapping, that is if it was not already in the enumerable mapping.
     */
    function _add(
        EnumerableMapping storage self,
        uint8 offset,
        bytes32 key,
        bytes32 value
    ) private returns (bool) {
        if (!_contains(self, key)) {
            self._entries.push(_encode(offset, key, value));
            self._indexes[key] = self._entries.length;
            return true;
        }

        return false;
    }

    /**
     * @notice Removes a key from the enumerable mapping.
     * @param self The enumerable mapping to update.
     * @param offset The offset to use when removing the key.
     * @param key The key to remove.
     * @return True if the key was removed from the enumerable mapping, that is if it was present in the enumerable mapping.
     */
    function _remove(
        EnumerableMapping storage self,
        uint8 offset,
        bytes32 key
    ) private returns (bool) {
        uint256 keyIndex = self._indexes[key];

        if (keyIndex != 0) {
            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = self._entries.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastentry = self._entries[lastIndex];
                bytes32 lastKey = _decodeKey(offset, lastentry);

                self._entries[toDeleteIndex] = lastentry;
                self._indexes[lastKey] = keyIndex;
            }

            self._entries.pop();
            delete self._indexes[key];

            return true;
        }

        return false;
    }

    /**
     * @notice Updates the value associated with the given key in the enumerable mapping.
     * @param self The enumerable mapping to update.
     * @param offset The offset to use when setting the key.
     * @param key The key to set.
     * @param value The value to set.
     * @return True if the value was updated, that is if the key was already in the enumerable mapping.
     */
    function _update(
        EnumerableMapping storage self,
        uint8 offset,
        bytes32 key,
        bytes32 value
    ) private returns (bool) {
        uint256 keyIndex = self._indexes[key];

        if (keyIndex != 0) {
            self._entries[keyIndex - 1] = _encode(offset, key, value);

            return true;
        }

        return false;
    }

    /**
     * @notice Encodes a key and a value into a bytes32.
     * @dev The key is encoded at the beginning of the bytes32 using the given offset.
     * The value is encoded at the end of the bytes32.
     * There is no overflow check, so the key and value must be small enough to fit both in the bytes32.
     * @param offset The offset to use when encoding the key.
     * @param key The key to encode.
     * @param value The value to encode.
     * @return encoded The encoded bytes32.
     */
    function _encode(
        uint8 offset,
        bytes32 key,
        bytes32 value
    ) private pure returns (bytes32 encoded) {
        encoded = (key << offset) | value;
    }

    /**
     * @notice Decodes a bytes32 into an addres key
     * @param offset The offset to use when decoding the key.
     * @param entry The bytes32 to decode.
     * @return key The key.
     */
    function _decodeKey(uint8 offset, bytes32 entry) private pure returns (bytes32 key) {
        key = entry >> offset;
    }

    /**
     * @notice Decodes a bytes32 into a bytes32 value.
     * @param mask The mask to use when decoding the value.
     * @param entry The bytes32 to decode.
     * @return value The decoded value.
     */
    function _decodeValue(uint256 mask, bytes32 entry) private pure returns (bytes32 value) {
        value = entry & bytes32(mask);
    }

    /** Address to Uint96 Map */

    /**
     * @dev Structure to represent a map of address keys to uint96 values.
     * The first 20 bytes of the key are used to store the address, and the last 12 bytes are used to store the uint96 value.
     */
    struct AddressToUint96Map {
        EnumerableMapping _inner;
    }

    uint8 private constant _ADDRESS_TO_UINT96_MAP_OFFSET = 96;
    uint256 private constant _ADDRESS_TO_UINT96_MAP_MASK = type(uint96).max;

    /**
     * @notice Returns the address key and the uint96 value at the given index.
     * @param self The address to uint96 map to query.
     * @param index The index.
     * @return key The key at the given index.
     * @return value The value at the given index.
     */
    function at(AddressToUint96Map storage self, uint256 index) internal view returns (address key, uint96 value) {
        bytes32 entry = _at(self._inner, index);

        key = address(uint160(uint256(_decodeKey(_ADDRESS_TO_UINT96_MAP_OFFSET, entry))));
        value = uint96(uint256(_decodeValue(_ADDRESS_TO_UINT96_MAP_MASK, entry)));
    }

    /**
     * @notice Returns the uint96 value associated with the given key.
     * @dev Returns 0 if the key is not in the map. Use `contains` to check for existence.
     * @param self The address to uint96 map to query.
     * @param key The address key.
     * @return value The uint96 value associated with the given key.
     */
    function get(AddressToUint96Map storage self, address key) internal view returns (uint96 value) {
        bytes32 entry = _get(self._inner, bytes32(uint256(uint160(key))));

        value = uint96(uint256(_decodeValue(_ADDRESS_TO_UINT96_MAP_MASK, entry)));
    }

    /**
     * @notice Returns the number of elements in the map.
     * @param self The address to uint96 map to query.
     * @return The number of elements in the map.
     */
    function length(AddressToUint96Map storage self) internal view returns (uint256) {
        return _length(self._inner);
    }

    /**
     * @notice Returns true if the map contains the given key.
     * @param self The address to uint96 map to query.
     * @param key The address key.
     * @return True if the map contains the given key.
     */
    function contains(AddressToUint96Map storage self, address key) internal view returns (bool) {
        return _contains(self._inner, bytes32(uint256(uint160(key))));
    }

    /**
     * @notice Adds a key-value pair to the map.
     * @param self The address to uint96 map to update.
     * @param key The address key.
     * @param value The uint96 value.
     * @return True if the key-value pair was added, that is if the key was not already in the map.
     */
    function add(
        AddressToUint96Map storage self,
        address key,
        uint96 value
    ) internal returns (bool) {
        return
            _add(self._inner, _ADDRESS_TO_UINT96_MAP_OFFSET, bytes32(uint256(uint160(key))), bytes32(uint256(value)));
    }

    /**
     * @notice Removes a key-value pair from the map.
     * @param self The address to uint96 map to update.
     * @param key The address key.
     * @return True if the key-value pair was removed, that is if the key was in the map.
     */
    function remove(AddressToUint96Map storage self, address key) internal returns (bool) {
        return _remove(self._inner, _ADDRESS_TO_UINT96_MAP_OFFSET, bytes32(uint256(uint160(key))));
    }

    /**
     * @notice Updates a key-value pair in the map.
     * @param self The address to uint96 map to update.
     * @param key The address key.
     * @param value The uint96 value.
     * @return True if the value was updated, that is if the key was already in the map.
     */
    function update(
        AddressToUint96Map storage self,
        address key,
        uint96 value
    ) internal returns (bool) {
        return
            _update(
                self._inner,
                _ADDRESS_TO_UINT96_MAP_OFFSET,
                bytes32(uint256(uint160(key))),
                bytes32(uint256(value))
            );
    }
}
