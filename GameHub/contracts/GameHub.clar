;; GameHub - Decentralized Gaming Achievement Platform
;; A comprehensive blockchain-based gaming platform that tracks achievements,
;; facilitates tournaments, and rewards competitive gaming excellence

;; Contract constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-input (err u104))
(define-constant err-insufficient-tokens (err u105))
(define-constant err-tournament-full (err u106))
(define-constant err-tournament-ended (err u107))

;; Token constants
(define-constant token-name "GameHub Victory Token")
(define-constant token-symbol "GVT")
(define-constant token-decimals u6)
(define-constant token-max-supply u4000000000000) ;; 4 million tokens with 6 decimals

;; Reward amounts (in micro-tokens)
(define-constant reward-achievement-unlock u70000000) ;; 70 GVT
(define-constant reward-tournament-win u300000000) ;; 300 GVT
(define-constant reward-leaderboard-top u150000000) ;; 150 GVT
(define-constant reward-game-completion u110000000) ;; 110 GVT
(define-constant reward-review-contribution u35000000) ;; 35 GVT

;; Data variables
(define-data-var total-supply uint u0)
(define-data-var next-game-id uint u1)
(define-data-var next-tournament-id uint u1)
(define-data-var next-achievement-id uint u1)

;; Token balances
(define-map token-balances principal uint)

;; Game registry
(define-map games
  uint
  {
    title: (string-ascii 128),
    developer: (string-ascii 64),
    genre: (string-ascii 32),
    difficulty-rating: uint, ;; 1-5
    completion-time-hours: uint,
    max-players: uint,
    release-date: uint,
    total-players: uint,
    average-rating: uint,
    verified: bool
  }
)

;; Player profiles
(define-map player-profiles
  principal
  {
    username: (string-ascii 32),
    gamer-tag: (string-ascii 32),
    skill-level: uint, ;; 1-10
    games-completed: uint,
    tournaments-won: uint,
    achievements-unlocked: uint,
    total-playtime-hours: uint,
    reputation-score: uint,
    join-date: uint,
    last-activity: uint,
    favorite-genres: (list 3 (string-ascii 32))
  }
)

;; Gaming achievements
(define-map achievements
  uint
  {
    game-id: uint,
    name: (string-ascii 128),
    description: (string-ascii 256),
    achievement-type: (string-ascii 32), ;; "completion", "score", "time", "skill"
    difficulty: uint, ;; 1-5
    points-value: uint,
    rarity-tier: (string-ascii 16), ;; "common", "rare", "epic", "legendary"
    unlock-requirement: (string-ascii 256),
    total-unlocks: uint,
    verified: bool
  }
)

;; Player achievements
(define-map player-achievements
  { player: principal, achievement-id: uint }
  {
    unlock-date: uint,
    score-achieved: (optional uint),
    time-taken: (optional uint),
    verified: bool,
    proof-hash: (optional (buff 32))
  }
)

;; Gaming tournaments
(define-map tournaments
  uint
  {
    game-id: uint,
    organizer: principal,
    title: (string-ascii 128),
    description: (string-ascii 500),
    tournament-type: (string-ascii 32), ;; "single", "bracket", "league"
    entry-fee: uint,
    prize-pool: uint,
    max-participants: uint,
    current-participants: uint,
    start-date: uint,
    end-date: uint,
    winner: (optional principal),
    active: bool
  }
)

;; Tournament participants
(define-map tournament-participants
  { tournament-id: uint, participant: principal }
  {
    registration-date: uint,
    current-score: uint,
    matches-played: uint,
    matches-won: uint,
    final-rank: (optional uint),
    eliminated: bool
  }
)

;; Game reviews
(define-map game-reviews
  { game-id: uint, reviewer: principal }
  {
    rating: uint, ;; 1-5 stars
    review-text: (string-ascii 1000),
    playtime-hours: uint,
    completion-status: (string-ascii 16), ;; "completed", "playing", "dropped"
    timestamp: uint,
    helpful-votes: uint
  }
)

;; Leaderboards
(define-map leaderboards
  { game-id: uint, player: principal }
  {
    high-score: uint,
    best-time: uint,
    level-reached: uint,
    last-updated: uint,
    global-rank: uint,
    verified: bool
  }
)

;; Gaming sessions
(define-map gaming-sessions
  { player: principal, game-id: uint, session-date: uint }
  {
    playtime-minutes: uint,
    score-achieved: uint,
    level-progress: uint,
    achievements-earned: uint,
    multiplayer: bool
  }
)

