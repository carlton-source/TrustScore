# TrustScore: Decentralized Identity & Reputation Protocol

A next-generation protocol for establishing and managing digital trust through decentralized identities and dynamic reputation scoring.

## Overview

TrustScore is a smart contract protocol that enables self-sovereign identity management with merit-based reputation scoring. It provides a transparent, objective framework for building trusted relationships in decentralized ecosystems.

## Features

- **Self-Sovereign Identity Management**

  - Create and manage decentralized identities (DIDs)
  - Full user control over identity data
  - Immutable identity records on-chain

- **Dynamic Reputation System**

  - Merit-based scoring mechanism
  - Time-based decay for maintaining relevancy
  - Configurable reputation actions and multipliers
  - Cross-platform reputation verification

- **Flexible Scoring Mechanisms**
  - Starting reputation score: 50 points
  - Maximum reputation cap: 1000 points
  - Minimum reputation floor: 0 points
  - 10% periodic decay rate

## Reputation Actions

The protocol includes pre-configured reputation actions with the following multipliers:

| Action Type            | Multiplier | Description                                          |
| ---------------------- | ---------- | ---------------------------------------------------- |
| Governance Vote        | 5          | Participation in protocol governance                 |
| Contract Fulfillment   | 10         | Successful completion of smart contract interactions |
| Community Contribution | 7          | Valuable contributions to the ecosystem              |

## Technical Documentation

### Storage

#### Identities Map

```clarity
{
  owner: principal,
  did: string-ascii,
  reputation-score: uint,
  created-at: uint,
  last-updated: uint
}
```

#### Reputation Actions Map

```clarity
{
  action-type: string-ascii,
  multiplier: uint
}
```

### Core Functions

#### Creating an Identity

```clarity
(create-identity (did string-ascii))
```

Creates a new decentralized identity with:

- Unique DID string (minimum 6 characters)
- Initial reputation score of 50
- Timestamp tracking for creation and updates

#### Updating Reputation

```clarity
(update-reputation (action-type string-ascii))
```

Updates an identity's reputation score based on actions:

- Validates action type exists
- Applies action multiplier
- Enforces maximum score cap
- Updates last modified timestamp

#### Reputation Decay

```clarity
(decay-reputation)
```

Applies time-based decay to reputation scores:

- 10% reduction per decay period
- Maintains minimum score floor
- Updates last modified timestamp

#### Verification

```clarity
(verify-reputation (owner principal) (min-reputation-threshold uint))
```

Verifies if an identity meets a minimum reputation threshold:

- Returns boolean result
- Enables cross-platform integration
- Supports external verification

### Error Handling

| Error Code                         | Description                   |
| ---------------------------------- | ----------------------------- |
| ERR-UNAUTHORIZED (u100)            | Action requires authorization |
| ERR-INVALID-PARAMETERS (u101)      | Invalid input parameters      |
| ERR-IDENTITY-EXISTS (u102)         | Identity already exists       |
| ERR-IDENTITY-NOT-FOUND (u103)      | Identity not found            |
| ERR-INSUFFICIENT-REPUTATION (u104) | Insufficient reputation score |
| ERR-MAX-REPUTATION-REACHED (u105)  | Maximum reputation reached    |

## Security Considerations

1. **Identity Verification**

   - Only identity owners can modify their records
   - DID validation prevents empty or invalid identifiers
   - Immutable creation timestamps

2. **Reputation Management**

   - Capped maximum reputation score
   - Protected minimum reputation floor
   - Controlled decay mechanism
   - Validated action types

3. **Access Control**
   - Principal-based ownership
   - Function-level authorization checks
   - Protected initialization functions

## Integration Guide

### Reading Identity Data

```clarity
;; Fetch identity details
(get-reputation (owner principal))

;; Verify reputation threshold
(verify-reputation owner min-reputation-threshold)
```

### Reputation Updates

```clarity
;; Update reputation with action
(update-reputation "governance-vote")

;; Apply reputation decay
(decay-reputation)
```

## Best Practices

1. **Identity Management**

   - Generate secure and unique DIDs
   - Maintain regular activity to counter decay
   - Monitor reputation score changes

2. **Integration**

   - Implement appropriate error handling
   - Verify reputation thresholds before critical actions
   - Consider decay periods in application logic

3. **Security**
   - Validate all user inputs
   - Implement proper authorization checks
   - Monitor for unusual reputation changes
