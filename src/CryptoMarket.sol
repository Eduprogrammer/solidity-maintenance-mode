// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CryptoMarket {

    address public owner;
    bool public maintenanceMode;

    event MaintenanceToggled(bool novoStatus);

    constructor() {
        owner = msg.sender;
        maintenanceMode = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Apenas o owner pode fazer isso");
        _;
    }

    modifier notInMaintenance() {
        require(!maintenanceMode, "Contrato em manutencao no momento");
        _;
    }

    function toggleMaintenance() public onlyOwner {
        maintenanceMode = !maintenanceMode;
        emit MaintenanceToggled(maintenanceMode);
    }

    function isUnderMaintenance() public view returns (bool) {
        return maintenanceMode;
    }

    function buyNFT() public notInMaintenance {
    }
}