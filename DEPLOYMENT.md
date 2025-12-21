# TrustVault Mainnet Deployment Guide

## Pre-Deployment Checklist

Before deploying to mainnet, ensure you complete all items in [SECURITY_AUDIT.md](SECURITY_AUDIT.md).

### Critical Requirements ✅

- [ ] **Security Audit**: Completed by reputable firm
- [ ] **Testnet Testing**: Minimum 1 month on testnet without critical issues
- [ ] **Test Coverage**: Achieved >90% code coverage
- [ ] **Admin Setup**: Multisig or DAO governance configured
- [ ] **Emergency Plan**: Incident response procedures documented
- [ ] **Insurance**: Security fund or insurance in place
- [ ] **Legal Review**: Terms of service and compliance verified

## Deployment Steps

### 1. Environment Setup

#### Install Dependencies

```bash
npm install
npm install -g @stacks/cli
```

#### Configure Mainnet Settings

Edit `settings/Mainnet.toml`:

```toml
[network]
name = "mainnet"
node_rpc_address = "https://api.mainnet.hiro.so"

[accounts.deployer]
mnemonic = "YOUR_DEPLOYMENT_MNEMONIC_PHRASE"
# Or use a Ledger hardware wallet:
# stx_address = "SP..."
# derivation = "m/44'/5757'/0'/0/0"
```

**⚠️ SECURITY WARNING**: Never commit private keys or mnemonics to version control!

### 2. Contract Verification

#### Run Final Tests

```bash
npm test
clarinet check
```

Expected output: **41 tests passed**

#### Gas Cost Analysis

```bash
npm run test:report
```

Review gas costs for each function to ensure they're within acceptable limits.

### 3. Testnet Deployment (Required First)

Deploy to testnet before mainnet:

```bash
# Deploy to testnet
clarinet deployments apply --testnet

# Get contract address
clarinet deployments status --testnet
```

Contract address example: `ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.trust-vault`

### ✅ Mainnet Deployed

**Contract Address**: `SPR54P37AA27XHMMTCDEW4YZFPFJX69162JR5CT4.trust-vault`  
**Deployment Date**: December 21, 2025  
**Network**: Stacks Mainnet  
**Cost**: 0.140730 STX

#### Testnet Testing Period

Run your application on testnet for **minimum 1 month**:

- [ ] Test all critical user flows
- [ ] Stress test with multiple concurrent users
- [ ] Test emergency pause mechanism
- [ ] Test admin functions
- [ ] Monitor for any unexpected behavior
- [ ] Gather user feedback

### 4. Admin Configuration

#### Option A: Multisig Admin (Recommended)

Use a 3-of-5 multisig wallet as admin:

