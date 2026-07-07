// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import "../src/CryptoMarket.sol";

contract CryptoMarketTest is Test {
    CryptoMarket public market;
    address public owner;
    address public user;

    function setUp() public {
        owner = address(this);
        user = address(0x1);

        market = new CryptoMarket();
    }

    function test_DeployComOwnerCorreto() public view {
        assertEq(market.owner(), owner);
    }

    function test_ComecaOperacional() public view {
        assertFalse(market.isUnderMaintenance());
    }

    function test_OwnerConsegueAtivarManutencao() public {
        market.toggleMaintenance();
        assertTrue(market.isUnderMaintenance());
    }

    function test_OwnerConsegueDesativarManutencao() public {
        market.toggleMaintenance();
        market.toggleMaintenance();
        assertFalse(market.isUnderMaintenance());
    }

    function test_RevertQuandoNaoOwnerTentaToggle() public {
        vm.prank(user);
        vm.expectRevert("Apenas o owner pode fazer isso");
        market.toggleMaintenance();
    }

    function test_BuyNFTFuncionaQuandoOperacional() public {
        market.buyNFT();
    }

    function test_RevertBuyNFTQuandoEmManutencao() public {
        market.toggleMaintenance();
        vm.expectRevert("Contrato em manutencao no momento");
        market.buyNFT();
    }

    function test_EmiteEventoAoAlternar() public {
        vm.expectEmit(true, true, true, true);
        emit CryptoMarket.MaintenanceToggled(true);
        market.toggleMaintenance();
    }
}