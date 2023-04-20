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
        uint256 initValue;
        uint256 changeValue;
        address creator;
    }

    mapping(uint256 => TokenData) public tokens;
    mapping(uint256 => Class) public classes;
    uint256 public numClasses;
    uint256 public numTokens;
    // Event to emit when a token is created
    event TokenCreated(uint256 tokenId, address ownerId, string name);

    // Function to create a token class
    function createTokenClass(
        string memory className,
        uint256 totalTokens,
        string memory actionType,
        uint256 initValue,
        uint256 changeValue,
        address creator
    ) external {
        Class storage newClass = classes[numClasses];
        newClass.className = className;
        newClass.numTokens = totalTokens;
        newClass.actionType = actionType;
        newClass.initValue = initValue;
        newClass.changeValue = changeValue;
        newClass.creator = creator;
        numClasses++;
    }

    // Function to create a token
    function createToken(uint256 classId) external {
        require(classes[classId].numTokens > 0, "Token class does not exist");

        Class storage tokenClass = classes[classId];
        // require(msg.value >= tokenClass.changeValue, "Not enough Ether sent");

        TokenData storage newToken = tokens[numTokens];
        newToken.ownerId = msg.sender;
        newToken.creatorId = tokenClass.creator;
        newToken.name = tokenClass.className;
        newToken.variableFieldValue = tokenClass.initValue;
        newToken.isDisabled = false;

        emit TokenCreated(numTokens, msg.sender, tokenClass.className);
        numTokens++;
        tokenClass.numTokens--;
    }

    // Function to authenticate a token
    function authenticateToken(
        uint256 tokenId,
        address userId
    ) external view returns (bool) {
        // require(tokens[tokenId].ownerId != address(0), false);
        // if (tokens[tokenId].ownerId != address(0)) {
        //     return false;
        // }
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
