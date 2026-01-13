# 🔥 Decentralized Erotic Content Platform Smart Contract

A censorship-resistant platform for verified adult content creators powered by Bitcoin and Stacks.

## 🌟 Features

- Creator registration and verification
- Content publishing as NFTs
- Subscription management
- Automated revenue splitting
- Platform fee handling
- Subscription status tracking

## 💫 Core Functions

### For Creators
- `register-creator`: Register as a content creator
- `publish-content`: Publish new content with pricing
- `get-creator-details`: View creator statistics

### For Subscribers
- `subscribe-to-creator`: Subscribe to a creator's content
- `check-subscription`: Verify subscription status
- `get-content-details`: View content information

### Platform Admin
- `verify-creator`: Verify creator credentials

## 🚀 Getting Started

1. Deploy contract using Clarinet
2. Register as creator with minimum subscription price
3. Wait for platform verification
4. Start publishing content
5. Subscribers can purchase subscriptions

## ⚡ Technical Details

- Platform fee: 5%
- Minimum subscription price: 1 STX
- Subscription duration: 1440 blocks (~10 days)
- Content stored as NFTs
- Verified creator badges

## 🔒 Security

- Owner-only verification
- Subscription expiration checks
- Creator verification requirements
```

Git commit message:
```
feat: implement decentralized adult content platform MVP with creator verification and subscriptions
```

PR Title:
```
✨ Add Decentralized Adult Content Platform Smart Contract
```

PR Description:
```
This PR implements the core smart contract for a decentralized adult content platform with the following features:

- Creator registration and verification system
- Content publishing with NFT minting
- Subscription management with auto-split payments
- Platform fee handling (5%)
- Creator badges and content ownership
- Subscription tracking and validation

The implementation focuses on core functionality while maintaining security and scalability. All core features have been tested with Clarinet.

Testing Instructions:
1. Deploy contract
2. Register test creator
3. Verify creator
4. Publish test content
5. Test subscription flow