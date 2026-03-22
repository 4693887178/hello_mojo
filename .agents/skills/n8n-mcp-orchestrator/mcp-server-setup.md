# MCP Server Setup Guide - n8n

Complete guide for setting up n8n as an MCP (Model Context Protocol) server to expose workflows as AI agent tools.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [MCP Server Trigger Configuration](#mcp-server-trigger-configuration)
4. [Tool Definition Best Practices](#tool-definition-best-practices)
5. [Authentication and Security](#authentication-and-security)
6. [Deployment Patterns](#deployment-patterns)
7. [Testing MCP Servers](#testing-mcp-servers)
8. [Monitoring and Debugging](#monitoring-and-debugging)
9. [Production Checklist](#production-checklist)

---

## Overview

When you configure an n8n workflow with an **MCP Server Trigger** node, that workflow becomes a **tool** that AI agents (like Claude Code or Claude Desktop) can invoke via the Model Context Protocol.

**Key Benefits:**

- Expose any n8n workflow as an AI-callable tool
- No additional coding required
- Built-in authentication and parameter validation
- Leverage n8n's 400+ integrations
- Production-ready scaling and monitoring

**Architecture:**

```
AI Agent (Claude Code)
        ↓
    MCP Protocol
        ↓
n8n MCP Server Endpoint
        ↓
MCP Server Trigger (workflow entry point)
        ↓
Workflow Execution (your business logic)
        ↓
Response returned to AI Agent
```

---

## Prerequisites

### n8n Installation

**Option 1: Docker (Recommended for Development)**

```bash
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -e N8N_MCP_ENABLED=true \
  -e N8N_MCP_PORT=8080 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n:latest
```

**Option 2: npm**

```bash
npm install n8n -g
N8N_MCP_ENABLED=true n8n start
```

**Option 3: n8n Cloud**

- MCP support is built-in
- No configuration needed
- Access via cloud dashboard

### Version Requirements

- **n8n**: v1.30.0 or later (MCP support added in v1.30)
- **Node.js**: v18 or later
- **Docker**: v20 or later (if using Docker)

### Environment Variables

```bash
# Required for MCP server functionality
export N8N_MCP_ENABLED=true
export N8N_MCP_PORT=8080  # Default MCP server port

# Optional: Security settings
export N8N_MCP_AUTH_TYPE=apiKey  # or oauth2, none
export N8N_MCP_API_KEY=your-secret-key

# Optional: CORS and networking
export N8N_MCP_CORS_ENABLED=true
export N8N_MCP_ALLOWED_ORIGINS=https://claude.ai,https://your-app.com
```

---

## MCP Server Trigger Configuration

### Adding MCP Server Trigger to Workflow

1. **Create New Workflow** in n8n
2. **Search for "MCP Server Trigger"** in node palette
3. **Drag and Drop** to canvas as first node
4. **Configure tool settings** (detailed below)

### Tool Configuration Fields

#### 1. Tool Name (Required)

- **Format**: lowercase, underscores for spaces
- **Examples**: `create_task`, `send_email`, `query_database`
- **Best Practices**:
  - Use verb-noun format: `create_`, `get_`, `update_`, `delete_`
  - Be specific: `create_support_ticket` vs. `create_ticket`
  - Avoid abbreviations: `create_customer` vs. `create_cust`

```json
{
  "toolName": "create_support_ticket"
}
```

#### 2. Tool Description (Required)

Clear, concise description that helps AI understand when to use the tool.

**Structure:**
```
[Action] [Object] [with optional details about parameters/behavior]
```

**Examples:**

```json
{
  "description": "Create a support ticket in Jira with automatic team notification and priority routing"
}
```

```json
{
  "description": "Query customer database by email, customer ID, or status. Returns customer profile with order history and support tickets."
}
```

**Best Practices:**
- Describe what the tool does, not how
- Mention key capabilities and parameters
- Keep under 200 characters
- Use action verbs (create, get, update, send, analyze)

#### 3. Parameters Schema (JSON Schema)

Define the input parameters your workflow expects.

**Basic Structure:**

```json
{
  "type": "object",
  "properties": {
    "parameterName": {
      "type": "string | number | boolean | array | object",
      "description": "Clear description of what this parameter does",
      "enum": ["option1", "option2"],  // Optional: restrict to specific values
      "default": "defaultValue"  // Optional: default value
    }
  },
  "required": ["requiredParam1", "requiredParam2"]
}
```

**Example: Task Creation Tool**

```json
{
  "type": "object",
  "properties": {
    "title": {
      "type": "string",
      "description": "Brief, descriptive title for the task"
    },
    "description": {
      "type": "string",
      "description": "Detailed description of what needs to be done"
    },
    "dueDate": {
      "type": "string",
      "description": "Due date in ISO 8601 format (e.g., 2025-10-25T14:00:00Z)"
    },
    "priority": {
      "type": "string",
      "enum": ["low", "medium", "high", "urgent"],
      "default": "medium",
      "description": "Task priority level"
    },
    "assignee": {
      "type": "string",
      "description": "Email address of person to assign the task to"
    },
    "tags": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "description": "Optional tags for categorization"
    }
  },
  "required": ["title"]
}
```

**Parameter Types Reference:**

| Type    | Description | Example |
|---------|-------------|---------|
| string  | Text value | "Hello World" |
| number  | Numeric value | 42, 3.14 |
| boolean | True/false | true, false |
| array   | List of values | ["tag1", "tag2"] |
| object  | Nested object | { "key": "value" } |
| enum    | Restricted to specific values | "low" \| "medium" \| "high" |

#### 4. Authentication Configuration (Optional)

**None (Default):**
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
    "requiredScopes": ["workflows:execute"]
  }
}
```

**OAuth 2.0:**
```json
{
  "authentication": {
    "type": "oauth2",
    "authorizationUrl": "https://auth.company.com/oauth/authorize",
    "tokenUrl": "https://auth.company.com/oauth/token",
    "scopes": ["workflows:read", "workflows:execute"],
    "clientId": "${OAUTH_CLIENT_ID}",
    "clientSecret": "${OAUTH_CLIENT_SECRET}"
  }
}
```

### Complete MCP Server Trigger Example

```json
{
  "toolName": "create_support_ticket",
  "description": "Create a support ticket in Jira with automatic priority routing, team notification, and customer email confirmation",
  "parameters": {
    "type": "object",
    "properties": {
      "title": {
        "type": "string",
        "description": "Brief issue title (max 100 chars)"
      },
      "description": {
        "type": "string",
        "description": "Detailed problem description with steps to reproduce"
      },
      "severity": {
        "type": "string",
        "enum": ["low", "medium", "high", "critical"],
        "default": "medium",
        "description": "Issue severity level"
      },
      "category": {
        "type": "string",
        "enum": ["bug", "feature_request", "question", "other"],
        "description": "Issue category"
      },
      "customerEmail": {
        "type": "string",
        "description": "Customer email for updates"
      },
      "attachments": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "url": {"type": "string"},
            "filename": {"type": "string"}
          }
        },
        "description": "Optional file attachments"
      }
    },
    "required": ["title", "description", "customerEmail"]
  },
  "authentication": {
    "type": "apiKey",
    "headerName": "X-API-Key"
  }
}
```

---

## Tool Definition Best Practices

### 1. Naming Conventions

**DO:**
- ✅ `create_task` - Clear action + object
- ✅ `get_customer_by_email` - Specific and descriptive
- ✅ `send_notification` - Action-oriented
- ✅ `analyze_sentiment` - Clear purpose

**DON'T:**
- ❌ `task` - Too vague
- ❌ `getCustByEmail` - Camel case, abbreviations
- ✅ `do_stuff` - Not descriptive
- ❌ `tool1` - Meaningless

### 2. Description Guidelines

**Structure: Action + Object + Key Details**

**Good Examples:**

```
"Create a task in Todoist with title, description, due date, and priority. Returns task ID and URL."

"Query customer database by email or ID. Returns profile, order history, and support tickets."

"Send templated email to one or more recipients. Supports welcome, notification, and alert templates."

"Analyze text sentiment using Claude API. Returns sentiment score (-1 to +1) and emotion labels."
```

**Poor Examples:**

```
"Creates tasks"  // Too brief
"This tool is for creating things in the system"  // Too vague
"Use this when you want to make a task or something"  // Unprofessional
```

### 3. Parameter Design

**Required vs. Optional:**

- Mark as `required` only if workflow cannot function without it
- Provide sensible `default` values for optional parameters
- Use `enum` to restrict to valid values

**Example:**

```json
{
  "priority": {
    "type": "string",
    "enum": ["low", "medium", "high", "urgent"],
    "default": "medium",  // Sensible default
    "description": "Task priority level"
  },
  "dueDate": {
    "type": "string",
    "description": "Optional due date (ISO 8601 format)"
    // Not required - can be added later
  }
}
```

### 4. Response Format

Always return structured, consistent responses:

**Success Response:**

```json
{
  "success": true,
  "data": {
    "id": "12345",
    "url": "https://app.example.com/resource/12345",
    "createdAt": "2025-10-20T10:30:00Z"
  },
  "message": "Resource created successfully"
}
```

**Error Response:**

```json
{
  "success": false,
  "error": {
    "code": "INVALID_PARAMETER",
    "message": "Email address is invalid",
    "field": "customerEmail",
    "value": "not-an-email"
  }
}
```

---

## Authentication and Security

### API Key Authentication

**Setup:**

1. **Generate API Key** in n8n settings
2. **Configure MCP Server Trigger:**

```json
{
  "authentication": {
    "type": "apiKey",
    "headerName": "X-API-Key",
    "validateKey": true
  }
}
```

3. **Validate in Workflow:**

```javascript
// Function node after MCP trigger
const apiKey = $input.headers['x-api-key'];
const validKeys = process.env.VALID_API_KEYS.split(',');

if (!validKeys.includes(apiKey)) {
  throw new Error('Invalid API key');
}

return { json: $input.item.json };
```

4. **Use in Claude Code:**

```json
{
  "mcpServers": {
    "n8n": {
      "url": "https://n8n.company.com/mcp",
      "apiKey": "${N8N_API_KEY}"
    }
  }
}
```

### OAuth 2.0 Authentication

**Setup with Auth0:**

1. **Create OAuth App** in Auth0
2. **Configure MCP Server Trigger:**

```json
{
  "authentication": {
    "type": "oauth2",
    "authorizationUrl": "https://your-domain.auth0.com/authorize",
    "tokenUrl": "https://your-domain.auth0.com/oauth/token",
    "scopes": ["openid", "profile", "workflow:execute"],
    "clientId": "${OAUTH_CLIENT_ID}",
    "clientSecret": "${OAUTH_CLIENT_SECRET}"
  }
}
```

3. **Validate Token in Workflow:**

```javascript
// Function node after MCP trigger
const token = $input.headers['authorization'].replace('Bearer ', '');

// Verify token with Auth0
const response = await fetch('https://your-domain.auth0.com/userinfo', {
  headers: { 'Authorization': `Bearer ${token}` }
});

if (!response.ok) {
  throw new Error('Invalid or expired token');
}

const user = await response.json();
return { json: { ...$ input.item.json, user } };
```

### IP Whitelisting

```javascript
// Function node: Validate IP
const clientIP = $input.headers['x-forwarded-for'] ||
                 $input.headers['x-real-ip'];

const allowedIPs = [
  '10.0.0.0/8',
  '192.168.1.100',
  '203.0.113.45'
];

if (!isIPAllowed(clientIP, allowedIPs)) {
  throw new Error('IP not whitelisted');
}
```

### Rate Limiting

```javascript
// Redis-based rate limiting
const clientId = $input.headers['x-client-id'];
const key = `ratelimit:${clientId}`;

// Check Redis
const count = await redis.incr(key);
await redis.expire(key, 60); // 1 minute window

if (count > 100) {  // 100 requests per minute
  throw new Error('Rate limit exceeded');
}
```

---

## Deployment Patterns

### Development Environment

```yaml
# docker-compose.dev.yml
version: '3.8'
services:
  n8n:
    image: n8nio/n8n:latest
    ports:
      - "5678:5678"  # UI
      - "8080:8080"  # MCP server
    environment:
      - N8N_MCP_ENABLED=true
      - N8N_MCP_PORT=8080
      - N8N_MCP_AUTH_TYPE=none
    volumes:
      - ./n8n-data:/home/node/.n8n
```

```bash
docker-compose -f docker-compose.dev.yml up
```

### Production Environment (Docker)

```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  n8n:
    image: n8nio/n8n:latest
    restart: unless-stopped
    ports:
      - "5678:5678"
      - "8080:8080"
    environment:
      - N8N_MCP_ENABLED=true
      - N8N_MCP_PORT=8080
      - N8N_MCP_AUTH_TYPE=apiKey
      - N8N_MCP_API_KEY=${N8N_API_KEY}
      - N8N_MCP_CORS_ENABLED=true
      - N8N_MCP_ALLOWED_ORIGINS=${ALLOWED_ORIGINS}
      - N8N_ENCRYPTION_KEY=${ENCRYPTION_KEY}
    volumes:
      - n8n-data:/home/node/.n8n
    networks:
      - n8n-network

  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - n8n
    networks:
      - n8n-network

volumes:
  n8n-data:

networks:
  n8n-network:
```

**nginx.conf:**

```nginx
server {
    listen 443 ssl http2;
    server_name mcp.company.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    # MCP endpoint
    location /mcp {
        proxy_pass http://n8n:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # n8n UI (optional)
    location / {
        proxy_pass http://n8n:5678;
        proxy_set_header Host $host;
    }
}
```

### Kubernetes Deployment

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: n8n-mcp-server
  namespace: automation
spec:
  replicas: 3
  selector:
    matchLabels:
      app: n8n
  template:
    metadata:
      labels:
        app: n8n
    spec:
      containers:
      - name: n8n
        image: n8nio/n8n:latest
        ports:
        - containerPort: 5678
          name: http
        - containerPort: 8080
          name: mcp
        env:
        - name: N8N_MCP_ENABLED
          value: "true"
        - name: N8N_MCP_PORT
          value: "8080"
        - name: N8N_MCP_AUTH_TYPE
          value: "apiKey"
        - name: N8N_MCP_API_KEY
          valueFrom:
            secretKeyRef:
              name: n8n-secrets
              key: mcp-api-key
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /healthz
            port: 5678
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /healthz
            port: 5678
          initialDelaySeconds: 10
          periodSeconds: 5
```

```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: n8n-mcp-service
  namespace: automation
spec:
  selector:
    app: n8n
  ports:
  - name: http
    port: 5678
    targetPort: 5678
  - name: mcp
    port: 8080
    targetPort: 8080
  type: LoadBalancer
```

---

## Testing MCP Servers

### Manual Testing with cURL

```bash
# Test MCP endpoint availability
curl https://n8n.company.com/mcp/tools

# Invoke tool without auth (should fail if auth enabled)
curl -X POST https://n8n.company.com/mcp/tools/create_task \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test task",
    "description": "Testing MCP server"
  }'

# Invoke tool with API key
curl -X POST https://n8n.company.com/mcp/tools/create_task \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{
    "title": "Test task",
    "description": "Testing MCP server",
    "priority": "high"
  }'
```

### Testing with Claude Code

```json
// Add to mcp_config.json
{
  "mcpServers": {
    "n8n-test": {
      "url": "https://n8n.company.com/mcp",
      "apiKey": "test-api-key"
    }
  }
}
```

```
# In Claude Code chat
User: "Test the create_task tool with a test task"

Claude Code:
→ Invokes: create_task({
    title: "Test Task",
    description: "Testing MCP server integration"
  })
← Response: { success: true, taskId: "12345" }
```

### Automated Testing

```javascript
// test-mcp-server.js
const axios = require('axios');

const MCP_URL = 'https://n8n.company.com/mcp';
const API_KEY = process.env.N8N_API_KEY;

async function testMCPTool(toolName, parameters) {
  try {
    const response = await axios.post(
      `${MCP_URL}/tools/${toolName}`,
      parameters,
      {
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': API_KEY
        }
      }
    );

    console.log(`✅ ${toolName}: SUCCESS`);
    console.log('Response:', response.data);
    return response.data;
  } catch (error) {
    console.error(`❌ ${toolName}: FAILED`);
    console.error('Error:', error.response?.data || error.message);
    throw error;
  }
}

// Run tests
async function runTests() {
  await testMCPTool('create_task', {
    title: 'Test Task',
    description: 'Automated test'
  });

  await testMCPTool('send_email', {
    to: 'test@example.com',
    template: 'notification',
    data: { message: 'Test' }
  });
}

runTests();
```

---

## Monitoring and Debugging

### Workflow Execution Logs

Add logging nodes to your workflows:

```javascript
// Function node: Log MCP invocation
const logEntry = {
  timestamp: new Date().toISOString(),
  tool: 'create_task',
  parameters: $input.item.json,
  clientId: $input.headers['x-client-id'] || 'unknown',
  ipAddress: $input.headers['x-real-ip']
};

console.log('[MCP] Tool invoked:', JSON.stringify(logEntry));

// Send to logging service (optional)
await fetch('https://logs.company.com/api/log', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(logEntry)
});

return { json: $input.item.json };
```

### Prometheus Metrics

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'n8n'
    static_configs:
      - targets: ['n8n:5678']
```

**Key Metrics:**
- `n8n_workflow_executions_total` - Total executions
- `n8n_workflow_execution_duration_seconds` - Execution time
- `n8n_workflow_errors_total` - Error count
- `n8n_mcp_tool_invocations_total` - MCP-specific metric

### Error Handling

```javascript
// Function node: Centralized error handling
try {
  // Your workflow logic
  const result = processData($input.item.json);
  return { json: { success: true, data: result } };

} catch (error) {
  // Log error
  console.error('[MCP Error]', {
    tool: 'create_task',
    error: error.message,
    stack: error.stack,
    input: $input.item.json
  });

  // Return structured error response
  return {
    json: {
      success: false,
      error: {
        code: error.code || 'INTERNAL_ERROR',
        message: error.message,
        timestamp: new Date().toISOString()
      }
    }
  };
}
```

---

## Production Checklist

### Security

- [ ] Authentication enabled (API key or OAuth)
- [ ] HTTPS/TLS configured
- [ ] IP whitelisting implemented (if applicable)
- [ ] Rate limiting configured
- [ ] Input validation in place
- [ ] Secrets stored in environment variables
- [ ] CORS configured with allowed origins
- [ ] Audit logging enabled

### Performance

- [ ] Resource limits set (CPU, memory)
- [ ] Timeout configuration appropriate
- [ ] Database connection pooling
- [ ] Caching implemented for expensive operations
- [ ] Horizontal scaling configured (multiple replicas)
- [ ] Load balancer in place

### Reliability

- [ ] Health checks configured
- [ ] Auto-restart on failure
- [ ] Backup and restore procedures
- [ ] Error handling comprehensive
- [ ] Monitoring and alerting set up
- [ ] Documentation up-to-date

### Testing

- [ ] Manual testing completed
- [ ] Automated tests written
- [ ] Load testing performed
- [ ] Security testing completed
- [ ] Integration testing with Claude Code

---

## Next Steps

1. **Create Your First MCP Server**
   - Follow the configuration guide above
   - Start with a simple tool (e.g., send_email)
   - Test with cURL before Claude integration

2. **Integrate with Claude Code**
   - Add to `mcp_config.json`
   - Test tool invocation
   - Iterate on tool description and parameters

3. **Build Production Workflows**
   - Implement authentication
   - Add comprehensive error handling
   - Deploy with proper monitoring

4. **Explore Advanced Patterns**
   - Multi-tool workflows
   - Human-in-the-loop approvals
   - Dynamic workflow generation

---

**Related Documentation:**
- **SKILL.md**: Complete MCP orchestration reference
- **mcp-client-patterns.md**: Using MCP clients in n8n
- **EXAMPLES.md**: 15+ practical examples

**External Resources:**
- n8n MCP Documentation: https://docs.n8n.io/integrations/builtin/core-nodes/mcp/
- MCP Specification: https://modelcontextprotocol.io
- n8n Community Forum: https://community.n8n.io
