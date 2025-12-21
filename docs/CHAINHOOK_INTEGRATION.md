# Chainhook Integration Guide

## Overview

This guide explains how to integrate Chainhooks with your TrustVault deployment for real-time event monitoring and automation.

## What are Chainhooks?

Chainhooks allow you to:
- **Monitor contract events** in real-time
- **Trigger webhooks** when specific functions are called
- **Build off-chain indices** for faster queries
- **Automate workflows** based on blockchain events
- **Send notifications** when important events occur

## Setup Instructions

### 1. Install Dependencies

```bash
npm install @hirosystems/chainhooks-client express @types/express
```

### 2. Get API Credentials

Sign up for Chainhooks API access:
- **Hiro Platform**: https://platform.hiro.so/
- Or run your own Chainhooks server: https://github.com/hirosystems/chainhook

### 3. Configure Environment Variables

Create a `.env` file:

```bash
CHAINHOOKS_API_KEY=your_api_key_here
CHAINHOOKS_BASE_URL=https://api.mainnet.hiro.so
WEBHOOK_URL=https://your-server.com/webhooks
TRUST_VAULT_CONTRACT=SPR54P37AA27XHMMTCDEW4YZFPFJX69162JR5CT4.trust-vault
```

### 4. Initialize Chainhook Monitoring

```typescript
import { TrustVaultChainhooks, CHAINHOOKS_BASE_URL } from './src/chainhooks';

const chainhooks = new TrustVaultChainhooks({
  baseUrl: CHAINHOOKS_BASE_URL.testnet,
  apiKey: process.env.CHAINHOOKS_API_KEY!,
  network: 'testnet',
  contractAddress: process.env.TRUST_VAULT_CONTRACT!,
  webhookUrl: process.env.WEBHOOK_URL!,
});

// Register all monitors
await chainhooks.registerAllMonitors();
```

## Monitored Events

### 1. Identity Registrations

**Function**: `register-identity`

**Triggered when**: A new user registers their identity

**Use cases**:
- Send welcome email to new users
- Create user profile in your database
- Initialize reputation tracking
- Analytics and growth metrics

**Webhook payload example**:
```json
{
  "address": "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
  "identityHash": "0x1234...",
  "recoveryAddress": "ST2...",
  "blockHeight": 12345,
  "txHash": "0xabc..."
}
```

### 2. Credential Issuance

**Function**: `issue-credential`

**Triggered when**: A credential is issued to an identity

**Use cases**:
- Notify credential holder
- Index credentials for search
- Track credential issuance trends
- Compliance and audit trails

### 3. Credential Revocations

**Function**: `revoke-credential`

**Triggered when**: A credential is revoked

**Use cases**:
- Alert credential holder immediately
- Update credential status in UI
- Log revocation reasons
- Compliance reporting

### 4. Reputation Changes

**Function**: `update-reputation`

**Triggered when**: Admin updates user reputation

**Use cases**:
- Track reputation history
- Alert users of score changes
- Identify suspicious patterns
- Generate reputation reports

### 5. ZK Proof Submissions

**Function**: `submit-proof`

**Triggered when**: A zero-knowledge proof is submitted

**Use cases**:
- Queue proofs for verification
- Track proof submission rate
- Monitor proof types
- Performance analytics

### 6. Emergency Pause Events

**Function**: `pause-contract`

**Triggered when**: Contract is paused

**Use cases**:
- **Critical alert**: Notify all stakeholders
- Disable UI interactions
- Log security incidents
- Initiate incident response

## Advanced Usage

### Filtering Events

You can add additional filters to narrow down events:

```typescript
const chainhook: ChainhookDefinition = {
  name: 'High-Value Credentials Only',
  chain: 'stacks',
  network: 'mainnet',
  version: 1,
  filters: {
    predicate: {
      scope: 'contract_call',
      contract_identifier: contractAddress,
      method: 'issue-credential',
      // Additional filters can be added here
    },
  },
  then_that: {
    http_post: {
      url: `${webhookUrl}/high-value-credentials`,
      authorization_header: `Bearer ${apiKey}`,
    },
  },
};
```

### Batch Processing

Process multiple events efficiently:

```typescript
const events = [];

app.post('/webhooks/credential-issued', async (req, res) => {
  events.push(req.body);
  
  // Process in batches of 100
  if (events.length >= 100) {
    await batchProcessCredentials(events);
    events.length = 0;
  }
  
  res.status(200).json({ success: true });
});
```

### Error Handling and Retries

Implement robust error handling:

