(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-MILESTONE (err u101))
(define-constant ERR-INSUFFICIENT-FUNDS (err u102))
(define-constant ERR-ALREADY-CLAIMED (err u103))
(define-constant ERR-NOT-ENROLLED (err u104))
(define-constant ERR-MILESTONE-EXPIRED (err u105))

(define-data-var fund-pool uint u0)
(define-data-var admin principal tx-sender)
(define-data-var expired-fund-pool uint u0)

(define-map Students 
    principal 
    {enrolled: bool, 
     milestones-completed: uint,
     total-earned: uint}
)

(define-map Milestones
    uint 
    {reward: uint,
     required-proof: (string-ascii 64),
     deadline: uint}
)

(define-map CompletedMilestones
    {student: principal, milestone-id: uint}
    {completed: bool, 
     proof-hash: (string-ascii 64)}
)

(define-public (initialize-milestone (milestone-id uint) (reward uint) (required-proof (string-ascii 64)) (deadline uint))
    (begin
        (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
        (ok (map-set Milestones milestone-id {reward: reward, required-proof: required-proof, deadline: deadline}))
    )
)

(define-public (enroll-student (student principal))
    (begin
        (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
        (ok (map-set Students student {enrolled: true, milestones-completed: u0, total-earned: u0}))
    )
)

(define-public (donate-to-fund)
    (let ((amount (stx-get-balance tx-sender)))
        (begin
            (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
            (var-set fund-pool (+ (var-get fund-pool) amount))
            (ok amount)
        )
    )
)

(define-public (submit-milestone (milestone-id uint) (proof-hash (string-ascii 64)))
    (let (
        (student-data (unwrap! (map-get? Students tx-sender) ERR-NOT-ENROLLED))
        (milestone-data (unwrap! (map-get? Milestones milestone-id) ERR-INVALID-MILESTONE))
    )
        (begin
            (asserts! (< stacks-block-height (get deadline milestone-data)) ERR-MILESTONE-EXPIRED)
            (asserts! (not (get completed (default-to {completed: false, proof-hash: ""} 
                (map-get? CompletedMilestones {student: tx-sender, milestone-id: milestone-id})))) ERR-ALREADY-CLAIMED)
            
            (map-set CompletedMilestones 
                {student: tx-sender, milestone-id: milestone-id}
                {completed: true, proof-hash: proof-hash}
            )
            
            (map-set Students tx-sender 
                {enrolled: (get enrolled student-data),
                 milestones-completed: (+ (get milestones-completed student-data) u1),
                 total-earned: (+ (get total-earned student-data) (get reward milestone-data))}
            )
            
            (ok true)
        )
    )
)

(define-public (claim-reward (milestone-id uint))
    (let (
        (student-data (unwrap! (map-get? Students tx-sender) ERR-NOT-ENROLLED))
        (milestone-data (unwrap! (map-get? Milestones milestone-id) ERR-INVALID-MILESTONE))
        (completion-data (unwrap! (map-get? CompletedMilestones {student: tx-sender, milestone-id: milestone-id}) ERR-INVALID-MILESTONE))
    )
        (begin
            (asserts! (get completed completion-data) ERR-INVALID-MILESTONE)
            (asserts! (>= (var-get fund-pool) (get reward milestone-data)) ERR-INSUFFICIENT-FUNDS)
            
            (try! (as-contract (stx-transfer? (get reward milestone-data) tx-sender tx-sender)))
            (var-set fund-pool (- (var-get fund-pool) (get reward milestone-data)))
            
            (ok (get reward milestone-data))
        )
    )
)

(define-read-only (get-student-info (student principal))
    (map-get? Students student)
)

(define-read-only (get-milestone-info (milestone-id uint))
    (map-get? Milestones milestone-id)
)

(define-read-only (get-fund-balance)
    (var-get fund-pool)
)

(define-public (expire-milestone (milestone-id uint))
    (let (
        (milestone-data (unwrap! (map-get? Milestones milestone-id) ERR-INVALID-MILESTONE))
    )
        (begin
            (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
            (asserts! (>= stacks-block-height (get deadline milestone-data)) ERR-INVALID-MILESTONE)
            (var-set expired-fund-pool (+ (var-get expired-fund-pool) (get reward milestone-data)))
            (map-delete Milestones milestone-id)
            (ok (get reward milestone-data))
        )
    )
)

(define-public (redistribute-expired-funds (recipient principal) (amount uint))
    (begin
        (asserts! (is-eq tx-sender (var-get admin)) ERR-NOT-AUTHORIZED)
        (asserts! (<= amount (var-get expired-fund-pool)) ERR-INSUFFICIENT-FUNDS)
        (try! (as-contract (stx-transfer? amount tx-sender recipient)))
        (var-set expired-fund-pool (- (var-get expired-fund-pool) amount))
        (ok amount)
    )
)

(define-read-only (get-expired-fund-balance)
    (var-get expired-fund-pool)
)

(define-read-only (is-milestone-expired (milestone-id uint))
    (match (map-get? Milestones milestone-id)
        milestone-data (>= stacks-block-height (get deadline milestone-data))
        true
    )
)