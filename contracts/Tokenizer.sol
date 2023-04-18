// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Token {
    struct TokenData {
        string name;
        address ownerId;
        address creatorId;
        uint256 variableFieldValue;
        bool isDisabled;
    }

    struct Class {
        string className;
        uint256 numTokens;
        string actionType;
        uint256 changeValue;
        address creator;
    }

    mapping(uint256 => TokenData) public tokens;
    mapping(uint256 => Class) public classes;

    // Event to emit when a token is created
    event TokenCreated(uint256 tokenId, address ownerId, string name);

    // Function to create a token class
    function createTokenClass(
        uint256 classId,
        string memory className,
        uint256 numTokens,
        string memory actionType,
        uint256 changeValue,
        address creator
    ) external {
        Class storage newClass = classes[classId];
        newClass.className = className;
        newClass.numTokens = numTokens;
        newClass.actionType = actionType;
        newClass.changeValue = changeValue;
        newClass.creator = creator;
    }

    // Function to create a token
    function createToken(uint256 tokenId) external payable {
        require(classes[tokenId].numTokens > 0, "Token class does not exist");
        require(tokens[tokenId].ownerId == address(0), "Token already created");

        Class storage tokenClass = classes[tokenId];
        require(msg.value >= tokenClass.changeValue, "Not enough Ether sent");

        TokenData storage newToken = tokens[tokenId];
        newToken.ownerId = msg.sender;
        newToken.creatorId = tokenClass.creator;
        newToken.name = tokenClass.className;
        newToken.variableFieldValue = 0;
        newToken.isDisabled = false;

        emit TokenCreated(tokenId, msg.sender, tokenClass.className);

        tokenClass.numTokens--;
    }

    // Function to authenticate a token
    function authenticateToken(
        uint256 tokenId,
        address userId
    ) external view returns (bool) {
        require(tokens[tokenId].ownerId != address(0), "Token does not exist");

        if (tokens[tokenId].isDisabled) {
            return false;
        }

        return tokens[tokenId].ownerId == userId;
    }

    // Function to use a token
    function useToken(uint256 tokenId, address userId) external {
        require(tokens[tokenId].ownerId != address(0), "Token does not exist");
        require(
            tokens[tokenId].ownerId == userId,
            "Not the owner of the token"
        );

        Class storage tokenClass = classes[tokenId];

        if (
            keccak256(bytes(tokenClass.actionType)) == keccak256(bytes("add"))
        ) {
            tokens[tokenId].variableFieldValue += tokenClass.changeValue;
        } else if (
            keccak256(bytes(tokenClass.actionType)) == keccak256(bytes("sub"))
        ) {
            tokens[tokenId].variableFieldValue -= tokenClass.changeValue;
        } else if (
            keccak256(bytes(tokenClass.actionType)) ==
            keccak256(bytes("disable"))
        ) {
            tokens[tokenId].isDisabled = true;
        }
    }
}
