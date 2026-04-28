# AML bridge: tenant (`BankId`) resolution

The Masarat domain events consumed by `Masarat.AmlBridge` do not carry a bank tenant. The bridge resolves **which bank** a transaction belongs to so it can pick the correct FlowGuard routing key (`transaction.{BankCode}`).

## Algorithm

1. Load the row from the **transactions** database (`masarattransactions`) table `"Transactions"` for the wallet transaction id (the same id as in the domain event, e.g. `TransferCompletedEvent.TransactionId`).
2. If `"ReportingBankId"` is set and not `00000000-0000-0000-0000-000000000000`, use it as `BankId`.
3. Otherwise take `"FromWalletId"` if set, else `"ToWalletId"`.
4. Look up that wallet id in the **wallets** database (`MasaratWallets`) table `"Wallets"` and read `"BankId"`.

If any step fails (missing row, no wallet id, wallet not found), the bridge **logs a warning** and **does not publish** to FlowGuard.

## Configuration

Map each resolved `BankId` (Guid) to a FlowGuard string code in `AmlIntegration:BankCodes` (see `appsettings.json` and `docker-compose.yml` for `masarat.aml.bridge`).