;; Helper function to get or create player profile
(define-private (get-or-create-profile (player principal))
  (match (map-get? player-profiles player)
    profile profile
    {
      username: "",
      gamer-tag: "",
      skill-level: u3,
      games-completed: u0,
      tournaments-won: u0,
      achievements-unlocked: u0,
      total-playtime-hours: u0,
      reputation-score: u100,
      join-date: stacks-block-height,
      last-activity: stacks-block-height,
      favorite-genres: (list)
    }
  )
)

;; Token functions
(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (user principal))
  (ok (default-to u0 (map-get? token-balances user)))
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-private (mint-tokens (recipient principal) (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? token-balances recipient)))
    (new-balance (+ current-balance amount))
    (new-total-supply (+ (var-get total-supply) amount))
  )
    (asserts! (<= new-total-supply token-max-supply) err-invalid-input)
    (map-set token-balances recipient new-balance)
    (var-set total-supply new-total-supply)
    (ok amount)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (let (
    (sender-balance (default-to u0 (map-get? token-balances sender)))
  )
    (asserts! (is-eq tx-sender sender) err-unauthorized)
    (asserts! (>= sender-balance amount) err-insufficient-tokens)
    (try! (mint-tokens recipient amount))
    (map-set token-balances sender (- sender-balance amount))
    (print {action: "transfer", sender: sender, recipient: recipient, amount: amount, memo: memo})
    (ok true)
  )
)

;; Game registration
(define-public (register-game (title (string-ascii 128)) (developer (string-ascii 64)) (genre (string-ascii 32))
                             (difficulty-rating uint) (completion-time-hours uint) (max-players uint))
  (let (
    (game-id (var-get next-game-id))
  )
    (asserts! (> (len title) u0) err-invalid-input)
    (asserts! (> (len developer) u0) err-invalid-input)
    (asserts! (and (>= difficulty-rating u1) (<= difficulty-rating u5)) err-invalid-input)
    (asserts! (> completion-time-hours u0) err-invalid-input)
    (asserts! (> max-players u0) err-invalid-input)
    
    (map-set games game-id {
      title: title,
      developer: developer,
      genre: genre,
      difficulty-rating: difficulty-rating,
      completion-time-hours: completion-time-hours,
      max-players: max-players,
      release-date: stacks-block-height,
      total-players: u0,
      average-rating: u0,
      verified: false
    })
    
    (var-set next-game-id (+ game-id u1))
    (print {action: "game-registered", game-id: game-id, title: title})
    (ok game-id)
  )
)

;; Achievement creation
(define-public (create-achievement (game-id uint) (name (string-ascii 128)) (description (string-ascii 256))
                                  (achievement-type (string-ascii 32)) (difficulty uint) (points-value uint)
                                  (rarity-tier (string-ascii 16)) (unlock-requirement (string-ascii 256)))
  (let (
    (game (unwrap! (map-get? games game-id) err-not-found))
    (achievement-id (var-get next-achievement-id))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len name) u0) err-invalid-input)
    (asserts! (> (len description) u0) err-invalid-input)
    (asserts! (and (>= difficulty u1) (<= difficulty u5)) err-invalid-input)
    (asserts! (> points-value u0) err-invalid-input)
    (asserts! (>= (get reputation-score profile) u150) err-unauthorized)
    
    (map-set achievements achievement-id {
      game-id: game-id,
      name: name,
      description: description,
      achievement-type: achievement-type,
      difficulty: difficulty,
      points-value: points-value,
      rarity-tier: rarity-tier,
      unlock-requirement: unlock-requirement,
      total-unlocks: u0,
      verified: false
    })
    
    ;; Update creator reputation
    (map-set player-profiles tx-sender
      (merge profile {
        reputation-score: (+ (get reputation-score profile) u15),
        last-activity: stacks-block-height
      })
    )
    
    (var-set next-achievement-id (+ achievement-id u1))
    (print {action: "achievement-created", achievement-id: achievement-id, game-id: game-id})
    (ok achievement-id)
  )
)

