# n8n MCP Orchestrator

> Expert MCP (Model Context Protocol) orchestration with n8n workflow automation

## Overview

The **n8n MCP Orchestrator** skill provides comprehensive guidance for building AI-powered automation systems using n8n's bidirectional Model Context Protocol (MCP) integration. This skill enables you to:

- Expose n8n workflows as tools for AI agents (Claude Code, Claude Desktop)
- Consume external MCP servers from within n8n workflows
- Build sophisticated agentic systems with workflow orchestration
- Create production-ready AI automation pipelines
- Orchestrate multi-agent workflows with centralized coordination

## What is MCP?

The **Model Context Protocol (MCP)** is an open standard that enables AI assistants to connect to external systems and tools. MCP provides a standardized way for AI agents to:

- **Invoke Tools**: Execute functions and workflows
- **Access Resources**: Read data and context
- **Use Prompts**: Leverage structured prompt templates
- **Authenticate**: Securely access protected services

## n8n's Unique Bidirectional Capability

Unlike most MCP implementations, n8n supports **bidirectional MCP patterns**:

### n8n as MCP Server

Expose your n8n workflows as tools that AI agents can invoke:

```
Claude Code → "Create a support ticket"
     ↓
n8n MCP Server (workflow executes)
     ↓
Jira ticket created + Slack notification sent
     ↓
Claude Code ← "Ticket JIRA-12345 created"
```

**Benefits:**
- Turn any workflow into an AI-callable tool
- Enable AI agents to automate business processes
- Integrate with 400+ services via n8n nodes
- No code required to expose tools

### n8n as MCP Client

Call external MCP servers from your n8n workflows:

```
n8n Workflow (scheduled daily)
     ↓
Call MCP Server: "generate_analytics_report"
     ↓
External Analytics Service processes request
     ↓
n8n receives report data
     ↓
Email report to stakeholders
```

**Benefits:**
- Orchestrate multiple MCP services in one workflow
- Build complex automation chains
- Leverage external AI capabilities
- Combine MCP tools with traditional integrations

## Quick Start

### 1. Create Your First MCP Server (n8n → AI Agent)

**Goal:** Expose a "create task" workflow as a tool for Claude Code

**Steps:**

1. **Create n8n Workflow**
   - Open n8n and create new workflow
   - Name: "Create Task Tool"

2. **Add MCP Server Trigger**
   - Add "MCP Server Trigger" node
   - Configure:
     - Tool Name: `create_task`
     - Description: "Create a task in Todoist with title, description, and due date"
     - Parameters:
       ```json
       {
         "type": "object",
         "properties": {
           "title": {"type": "string", "description": "Task title"},
           "description": {"type": "string", "description": "Task details"},
           "dueDate": {"type": "string", "description": "Due date (ISO format)"}
         },
         "required": ["title"]
       }
       ```

3. **Add Workflow Logic**
   - Add HTTP Request node to call Todoist API
   - Configure authentication and request parameters
   - Map MCP trigger parameters to API request

4. **Return Response**
   - Add Function node to format response
   - Return structured data:
     ```json
     {
       "success": true,
       "taskId": "12345",
       "url": "https://todoist.com/app/task/12345"
     }
     ```

5. **Activate Workflow**
   - Save and activate the workflow
   - Note the MCP server URL (e.g., `https://your-n8n.com/mcp`)

6. **Configure Claude Code**
   - Add to `mcp_config.json`:
     ```json
     {
       "mcpServers": {
         "n8n-tasks": {
           "url": "https://your-n8n.com/mcp",
           "apiKey": "your-api-key"
         }
       }
     }
     ```

7. **Test in Claude Code**
   ```
   User: "Create a task to review the code tomorrow at 2pm"

   Claude Code:
   - Recognizes create_task tool
   - Calls n8n workflow via MCP
   - Returns confirmation with task ID
   ```

### 2. Create Your First MCP Client (n8n → External MCP Server)

**Goal:** Call an external analytics MCP server from n8n workflow

**Steps:**

1. **Create n8n Workflow**
   - Trigger: Schedule (daily at 9am)

2. **Add MCP Client Tool Node**
   - Configure:
     - Server URL: `https://analytics.company.com/mcp`
     - Authentication: API Key
     - Tool: `generate_daily_report`
     - Parameters:
       ```json
       {
         "date": "{{DateTime.now().toISODate()}}",
         "metrics": ["revenue", "users", "engagement"]
       }
       ```

3. **Process Response**
   - Add Function node to format report data
   - Parse JSON response from MCP server

4. **Send Report**
   - Add Email node
   - Send formatted report to stakeholders

5. **Activate and Test**
   - Save and activate workflow
   - Test execution to verify MCP call succeeds

## Key Concepts

### MCP Server Components

When creating MCP servers in n8n:

- **Tool Name**: Unique identifier (e.g., `create_ticket`, `send_email`)
- **Description**: Clear explanation for AI to understand when to use
- **Parameters**: JSON Schema defining required and optional inputs
- **Response**: Structured output returned to AI agent
- **Authentication**: Optional security layer

### MCP Client Components

When consuming external MCP servers:

- **Server URL**: Endpoint of the MCP server
- **Authentication**: API key, OAuth, or none
- **Tool Selection**: Choose from available tools on server
- **Parameter Mapping**: Map workflow data to tool parameters
- **Response Handling**: Process returned data in subsequent nodes

### Workflow Patterns

**Sequential Execution:**
```
Step 1 → Step 2 → Step 3 → Step 4
```

**Parallel Execution:**
```
        ┌─→ Step 2a ─┐
Step 1 ─┼─→ Step 2b ─┼─→ Step 3
        └─→ Step 2c ─┘
```