```clarity
;; After deployment, transfer admin to multisig
(contract-call? .trust-vault set-admin 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

Recommended multisig solutions:
- [Stacks Safe](https://safe.stacks.org/)
- Custom multisig contract

#### Option B: DAO Governance

Integrate with a DAO for decentralized admin control:

```clarity
;; Transfer admin to DAO contract
(contract-call? .trust-vault set-admin 'SP...dao-contract)
```

### 5. Pause Guardian Setup

Set a separate pause guardian for emergency response:

```clarity
;; Set pause guardian (different from admin for security)
(contract-call? .trust-vault set-pause-guardian 
  (some 'SP3X6QWWETNBZWGBK6DRGTR1KX50S74D3425Q1QPK))
```

**Best Practice**: Use a different entity than admin for pause guardian to enable faster emergency response.

### 6. Mainnet Deployment

#### Final Preparation

1. **Backup everything**:
   ```bash
   git tag -a v1.0.0-mainnet -m "Mainnet release"
   git push origin v1.0.0-mainnet
   ```

2. **Fund deployer wallet** with sufficient STX for deployment:
   - Contract deployment: ~0.5 STX
   - Initial transactions: ~0.1 STX
   - Total recommended: 1 STX minimum

3. **Create deployment plan**:
   ```bash
   clarinet deployments generate --mainnet
   ```

#### Execute Deployment

```bash
# Deploy to mainnet
clarinet deployments apply --mainnet

# Verify deployment
clarinet deployments status --mainnet
```

#### Post-Deployment Verification

1. **Verify contract is deployed**:
   ```bash
   curl https://api.mainnet.hiro.so/v2/contracts/interface/SP.../trust-vault
   ```

2. **Test read-only functions**:
   ```bash
   stx call_read_only_function SP.../trust-vault get-identity ...
   ```

3. **Verify admin address**:
   ```bash
   stx call_read_only_function SP.../trust-vault get-admin
   ```

### 7. Initialize Contract

#### Transfer Admin Rights

```bash
# Transfer to multisig/DAO
stx call_contract_func SP.../trust-vault set-admin \
  --network mainnet \
  --privateKey YOUR_KEY \
  --arg principal:SP...multisig-address
```

#### Set Pause Guardian

```bash
stx call_contract_func SP.../trust-vault set-pause-guardian \
  --network mainnet \
  --privateKey YOUR_KEY \
  --arg optional-principal:some:SP...guardian-address
```

### 8. Chainhook Integration

Set up real-time monitoring:

```bash
# Install chainhook dependencies
npm install @hirosystems/chainhooks-client express

# Set environment variables
export CHAINHOOKS_API_KEY=your_api_key
export TRUST_VAULT_CONTRACT=SPR54P37AA27XHMMTCDEW4YZFPFJX69162JR5CT4.trust-vault
export WEBHOOK_URL=https://your-server.com/webhooks

# Start webhook server
node examples/chainhook-integration.js
```

See [CHAINHOOK_INTEGRATION.md](docs/CHAINHOOK_INTEGRATION.md) for details.

### 9. Monitoring Setup

#### Set Up Alerts

Configure alerts for critical events:

- **Contract paused**: Immediate notification to all stakeholders
- **Admin changed**: Alert security team
- **High volume of credential revocations**: Potential abuse
- **Reputation manipulation**: Unusual pattern detection

#### Monitoring Tools

- **Hiro Platform**: https://platform.hiro.so/
- **Stacks Explorer**: https://explorer.hiro.so/
- **Custom Dashboard**: Using chainhook data

#### Health Checks

```bash
# Check contract status
curl https://api.mainnet.hiro.so/v2/contracts/interface/SP.../trust-vault

# Check recent transactions
curl https://api.mainnet.hiro.so/extended/v1/address/SP.../transactions
```

### 10. Documentation

Update public documentation:

- [ ] API documentation
- [ ] User guides
- [ ] Developer integration docs
- [ ] Security disclosures
- [ ] Terms of service
- [ ] Privacy policy

## Post-Deployment Operations

### Regular Maintenance

#### Weekly

- [ ] Review transaction logs
- [ ] Check for unusual patterns
- [ ] Monitor gas costs
- [ ] Review credential issuance/revocation trends

#### Monthly

- [ ] Security review
- [ ] Performance analysis
- [ ] User feedback review
- [ ] Update documentation

#### Quarterly

- [ ] External security audit
- [ ] Governance review
- [ ] Roadmap planning
- [ ] Community updates

### Emergency Procedures

#### If Contract Must Be Paused

1. **Assess severity** (Critical/High/Medium/Low)
2. **Trigger pause**:
   ```bash
   stx call_contract_func SP.../trust-vault pause-contract
   ```
3. **Notify stakeholders** immediately
4. **Investigate issue**
5. **Develop fix**
6. **Test fix on testnet**
7. **Deploy new version** (if needed)
8. **Unpause** when safe:
   ```bash
   stx call_contract_func SP.../trust-vault unpause-contract
   ```

### Incident Response Contacts

Maintain a list of key contacts:

- **Security Team**: security@trustvault.example
- **Dev Team Lead**: dev-lead@trustvault.example
- **Audit Firm**: auditors@example.com
- **Legal**: legal@trustvault.example
- **Community Manager**: community@trustvault.example

## Upgrade Strategy

### When to Upgrade

- Critical security fixes
- Major feature additions
- Performance improvements
- Community governance decisions

### Upgrade Process

Since Clarity contracts are immutable:

1. **Deploy new contract version** (e.g., trust-vault-v2)
2. **Migrate data** (if possible/needed)
3. **Update client applications** to point to new contract
4. **Deprecate old contract** gradually
5. **Document migration** for users

## Rollback Plan

If critical issues are discovered:

1. **Pause contract** immediately
2. **Communicate** with users
3. **Assess impact**
4. **Deploy fixed version** as new contract
5. **Migrate users** to new contract
6. **Compensate** affected users if necessary

## Cost Estimates

### Deployment Costs

- Contract deployment: ~0.3 STX
- Initial transactions: ~0.1 STX
- Testing: ~0.1 STX
- **Total**: ~0.5 STX

### Operational Costs

- Chainhook API: Free tier or ~$50/month
- Webhook server: ~$20-100/month
- Monitoring: ~$50-200/month
- **Total**: ~$120-350/month

## Success Metrics

Track these KPIs:

- **Identities Registered**: Target growth rate
- **Credentials Issued**: Active usage indicator
- **Average Reputation Score**: System health
- **Zero Downtime**: Uptime target 99.9%
- **No Critical Bugs**: Quality metric
- **User Satisfaction**: NPS score >70

## Support Resources

- **Documentation**: https://docs.trustvault.example
- **Discord**: https://discord.gg/trustvault
- **GitHub**: https://github.com/yourusername/trust-vault
- **Email**: support@trustvault.example
- **Bug Bounty**: https://bugcrowd.com/trustvault

## Legal Considerations

### Terms of Service

Ensure your ToS covers:
- User responsibilities
- Liability limitations
- Data handling
- Dispute resolution
- Governing law

### Privacy Policy

GDPR/CCPA compliance:
- Data collection practices
- User rights
- Data retention
- International transfers

### Regulatory Compliance

Depending on your jurisdiction:
- KYC/AML requirements
- Data protection regulations
- Securities laws (if applicable)
- Consumer protection laws

## Insurance & Security Fund

Consider:
- **Smart contract insurance**: Nexus Mutual, etc.
- **Security fund**: Set aside funds for potential exploits
- **Bug bounty program**: Incentivize white-hat researchers

## Timeline

**Recommended minimum timeline from code complete to mainnet**:

| Phase | Duration | Tasks |
|-------|----------|-------|
| Security Audit | 2-4 weeks | External audit, fixes |
| Testnet Deployment | 4-6 weeks | User testing, monitoring |
| Documentation | 2 weeks | User/dev docs, ToS |
| Final Prep | 1 week | Multisig setup, monitoring |
| Mainnet Deployment | 1 day | Deploy, verify, initialize |
| **Total** | **9-13 weeks** | |

---

## Quick Reference Commands

```bash
# Check contract
clarinet check

# Run tests
npm test

# Deploy testnet
clarinet deployments apply --testnet

# Deploy mainnet
clarinet deployments apply --mainnet

# Emergency pause
stx call_contract_func SP.../trust-vault pause-contract

# Unpause
stx call_contract_func SP.../trust-vault unpause-contract

# Check contract status
curl https://api.mainnet.hiro.so/v2/contracts/interface/SP.../trust-vault
```

---

**Last Updated**: December 21, 2025  
**Version**: 1.0.0  
**Status**: Pre-Mainnet