;; Achievement unlocking
(define-public (unlock-achievement (achievement-id uint) (score-achieved (optional uint)) 
                                  (time-taken (optional uint)) (proof-hash (optional (buff 32))))
  (let (
    (achievement (unwrap! (map-get? achievements achievement-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (is-none (map-get? player-achievements {player: tx-sender, achievement-id: achievement-id})) err-already-exists)
    (asserts! (get verified achievement) err-unauthorized)
    
    ;; Record achievement unlock
    (map-set player-achievements {player: tx-sender, achievement-id: achievement-id} {
      unlock-date: stacks-block-height,
      score-achieved: score-achieved,
      time-taken: time-taken,
      verified: false,
      proof-hash: proof-hash
    })
    
    ;; Update achievement stats
    (map-set achievements achievement-id
      (merge achievement {total-unlocks: (+ (get total-unlocks achievement) u1)})
    )
    
    ;; Update player profile
    (map-set player-profiles tx-sender
      (merge profile {
        achievements-unlocked: (+ (get achievements-unlocked profile) u1),
        reputation-score: (+ (get reputation-score profile) (get points-value achievement)),
        last-activity: stacks-block-height
      })
    )
    
    ;; Award achievement reward based on rarity
    (let (
      (reward-multiplier 
        (if (is-eq (get rarity-tier achievement) "legendary")
          u4
          (if (is-eq (get rarity-tier achievement) "epic")
            u3
            (if (is-eq (get rarity-tier achievement) "rare")
              u2
              u1))))
    )
      (try! (mint-tokens tx-sender (* reward-achievement-unlock reward-multiplier)))
    )
    
    (print {action: "achievement-unlocked", player: tx-sender, achievement-id: achievement-id})
    (ok true)
  )
)

;; Tournament creation
(define-public (create-tournament (game-id uint) (title (string-ascii 128)) (description (string-ascii 500))
                                 (tournament-type (string-ascii 32)) (entry-fee uint) (max-participants uint)
                                 (duration-days uint))
  (let (
    (game (unwrap! (map-get? games game-id) err-not-found))
    (tournament-id (var-get next-tournament-id))
    (organizer-profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len title) u0) err-invalid-input)
    (asserts! (> (len description) u0) err-invalid-input)
    (asserts! (> max-participants u1) err-invalid-input)
    (asserts! (> duration-days u0) err-invalid-input)
    (asserts! (>= (get reputation-score organizer-profile) u200) err-unauthorized)
    
    (map-set tournaments tournament-id {
      game-id: game-id,
      organizer: tx-sender,
      title: title,
      description: description,
      tournament-type: tournament-type,
      entry-fee: entry-fee,
      prize-pool: u0,
      max-participants: max-participants,
      current-participants: u0,
      start-date: stacks-block-height,
      end-date: (+ stacks-block-height duration-days),
      winner: none,
      active: true
    })
    
    ;; Update organizer reputation
    (map-set player-profiles tx-sender
      (merge organizer-profile {
        reputation-score: (+ (get reputation-score organizer-profile) u25),
        last-activity: stacks-block-height
      })
    )
    
    (var-set next-tournament-id (+ tournament-id u1))
    (print {action: "tournament-created", tournament-id: tournament-id, organizer: tx-sender})
    (ok tournament-id)
  )
)

;; Tournament registration
(define-public (join-tournament (tournament-id uint))
  (let (
    (tournament (unwrap! (map-get? tournaments tournament-id) err-not-found))
    (player-balance (default-to u0 (map-get? token-balances tx-sender)))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (get active tournament) err-tournament-ended)
    (asserts! (< (get current-participants tournament) (get max-participants tournament)) err-tournament-full)
    (asserts! (>= player-balance (get entry-fee tournament)) err-insufficient-tokens)
    (asserts! (is-none (map-get? tournament-participants {tournament-id: tournament-id, participant: tx-sender})) err-already-exists)
    
    ;; Deduct entry fee
    (map-set token-balances tx-sender (- player-balance (get entry-fee tournament)))
    
    ;; Add to prize pool
    (map-set tournaments tournament-id
      (merge tournament {
        prize-pool: (+ (get prize-pool tournament) (get entry-fee tournament)),
        current-participants: (+ (get current-participants tournament) u1)
      })
    )
    
    ;; Register participant
    (map-set tournament-participants {tournament-id: tournament-id, participant: tx-sender} {
      registration-date: stacks-block-height,
      current-score: u0,
      matches-played: u0,
      matches-won: u0,
      final-rank: none,
      eliminated: false
    })
    
    ;; Update profile
    (map-set player-profiles tx-sender (merge profile {last-activity: stacks-block-height}))
    
    (print {action: "tournament-joined", tournament-id: tournament-id, participant: tx-sender})
    (ok true)
  )
)

;; Game review system
(define-public (review-game (game-id uint) (rating uint) (review-text (string-ascii 1000))
                           (playtime-hours uint) (completion-status (string-ascii 16)))
  (let (
    (game (unwrap! (map-get? games game-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (and (>= rating u1) (<= rating u5)) err-invalid-input)
    (asserts! (> (len review-text) u0) err-invalid-input)
    (asserts! (> playtime-hours u0) err-invalid-input)
    (asserts! (is-none (map-get? game-reviews {game-id: game-id, reviewer: tx-sender})) err-already-exists)
    
    (map-set game-reviews {game-id: game-id, reviewer: tx-sender} {
      rating: rating,
      review-text: review-text,
      playtime-hours: playtime-hours,
      completion-status: completion-status,
      timestamp: stacks-block-height,
      helpful-votes: u0
    })
    
    ;; Award review reward
    (try! (mint-tokens tx-sender reward-review-contribution))
    
    ;; Update reviewer reputation
    (map-set player-profiles tx-sender
      (merge profile {
        reputation-score: (+ (get reputation-score profile) u8),
        last-activity: stacks-block-height
      })
    )
    
    (print {action: "game-reviewed", game-id: game-id, reviewer: tx-sender, rating: rating})
    (ok true)
  )
)

;; Gaming session logging
(define-public (log-gaming-session (game-id uint) (playtime-minutes uint) (score-achieved uint)
                                  (level-progress uint) (achievements-earned uint) (multiplayer bool))
  (let (
    (game (unwrap! (map-get? games game-id) err-not-found))
    (session-date (/ stacks-block-height u144)) ;; Daily grouping
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> playtime-minutes u0) err-invalid-input)
    
    (map-set gaming-sessions {player: tx-sender, game-id: game-id, session-date: session-date} {
      playtime-minutes: playtime-minutes,
      score-achieved: score-achieved,
      level-progress: level-progress,
      achievements-earned: achievements-earned,
      multiplayer: multiplayer
    })
    
    ;; Update player profile
    (map-set player-profiles tx-sender
      (merge profile {
        total-playtime-hours: (+ (get total-playtime-hours profile) (/ playtime-minutes u60)),
        last-activity: stacks-block-height
      })
    )
    
    ;; Small reward for session logging
    (try! (mint-tokens tx-sender u15000000)) ;; 15 GVT
    
    (print {action: "gaming-session-logged", player: tx-sender, game-id: game-id, playtime: playtime-minutes})
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-player-profile (player principal))
  (map-get? player-profiles player)
)

(define-read-only (get-game (game-id uint))
  (map-get? games game-id)
)

(define-read-only (get-achievement (achievement-id uint))
  (map-get? achievements achievement-id)
)

(define-read-only (get-player-achievement (player principal) (achievement-id uint))
  (map-get? player-achievements {player: player, achievement-id: achievement-id})
)

(define-read-only (get-tournament (tournament-id uint))
  (map-get? tournaments tournament-id)
)

(define-read-only (get-tournament-participation (tournament-id uint) (participant principal))
  (map-get? tournament-participants {tournament-id: tournament-id, participant: participant})
)

(define-read-only (get-game-review (game-id uint) (reviewer principal))
  (map-get? game-reviews {game-id: game-id, reviewer: reviewer})
)

(define-read-only (get-leaderboard-entry (game-id uint) (player principal))
  (map-get? leaderboards {game-id: game-id, player: player})
)

(define-read-only (get-gaming-session (player principal) (game-id uint) (session-date uint))
  (map-get? gaming-sessions {player: player, game-id: game-id, session-date: session-date})
)

;; Admin functions
(define-public (verify-game (game-id uint))
  (let (
    (game (unwrap! (map-get? games game-id) err-not-found))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set games game-id (merge game {verified: true}))
    (print {action: "game-verified", game-id: game-id})
    (ok true)
  )
)

(define-public (update-gamer-tag (new-gamer-tag (string-ascii 32)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-gamer-tag) u0) err-invalid-input)
    (map-set player-profiles tx-sender (merge profile {gamer-tag: new-gamer-tag}))
    (print {action: "gamer-tag-updated", player: tx-sender, gamer-tag: new-gamer-tag})
    (ok true)
  )
)