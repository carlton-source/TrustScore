
;; Title: TrustScore - Decentralized Identity & Reputation Protocol
;; 
;; A next-generation protocol for establishing and managing digital trust through 
;; decentralized identities and dynamic reputation scoring. This system enables:
;;
;; - Self-sovereign identity management
;; - Merit-based reputation scoring
;; - Time-based score decay for relevancy
;; - Cross-platform reputation verification
;; 
;; The protocol creates an objective, transparent framework for building
;; trusted relationships in decentralized ecosystems.

;; Constants & Errors

;; Error Codes
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INVALID-PARAMETERS (err u101))
(define-constant ERR-IDENTITY-EXISTS (err u102))
(define-constant ERR-IDENTITY-NOT-FOUND (err u103))
(define-constant ERR-INSUFFICIENT-REPUTATION (err u104))
(define-constant ERR-MAX-REPUTATION-REACHED (err u105))

;; System Constants
(define-constant MAX-REPUTATION-SCORE u1000)
(define-constant MIN-REPUTATION-SCORE u0)
(define-constant REPUTATION-DECAY-RATE u10)  ;; 10% decay per period

;; Storage

(define-map identities 
  {owner: principal}
  {
    did: (string-ascii 50),  ;; Decentralized Identity
    reputation-score: uint,
    created-at: uint,
    last-updated: uint
  }
)

(define-map reputation-actions
  {action-type: (string-ascii 50)}
  {multiplier: uint}
)

;; Private Functions

(define-private (is-valid-owner (owner principal))
  (and 
    (is-some (map-get? identities {owner: owner}))
    (is-eq owner tx-sender)
  )
)

;; Public Functions

;; Initialize Reputation Actions
(define-public (initialize-reputation-actions)
  (begin
    (map-set reputation-actions 
      {action-type: "governance-vote"} 
      {multiplier: u5}
    )
    (map-set reputation-actions 
      {action-type: "contract-fulfillment"} 
      {multiplier: u10}
    )
    (map-set reputation-actions 
      {action-type: "community-contribution"} 
      {multiplier: u7}
    )
    (ok true)
  )
)

;; Create New Identity
(define-public (create-identity (did (string-ascii 50)))
  (let 
    (
      (sender tx-sender)
      (current-stacks-block-height stacks-block-height)
    )
    (begin
      (asserts! (is-none (map-get? identities {owner: sender})) 
        (err ERR-IDENTITY-EXISTS))
      
      (asserts! (> (len did) u5) 
        (err ERR-INVALID-PARAMETERS))
      
      (map-set identities 
        {owner: sender}
        {
          did: did,
          reputation-score: u50,  ;; Starting reputation
          created-at: current-stacks-block-height,
          last-updated: current-stacks-block-height
        }
      )
      (ok did)
    )
  )
)

;; Update Reputation Score
(define-public (update-reputation 
  (action-type (string-ascii 50))
)
  (let 
    (
      (owner tx-sender)
      (current-identity 
        (unwrap! 
          (map-get? identities {owner: owner}) 
          (err ERR-IDENTITY-NOT-FOUND)
        )
      )
      (action-multiplier 
        (default-to u0 
          (get multiplier 
            (map-get? reputation-actions {action-type: action-type})
          )
        )
      )
      (current-score (get reputation-score current-identity))
      (updated-score 
        (if (< (+ current-score action-multiplier) MAX-REPUTATION-SCORE)
            (+ current-score action-multiplier)
            MAX-REPUTATION-SCORE
        )
      )
    )
    (begin
      (asserts! (is-some (map-get? reputation-actions {action-type: action-type}))
        (err ERR-INVALID-PARAMETERS))

      (map-set identities 
        {owner: owner}
        (merge current-identity {
          reputation-score: updated-score,
          last-updated: stacks-block-height
        })
      )
      (ok updated-score)
    )
  )
)

;; Apply Time-Based Reputation Decay
(define-public (decay-reputation)
  (let 
    (
      (owner tx-sender)
      (current-identity 
        (unwrap! 
          (map-get? identities {owner: owner}) 
          (err ERR-IDENTITY-NOT-FOUND)
        )
      )
      (current-score (get reputation-score current-identity))
      (decay-amount 
        (/ (* current-score REPUTATION-DECAY-RATE) u100)
      )
      (updated-score 
        (if (> (- current-score decay-amount) MIN-REPUTATION-SCORE)
            (- current-score decay-amount)
            MIN-REPUTATION-SCORE
        )
      )
    )
    (begin
      (map-set identities 
        {owner: owner}
        (merge current-identity {
          reputation-score: updated-score,
          last-updated: stacks-block-height
        })
      )
      (ok updated-score)
    )
  )
)

;; Read-Only Functions

;; Get Identity Reputation
(define-read-only (get-reputation (owner principal))
  (map-get? identities {owner: owner})
)

;; Verify Reputation Threshold
(define-read-only (verify-reputation 
  (owner principal) 
  (min-reputation-threshold uint)
)
  (match 
    (map-get? identities {owner: owner})
    identity 
      (if (>= (get reputation-score identity) min-reputation-threshold)
          (some true)
          none
      )
    none
  )
)

;; Initialize Contract

(initialize-reputation-actions)