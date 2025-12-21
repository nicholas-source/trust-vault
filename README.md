# TrustVault

[![Clarity](https://img.shields.io/badge/Clarity-v4-blue.svg)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-orange.svg)](https://stacks.org/)
[![License](https://img.shields.io/badge/License-ISC-green.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-41%20Passing-brightgreen.svg)](./tests)
[![Coverage](https://img.shields.io/badge/Coverage-Enhanced-blue.svg)](./tests)

A comprehensive blockchain-based self-sovereign identity management system built on the Stacks blockchain, enabling users to maintain full control over their digital identity while providing robust mechanisms for credential issuance, verification, and reputation tracking through zero-knowledge proofs and cryptographic attestations.

## ⚠️ Mainnet Readiness Status

**Current Status**: 🟢 **DEPLOYED TO MAINNET** (Beta)

**Contract Address**: [`SPR54P37AA27XHMMTCDEW4YZFPFJX69162JR5CT4.trust-vault`](https://explorer.hiro.so/txid/SPR54P37AA27XHMMTCDEW4YZFPFJX69162JR5CT4.trust-vault?chain=mainnet)  
**Deployed**: December 21, 2025  
**Network**: Stacks Mainnet

### Deployment Checklist

- ✅ Contract deployed to mainnet
- ✅ Emergency pause mechanism active
- ✅ Comprehensive test coverage (41 tests)
- ✅ Chainhook integration ready
- ✅ Documentation complete
- ⚠️ External security audit (recommended)
- ⚠️ Admin transfer to multisig (recommended)
- ⚠️ Pause guardian setup (recommended)

**⚠️ Important**: While deployed, consider this BETA until security audit is completed and admin is transferred to multisig governance.

See [CONTRACT_INFO.md](CONTRACT_INFO.md) for detailed deployment information.

---

## 🚀 Quick Links

- **[Get Started Now →](QUICKSTART.md)** - 5-minute setup guide
- **[Contract Info](CONTRACT_INFO.md)** - Full API reference & examples
- **[Security Audit](SECURITY_AUDIT.md)** - Security checklist & recommendations
- **[Deployment Guide](DEPLOYMENT.md)** - Complete deployment procedures
- **[Chainhook Setup](docs/CHAINHOOK_INTEGRATION.md)** - Real-time event monitoring

### Contract Access

- **Explorer**: [View on Stacks Explorer](https://explorer.hiro.so/txid/SPR54P37AA27XHMMTCDEW4YZFPFJX69162JR5CT4.trust-vault?chain=mainnet)
- **API**: `https://api.mainnet.hiro.so/v2/contracts/interface/SPR54P37AA27XHMMTCDEW4YZFPFJX69162JR5CT4/trust-vault`
- **Full Address**: `SPR54P37AA27XHMMTCDEW4YZFPFJX69162JR5CT4.trust-vault`

---

## 🚀 Features

### Core Identity Management

- **Self-Sovereign Identity Registration**: Cryptographic hash-based identity anchoring
- **Secure Identity Recovery**: Designated recovery address mechanisms
- **Identity Status Tracking**: Active, recovered, and other status states
- **Emergency Pause Mechanism**: 🆕 Contract-level circuit breaker for security incidents

### Verifiable Credentials

- **Credential Lifecycle Management**: Issue, verify, and revoke credentials
- **Expiration Management**: Time-bound credential validity
- **Issuer-Subject Relationships**: Comprehensive credential provenance
- **Metadata Support**: Rich credential descriptions and context

### Zero-Knowledge Proof System

- **Cryptographic Proof Submission**: Secure proof data storage
- **Administrative Verification**: Controlled proof validation process
- **Proof Integrity**: Hash-based proof identification and validation

### Reputation System

- **Dynamic Scoring**: Administrative reputation score management
- **Score Boundaries**: Configurable minimum and maximum reputation limits
- **Reputation History**: Block-based timestamp tracking

### Security Features

- **Comprehensive Input Validation**: Multi-layer security checks
- **Administrative Controls**: Secure admin privilege management
- **Error Handling**: Detailed error codes and validation
- **Recovery Mechanisms**: Secure identity recovery processes
- **Emergency Pause System**: 🆕 Admin and guardian can pause contract operations
- **Pause Guardian**: 🆕 Separate pause authority for faster emergency response

## 🔗 Real-Time Event Monitoring

### Chainhook Integration

TrustVault now supports real-time blockchain event monitoring via Chainhooks:

- Monitor identity registrations, credential issuance/revocation
- Track reputation changes and ZK proof submissions
- Receive instant notifications for contract pause events
- Build off-chain indices for faster queries

See [docs/CHAINHOOK_INTEGRATION.md](docs/CHAINHOOK_INTEGRATION.md) for setup guide.

**Example**:

```typescript
import { TrustVaultChainhooks } from './src/chainhooks';

const monitor = new TrustVaultChainhooks({
  baseUrl: 'https://api.mainnet.hiro.so',
  apiKey: process.env.CHAINHOOKS_API_KEY,
  network: 'mainnet',
  contractAddress: 'SP.../trust-vault',
  webhookUrl: 'https://your-server.com/webhooks',
});

await monitor.registerAllMonitors();
```

## 📋 Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) (v18 or higher)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

## 🛠️ Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/nicholas-source/trust-vault.git
   cd trust-vault
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Verify Clarinet installation**

   ```bash
   clarinet --version
   ```

## 🚦 Getting Started

### Contract Deployment

1. **Check contract syntax**

   ```bash
   clarinet check
   ```

2. **Run tests**

   ```bash
   npm test
   ```

3. **Deploy to local devnet**

   ```bash
   clarinet integrate
   ```

### Basic Usage Examples

#### Register an Identity

```clarity
(contract-call? .trust-vault register-identity 
    0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
    (some 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7))
```

#### Issue a Credential

```clarity
(contract-call? .trust-vault issue-credential
    'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7
    0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890
    u1000000
    u"Educational Credential - Computer Science Degree")
```

#### Submit a Zero-Knowledge Proof

```clarity
(contract-call? .trust-vault submit-proof
    0x9876543210fedcba9876543210fedcba9876543210fedcba9876543210fedcba
    0x1234567890abcdef...)
```

## 🧪 Testing

The project includes comprehensive test suites using Vitest and Clarinet SDK.

### Run all tests

```bash
npm test
```

### Run tests with coverage and cost analysis

```bash
npm run test:report
```

### Watch mode for development

```bash
npm run test:watch
```

## 📊 Contract Architecture

### Data Structures

#### Identity Registry

```clarity
{
  hash: (buff 32),                    ; Cryptographic identity hash
  credentials: (list 10 principal),   ; Associated credential issuers
  reputation-score: uint,             ; Current reputation score (0-1000)
  recovery-address: (optional principal), ; Recovery mechanism
  last-updated: uint,                 ; Last modification block
  status: (string-ascii 20)          ; Identity status
}
```

#### Credential Registry

```clarity
{
  subject: principal,                 ; Credential holder
  claim-hash: (buff 32),             ; Cryptographic claim hash
  expiration: uint,                   ; Expiration block height
  revoked: bool,                      ; Revocation status
  metadata: (string-utf8 256)        ; Credential metadata
}
```

#### Zero-Knowledge Proof Storage

```clarity
{
  prover: principal,                  ; Proof submitter
  verified: bool,                     ; Verification status
  timestamp: uint,                    ; Submission block
  proof-data: (buff 1024)           ; Cryptographic proof data
}
```

### Key Functions

#### Public Functions

- `register-identity`: Register a new self-sovereign identity
- `submit-proof`: Submit zero-knowledge proof for verification
- `verify-proof`: Administratively verify a submitted proof
- `issue-credential`: Issue verifiable credentials
- `revoke-credential`: Revoke previously issued credentials
- `update-reputation`: Update identity reputation scores
- `initiate-recovery`: Recover identity using recovery address
- `set-admin`: Transfer administrative privileges

#### Read-Only Functions

- `get-identity`: Retrieve identity information
- `get-credential`: Retrieve credential details
- `verify-credential`: Check credential validity
- `get-proof`: Retrieve proof information

## 🔐 Security Considerations

### Input Validation

- **Hash Validation**: Ensures non-zero cryptographic hashes
- **Expiration Validation**: Prevents past expiration dates
- **Metadata Length**: Enforces storage limits
- **Proof Data Integrity**: Validates minimum proof size requirements

### Access Controls

- **Administrative Functions**: Restricted to contract admin
- **Credential Management**: Issuer-only revocation rights
- **Identity Recovery**: Recovery address authorization required

### Error Handling

Comprehensive error codes provide clear feedback:

- `ERR-NOT-AUTHORIZED` (u1000): Unauthorized access attempt
- `ERR-ALREADY-REGISTERED` (u1001): Identity already exists
- `ERR-NOT-REGISTERED` (u1002): Identity not found
- `ERR-INVALID-PROOF` (u1003): Invalid proof submission
- And more...

## 🔧 Configuration

### System Constants

```clarity
MIN-REPUTATION-SCORE: u0           ; Minimum reputation score
MAX-REPUTATION-SCORE: u1000        ; Maximum reputation score
MIN-EXPIRATION-BLOCKS: u1          ; Minimum credential validity
MAX-METADATA-LENGTH: u256          ; Maximum metadata size
MINIMUM-PROOF-SIZE: u64            ; Minimum proof data size
```

## 📈 Roadmap

- [x] Emergency pause mechanism
- [x] Comprehensive test suite (41 tests)
- [x] Chainhook integration for real-time monitoring
- [ ] Enhanced zero-knowledge proof verification algorithms
- [ ] Multi-signature recovery mechanisms
- [ ] Credential delegation and proxy mechanisms
- [ ] Integration with external identity providers
- [ ] Advanced reputation scoring algorithms
- [ ] Cross-chain identity verification
- [ ] Privacy-preserving credential sharing
- [ ] External security audit
- [ ] Mainnet deployment

## 📚 Documentation

- **[Security Audit Checklist](SECURITY_AUDIT.md)**: Pre-mainnet security review
- **[Deployment Guide](DEPLOYMENT.md)**: Step-by-step mainnet deployment
- **[Chainhook Integration](docs/CHAINHOOK_INTEGRATION.md)**: Real-time event monitoring setup
- **[API Reference](contracts/trust-vault.clar)**: Contract functions and data structures

## 🔐 Security Considerations

We welcome contributions to TrustVault! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Clarity best practices and conventions
- Include comprehensive tests for new features
- Update documentation for API changes
- Ensure all tests pass before submitting PRs

## 📄 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: [Stacks Documentation](https://docs.stacks.co/)
- **Clarity Language**: [Clarity Documentation](https://clarity-lang.org/)

## 🙏 Acknowledgments

- Stacks Foundation for the Clarity smart contract language
- Hiro Systems for Clarinet development tools
- The Stacks community for continued support and feedback

---

**TrustVault** - Empowering self-sovereign digital identity on the blockchain.
