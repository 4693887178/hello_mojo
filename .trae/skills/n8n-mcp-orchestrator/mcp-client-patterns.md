# MCP Client Patterns - n8n

Complete guide for using n8n as an MCP (Model Context Protocol) client to consume external MCP servers from within workflows.

## Table of Contents

1. [Overview](#overview)
2. [MCP Client Tool Node](#mcp-client-tool-node)
3. [Connecting to External MCP Servers](#connecting-to-external-mcp-servers)
4. [Common Integration Patterns](#common-integration-patterns)
5. [Error Handling](#error-handling)
6. [Authentication Methods](#authentication-methods)
7. [Performance Optimization](#performance-optimization)
8. [Production Best Practices](#production-best-practices)

---

## Overview

The **MCP Client Tool** node in n8n allows your workflows to invoke tools from external MCP servers. This enables you to:

- Call AI services (Claude, GPT, custom LLMs)
- Integrate with MCP-compatible third-party services
- Orchestrate multiple MCP servers in a single workflow
- Build complex automation chains
- Leverage external capabilities without direct API integration

**Architecture:**

```
n8n Workflow
     ↓
MCP Client Tool Node
     ↓
MCP Protocol (HTTP/WebSocket)
     ↓
External MCP Server
     ↓
Tool Execution
     ↓
Response returned to n8n
     ↓
Continue workflow
```

---

## MCP Client Tool Node

### Configuration Fields

#### 1. MCP Server Connection

**Server URL:**
- Full URL to the MCP server endpoint
- Format: `https://server.example.com/mcp`
- Supports HTTP, HTTPS, WebSocket (wss://)

```json
{
  "serverUrl": "https://analytics.company.com/mcp"
}
```

**Connection Timeout:**
- Maximum time to wait for connection (milliseconds)
- Default: 30000 (30 seconds)
- Increase for slow servers or complex operations

```json
{
  "connectionTimeout": 60000
}
```

#### 2. Authentication

**None:**
```json
{
  "authentication": {
    "type": "none"
  }
}
```

**API Key:**
```json
{
  "authentication": {
    "type": "apiKey",
    "headerName": "X-API-Key",
    "apiKey": "{{$credentials.mcpApiKey}}"
  }
}
```

**Bearer Token:**
```json
{
  "authentication": {
    "type": "bearer",
    "token": "{{$credentials.mcpBearerToken}}"
  }
}
```

**OAuth 2.0:**
```json
{
  "authentication": {
    "type": "oauth2",
    "credentials": "{{$credentials.mcpOAuth}}"
  }
}
```

#### 3. Tool Selection

**Discover Available Tools:**

The MCP Client Tool node can automatically discover tools from the server:

```json
{
  "discoverTools": true
}
```

This queries the MCP server's `/tools` endpoint and populates a dropdown.

**Manual Tool Selection:**

```json
{
  "toolName": "generate_report",
  "parameters": {
    "date": "{{DateTime.now().toISODate()}}",
    "metrics": ["revenue", "users"],
    "format": "json"
  }
}
```

#### 4. Parameters

Map workflow data to tool parameters using n8n expressions:

```json
{
  "parameters": {
    "customerId": "{{$json.customerId}}",
    "startDate": "{{$json.filters.startDate}}",
    "endDate": "{{$json.filters.endDate}}",
    "includeDetails": true,
    "format": "json"
  }
}
```

**Dynamic Parameters:**

```javascript
// Function node before MCP Client Tool
const params = {
  query: $json.searchTerm,
  filters: {},
  limit: 10
};

// Add optional filters if present
if ($json.category) {
  params.filters.category = $json.category;
}

if ($json.dateRange) {
  params.filters.startDate = $json.dateRange.start;
  params.filters.endDate = $json.dateRange.end;
}

return { json: params };
```

```json
// MCP Client Tool configuration
{
  "parameters": "={{$json}}"
}
```

---

## Connecting to External MCP Servers

### Example 1: Claude API via MCP

**Use Case:** Call Claude for text analysis

**MCP Server:** Anthropic's Claude MCP server

**Setup:**

```json
{
  "serverUrl": "https://api.anthropic.com/mcp/v1",
  "authentication": {
    "type": "apiKey",
    "headerName": "x-api-key",
    "apiKey": "{{$credentials.anthropicApiKey}}"
  },
  "toolName": "analyze_text",
  "parameters": {
    "text": "{{$json.content}}",
    "task": "sentiment_analysis",
    "model": "claude-sonnet-4"
  }
}
```

**Workflow:**

```
1. Webhook: Receive text content
   ↓
2. MCP Client Tool: Analyze with Claude
   ↓
3. Function: Process results
   ↓
4. Database: Store analysis
```

### Example 2: Analytics Service

**Use Case:** Generate daily analytics report

**MCP Server:** Internal analytics service

**Setup:**

```json
{
  "serverUrl": "https://analytics.company.com/mcp",
  "authentication": {
    "type": "bearer",
    "token": "{{$credentials.analyticsToken}}"
  },
  "toolName": "generate_daily_report",
  "parameters": {
    "date": "{{DateTime.now().minus({ days: 1 }).toISODate()}}",
    "metrics": ["revenue", "users", "engagement", "churn"],
    "format": "json",
    "includeCharts": true
  }
}
```

**Workflow:**

```
1. Schedule: Every day at 9am
   ↓
2. Function: Prepare date parameters
   ↓
3. MCP Client Tool: Generate report
   ↓
4. Email: Send report to stakeholders
```

### Example 3: Custom LLM Service

**Use Case:** Classify support tickets

**MCP Server:** Internal fine-tuned LLM

**Setup:**

```json
{
  "serverUrl": "https://ml.company.com/mcp",
  "authentication": {
    "type": "apiKey",
    "headerName": "X-ML-API-Key",
    "apiKey": "{{$credentials.mlApiKey}}"
  },
  "toolName": "classify_ticket",
  "parameters": {
    "title": "{{$json.ticketTitle}}",
    "description": "{{$json.ticketDescription}}",
    "model": "support-classifier-v2",
    "returnProbabilities": true
  }
}
```

**Workflow:**

```
1. Jira Webhook: New ticket created
   ↓
2. MCP Client Tool: Classify ticket
   ↓
3. Switch: Route by classification
   ├─→ Bug: Assign to engineering
   ├─→ Feature: Assign to product
   └─→ Question: Assign to support
```

---

## Common Integration Patterns

### Pattern 1: Sequential MCP Calls

Call multiple MCP tools in sequence, passing results forward.

**Scenario:** Content creation pipeline

```
1. MCP: Research Tool
   → Gathers information on topic
   ↓
2. MCP: Writing Tool
   → Generates draft using research
   ↓
3. MCP: SEO Tool
   → Optimizes content for search
   ↓
4. CMS: Publish
```

**Implementation:**

```
┌─────────────────────────────────────────────┐
│ 1. MCP Client: Research                     │
│    Server: research-service.com/mcp         │
│    Tool: gather_information                 │
│    Params: { topic, depth: "comprehensive" }│
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 2. Function: Extract Research Data          │
│    Code:                                    │
│      return {                               │
│        json: {                              │
│          topic: $json.topic,                │
│          facts: $json.findings.facts,       │
│          sources: $json.findings.sources    │
│        }                                    │
│      };                                     │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 3. MCP Client: Content Generation           │
│    Server: writer-service.com/mcp           │
│    Tool: generate_article                   │
│    Params: {                                │
│      topic: {{$json.topic}},                │
│      research: {{$json.facts}},             │
│      tone: "professional",                  │
│      length: 1500                           │
│    }                                        │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 4. MCP Client: SEO Optimization             │
│    Server: seo-service.com/mcp              │
│    Tool: optimize_content                   │
│    Params: {                                │
│      content: {{$json.article}},            │
│      keywords: ["ai", "automation"],        │
│      targetLength: 1500                     │
│    }                                        │
└─────────────────────────────────────────────┘
```

### Pattern 2: Parallel MCP Calls

Execute multiple MCP calls simultaneously for efficiency.

**Scenario:** Data enrichment from multiple sources

```
Input: Customer ID
     ↓
┌────────────┬────────────┬────────────┐
│ MCP: CRM   │ MCP: Email │ MCP: Social│
│ Get orders │ Get stats  │ Get profile│
└────────────┴────────────┴────────────┘
     │            │            │
     └────────────┴────────────┘
                  ↓
          Combine Results
```

**Implementation:**

```
┌─────────────────────────────────────────────┐
│ 1. Set: Customer ID from input               │
│    customerId: {{$json.customerId}}         │
└─────────────────────────────────────────────┘
                    ↓
          ┌─────────┴─────────┐
          ↓                   ↓
┌──────────────────┐  ┌──────────────────┐
│ 2a. MCP: Orders  │  │ 2b. MCP: Email   │
│ Server: crm/mcp  │  │ Server: mail/mcp │
│ Tool: get_orders │  │ Tool: get_stats  │
│ Params:          │  │ Params:          │
│   customerId     │  │   customerId     │
└──────────────────┘  └──────────────────┘
          │                   │
          └─────────┬─────────┘
                    ↓
          ┌─────────┴─────────┐
          ↓                   ↓
┌──────────────────┐  ┌──────────────────┐
│ 2c. MCP: Social  │  │ 2d. MCP: Support │
│ Server: soc/mcp  │  │ Server: sup/mcp  │
│ Tool: get_profile│  │ Tool: get_tickets│
│ Params:          │  │ Params:          │
│   customerId     │  │   customerId     │
└──────────────────┘  └──────────────────┘
          │                   │
          └─────────┴─────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 3. Function: Merge All Data                 │
│    Code:                                    │
│      const items = $input.all();            │
│      return {                               │
│        json: {                              │
│          customerId: '12345',               │
│          orders: items[0].json,             │
│          emailStats: items[1].json,         │
│          socialProfile: items[2].json,      │
│          supportTickets: items[3].json      │
│        }                                    │
│      };                                     │
└─────────────────────────────────────────────┘
```

**Note:** Use n8n's "Execute Once for All Items" mode to process all parallel results together.

### Pattern 3: Conditional MCP Routing

Route to different MCP servers based on conditions.

**Scenario:** Multi-model AI routing

```
Input: Task complexity
     ↓
  Decision
     ↓
├─→ Simple: Call fast model (GPT-3.5)
├─→ Medium: Call balanced model (GPT-4)
└─→ Complex: Call advanced model (Claude Sonnet 4)
```

**Implementation:**

```
┌─────────────────────────────────────────────┐
│ 1. Function: Analyze Task Complexity        │
│    Code:                                    │
│      const taskLength = $json.task.length;  │
│      const hasCodeSnippets = /```/.test(    │
│        $json.task                           │
│      );                                     │
│                                             │
│      let complexity;                        │
│      if (taskLength < 500 && !hasCodeSnippets) {│
│        complexity = 'simple';               │
│      } else if (taskLength < 2000) {        │
│        complexity = 'medium';               │
│      } else {                               │
│        complexity = 'complex';              │
│      }                                      │
│                                             │
│      return {                               │
│        json: {                              │
│          task: $json.task,                  │
│          complexity                         │
│        }                                    │
│      };                                     │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 2. Switch: Route by Complexity              │
│    Cases:                                   │
│      - complexity === 'simple' → Branch 1   │
│      - complexity === 'medium' → Branch 2   │
│      - complexity === 'complex' → Branch 3  │
└─────────────────────────────────────────────┘
          │            │            │
          ↓            ↓            ↓
    ┌─────────┐  ┌─────────┐  ┌─────────┐
    │ MCP:    │  │ MCP:    │  │ MCP:    │
    │ GPT-3.5 │  │ GPT-4   │  │ Claude  │
    └─────────┘  └─────────┘  └─────────┘
          │            │            │
          └────────────┴────────────┘
                    ↓
          Process response
```

### Pattern 4: Retry with Fallback

Implement retry logic with fallback to alternative MCP servers.

**Scenario:** AI service with fallback

```
1. Try primary AI service
   ↓
2. If fails → Retry 3 times
   ↓
3. Still fails → Fall back to secondary service
   ↓
4. Return result or error
```

**Implementation:**

```javascript
// Function node: MCP with Retry Logic
const MAX_RETRIES = 3;
const PRIMARY_SERVER = 'https://primary-ai.com/mcp';
const FALLBACK_SERVER = 'https://fallback-ai.com/mcp';

async function callMCPWithRetry(serverUrl, tool, params, retries = 0) {
  try {
    const response = await fetch(`${serverUrl}/tools/${tool}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.MCP_TOKEN}`
      },
      body: JSON.stringify(params)
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    return await response.json();

  } catch (error) {
    console.log(`Attempt ${retries + 1} failed:`, error.message);

    if (retries < MAX_RETRIES) {
      // Exponential backoff
      await new Promise(resolve =>
        setTimeout(resolve, 1000 * Math.pow(2, retries))
      );
      return callMCPWithRetry(serverUrl, tool, params, retries + 1);
    }

    throw error;
  }
}

try {
  // Try primary server
  const result = await callMCPWithRetry(
    PRIMARY_SERVER,
    'analyze_text',
    { text: $json.content }
  );

  return { json: { result, source: 'primary' } };

} catch (primaryError) {
  console.log('Primary server failed, trying fallback...');

  try {
    // Fall back to secondary server
    const result = await callMCPWithRetry(
      FALLBACK_SERVER,
      'analyze_text',
      { text: $json.content }
    );

    return { json: { result, source: 'fallback' } };

  } catch (fallbackError) {
    throw new Error('Both primary and fallback servers failed');
  }
}
```

### Pattern 5: Streaming Responses

Handle streaming responses from MCP servers (for long-running operations).

**Scenario:** Real-time text generation

```
1. Start MCP tool call
   ↓
2. Receive streaming response
   ↓
3. Process chunks as they arrive
   ↓
4. Accumulate final result
```

**Implementation:**

```javascript
// Function node: Stream Handler
async function handleStreamingMCP(serverUrl, tool, params) {
  const response = await fetch(`${serverUrl}/tools/${tool}/stream`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.MCP_TOKEN}`
    },
    body: JSON.stringify(params)
  });

  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let fullText = '';
  let chunks = [];

  while (true) {
    const { done, value } = await reader.read();

    if (done) break;

    const chunk = decoder.decode(value, { stream: true });
    chunks.push(chunk);
    fullText += chunk;

    // Optional: Send progress updates
    console.log(`Received ${fullText.length} characters so far...`);
  }

  return {
    json: {
      fullText,
      chunks,
      chunkCount: chunks.length
    }
  };
}

return await handleStreamingMCP(
  'https://ai-service.com/mcp',
  'generate_text',
  { prompt: $json.prompt, maxTokens: 2000 }
);
```

---

## Error Handling

### Graceful Error Recovery

```javascript
// Function node: MCP Call with Error Handling
async function safeMCPCall(serverUrl, tool, params) {
  try {
    const response = await fetch(`${serverUrl}/tools/${tool}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.MCP_TOKEN}`
      },
      body: JSON.stringify(params),
      timeout: 30000  // 30 second timeout
    });

    if (!response.ok) {
      const errorBody = await response.json();
      throw new Error(
        `MCP Error (${response.status}): ${errorBody.error?.message || 'Unknown error'}`
      );
    }

    const result = await response.json();

    return {
      json: {
        success: true,
        data: result,
        timestamp: new Date().toISOString()
      }
    };

  } catch (error) {
    console.error('MCP call failed:', error);

    // Log to monitoring service
    await fetch('https://monitoring.company.com/api/errors', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        service: 'n8n-mcp-client',
        error: error.message,
        stack: error.stack,
        context: { serverUrl, tool, params }
      })
    });

    // Return error in structured format
    return {
      json: {
        success: false,
        error: {
          message: error.message,
          code: error.code || 'MCP_ERROR',
          serverUrl,
          tool,
          timestamp: new Date().toISOString()
        }
      }
    };
  }
}

return await safeMCPCall(
  'https://ai-service.com/mcp',
  'analyze_text',
  { text: $json.content }
);
```

### Error Types and Handling

```javascript
// Comprehensive error handling
function handleMCPError(error, context) {
  const errorTypes = {
    'TIMEOUT': {
      retry: true,
      backoff: 2000,
      message: 'Request timed out, retrying...'
    },
    'RATE_LIMIT': {
      retry: true,
      backoff: 60000,  // Wait 1 minute
      message: 'Rate limit hit, waiting before retry'
    },
    'AUTHENTICATION': {
      retry: false,
      message: 'Authentication failed, check credentials'
    },
    'INVALID_PARAMETERS': {
      retry: false,
      message: 'Invalid parameters provided'
    },
    'SERVER_ERROR': {
      retry: true,
      backoff: 5000,
      message: 'Server error, will retry'
    }
  };

  const errorType = error.code || 'UNKNOWN';
  const config = errorTypes[errorType] || { retry: false };

  return {
    shouldRetry: config.retry,
    backoffMs: config.backoff || 0,
    userMessage: config.message,
    technicalDetails: {
      error: error.message,
      code: errorType,
      context
    }
  };
}
```

---

## Authentication Methods

### API Key Authentication

```json
{
  "authentication": {
    "type": "apiKey",
    "headerName": "X-API-Key",
    "apiKey": "{{$credentials.mcpApiKey}}"
  }
}
```

**Best Practice:** Store API key in n8n credentials:

1. Go to **Credentials** in n8n
2. Create new **API Key** credential
3. Name: "MCP Service API Key"
4. Value: Your API key
5. Reference in node: `{{$credentials.mcpServiceApiKey}}`

### Bearer Token Authentication

```json
{
  "authentication": {
    "type": "bearer",
    "token": "{{$credentials.mcpBearerToken}}"
  }
}
```

### OAuth 2.0 Authentication

**Setup OAuth Credential:**

1. Create OAuth2 credential in n8n
2. Configure:
   - Authorization URL
   - Access Token URL
   - Client ID
   - Client Secret
   - Scopes

**Use in MCP Client:**

```json
{
  "authentication": {
    "type": "oauth2",
    "credentials": "{{$credentials.mcpOAuth2}}"
  }
}
```

### Custom Authentication Headers

```javascript
// Function node: Add custom auth headers
const customHeaders = {
  'X-Client-ID': process.env.MCP_CLIENT_ID,
  'X-Client-Secret': process.env.MCP_CLIENT_SECRET,
  'X-Timestamp': Date.now().toString(),
  'X-Signature': generateSignature($json)
};

return {
  json: {
    ...$json,
    customHeaders
  }
};

function generateSignature(data) {
  const crypto = require('crypto');
  const secret = process.env.MCP_SECRET;
  return crypto
    .createHmac('sha256', secret)
    .update(JSON.stringify(data))
    .digest('hex');
}
```

---

## Performance Optimization

### Connection Pooling

```javascript
// Global connection pool for MCP servers
const connectionPool = new Map();

function getConnection(serverUrl) {
  if (!connectionPool.has(serverUrl)) {
    connectionPool.set(serverUrl, {
      url: serverUrl,
      activeRequests: 0,
      lastUsed: Date.now()
    });
  }

  const connection = connectionPool.get(serverUrl);
  connection.activeRequests++;
  connection.lastUsed = Date.now();

  return connection;
}

function releaseConnection(serverUrl) {
  const connection = connectionPool.get(serverUrl);
  if (connection) {
    connection.activeRequests--;
  }
}

// Cleanup idle connections (run periodically)
function cleanupConnections() {
  const now = Date.now();
  const maxIdleTime = 5 * 60 * 1000;  // 5 minutes

  for (const [url, connection] of connectionPool.entries()) {
    if (
      connection.activeRequests === 0 &&
      now - connection.lastUsed > maxIdleTime
    ) {
      connectionPool.delete(url);
    }
  }
}
```

### Response Caching

```javascript
// Simple in-memory cache
const cache = new Map();
const CACHE_TTL = 5 * 60 * 1000;  // 5 minutes

function getCacheKey(serverUrl, tool, params) {
  return `${serverUrl}:${tool}:${JSON.stringify(params)}`;
}

async function cachedMCPCall(serverUrl, tool, params) {
  const cacheKey = getCacheKey(serverUrl, tool, params);
  const cached = cache.get(cacheKey);

  if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
    console.log('Cache hit:', cacheKey);
    return { json: cached.data };
  }

  console.log('Cache miss:', cacheKey);
  const result = await callMCP(serverUrl, tool, params);

  cache.set(cacheKey, {
    data: result,
    timestamp: Date.now()
  });

  return { json: result };
}
```

### Batch Processing

```javascript
// Batch multiple MCP calls
async function batchMCPCalls(serverUrl, calls) {
  const batchSize = 10;
  const results = [];

  for (let i = 0; i < calls.length; i += batchSize) {
    const batch = calls.slice(i, i + batchSize);

    const batchResults = await Promise.all(
      batch.map(call =>
        callMCP(serverUrl, call.tool, call.params)
      )
    );

    results.push(...batchResults);
  }

  return { json: results };
}

// Usage
const calls = [
  { tool: 'analyze_text', params: { text: 'text1' } },
  { tool: 'analyze_text', params: { text: 'text2' } },
  { tool: 'analyze_text', params: { text: 'text3' } }
  // ... more calls
];

return await batchMCPCalls('https://ai-service.com/mcp', calls);
```

---

## Production Best Practices

### 1. Centralized MCP Configuration

Create a configuration management workflow:

```javascript
// Workflow: MCP Configuration Manager
const MCP_SERVERS = {
  analytics: {
    url: 'https://analytics.company.com/mcp',
    auth: { type: 'apiKey', key: process.env.ANALYTICS_API_KEY },
    timeout: 60000,
    retries: 3
  },
  ai: {
    url: 'https://ai.company.com/mcp',
    auth: { type: 'bearer', token: process.env.AI_TOKEN },
    timeout: 30000,
    retries: 2
  },
  crm: {
    url: 'https://crm.company.com/mcp',
    auth: { type: 'oauth2', credentials: 'crmOAuth' },
    timeout: 45000,
    retries: 3
  }
};

function getMCPConfig(serverName) {
  return MCP_SERVERS[serverName] || null;
}
```

### 2. Monitoring and Logging

```javascript
// Comprehensive logging
async function monitoredMCPCall(serverUrl, tool, params) {
  const startTime = Date.now();
  const callId = generateUUID();

  console.log(`[${callId}] MCP Call Started:`, {
    server: serverUrl,
    tool,
    timestamp: new Date().toISOString()
  });

  try {
    const result = await callMCP(serverUrl, tool, params);
    const duration = Date.now() - startTime;

    console.log(`[${callId}] MCP Call Succeeded:`, {
      duration: `${duration}ms`,
      responseSize: JSON.stringify(result).length
    });

    // Send metrics to monitoring
    await sendMetric('mcp_call_success', {
      server: serverUrl,
      tool,
      duration
    });

    return { json: result };

  } catch (error) {
    const duration = Date.now() - startTime;

    console.error(`[${callId}] MCP Call Failed:`, {
      error: error.message,
      duration: `${duration}ms`
    });

    // Send error to monitoring
    await sendMetric('mcp_call_error', {
      server: serverUrl,
      tool,
      error: error.message,
      duration
    });

    throw error;
  }
}
```

### 3. Circuit Breaker Pattern

```javascript
// Circuit breaker to prevent cascading failures
class CircuitBreaker {
  constructor(threshold = 5, timeout = 60000) {
    this.failures = 0;
    this.threshold = threshold;
    this.timeout = timeout;
    this.state = 'CLOSED';  // CLOSED, OPEN, HALF_OPEN
    this.nextAttempt = Date.now();
  }

  async call(fn) {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new Error('Circuit breaker is OPEN');
      }
      this.state = 'HALF_OPEN';
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  onSuccess() {
    this.failures = 0;
    this.state = 'CLOSED';
  }

  onFailure() {
    this.failures++;
    if (this.failures >= this.threshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.timeout;
    }
  }
}

// Usage
const breaker = new CircuitBreaker();

await breaker.call(() =>
  callMCP('https://unstable-service.com/mcp', 'tool', params)
);
```

---

## Quick Reference

### Common MCP Client Configurations

**Basic Call:**
```json
{
  "serverUrl": "https://service.com/mcp",
  "toolName": "tool_name",
  "parameters": { "param": "value" }
}
```

**With Authentication:**
```json
{
  "serverUrl": "https://service.com/mcp",
  "toolName": "tool_name",
  "parameters": { "param": "value" },
  "authentication": {
    "type": "apiKey",
    "apiKey": "{{$credentials.apiKey}}"
  }
}
```

**With Timeout:**
```json
{
  "serverUrl": "https://service.com/mcp",
  "toolName": "tool_name",
  "parameters": { "param": "value" },
  "timeout": 60000
}
```

---

## Next Steps

1. **Start Simple**: Connect to a single MCP server
2. **Add Error Handling**: Implement retry and fallback logic
3. **Optimize**: Add caching and connection pooling
4. **Monitor**: Set up logging and metrics
5. **Scale**: Implement circuit breakers and load balancing

**Related Documentation:**
- **SKILL.md**: Complete MCP orchestration reference
- **mcp-server-setup.md**: Exposing n8n as MCP server
- **EXAMPLES.md**: 15+ practical MCP examples

**External Resources:**
- n8n MCP Client Docs: https://docs.n8n.io/integrations/builtin/core-nodes/mcp/
- MCP Specification: https://modelcontextprotocol.io
- n8n Community: https://community.n8n.io
