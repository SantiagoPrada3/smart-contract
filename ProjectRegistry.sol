// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProjectRegistry {
    address public owner;
    uint256 public nextId;

    struct Project {
        uint256 id;
        address proposer;
        string title;
        string description;
        uint256 timestamp;
        bool active;
    }

    mapping(uint256 => Project) public projects;
    event ProjectCreated(uint256 indexed id, address indexed proposer, string title);
    event ProjectToggled(uint256 indexed id, bool active);

    modifier onlyOwner() {
        require(msg.sender == owner, "Solo owner");
        _;
    }

    modifier exists(uint256 id) {
        require(projects[id].id != 0, "No existe");
        _;
    }

    constructor() {
        owner = msg.sender;
        nextId = 1;
    }

    function createProject(string calldata title, string calldata description) external returns (uint256) {
        uint256 id = nextId++;
        projects[id] = Project({
            id: id,
            proposer: msg.sender,
            title: title,
            description: description,
            timestamp: block.timestamp,
            active: true
        });
        emit ProjectCreated(id, msg.sender, title);
        return id;
    }

    function toggleActive(uint256 id) external onlyOwner exists(id) {
        projects[id].active = !projects[id].active;
        emit ProjectToggled(id, projects[id].active);
    }

    function getProject(uint256 id) external view exists(id) returns (Project memory) {
        return projects[id];
    }

    // función auxiliar: transferir ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "0 address");
        owner = newOwner;
    }
}
