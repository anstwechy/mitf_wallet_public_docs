# Money movement — sequence diagrams

This page collects **sequence diagrams** for every **financial journey** the MITF Wallet platform supports. It complements the numeric ledger examples in [Transaction flows & ledger examples](transaction-flows-and-ledger-examples.md) and the step tables in [Financial operations & reconciliation](../reconciliation/financial-operations-and-reconciliation.md).

**Source alignment:** Diagrams follow the **Key Flows** section and bounded-context behaviour in the main **`mitf_wallet`** repository `README.md` (local path `mitf_wallet/README.md`).

---

## 1. Onboarding — register user and create wallet

Same as **Onboarding** in the main repo: one REST call creates the user, then **Users** creates the wallet via **Wallets**; **Wallets** opens the ledger account and publishes `WalletCreatedEvent`.

```mermaid
sequenceDiagram
    autonumber
    participant C as Client
    participant U as Users API
    participant DU as DB MasaratUsers
    participant W as Wallets API
    participant L as Ledger API
    participant DW as DB MasaratWallets
    participant RMQ as RabbitMQ

    C->>+U: POST /onboarding/accounts
    alt Resident
        U->>DU: RegisterResident
    else Foreign
        U->>DU: RegisterForeign
    end
    U->>+W: gRPC CreateWallet
    W->>+L: gRPC CreateAccountsForWallet
    L-->>-W: liabilityAccountId
    W->>DW: Save wallet + liabilityAccountId
    W->>RMQ: WalletCreatedEvent
    W-->>-U: CreateWalletResponse
    U-->>-C: 201 userId walletId
```

---

## 2. Wallet creation (direct call — detail)

When any **caller** (Users, Gateway, load test job) invokes **CreateWallet** without the full onboarding REST path.

```mermaid
sequenceDiagram
    autonumber
    participant Caller as Caller
    participant W as Wallets API
    participant L as Ledger API
    participant DW as DB MasaratWallets
    participant RMQ as RabbitMQ

    Caller->>+W: CreateWallet
    W->>DW: Exists check + classification
    W->>+L: gRPC CreateAccountsForWallet
    L-->>-W: liabilityAccountId
    W->>DW: Save wallet
    W->>RMQ: WalletCreatedEvent
    W-->>-Caller: CreateWalletResponse
```

---

## 3. P2P transfer (wallet to wallet)

**Transfer** on **Transactions API**: balance and fee rules, optional **transaction_authorization_token** when the wallet classification requires PIN (see section 8).

```mermaid
sequenceDiagram
    autonumber
    participant C as Client
    participant T as Transactions API
    participant DB as DB MasaratWallets
    participant L as Ledger API
    participant RMQ as RabbitMQ

    C->>+T: gRPC Transfer
    T->>DB: Load wallets + classifications
    opt PIN classification
        T->>T: Validate transaction_authorization_token
    end
    T->>T: FeeCalculator P2P fee
    T->>L: gRPC GetBalance
    L-->>T: balances
    alt Validation fails
        T-->>C: success false
    else OK
        T->>DB: Reserve balance + Pending transaction
        T->>L: gRPC PostJournal P2P legs
        L-->>T: OK
        T->>DB: Completed + idempotency
        T->>RMQ: TransferCompletedEvent
        T-->>-C: success true transactionId
    end
```

---

## 4. Fund wallet (top-up)

**FundWallet**: single **PostEntry** — credit to the wallet liability. Matching **bank / current account** debit is outside this ledger (external).

```mermaid
sequenceDiagram
    autonumber
    participant C as Client
    participant T as Transactions API
    participant L as Ledger API
    participant RMQ as RabbitMQ

    C->>+T: gRPC FundWallet
    T->>T: Validate wallet + allocate transactionId
    T->>L: gRPC PostEntry credit wallet liability
    L-->>T: OK
    T->>T: Idempotency + persist
    T->>RMQ: WalletFundedEvent
    T-->>-C: success
```

---

## 5. Merchant payment

**ProcessMerchantPayment**: debit customer wallet, credit **merchant settlement** (+ fee revenue leg when configured).

```mermaid
sequenceDiagram
    autonumber
    participant C as Client
    participant T as Transactions API
    participant DB as DB MasaratWallets
    participant L as Ledger API
    participant RMQ as RabbitMQ

    C->>+T: gRPC ProcessMerchantPayment
    T->>DB: Load wallet + classification
    opt PIN classification
        T->>T: Validate transaction_authorization_token
    end
    T->>T: FeeCalculator merchant fee + reserve
    T->>L: gRPC GetBalance
    L-->>T: balance
    T->>DB: Pending transaction
    T->>L: gRPC PostJournal wallet debit settlement credit fee legs
    L-->>T: OK
    T->>DB: Completed + idempotency
    T->>RMQ: MerchantPaymentCompletedEvent
    T-->>-C: success true
```

---