**Conditional Routing:**
```
        ┌─→ Path A (if condition)
Step 1 ─┤
        └─→ Path B (else)
```

## Use Cases

### Customer Support Automation

**Scenario:** AI-powered ticket triage and response

```
1. Customer asks question in chat
2. Claude Code analyzes question
3. Calls n8n: search_knowledge_base()
4. n8n queries internal docs and past tickets
5. Returns relevant solutions to Claude
6. If complex: Claude calls create_support_ticket()
7. n8n creates Jira ticket and notifies team
```

### Content Creation Pipeline

**Scenario:** Multi-agent content generation

```
1. User requests blog post via Claude Code
2. Claude orchestrates:
   - Research agent → calls n8n: gather_data()
   - Writing agent → calls n8n: generate_content()
   - SEO agent → calls n8n: optimize_seo()
3. n8n publishes to CMS and shares on social
```

### DevOps Automation

**Scenario:** Autonomous monitoring and remediation

```
1. n8n monitors system health (every 5 min)
2. Anomaly detected → calls Claude via MCP
3. Claude analyzes logs and determines fix
4. Calls n8n: execute_remediation(action)
5. n8n restarts service, creates incident ticket
6. Claude verifies fix and documents incident
```

### Sales Automation

**Scenario:** Lead qualification and follow-up

```
1. New lead captured in CRM
2. n8n calls Claude: analyze_lead(lead_data)
3. Claude scores lead and suggests actions
4. Returns to n8n with recommendations
5. n8n executes:
   - High-value lead → Schedule demo
   - Medium lead → Add to nurture campaign
   - Low lead → Archive
```

## Architecture Patterns

### Pattern 1: Claude as Orchestrator

```
         Claude Code (Orchestrator)
                  │
      ┌───────────┼───────────┐
      ↓           ↓           ↓
  n8n Tool 1  n8n Tool 2  n8n Tool 3
      │           │           │
  Execute     Execute     Execute
  Workflow    Workflow    Workflow
```

**Use when:** Single AI agent coordinates multiple workflows

### Pattern 2: Workflow as Orchestrator

```
      n8n Workflow (Orchestrator)
                  │
      ┌───────────┼───────────┐
      ↓           ↓           ↓
   Claude      MCP Tool    HTTP API
 (via MCP)    (external)   (traditional)
```

**Use when:** Workflow needs AI assistance at specific steps

### Pattern 3: Event-Driven

```
External Event → n8n Webhook → Claude (MCP) → n8n Tools
                                     ↓
                              Analysis + Decision
```

**Use when:** Real-time event processing with AI analysis

## Integration with Claude Code

### Configuration

Add n8n MCP server to Claude Code's `mcp_config.json`:

```json
{
  "mcpServers": {
    "n8n-workflows": {
      "url": "https://your-n8n-instance.com/mcp",
      "apiKey": "${N8N_API_KEY}",
      "description": "Business automation workflows",
      "timeout": 30000
    }
  }
}
```

### Environment Variables

```bash
# .env
N8N_API_KEY=your-secret-api-key
N8N_MCP_URL=https://your-n8n-instance.com/mcp
```

### Usage in Conversations

Claude Code automatically discovers and uses n8n tools:

```
User: "Send a Slack message to the engineering channel about the deployment"

Claude Code:
1. Recognizes send_slack_message tool from n8n
2. Calls MCP tool with parameters:
   {
     "channel": "engineering",
     "message": "Deployment completed successfully",
     "attachments": [...]
   }
3. n8n workflow executes Slack API call
4. Returns confirmation to Claude
5. Claude responds to user with success message
```

## Production Deployment

### Hosting Options

**Self-Hosted:**
- Docker: `docker run -it --rm --name n8n -p 5678:5678 -v ~/.n8n:/home/node/.n8n n8nio/n8n`
- Kubernetes: Full orchestration with scaling
- VM: Traditional server deployment

**Cloud:**
- n8n Cloud: Fully managed, built-in MCP support
- AWS/GCP/Azure: Self-managed cloud deployment

### Security Checklist

- [ ] Enable authentication (API key, OAuth 2.0)
- [ ] Use HTTPS/TLS for all MCP endpoints
- [ ] Implement rate limiting
- [ ] Set up IP whitelisting
- [ ] Enable audit logging
- [ ] Store secrets in environment variables
- [ ] Regular security updates

### Monitoring

Key metrics to track:
- MCP tool invocation count
- Tool execution duration
- Error rates
- Active connections
- Request per second

## Learning Path

1. **Beginner**: Create basic MCP server workflow
2. **Intermediate**: Build MCP client workflow calling external services
3. **Advanced**: Orchestrate multi-agent workflows with bidirectional MCP
4. **Expert**: Production deployment with security, monitoring, scaling

## Resources

- **SKILL.md**: Complete technical reference
- **EXAMPLES.md**: 15+ practical examples
- **mcp-server-setup.md**: Detailed MCP server configuration
- **mcp-client-patterns.md**: MCP client usage patterns
- **n8n Documentation**: https://docs.n8n.io
- **MCP Specification**: https://modelcontextprotocol.io
- **Claude Code Docs**: https://docs.anthropic.com/claude/docs/mcp

## Next Steps

1. Read **SKILL.md** for comprehensive technical details
2. Explore **EXAMPLES.md** for real-world implementations
3. Follow **mcp-server-setup.md** to expose your first workflow
4. Study **mcp-client-patterns.md** to consume external MCP services
5. Build your first agentic workflow combining both patterns

---

**Version**: 1.0.0
**Last Updated**: October 2025
**Maintained By**: Claude Code Skills Team
