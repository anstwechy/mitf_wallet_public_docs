# gRPC Services Reference

Canonical reference for all gRPC services, RPCs, and message types. For examples and usage see [API reference](api.md).

**Packages:** `user`, `wallet`, `transaction`, `ledger`.  
**Ports:** User 5003, Wallet 5002, Transaction 5004, Ledger 5001.

---

## User Service (`user.UserService`)


| RPC                 | Request                                                  | Response                                           |
| ------------------- | -------------------------------------------------------- | -------------------------------------------------- |
| RegisterResident    | national_id, full_name, linked_bank_account_id           | success, user_id, error_message                    |
| RegisterForeign     | passport_or_id_number, full_name, linked_bank_account_id | success, user_id, error_message                    |
| UserHasWallet       | bank_id, user_id                                         | has_wallet                                         |
| GetUser             | user_id                                                  | found, user_id, national_id, full_name, kyc_status |
| GetUserByNationalId | national_id                                              | found, user_id, full_name                          |


---

## Wallet Service (`wallet.WalletService`)

**Note:** RPCs that require bank context need header `x-bank-id: <bank-guid>`: CreateWallet, GetWalletByUserId.

Transaction RPCs (Transfer, FundWallet, ProcessMerchantPayment, ProcessCashWithdrawal, CreatePooledAccount, FundWalletFromPooledAccount) have been moved to the **Transaction Service** (port 5004). Calling them on the Wallet service will return Unimplemented.


| RPC                            | Request                                                                             | Response                                                                                          |
| ------------------------------ | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| CreateWallet                   | user_id, classification_id, idempotency_key, employer_id                            | success, wallet_id, error_message                                                                 |
| GetWalletByUserId              | user_id                                                                             | found, wallet_id, balance, locked_balance, ledger_balance, currency                              |
| GetWalletByNumber              | wallet_number                                                                       | found, wallet_id, wallet_number, locked_balance, ledger_balance, currency                        |
| GetBalance                     | wallet_id                                                                           | balance, locked_balance, ledger_balance, currency                                                 |
| CreateWalletClassification     | code, display_name, description                                                     | success, id, error_message                                                                        |
| UpdateWalletClassification     | id, display_name, description, optional limits/flags                                | success, error_message                                                                            |
| DeactivateWalletClassification | id                                                                                  | success, error_message                                                                            |
| GetWalletClassification        | id, code                                                                            | found, id, code, display_name, description, is_active, limits, permissions                        |
| ListWalletClassifications      | active_only                                                                         | items[] (id, code, display_name, description, is_active, limits, permissions)                     |
| SuspendWallet                  | wallet_id                                                                           | success, error_message                                                                            |
| CloseWallet                    | wallet_id                                                                           | success, error_message                                                                            |
| ReactivateWallet               | wallet_id                                                                           | success, error_message                                                                            |
| ListFeeRules                   | classification_id (optional)                                                        | items[] (id, classification_id, transaction_type, percentage, min_amount, fixed_amount, currency) |
| CreateFeeRule                  | classification_id, transaction_type, percentage, min_amount, fixed_amount, currency | success, id, error_message                                                                        |
| UpdateFeeRule                  | id, percentage, min_amount, fixed_amount, currency                                  | success, error_message                                                                            |
| SetWalletPin                   | wallet_id, pin                                                                      | success, error_message                                                                            |
| ChangeWalletPin                | wallet_id, current_pin, new_pin                                                     | success, error_message                                                                            |
| VerifyWalletPin                | wallet_id, pin                                                                      | success, transaction_authorization_token, error_message                                           |


---

## Transaction Service (`transaction.TransactionService`)

**Note:** All RPCs require header `x-bank-id: <bank-guid>`.

**Queued processing:** Transfer, FundWallet, merchant/cash, fund-from-pool, **CreatePooledAccount**, and **ReverseTransaction** always enqueue to RabbitMQ. Responses include `request_id` / `request_status` (`QUEUED` … `FAILED`); poll **GetRequestStatus** until terminal. For **CreatePooledAccount** success, `GetRequestStatus.transaction_id` is the **pool id** (same field name as for wallet transaction ids).

**Ingress cap:** Money-moving RPCs (Transfer, FundWallet, merchant/cash, pool fund/create, Reverse) share one backpressure limiter → **ResourceExhausted** when saturated — [Transfer backpressure client contract](../architecture/transfer-backpressure-client-contract.md).

