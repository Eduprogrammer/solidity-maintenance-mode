# CryptoMarket — Modo Manutenção (Solidity + Foundry)

> Da Série Cliente Imaginário #1: "Preciso travar meu contrato sem fazer novo deploy"

Simulação de um pedido real de cliente: um marketplace de NFTs (**CryptoMarket**) precisa de um mecanismo para pausar transações críticas em caso de bug ou emergência — sem depender de um novo deploy.

Ainda não tenho clientes reais em Web3. Este projeto faz parte de uma série onde simulo pedidos de clientes e os resolvo com o mesmo rigor que teria em um projeto real: entendimento da dor, arquitetura, testes, deploy local e validação via CLI.

Artigo completo com o passo a passo: [link do Dev.to]

## O problema

> "Se um bug aparecer no meio da noite, eu preciso conseguir travar as transações imediatamente, sem depender de ninguém, sem precisar rodar um novo deploy. E quando eu resolver, preciso poder destravar do mesmo jeito."

## A solução

Um mecanismo de **Modo Manutenção**: um interruptor on-chain que só o dono do contrato pode ligar ou desligar, bloqueando funções críticas enquanto ativo, com consulta pública de status a qualquer momento.

| Função | Quem pode chamar | O que faz |
|---|---|---|
| `toggleMaintenance()` | Só o owner | Liga/desliga o modo manutenção |
| `isUnderMaintenance()` | Qualquer um | Consulta o status atual |
| `buyNFT()` (exemplo) | Usuários | Só executa se **não** estiver em manutenção |

## Stack

- **Solidity** `^0.8.20`
- **Foundry** (Forge, Anvil, Cast)

## Contrato

```solidity
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
```

## Testes

8 testes cobrindo deploy, estado inicial, toggle nos dois sentidos, controle de acesso, bloqueio de funções e emissão de eventos.

```bash
forge test -vvv
```

Ran 8 tests for test/CryptoMarket.t.sol:CryptoMarketTest
[PASS] test_BuyNFTFuncionaQuandoOperacional()
[PASS] test_ComecaOperacional()
[PASS] test_DeployComOwnerCorreto()
[PASS] test_EmiteEventoAoAlternar()
[PASS] test_OwnerConsegueAtivarManutencao()
[PASS] test_OwnerConsegueDesativarManutencao()
[PASS] test_RevertBuyNFTQuandoEmManutencao()
[PASS] test_RevertQuandoNaoOwnerTentaToggle()
Suite result: ok. 8 passed; 0 failed; 0 skipped

## Deploy local (Anvil)

```bash
anvil
```

```bash
forge create src/CryptoMarket.sol:CryptoMarket \
  --rpc-url http://127.0.0.1:8545 \
  --private-key <CHAVE_PRIVADA> \
  --broadcast
```

## Interagindo via Cast

```bash
# Consultar status
cast call <ENDERECO_CONTRATO> "isUnderMaintenance()(bool)" --rpc-url http://127.0.0.1:8545

# Ativar manutenção
cast send <ENDERECO_CONTRATO> "toggleMaintenance()" --rpc-url http://127.0.0.1:8545 --private-key <CHAVE_OWNER>

# Tentar buyNFT() durante manutenção -> reverte
cast send <ENDERECO_CONTRATO> "buyNFT()" --rpc-url http://127.0.0.1:8545 --private-key <CHAVE_OWNER>
```

## Autor

**Edu** — [LinkedIn](https://linkedin.com/in/educarlos29/) · [GitHub](https://github.com/Eduprogrammer)

---

*#solidity #foundry #web3 #blockchain #smartcontracts*

