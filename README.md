#  Scholarship Trust Fund with Proof-of-Learning

A decentralized scholarship system that empowers students through verified learning achievements.

## 🌟 Features

- 📚 Proof-of-learning milestones
- 💰 Transparent fund pool
- 🤝 Community-driven donations
- ⚡ Direct fund transfers
- ✅ Learning pathway validation
- 🛡️ Emergency pause mechanism for enhanced security
- 🔄 Flexible contract management with pause/unpause capabilities

## 🔧 Smart Contract Functions

### For Administrators
- `initialize-milestone`: Create new learning milestones
- `enroll-student`: Add students to the program
- `pause-contract`: Temporarily halt all contract operations
- `unpause-contract`: Resume contract operations
- `expire-milestone`: Remove expired milestones and reclaim funds
- `redistribute-expired-funds`: Distribute expired milestone funds

### For Students
- `submit-milestone`: Submit proof of learning completion
- `claim-reward`: Receive scholarship funds for completed milestones
- `unenroll-student`: Remove oneself from the program

### For Donors
- `donate-to-fund`: Contribute STX to the scholarship pool

### Read-Only Functions
- `get-student-info`: View student progress
- `get-milestone-info`: Check milestone details
- `get-fund-balance`: View total available funds
- `get-expired-fund-balance`: View expired funds available for redistribution
- `is-milestone-expired`: Check if a milestone has passed its deadline
- `get-contract-paused-status`: Check if contract operations are paused

## 🚀 Getting Started

1. Deploy the contract using Clarinet
2. Initialize learning milestones
3. Enroll students
4. Accept donations
5. Verify and reward learning achievements

## 💡 Usage Example

```clarity
;; Initialize a milestone
(contract-call? .scholarship-fund initialize-milestone u1 u1000 "intro-to-blockchain")

;; Enroll a student
(contract-call? .scholarship-fund enroll-student 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Submit proof of learning
(contract-call? .scholarship-fund submit-milestone u1 "QmHash123...")

;; Claim reward
(contract-call? .scholarship-fund claim-reward u1)
```

## 📝 License

MIT
```

Git commit message:
```
feat: Implement Scholarship Trust Fund with Proof-of-Learning MVP
```

PR Title:
```
✨ Add Scholarship Trust Fund Smart Contract MVP
```

PR Description:
```
This PR introduces the initial implementation of the Scholarship Trust Fund with Proof-of-Learning system.

Key additions:
- Core smart contract with milestone tracking
- Student enrollment and verification
- Transparent fund management
- Direct reward distribution
- Read-only information functions

The implementation focuses on essential features while maintaining security and scalability.

Testing completed:
- Contract deployment
- Milestone creation
- Student enrollment
- Fund distribution
- Access control

