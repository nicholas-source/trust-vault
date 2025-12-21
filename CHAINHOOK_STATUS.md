# Chainhook Integration Status

## ✅ Completed

### 1. API Format Fixes
- ✅ Updated from Chainhooks v1.0 to v2.0 API format
- ✅ Changed `then_that` to `action` structure
- ✅ Updated filters from `predicate` to `events` array format
- ✅ Corrected action format: `{ type: 'http_post', url: '...' }`
- ✅ Added `version: '1'` string format instead of number
- ✅ Added `options: { enable_on_registration: true }`

### 2. Successfully Registered Chainhooks
Three chainhooks were successfully registered before hitting the API limit:

1. **TrustVault Identity Registrations**
   - UUID: `21e6db9b-0ecb-4529-92e6-eb9bf26fb2f9`
   - Monitors: `register-identity` function calls
   - Webhook: `/identity-registered`

2. **TrustVault Emergency Pause Events**
   - UUID: `d73976d1-e04b-4a04-852c-89d10976c0e5`
   - Monitors: `pause-contract` function calls
   - Webhook: `/contract-paused`

3. **TrustVault Credential Revocations**
   - UUID: `6fd80adc-a565-42dd-b89b-ddcd82f81b7a`
   - Monitors: `revoke-credential` function calls
   - Webhook: `/credential-revoked`

### 3. Tools Created
- ✅ `scripts/test-api.ts` - API connection testing tool
- ✅ `scripts/cleanup-chainhooks.ts` - Interactive cleanup tool
- ✅ `npm run cleanup:chainhooks` command added

## ⚠️ Current Issue

**API Limit Reached**: Your starter tier allows 10 chainhooks, and you currently have 10 registered.

### Remaining Chainhooks to Register
4. **TrustVault Credential Issuance**
   - Monitors: `issue-credential` function calls
   - Webhook: `/credential-issued`

5. **TrustVault Reputation Updates**
   - Monitors: `update-reputation` function calls
   - Webhook: `/reputation-updated`

6. **TrustVault ZK Proof Submissions**
   - Monitors: `submit-proof` function calls
   - Webhook: `/proof-submitted`

## 🔧 Next Steps

### Option 1: Clean Up Existing Chainhooks
Run the cleanup tool to remove unused chainhooks:

```bash
npm run cleanup:chainhooks
```

The tool offers:
1. Delete all non-TrustVault chainhooks (recommended)
2. Delete all TrustVault chainhooks
3. Delete all chainhooks
4. Select specific chainhooks to delete
5. Cancel

After cleanup, run:
```bash
npm run setup:chainhooks
```

### Option 2: Upgrade API Tier
Contact Hiro to upgrade from starter tier (10 chainhooks) to a higher tier.

### Option 3: Prioritize Chainhooks
Keep only the most critical chainhooks:
- Identity registrations (already active ✅)
- Credential issuance (needs registration)
- Pause events (already active ✅)

## 📊 API Usage Summary

**Rate Limits** (Starter Tier):
- Per Second: 40 requests
- Per Minute: 900 requests  
- Per Month: 150,000 requests
- Current Usage: 149,947 remaining (53 used)

**Chainhook Limits**:
- Maximum: 10 chainhooks
- Currently Registered: 10 chainhooks
- TrustVault: 3 chainhooks
- Other Projects: 7 chainhooks

## 🎯 Recommendations

1. **Immediate Action**: Run cleanup tool to delete non-TrustVault chainhooks
   ```bash
   npm run cleanup:chainhooks
   # Choose option 1: Delete all non-TrustVault chainhooks
   ```

2. **Register Remaining**: After cleanup, complete the setup
   ```bash
   npm run setup:chainhooks
   ```

3. **Monitor Usage**: Use the test script to check status
   ```bash
   npx tsx scripts/test-api.ts
   ```

## 📚 Working Configuration

The chainhook definitions are now correctly formatted for Chainhooks API v2.0:

```typescript
{
  name: 'TrustVault Identity Registrations',
  chain: 'stacks',
  network: 'mainnet',
  version: '1',
  filters: {
    events: [
      {
        type: 'contract_call',
        contract_identifier: 'SPR54P37AA27XHMMTCDEW4YZFPFJX69162JR5CT4.trust-vault',
        method: 'register-identity',
      },
    ],
  },
  action: {
    type: 'http_post',
    url: 'https://webhook.site/f3a8b27a-df56-4777-b968-b5a5fb4e0ef4/identity-registered',
  },
  options: {
    enable_on_registration: true,
  },
}
```

## 🔗 Resources

- Chainhooks API: https://api.mainnet.hiro.so
- Webhook Testing: https://webhook.site/f3a8b27a-df56-4777-b968-b5a5fb4e0ef4
- API Documentation: https://docs.hiro.so/chainhooks
- Contract: SPR54P37AA27XHMMTCDEW4YZFPFJX69162JR5CT4.trust-vault

---

Last Updated: 2025-12-21
