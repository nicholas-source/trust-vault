;; TrustVault: Self-Sovereign Identity & Verifiable Credential Platform
;;
;; A comprehensive blockchain-based identity management system that enables 
;; users to maintain full control over their digital identity while providing
;; robust mechanisms for credential issuance, verification, and reputation
;; tracking through zero-knowledge proofs and cryptographic attestations.
;;
;; Key Features:
;; - Self-sovereign identity registration with cryptographic hash anchoring
;; - Verifiable credential lifecycle management (issue, verify, revoke)
;; - Zero-knowledge proof submission and verification framework
;; - Dynamic reputation scoring system with administrative oversight
;; - Secure identity recovery mechanisms with designated recovery addresses
;; - Comprehensive input validation and security controls

;; ERROR CONSTANTS

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-ALREADY-REGISTERED (err u1001))
(define-constant ERR-NOT-REGISTERED (err u1002))
(define-constant ERR-INVALID-PROOF (err u1003))
(define-constant ERR-INVALID-CREDENTIAL (err u1004))
(define-constant ERR-EXPIRED-CREDENTIAL (err u1005))
(define-constant ERR-REVOKED-CREDENTIAL (err u1006))
(define-constant ERR-INVALID-SCORE (err u1007))
(define-constant ERR-INVALID-INPUT (err u1008))
(define-constant ERR-INVALID-EXPIRATION (err u1009))
(define-constant ERR-INVALID-RECOVERY-ADDRESS (err u1010))
(define-constant ERR-INVALID-PROOF-DATA (err u1011))

;; SYSTEM CONSTANTS

(define-constant MIN-REPUTATION-SCORE u0)
(define-constant MAX-REPUTATION-SCORE u1000)
(define-constant MIN-EXPIRATION-BLOCKS u1)
(define-constant MAX-METADATA-LENGTH u256)
(define-constant MINIMUM-PROOF-SIZE u64)

;; DATA STRUCTURES

;; Identity Registry: Maps principals to their identity metadata
(define-map identities
  principal
  {
    hash: (buff 32),
    credentials: (list 10 principal),
    reputation-score: uint,
    recovery-address: (optional principal),
    last-updated: uint,
    status: (string-ascii 20),
  }
)

;; Credential Registry: Stores verifiable credentials with issuer-nonce composite key
(define-map credentials
  {
    issuer: principal,
    nonce: uint,
  }
  {
    subject: principal,
    claim-hash: (buff 32),
    expiration: uint,
    revoked: bool,
    metadata: (string-utf8 256),
  }
)

;; Zero-Knowledge Proof Storage: Manages cryptographic proofs and verification status
(define-map zero-knowledge-proofs
  (buff 32)
  {
    prover: principal,
    verified: bool,
    timestamp: uint,
    proof-data: (buff 1024),
  }
)

;; STATE VARIABLES

(define-data-var admin principal tx-sender)
(define-data-var credential-nonce uint u0)

;; VALIDATION FUNCTIONS

;; Validates recovery address to prevent security vulnerabilities
(define-private (is-valid-recovery-address (recovery-addr (optional principal)))
  (match recovery-addr
    recovery-principal (and
      (not (is-eq recovery-principal tx-sender))
      (not (is-eq recovery-principal (var-get admin)))
    )
    true
  )
)

;; Ensures proof data meets minimum security requirements
(define-private (is-valid-proof-data (proof-data (buff 1024)))
  (let ((proof-len (len proof-data)))
    (and
      (>= proof-len MINIMUM-PROOF-SIZE)
      (not (is-eq proof-data 0x))
    )
  )
)

;; Validates credential expiration times
(define-private (is-valid-expiration (expiration uint))
  (> expiration (+ stacks-block-height MIN-EXPIRATION-BLOCKS))
)

;; Ensures metadata doesn't exceed storage limits
(define-private (is-valid-metadata-length (metadata (string-utf8 256)))
  (<= (len metadata) MAX-METADATA-LENGTH)
)

;; Validates cryptographic hash integrity
(define-private (is-valid-hash (hash (buff 32)))
  (not (is-eq hash 0x0000000000000000000000000000000000000000000000000000000000000000))
)

;; ADMINISTRATIVE FUNCTIONS

;; Transfers administrative privileges to a new principal
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
    (asserts! (not (is-eq new-admin tx-sender)) ERR-INVALID-INPUT)
    (ok (var-set admin new-admin))
  )
)

;; IDENTITY MANAGEMENT

;; Registers a new self-sovereign identity with optional recovery mechanism
(define-public (register-identity
    (identity-hash (buff 32))
    (recovery-addr (optional principal))
  )
  (let (
      (sender tx-sender)
      (existing-identity (map-get? identities sender))
    )
    (asserts! (is-none existing-identity) ERR-ALREADY-REGISTERED)
    (asserts! (is-valid-hash identity-hash) ERR-INVALID-INPUT)
    (asserts! (is-valid-recovery-address recovery-addr)
      ERR-INVALID-RECOVERY-ADDRESS
    )

    (ok (map-set identities sender {
      hash: identity-hash,
      credentials: (list),
      reputation-score: u100,
      recovery-address: recovery-addr,
      last-updated: stacks-block-height,
      status: "ACTIVE",
    }))
  )
)

;; ZERO-KNOWLEDGE PROOF SYSTEM

;; Submits a cryptographic proof for verification
(define-public (submit-proof
    (proof-hash (buff 32))
    (proof-data (buff 1024))
  )
  (let (
      (sender tx-sender)
      (existing-identity (map-get? identities sender))
      (existing-proof (map-get? zero-knowledge-proofs proof-hash))
    )
    (asserts! (is-some existing-identity) ERR-NOT-REGISTERED)
    (asserts! (is-valid-hash proof-hash) ERR-INVALID-INPUT)
    (asserts! (is-valid-proof-data proof-data) ERR-INVALID-PROOF-DATA)
    (asserts! (is-none existing-proof) ERR-INVALID-PROOF)

    (ok (map-set zero-knowledge-proofs proof-hash {
      prover: sender,
      verified: false,
      timestamp: stacks-block-height,
      proof-data: proof-data,
    }))
  )
)

;; Administratively verifies a submitted zero-knowledge proof
(define-public (verify-proof (proof-hash (buff 32)))
  (let (
      (proof (map-get? zero-knowledge-proofs proof-hash))
      (sender tx-sender)
    )
    (asserts! (is-some proof) ERR-INVALID-PROOF)
    (asserts! (is-eq sender (var-get admin)) ERR-NOT-AUTHORIZED)
    (ok (map-set zero-knowledge-proofs proof-hash
      (merge (unwrap-panic proof) { verified: true })
    ))
  )
)