| RPC                         | Request                                                                                                                    | Response                                                                                                                                                                                                             |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Transfer                    | from_wallet_id, to_wallet_id, amount, currency, idempotency_key, transaction_authorization_token (optional)                | success, transaction_id, error_message, request_id, request_status                                                                                                                                                                               |
| FundWallet                  | wallet_id, amount, currency, idempotency_key, linked_bank_account_id, transaction_authorization_token (optional)           | success, transaction_id, error_message, request_id, request_status                                                                                                                                                                               |
| ProcessMerchantPayment      | wallet_id, amount, currency, idempotency_key, merchant_reference, transaction_authorization_token (optional)               | success, transaction_id, error_message, request_id, request_status                                                                                                                                                                               |
| ProcessCashWithdrawal       | wallet_id, amount, currency, idempotency_key, transaction_authorization_token (optional)                                   | success, transaction_id, error_message, request_id, request_status                                                                                                                                                                               |
| CreatePooledAccount         | currency, type (CORPORATE/MASARAT_POOL), employer_id, name, **idempotency_key**                                            | success, pool_id (set when already terminal), error_message, request_id, request_status                                                                                                                                                            |
| FundWalletFromPooledAccount | pool_id, wallet_id, amount, currency, idempotency_key                                                                      | success, transaction_id, error_message, request_id, request_status                                                                                                                                                                               |
| GetRequestStatus            | request_id                                                                                                                  | found, request_id, operation_type, status, transaction_id, error_message, idempotency_key                                                                                                                                                                               |
| GetTransaction              | transaction_id                                                                                                             | found, transaction_id, type, status, amount, fee, currency, from/to_wallet_id, created_at, completed_at, error_message, ledger_entries[], reference, channel, counterparty, purpose, actor_id, actor_type            |
| ListTransactions            | wallet_id, type, status, reference, min_amount, max_amount, from_date_utc, to_date_utc, page_size, page_token              | items[] (transaction summary incl. reversal_of_transaction_id, reversal_count), next_page_token                                                                                                                      |
| ReverseTransaction          | transaction_id, reason, idempotency_key (optional), amount (optional; partial reversal), fee_reversal_policy (FULL or NONE) | success, error_message, request_id, request_status. Reverses completed P2P/Merchant/Withdrawal; supports partial reversal and fee reversal policy. See [Financial operations and reconciliation](../reconciliation/financial-operations-and-reconciliation.md). |
| GetPooledAccount            | pool_id                                                                                                                    | found, pool_id, type, currency, name, employer_id, balance                                                                                                                                                           |
| ListPooledAccounts          | type, employer_id                                                                                                          | items[] (pool_id, type, currency, name, employer_id, balance)                                                                                                                                                        |
| GetSpendingSummary          | wallet_id, from_date_utc, to_date_utc, group_by (DAY, WEEK, MONTH)                                                         | periods[] (period_start_utc, period_end_utc, total_debits, total_credits, net, transaction_count, total_fees, debit_count, credit_count, by_type[]), error_message                                                   |


---

## Ledger Service (`ledger.LedgerService`)


| RPC                     | Request                                                                                         | Response                                                                                                                                      |
| ----------------------- | ----------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| CreateAccountsForWallet | wallet_id, currency                                                                             | success, asset_account_id (currently empty), liability_account_id, error_message. **Creates one liability account per wallet.**               |
| PostEntry               | account_id, amount (non-zero), currency, transaction_id, idempotency_key                        | success, entry_id, error_message                                                                                                              |
| PostJournal             | transaction_id, idempotency_key_base, currency, legs[] (account_id, amount, idempotency_suffix) | success, entry_ids, error_message                                                                                                             |
| GetBalance              | account_id                                                                                      | balance, currency                                                                                                                             |
| GetEntriesByTransaction | transaction_id                                                                                  | entries[] (LedgerEntryMessage: id, account_id, amount, currency, transaction_id, idempotency_key, created_at_utc, description), error_message |
| ExportEntries           | from_date_utc, to_date_utc                                                                      | entries[] (id, account_id, amount, currency, transaction_id, idempotency_key, created_at_utc, description), error_message                     |


**PostJournal** posts multiple legs atomically; the sum of leg amounts must be zero. Used by the Transactions API for transfers (debit + credit + optional fee).

For wallets whose classification **`OperationAuthMode`** requires user PIN, Transfer, FundWallet, ProcessMerchantPayment, and ProcessCashWithdrawal require a valid **transaction_authorization_token** (from Wallet Service **VerifyWalletPin**). Classifications using **external OTP trusted session** do not require that token on the debited wallet. See [System hardening](../security/system-hardening.md).

---

## Proto Files

- User: `src/contracts/Masarat.GrpcContracts/Proto/user_service.proto`
- Wallet: `src/contracts/Masarat.GrpcContracts/Proto/wallet_service.proto`
- Transaction: `src/contracts/Masarat.GrpcContracts/Proto/transaction_service.proto`
- Ledger: `src/contracts/Masarat.GrpcContracts/Proto/ledger_service.proto`