## 6. Cash withdrawal

**ProcessCashWithdrawal**: debit wallet, credit **cash settlement** (+ optional fee leg).

```mermaid
sequenceDiagram
    autonumber
    participant C as Client
    participant T as Transactions API
    participant DB as DB MasaratWallets
    participant L as Ledger API
    participant RMQ as RabbitMQ

    C->>+T: gRPC ProcessCashWithdrawal
    T->>DB: Load wallet + classification
    opt PIN classification
        T->>T: Validate transaction_authorization_token
    end
    T->>T: FeeCalculator withdrawal fee + reserve
    T->>L: gRPC GetBalance
    L-->>T: balance
    T->>DB: Pending transaction
    T->>L: gRPC PostJournal wallet debit cash settlement credit fee legs
    L-->>T: OK
    T->>DB: Completed + idempotency
    T->>RMQ: CashWithdrawalCompletedEvent
    T-->>-C: success true
```

---

## 7. Fund wallet from pooled account

**FundWalletFromPooledAccount**: **PostJournal** debits **pool liability**, credits **wallet liability** (institution pool → customer wallet).

```mermaid
sequenceDiagram
    autonumber
    participant C as Client
    participant T as Transactions API
    participant L as Ledger API
    participant RMQ as RabbitMQ

    C->>+T: gRPC FundWalletFromPooledAccount
    T->>T: Allocate transactionId + validate
    T->>L: gRPC PostJournal debit pool credit wallet
    L-->>T: OK
    T->>T: Idempotency + persist
    T->>RMQ: WalletFundedEvent
    T-->>-C: success
```

---

## 8. Wallet PIN and transaction authorization (before debits)

Applies before **Transfer**, **FundWallet** (when treated as debit path with token — see hardening docs), **ProcessMerchantPayment**, and **ProcessCashWithdrawal** when **OperationAuthMode** requires user PIN.

```mermaid
sequenceDiagram
    autonumber
    participant App as Client
    participant W as Wallets API
    participant T as Transactions API
    participant DW as DB MasaratWallets

    Note over App,DW: One-time set or change PIN
    App->>+W: gRPC SetWalletPin
    W->>DW: Store PIN hash
    W-->>-App: success

    Note over App,DW: Before debit — verify PIN
    App->>+W: gRPC VerifyWalletPin
    W->>DW: Verify + lockout rules
    alt Invalid
        W-->>App: success false
    else Valid
        W-->>-App: transaction_authorization_token
    end

    App->>+T: gRPC debit operation + token
    T->>T: Validate token for wallet
    alt Invalid token
        T-->>App: success false
    else Valid
        T->>T: Execute money movement
        T-->>-App: success true
    end
```

---

## 9. Reverse transaction (P2P, merchant, or withdrawal)

**ReverseTransaction** posts a **balancing PostJournal** for a **Completed** transaction. **Fund wallet** and **fund from pool** are **not** reversed through this API (per finance reference).

```mermaid
sequenceDiagram
    autonumber
    participant C as Client
    participant T as Transactions API
    participant DB as DB MasaratWallets
    participant L as Ledger API
    participant RMQ as RabbitMQ

    C->>+T: gRPC ReverseTransaction + x-bank-id
    T->>DB: Load transaction Completed + bank scope
    T->>T: Build reversal legs full partial fee policy
    T->>L: gRPC PostJournal reversal legs
    L-->>T: OK
    T->>DB: Status Reversed or partial Completed
    T->>RMQ: TransactionReversedEvent
    T-->>-C: success
```

---

## Diagram index (quick lookup)

| Flow | API / entry | Ledger call | Domain event (on success) |
| ---- | ----------- | ----------- | --------------------------- |
| Onboarding | Users `POST /onboarding/accounts` | CreateAccountsForWallet | WalletCreatedEvent (from Wallets) |
| Create wallet | Wallets CreateWallet | CreateAccountsForWallet | WalletCreatedEvent |
| P2P | Transactions Transfer | PostJournal | TransferCompletedEvent |
| Fund wallet | Transactions FundWallet | PostEntry | WalletFundedEvent |
| Merchant | Transactions ProcessMerchantPayment | PostJournal | MerchantPaymentCompletedEvent |
| Cash out | Transactions ProcessCashWithdrawal | PostJournal | CashWithdrawalCompletedEvent |
| Pool → wallet | Transactions FundWalletFromPooledAccount | PostJournal | WalletFundedEvent |
| Reversal | Transactions ReverseTransaction | PostJournal | TransactionReversedEvent |

---

## Further reading

- [Financial operations & reconciliation](../reconciliation/financial-operations-and-reconciliation.md) — business narrative and reconciliation  
- [Transaction flows & ledger examples](transaction-flows-and-ledger-examples.md) — worked ledger leg tables  
- [Domain events](events.md) — event contracts  
- [gRPC reference](../reference/grpc-services.md) — RPC listing
