# GameHub 🎮

> A decentralized gaming achievement platform that tracks accomplishments, facilitates tournaments, and rewards competitive gaming excellence on the Stacks blockchain

[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-purple)](https://stacks.co/)
[![Clarity](https://img.shields.io/badge/Smart_Contract-Clarity-blue)](https://clarity-lang.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## Overview

GameHub revolutionizes the gaming ecosystem by creating a unified, blockchain-based platform where achievements are permanent, tournaments are transparent, and gaming excellence is rewarded with real value. Players earn GameHub Victory Tokens (GVT) for unlocking achievements, winning tournaments, and contributing to the gaming community.

### Key Features

- **🏆 Achievement System** - Permanent, verifiable gaming achievements across multiple games
- **🎯 Tournament Platform** - Organized competitive gaming with automated prize distribution
- **📊 Leaderboards** - Global rankings with verified scores and performance metrics
- **💎 Token Rewards** - Earn GVT tokens for gaming accomplishments and community contributions
- **🎮 Game Registry** - Decentralized catalog of games with community reviews and ratings
- **👥 Player Profiles** - Comprehensive gaming identity with reputation and skill tracking
- **📈 Analytics Dashboard** - Detailed gaming statistics and performance insights

## Getting Started

### Prerequisites

- [Clarinet CLI](https://github.com/hirosystems/clarinet) installed
- [Stacks Wallet](https://www.hiro.so/wallet) for interacting with the contract
- Node.js 16+ (for running tests)

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/gamehub-stacks
cd gamehub-stacks
```

2. Install dependencies
```bash
clarinet install
```

3. Run tests
```bash
clarinet test
```

4. Deploy to testnet
```bash
clarinet deploy --testnet
```

## Smart Contract Architecture

### Core Components

#### Token Economy (GVT)
- **Token Name**: GameHub Victory Token
- **Symbol**: GVT
- **Decimals**: 6
- **Max Supply**: 4,000,000 GVT
- **Distribution**: Merit-based rewards for gaming achievements and contributions

#### Gaming Ecosystem
- **Game Registry**: Verified catalog of games with metadata and community ratings
- **Achievement System**: Tiered accomplishments with rarity-based rewards
- **Tournament Framework**: Competitive events with entry fees and prize pools
- **Player Profiles**: Comprehensive gaming identity and reputation system

### Reward Structure

| Activity | GVT Reward | Requirements |
|----------|------------|--------------|
| Achievement Unlock | 70-280 GVT | Based on rarity tier (common to legendary) |
| Tournament Victory | 300 GVT | Win organized tournament |
| Leaderboard Top Rank | 150 GVT | Achieve top position in game rankings |
| Game Completion | 110 GVT | Complete verified game |
| Review Contribution | 35 GVT | Write helpful game review |
| Gaming Session | 15 GVT | Log verified gameplay session |

### Data Models

#### Player Profile
```clarity
{
  username: (string-ascii 32),
  gamer-tag: (string-ascii 32),
  skill-level: uint,              // 1-10 progression
  games-completed: uint,
  tournaments-won: uint,
  achievements-unlocked: uint,
  total-playtime-hours: uint,
  reputation-score: uint,         // Starts at 100
  join-date: uint,
  last-activity: uint,
  favorite-genres: (list 3 (string-ascii 32))
}
```

#### Achievement Structure
```clarity
{
  game-id: uint,
  name: (string-ascii 128),
  description: (string-ascii 256),
  achievement-type: (string-ascii 32),  // "completion", "score", "time", "skill"
  difficulty: uint,                     // 1-5 scale
  points-value: uint,
  rarity-tier: (string-ascii 16),      // "common", "rare", "epic", "legendary"
  unlock-requirement: (string-ascii 256),
  total-unlocks: uint,
  verified: bool
}
```

#### Tournament Framework
```clarity
{
  game-id: uint,
  organizer: principal,
  title: (string-ascii 128),
  description: (string-ascii 500),
  tournament-type: (string-ascii 32),   // "single", "bracket", "league"
  entry-fee: uint,
  prize-pool: uint,
  max-participants: uint,
  current-participants: uint,
  start-date: uint,
  end-date: uint,
  winner: (optional principal),
  active: bool
}
```

## Core Functions

### Player Functions

#### `register-game`
Add a new game to the platform registry
```clarity
(register-game 
  "Cyber Champions 2024" 
  "Epic Studios" 
  "Action RPG" 
  u4 
  u50 
  u4)
```

#### `unlock-achievement`
Claim achievement rewards with optional proof verification
```clarity
(unlock-achievement 
  u1 
  (some u95000) 
  (some u3600) 
  (some 0x1234567890abcdef))
```

#### `join-tournament`
Register for competitive tournaments
```clarity
(join-tournament u5)
```

#### `review-game`
Contribute game reviews and earn reputation
```clarity
(review-game 
  u1 
  u5 
  "Amazing gameplay and graphics!" 
  u45 
  "completed")
```

#### `log-gaming-session`
Track gameplay sessions for rewards
```clarity
(log-gaming-session u1 u120 u85000 u15 u2 true)
```

### Content Creation Functions

#### `create-achievement`
Design achievements for games (requires reputation 150+)
```clarity
(create-achievement 
  u1 
  "Speed Demon" 
  "Complete the game in under 2 hours"
  "time" 
  u4 
  u500 
  "epic" 
  "Finish game with time < 120 minutes")
```

#### `create-tournament`
Organize competitive events (requires reputation 200+)
```clarity
(create-tournament 
  u1 
  "Monthly Championship" 
  "Compete for the ultimate prize!"
  "bracket" 
  u50000000 
  u32 
  u7)
```

## Achievement System

### Rarity Tiers

| Tier | Multiplier | Reward Range | Unlock Rate |
|------|------------|--------------|-------------|
| Common | 1x | 70 GVT | ~60% of players |
| Rare | 2x | 140 GVT | ~25% of players |
| Epic | 3x | 210 GVT | ~10% of players |
| Legendary | 4x | 280 GVT | ~5% of players |

### Achievement Types

- **Completion**: Finishing games, levels, or campaigns
- **Score**: Reaching specific score thresholds
- **Time**: Speed run accomplishments
- **Skill**: Demonstrating mastery of game mechanics

## Tournament System

### Tournament Types

#### Single Elimination
- **Format**: One loss elimination
- **Duration**: Typically 1-3 days
- **Ideal Size**: 8-64 participants

#### Bracket Tournament
- **Format**: Multi-round elimination with seeding
- **Duration**: 3-7 days
- **Ideal Size**: 16-128 participants

#### League Format
- **Format**: Round-robin or season play
- **Duration**: 2-4 weeks
- **Ideal Size**: 6-20 participants

### Prize Distribution

Tournaments automatically distribute prizes based on performance:
- **Winner**: 60% of prize pool + 300 GVT bonus
- **Runner-up**: 25% of prize pool + 150 GVT bonus
- **Semi-finalists**: 10% of prize pool + 75 GVT bonus
- **Quarter-finalists**: 5% of prize pool + 35 GVT bonus

## API Reference

### Read-Only Functions

```clarity
;; Get player profile and statistics
(get-player-profile (player principal))

;; View game information and ratings
(get-game (game-id uint))

;; Check achievement details and unlock stats
(get-achievement (achievement-id uint))

;; View tournament information and status
(get-tournament (tournament-id uint))

;; Check leaderboard rankings
(get-leaderboard-entry (game-id uint) (player principal))

;; Get gaming session data
(get-gaming-session (player principal) (game-id uint) (session-date uint))
```

### Profile Management

```clarity
;; Update gamer tag
(update-gamer-tag "ProGamer2024")

;; View token balance
(get-balance (player principal))

;; Transfer tokens between players
(transfer u1000000 tx-sender recipient-principal none)
```

## Reputation System

### Earning Reputation

| Action | Reputation Points | Requirements |
|--------|------------------|--------------|
| Achievement Creation | +15 | Successfully verified achievement |
| Tournament Organization | +25 | Host completed tournament |
| Game Review | +8 | Write detailed review |
| Achievement Unlock | +Variable | Based on achievement point value |

### Reputation Benefits

- **150+ Reputation**: Can create achievements
- **200+ Reputation**: Can organize tournaments
- **300+ Reputation**: Eligible for platform governance
- **500+ Reputation**: Can verify achievements

## Testing

Run the comprehensive test suite:

```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/gamehub_test.ts

# Check contract syntax
clarinet check
```

### Test Coverage
- Achievement creation and unlocking
- Tournament lifecycle management
- Token distribution and rewards
- Reputation system mechanics
- Game registry and reviews
- Access control and permissions

## Security Features

- **Access Control**: Role-based permissions for content creation and verification
- **Anti-Fraud**: Proof verification system for achievements and scores
- **Economic Security**: Capped token supply with merit-based distribution
- **Tournament Integrity**: Automated prize distribution and transparent results
- **Reputation Protection**: Anti-gaming measures for reputation scores

## Integration Examples

### Web3 Gaming Integration

```javascript
// Connect to GameHub contract
import { openContractCall } from '@stacks/connect';

// Unlock achievement with proof
const unlockAchievement = await openContractCall({
  contractAddress: 'SP...',
  contractName: 'gamehub',
  functionName: 'unlock-achievement',
  functionArgs: [
    uintCV(achievementId),
    someCV(uintCV(score)),
    someCV(uintCV(timeMs)),
    someCV(bufferCV(proofHash))
  ]
});
```

### Game Engine Integration

```python
# Python SDK for game developers
import gamehub_sdk

# Initialize GameHub connection
gh = gamehub_sdk.GameHub(contract_address="SP...")

# Register new game
game_id = gh.register_game(
    title="My Awesome Game",
    developer="Indie Studios",
    genre="Puzzle",
    difficulty=3,
    completion_time=20,
    max_players=1
)

# Create achievements
achievement_id = gh.create_achievement(
    game_id=game_id,
    name="Puzzle Master",
    description="Solve 100 puzzles",
    achievement_type="completion",
    difficulty=3,
    points=200,
    rarity="rare"
)
```

## Deployment

### Testnet Deployment
```bash
clarinet deploy --testnet
```

### Mainnet Deployment
```bash
clarinet deploy --mainnet
```

### Environment Configuration
```toml
# Clarinet.toml
[contracts.gamehub]
path = "contracts/gamehub.clar"
clarity_version = 2

[network.testnet]
node_rpc_address = "https://stacks-node-api.testnet.stacks.co"
```

## Roadmap

### Phase 1 (Current)
- Core achievement and tournament systems
- Basic player profiles and reputation
- Token rewards and distribution

### Phase 2 (Q2 2024)
- Advanced leaderboard features
- Social gaming features
- Mobile SDK integration

### Phase 3 (Q3 2024)
- Cross-game achievement compatibility
- Advanced tournament formats
- DAO governance implementation

### Phase 4 (Q4 2024)
- NFT integration for rare achievements
- Streaming platform integration
- Advanced analytics dashboard

## Contributing

We welcome contributions from the gaming community! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: [Wiki](https://github.com/yourusername/gamehub-stacks/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/gamehub-stacks/issues)
- **Community**: [Discord](https://discord.gg/gamehub)
- **Developer Support**: [Telegram](https://t.me/gamehub_dev)

## Acknowledgments

- Stacks Foundation for blockchain infrastructure
- Gaming community for feedback and testing
- Open source contributors and maintainers

---

**Level up your gaming achievements with blockchain permanence and real rewards! 🚀**