```typescript
app.post('/webhooks/identity-registered', async (req, res) => {
  try {
    await processIdentityRegistration(req.body);
    res.status(200).json({ success: true });
  } catch (error) {
    console.error('Failed to process webhook:', error);
    
    // Queue for retry
    await retryQueue.add({
      type: 'identity-registered',
      payload: req.body,
      attempts: 0,
    });
    
    // Still return 200 to prevent Chainhooks from retrying
    res.status(200).json({ queued: true });
  }
});
```

## Webhook Security

### 1. Verify Request Signatures

```typescript
import crypto from 'crypto';

function verifyWebhookSignature(req: Request): boolean {
  const signature = req.headers['x-chainhook-signature'];
  const payload = JSON.stringify(req.body);
  
  const expectedSignature = crypto
    .createHmac('sha256', process.env.CHAINHOOKS_API_KEY!)
    .update(payload)
    .digest('hex');
  
  return signature === expectedSignature;
}

app.post('/webhooks/*', (req, res, next) => {
  if (!verifyWebhookSignature(req)) {
    return res.status(401).json({ error: 'Invalid signature' });
  }
  next();
});
```

### 2. Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

const webhookLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 100, // Max 100 requests per minute
});

app.use('/webhooks', webhookLimiter);
```

### 3. IP Whitelisting

```typescript
const ALLOWED_IPS = [
  '34.94.100.100', // Hiro Chainhooks IP
  // Add more IPs as needed
];

app.use('/webhooks', (req, res, next) => {
  const clientIP = req.ip;
  
  if (!ALLOWED_IPS.includes(clientIP)) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  
  next();
});
```

## Database Integration

### Store Events in PostgreSQL

```typescript
import { Pool } from 'pg';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

app.post('/webhooks/identity-registered', async (req, res) => {
  const { address, identityHash, blockHeight, txHash } = req.body;
  
  await pool.query(
    `INSERT INTO identities (address, identity_hash, block_height, tx_hash, created_at)
     VALUES ($1, $2, $3, $4, NOW())`,
    [address, identityHash, blockHeight, txHash]
  );
  
  res.status(200).json({ success: true });
});
```

### Build Search Indices

```typescript
// Index credentials for fast lookup
await pool.query(
  `CREATE INDEX idx_credentials_subject ON credentials(subject);
   CREATE INDEX idx_credentials_issuer ON credentials(issuer);
   CREATE INDEX idx_credentials_expiration ON credentials(expiration);`
);
```

## Monitoring & Observability

### Track Webhook Performance

```typescript
import { performance } from 'perf_hooks';

app.post('/webhooks/*', async (req, res, next) => {
  const start = performance.now();
  
  res.on('finish', () => {
    const duration = performance.now() - start;
    console.log(`Webhook processed in ${duration}ms`);
    
    // Send to monitoring service
    metrics.histogram('webhook.duration', duration, {
      endpoint: req.path,
      status: res.statusCode,
    });
  });
  
  next();
});
```

### Health Checks

```typescript
app.get('/health', async (req, res) => {
  try {
    // Check database connection
    await pool.query('SELECT 1');
    
    // Check Chainhooks API
    await chainhooks.checkStatus();
    
    res.status(200).json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: error.message,
    });
  }
});
```

## Deployment Checklist

- [ ] Set up webhook endpoint with HTTPS
- [ ] Configure environment variables
- [ ] Register chainhooks with API
- [ ] Test webhook endpoints locally
- [ ] Implement webhook signature verification
- [ ] Set up error handling and retries
- [ ] Configure logging and monitoring
- [ ] Set up database for event storage
- [ ] Test with testnet before mainnet
- [ ] Document runbooks for incidents
- [ ] Configure alerts for critical events

## Troubleshooting

### Webhooks Not Receiving Events

1. Check chainhook registration status
2. Verify webhook URL is publicly accessible
3. Check firewall and security group settings
4. Test with ngrok for local development

### High Latency

1. Use async processing with queues
2. Batch database writes
3. Scale horizontally with load balancer
4. Optimize database queries

### Missing Events

1. Check webhook endpoint logs
2. Verify chainhook is enabled
3. Check for errors in Chainhooks dashboard
4. Implement event replay mechanism

## Resources

- [Chainhooks Documentation](https://docs.hiro.so/chainhooks)
- [Hiro Platform](https://platform.hiro.so/)
- [TrustVault Examples](./examples/chainhook-integration.ts)
- [Stacks API Reference](https://docs.stacks.co/api)

## Support

For issues or questions:
- GitHub Issues: [Your Repo URL]
- Discord: [Your Discord]
- Email: support@trustvault.example
