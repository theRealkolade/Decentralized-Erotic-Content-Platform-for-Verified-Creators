(define-constant contract-owner tx-sender)
(define-constant commission-rate u50) ;; 5% platform fee
(define-constant min-subscription-price u1000000) ;; in microSTX

(define-non-fungible-token content-nft (string-ascii 36))
(define-non-fungible-token creator-badge (string-ascii 36))

(define-map creators 
  { creator: principal }
  {
    verified: bool,
    subscription-price: uint,
    subscriber-count: uint,
    total-earnings: uint
  }
)

(define-map subscriptions
  { subscriber: principal, creator: principal }
  {
    expires-at: uint,
    active: bool
  }
)

(define-map content-items
  { content-id: (string-ascii 36) }
  {
    creator: principal,
    price: uint,
    metadata-url: (string-ascii 256),
    created-at: uint
  }
)

(define-data-var total-content uint u0)
(define-data-var total-creators uint u0)
(define-data-var platform-treasury uint u0)

(define-public (register-creator (subscription-price uint))
  (let
    (
      (creator-count (var-get total-creators))
      (creator-id "creator-badge")
    )
    (asserts! (>= subscription-price min-subscription-price) (err u1))
    (asserts! (is-none (map-get? creators {creator: tx-sender})) (err u2))
    
    (try! (nft-mint? creator-badge creator-id tx-sender))
    (map-set creators
      {creator: tx-sender}
      {
        verified: false,
        subscription-price: subscription-price,
        subscriber-count: u0,
        total-earnings: u0
      }
    )
    (var-set total-creators (+ creator-count u1))
    (ok creator-id)
  )
)

(define-public (verify-creator (creator principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u3))
    (map-set creators
      {creator: creator}
      (merge (unwrap-panic (map-get? creators {creator: creator}))
        {verified: true}
      )
    )
    (ok true)
  )
)

(define-public (publish-content (content-id (string-ascii 36)) (price uint) (metadata-url (string-ascii 256)))
  (let
    (
      (creator-data (unwrap! (map-get? creators {creator: tx-sender}) (err u4)))
    )
    (asserts! (get verified creator-data) (err u5))
    (try! (nft-mint? content-nft content-id tx-sender))
    
    (map-set content-items
      {content-id: content-id}
      {
        creator: tx-sender,
        price: price,
        metadata-url: metadata-url,
        created-at: stacks-block-height
      }
    )
    (var-set total-content (+ (var-get total-content) u1))
    (ok true)
  )
)

(define-public (subscribe-to-creator (creator principal))
  (let
    (
      (creator-data (unwrap! (map-get? creators {creator: creator}) (err u6)))
      (price (get subscription-price creator-data))
      (commission (/ (* price commission-rate) u1000))
    )
    (asserts! (get verified creator-data) (err u7))
    
    (try! (stx-transfer? (- price commission) tx-sender creator))
    (try! (stx-transfer? commission tx-sender contract-owner))
    
    (map-set subscriptions
      {subscriber: tx-sender, creator: creator}
      {
        expires-at: (+ stacks-block-height u1440),
        active: true
      }
    )
    
    (map-set creators
      {creator: creator}
      (merge creator-data
        {
          subscriber-count: (+ (get subscriber-count creator-data) u1),
          total-earnings: (+ (get total-earnings creator-data) (- price commission))
        }
      )
    )
    (var-set platform-treasury (+ (var-get platform-treasury) commission))
    (ok true)
  )
)

(define-read-only (get-creator-details (creator principal))
  (map-get? creators {creator: creator})
)

(define-read-only (check-subscription (subscriber principal) (creator principal))
  (let
    (
      (sub-data (map-get? subscriptions {subscriber: subscriber, creator: creator}))
    )
    (and
      (is-some sub-data)
      (get active (unwrap! sub-data false))
      (< stacks-block-height (get expires-at (unwrap! sub-data false)))
    )
  )
)

(define-public (purchase-content (content-id (string-ascii 36)))
  (let
    (
      (content-data (unwrap! (map-get? content-items {content-id: content-id}) (err u8)))
      (creator (get creator content-data))
      (price (get price content-data))
      (commission (/ (* price commission-rate) u1000))
    )
    (try! (stx-transfer? (- price commission) tx-sender creator))
    (try! (stx-transfer? commission tx-sender contract-owner))
    
    (let
      (
        (creator-data (unwrap! (map-get? creators {creator: creator}) (err u9)))
      )
      (map-set creators
        {creator: creator}
        (merge creator-data
          {
            total-earnings: (+ (get total-earnings creator-data) (- price commission))
          }
        )
      )
    )
    (var-set platform-treasury (+ (var-get platform-treasury) commission))
    (ok true)
  )
)

(define-read-only (get-content-details (content-id (string-ascii 36)))
  (map-get? content-items {content-id: content-id})
)