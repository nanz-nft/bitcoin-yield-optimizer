;; Title: Bitcoin Yield Optimizer: Trustless Staking Protocol
;; Summary: Non-custodial BTC staking protocol enabling Bitcoin-native yield generation through Stacks L2
;; Description: 
;; A secure, Bitcoin-compliant smart contract that enables native BTC holders to participate in decentralized finance
;; while maintaining full self-custody. Key features include:
;; - SIP-010 compliant yield-bearing stBTC tokens
;; - Programmatic yield distribution with adjustable APY (up to 50%)
;; - On-chain risk scoring system with insurance fund integration
;; - Bitcoin-native design requiring no wrapped tokens or cross-chain bridges
;; - Fully transparent yield calculations verified against Bitcoin block height
;; - Compliance-focused architecture maintaining Bitcoin's core principles
;; Built on Stacks Layer 2, this contract leverages Bitcoin's security model while enabling complex DeFi operations
;; through Clarity's predictable execution environment. Implements strict compliance with Bitcoin's UTXO model
;; for all stake/redeem operations.

(define-constant contract-owner tx-sender)

;; Error constants
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-ALREADY-INITIALIZED (err u101))
(define-constant ERR-NOT-INITIALIZED (err u102))
(define-constant ERR-POOL-ACTIVE (err u103))
(define-constant ERR-POOL-INACTIVE (err u104))
(define-constant ERR-INVALID-AMOUNT (err u105))
(define-constant ERR-INSUFFICIENT-BALANCE (err u106))
(define-constant ERR-NO-YIELD-AVAILABLE (err u107))
(define-constant ERR-MINIMUM-STAKE (err u108))
(define-constant ERR-UNAUTHORIZED (err u109))
(define-constant ERR-INVALID-URI (err u110))

;; Constants
(define-constant MINIMUM-STAKE-AMOUNT u1000000) ;; 0.01 BTC in sats
(define-constant BLOCKS-PER-DAY u144)
(define-constant MAX-YIELD-RATE u5000) ;; 50% maximum APY
(define-constant MAX-TOKEN-URI-LENGTH u200) ;; Maximum length for token URI

;; Data variables
(define-data-var total-staked uint u0)
(define-data-var total-yield uint u0)
(define-data-var pool-active bool false)
(define-data-var insurance-active bool false)
(define-data-var yield-rate uint u500) ;; 5% base APY
(define-data-var last-distribution-block uint u0)
(define-data-var insurance-fund-balance uint u0)
(define-data-var token-name (string-ascii 32) "Staked BTC")
(define-data-var token-symbol (string-ascii 10) "stBTC")
(define-data-var token-uri (optional (string-utf8 256)) none)

;; Data maps
(define-map staker-balances principal uint)

(define-map staker-rewards principal uint)

(define-map yield-distribution-history 
    uint 
    {
        block: uint,
        amount: uint,
        apy: uint
    }
)

(define-map risk-scores principal uint)

(define-map insurance-coverage principal uint)

(define-map allowances 
    { 
        owner: principal, 
        spender: principal 
    } 
    uint
)