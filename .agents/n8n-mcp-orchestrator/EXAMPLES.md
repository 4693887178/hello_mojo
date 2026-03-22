# n8n MCP Orchestrator - Practical Examples

This document provides 15+ real-world examples of MCP orchestration patterns using n8n, covering beginner to advanced scenarios.

## Table of Contents

1. [Basic MCP Server Examples](#basic-mcp-server-examples)
2. [Basic MCP Client Examples](#basic-mcp-client-examples)
3. [Claude Code Integration Examples](#claude-code-integration-examples)
4. [Multi-Agent Orchestration Examples](#multi-agent-orchestration-examples)
5. [Production Examples](#production-examples)
6. [Advanced Patterns](#advanced-patterns)

---

## Basic MCP Server Examples

### Example 1: Simple Task Creator

**Goal:** Expose a workflow that creates tasks in a task management system.

**n8n Workflow:**

```
Workflow: "Create Task MCP Tool"

┌─────────────────────────────────────────────────────────────┐
│ 1. MCP Server Trigger                                       │
│    Tool: create_task                                        │
│    Description: "Create a new task with title and due date" │
│    Parameters:                                              │
│      - title (string, required)                             │
│      - description (string, optional)                       │
│      - dueDate (string, optional)                           │
│      - priority (enum: low|medium|high, optional)           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Function: Validate Input                                 │
│    Code:                                                    │
│      const { title, description, dueDate, priority } =      │
│        $input.item.json;                                    │
│                                                             │
│      if (!title || title.trim() === '') {                   │
│        throw new Error('Title is required');                │
│      }                                                      │
│                                                             │
│      return {                                               │
│        json: {                                              │
│          title,                                             │
│          description: description || '',                    │
│          dueDate: dueDate || null,                          │
│          priority: priority || 'medium'                     │
│        }                                                    │
│      };                                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. HTTP Request: POST to Todoist API                        │
│    URL: https://api.todoist.com/rest/v2/tasks              │
│    Authentication: Bearer Token                             │
│    Body:                                                    │
│      {                                                      │
│        "content": "{{$json.title}}",                        │
│        "description": "{{$json.description}}",              │
│        "due_string": "{{$json.dueDate}}",                   │
│        "priority": "{{$json.priority}}"                     │
│      }                                                      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Function: Format Response                                │
│    Code:                                                    │
│      const task = $input.item.json;                         │
│                                                             │
│      return {                                               │
│        json: {                                              │
│          success: true,                                     │
│          taskId: task.id,                                   │
│          title: task.content,                               │
│          url: task.url,                                     │
│          createdAt: new Date().toISOString()                │
│        }                                                    │
│      };                                                     │
└─────────────────────────────────────────────────────────────┘
```

**Claude Code Configuration:**

```json
{
  "mcpServers": {
    "task-manager": {
      "url": "https://n8n.company.com/mcp",
      "apiKey": "${TASK_MCP_API_KEY}"
    }
  }
}
```

**Usage:**

```
User: "Create a task to review the pull request tomorrow"

Claude Code:
→ Invokes: create_task(
    title="Review pull request",
    dueDate="tomorrow",
    priority="high"
  )
← Response: {
    success: true,
    taskId: "12345",
    url: "https://todoist.com/app/task/12345"
  }

Claude: "Task created! You can view it here: https://todoist.com/app/task/12345"
```

---

### Example 2: Email Sender with Template Support

**Goal:** Send emails with dynamic templates via MCP.

**n8n Workflow:**

```
Workflow: "Send Email MCP Tool"

┌─────────────────────────────────────────────────────────────┐
│ 1. MCP Server Trigger                                       │
│    Tool: send_email                                         │
│    Description: "Send templated email to recipients"        │
│    Parameters:                                              │
│      - to (string | array, required)                        │
│      - template (enum: welcome|notification|alert)          │
│      - data (object, optional)                              │
│      - subject (string, optional)                           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Switch: Route by Template                                │
│    Cases:                                                   │
│      - template === 'welcome' → Branch 1                    │
│      - template === 'notification' → Branch 2               │
│      - template === 'alert' → Branch 3                      │
└─────────────────────────────────────────────────────────────┘
          ↓                 ↓                 ↓
    ┌─────────┐      ┌─────────┐      ┌─────────┐
    │ Welcome │      │ Notify  │      │ Alert   │
    │ Template│      │ Template│      │ Template│
    └─────────┘      └─────────┘      └─────────┘
          ↓                 ↓                 ↓
          └─────────────────┴─────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Email: Send via SMTP                                     │
│    To: {{$json.to}}                                         │
│    Subject: {{$json.subject}}                               │
│    Body: {{$json.htmlContent}}                              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Function: Return Confirmation                            │
│    Return: { sent: true, timestamp: ISO8601 }               │
└─────────────────────────────────────────────────────────────┘
```

**Template Examples:**

```javascript
// Welcome Template
{
  subject: `Welcome to ${data.appName}, ${data.userName}!`,
  htmlContent: `
    <h1>Welcome ${data.userName}!</h1>
    <p>We're excited to have you on board.</p>
    <a href="${data.dashboardUrl}">Get Started</a>
  `
}

// Notification Template
{
  subject: `New ${data.eventType}: ${data.title}`,
  htmlContent: `
    <h2>${data.title}</h2>
    <p>${data.message}</p>
    <a href="${data.actionUrl}">${data.actionText}</a>
  `
}

// Alert Template
{
  subject: `[ALERT] ${data.severity}: ${data.title}`,
  htmlContent: `
    <div style="background: #ff0000; color: white; padding: 20px;">
      <h1>⚠️ ${data.title}</h1>
      <p>${data.description}</p>
      <p><strong>Action Required:</strong> ${data.actionRequired}</p>
    </div>
  `
}
```

---

### Example 3: Database Query Tool

**Goal:** Expose database queries as MCP tools for AI agents.

**n8n Workflow:**

```
Workflow: "Query Customer Data"

┌─────────────────────────────────────────────────────────────┐
│ 1. MCP Server Trigger                                       │
│    Tool: query_customers                                    │
│    Description: "Query customer database"                   │
│    Parameters:                                              │
│      - email (string, optional)                             │
│      - customerId (string, optional)                        │
│      - status (enum: active|inactive|trial, optional)       │
│      - limit (number, default: 10)                          │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Function: Build SQL Query                                │
│    Code:                                                    │
│      const { email, customerId, status, limit } = $json;    │
│      let where = [];                                        │
│                                                             │
│      if (email) where.push(`email = '${email}'`);           │
│      if (customerId) where.push(`id = '${customerId}'`);    │
│      if (status) where.push(`status = '${status}'`);        │
│                                                             │
│      const sql = `                                          │
│        SELECT id, email, name, status, created_at           │
│        FROM customers                                       │
│        ${where.length ? 'WHERE ' + where.join(' AND ') : ''}│
│        LIMIT ${limit || 10}                                 │
│      `;                                                     │
│                                                             │
│      return { json: { sql } };                              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Postgres: Execute Query                                  │
│    Query: {{$json.sql}}                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Function: Format Results                                 │
│    Code:                                                    │
│      return {                                               │
│        json: {                                              │
│          customers: $input.all(),                           │
│          count: $input.all().length,                        │
│          timestamp: new Date().toISOString()                │
│        }                                                    │
│      };                                                     │
└─────────────────────────────────────────────────────────────┘
```

**Security Note:** Always use parameterized queries and validate inputs in production!

---

## Basic MCP Client Examples

### Example 4: Call External Analytics Service

**Goal:** Call an external MCP analytics service from n8n workflow.

**n8n Workflow:**

```
Workflow: "Daily Analytics Report"

┌─────────────────────────────────────────────────────────────┐
│ 1. Schedule Trigger                                         │
│    Cron: 0 9 * * *  (Every day at 9am)                      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Function: Prepare Parameters                             │
│    Code:                                                    │
│      const yesterday = new Date();                          │
│      yesterday.setDate(yesterday.getDate() - 1);            │
│                                                             │
│      return {                                               │
│        json: {                                              │
│          date: yesterday.toISOString().split('T')[0],       │
│          metrics: ['revenue', 'users', 'engagement'],       │
│          format: 'json'                                     │
│        }                                                    │
│      };                                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. MCP Client Tool                                          │
│    Server: https://analytics.company.com/mcp                │
│    Tool: generate_daily_report                              │
│    Parameters:                                              │
│      date: {{$json.date}}                                   │
│      metrics: {{$json.metrics}}                             │
│      format: {{$json.format}}                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Function: Format Report                                  │
│    Code:                                                    │
│      const report = $json;                                  │
│                                                             │
│      return {                                               │
│        json: {                                              │
│          subject: `Daily Report - ${report.date}`,          │
│          body: `                                            │
│            Revenue: $${report.revenue}                      │
│            New Users: ${report.users}                       │
│            Engagement: ${report.engagement}%                │
│          `                                                  │
│        }                                                    │
│      };                                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. Email: Send to Stakeholders                              │
│    To: team@company.com                                     │
│    Subject: {{$json.subject}}                               │
│    Body: {{$json.body}}                                     │
└─────────────────────────────────────────────────────────────┘
```

---

### Example 5: Multi-MCP Server Orchestration

**Goal:** Call multiple MCP servers and combine results.

**n8n Workflow:**

```
Workflow: "Enriched Customer Profile"

┌─────────────────────────────────────────────────────────────┐
│ 1. Webhook Trigger                                          │
│    Path: /enrich-customer                                   │
│    Body: { customerId: "12345" }                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
          ┌───────────────┴───────────────┐
          ↓                               ↓
┌────────────────────────┐    ┌────────────────────────┐
│ 2a. MCP: Get Orders    │    │ 2b. MCP: Get Support   │
│ Server: crm-mcp        │    │ Server: support-mcp    │
│ Tool: get_orders       │    │ Tool: get_tickets      │
│ Params:                │    │ Params:                │
│   customerId: 12345    │    │   customerId: 12345    │
└────────────────────────┘    └────────────────────────┘
          │                               │
          └───────────────┬───────────────┘
                          ↓
          ┌───────────────┴───────────────┐
          ↓                               ↓
┌────────────────────────┐    ┌────────────────────────┐
│ 3a. MCP: Social Data   │    │ 3b. MCP: Email Stats   │
│ Server: social-mcp     │    │ Server: email-mcp      │
│ Tool: get_social       │    │ Tool: get_engagement   │
│ Params:                │    │ Params:                │
│   customerId: 12345    │    │   customerId: 12345    │
└────────────────────────┘    └────────────────────────┘
          │                               │
          └───────────────┬───────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Function: Combine All Data                               │
│    Code:                                                    │
│      const items = $input.all();                            │
│                                                             │
│      return {                                               │
│        json: {                                              │
│          customerId: '12345',                               │
│          orders: items[0].json,                             │
│          support: items[1].json,                            │
│          social: items[2].json,                             │
│          email: items[3].json,                              │
│          enrichedAt: new Date().toISOString()               │
│        }                                                    │
│      };                                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. HTTP Request: Update CRM                                 │
│    POST /api/customers/12345/profile                        │
│    Body: {{$json}}                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## Claude Code Integration Examples

### Example 6: Support Ticket Creation with AI Triage

**Goal:** Claude Code analyzes user issue and creates appropriate support ticket.

**n8n Workflow (MCP Server):**

```
Workflow: "Create Support Ticket"

┌─────────────────────────────────────────────────────────────┐
│ 1. MCP Server Trigger                                       │
│    Tool: create_support_ticket                              │
│    Parameters:                                              │
│      - title (string)                                       │
│      - description (string)                                 │
│      - severity (enum: low|medium|high|critical)            │
│      - category (enum: bug|feature|question)                │
│      - customerEmail (string)                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. HTTP Request: Create Jira Ticket                         │
│    POST https://company.atlassian.net/rest/api/3/issue     │
│    Body:                                                    │
│      {                                                      │
│        "fields": {                                          │
│          "project": {"key": "SUP"},                         │
│          "summary": "{{$json.title}}",                      │
│          "description": "{{$json.description}}",            │
│          "priority": "{{$json.severity}}",                  │
│          "labels": ["{{$json.category}}"],                  │
│          "customfield_email": "{{$json.customerEmail}}"     │
│        }                                                    │
│      }                                                      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Slack: Notify Support Team                               │
│    Channel: #support                                        │
│    Message:                                                 │
│      New {{$json.severity}} ticket: {{$json.title}}         │
│      Category: {{$json.category}}                           │
│      Jira: JIRA-{{$json.id}}                                │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Email: Confirmation to Customer                          │
│    To: {{$json.customerEmail}}                              │
│    Template: ticket_created                                 │
│    Data: { ticketId, estimatedResponse }                    │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. Return Response                                          │
│    {                                                        │
│      ticketId: "SUP-12345",                                 │
│      status: "created",                                     │
│      url: "https://company.atlassian.net/browse/SUP-12345", │
│      assignedTo: "auto-assigned-engineer"                   │
│    }                                                        │
└─────────────────────────────────────────────────────────────┘
```

**Claude Code Usage:**

```
User: "I'm getting a 500 error when trying to log in. I've tried clearing cache and different browsers. Email: user@example.com"

Claude Code:
1. Analyzes the issue
2. Determines:
   - Category: bug
   - Severity: high (login issue affects access)
   - Requires immediate attention

3. Invokes MCP tool:
   create_support_ticket({
     title: "Login Error: 500 Status Code",
     description: `
       User reports 500 error during login.

       Troubleshooting attempted:
       - Cleared browser cache
       - Tested multiple browsers
       - Issue persists

       Customer email: user@example.com
     `,
     severity: "high",
     category: "bug",
     customerEmail: "user@example.com"
   })

4. Receives response:
   {
     ticketId: "SUP-12345",
     status: "created",
     url: "https://company.atlassian.net/browse/SUP-12345"
   }

5. Responds to user:
   "I've created a high-priority support ticket (SUP-12345) for your login issue.
    Our engineering team has been notified and will investigate immediately.
    You'll receive email updates at user@example.com.

    Ticket URL: https://company.atlassian.net/browse/SUP-12345"
```

---

### Example 7: Knowledge Base Search and Response

**Goal:** Claude searches knowledge base via n8n and provides relevant solutions.

**n8n Workflow (MCP Server):**

```
Workflow: "Search Knowledge Base"

┌─────────────────────────────────────────────────────────────┐
│ 1. MCP Server Trigger                                       │
│    Tool: search_knowledge_base                              │
│    Parameters:                                              │
│      - query (string)                                       │
│      - category (string, optional)                          │
│      - limit (number, default: 5)                           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. HTTP Request: Search Internal Docs                       │
│    POST https://docs.company.com/api/search                 │
│    Body: { q: "{{$json.query}}", limit: {{$json.limit}} }  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Postgres: Search Past Tickets                            │
│    Query:                                                   │
│      SELECT title, solution, votes                          │
│      FROM resolved_tickets                                  │
│      WHERE solution_text ILIKE '%{{$json.query}}%'          │
│      ORDER BY votes DESC                                    │
│      LIMIT {{$json.limit}}                                  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Function: Combine and Rank Results                       │
│    Code:                                                    │
│      const docs = $('HTTP Request').all();                  │
│      const tickets = $('Postgres').all();                   │
│                                                             │
│      const combined = [                                     │
│        ...docs.map(d => ({                                  │
│          type: 'doc',                                       │
│          title: d.json.title,                               │
│          content: d.json.content,                           │
│          url: d.json.url,                                   │
│          relevance: d.json.score                            │
│        })),                                                 │
│        ...tickets.map(t => ({                               │
│          type: 'ticket',                                    │
│          title: t.json.title,                               │
│          content: t.json.solution,                          │
│          votes: t.json.votes                                │
│        }))                                                  │
│      ];                                                     │
│                                                             │
│      // Sort by relevance/votes                             │
│      combined.sort((a, b) =>                                │
│        (b.relevance || b.votes || 0) -                      │
│        (a.relevance || a.votes || 0)                        │
│      );                                                     │
│                                                             │
│      return { json: { results: combined.slice(0, 5) } };    │
└─────────────────────────────────────────────────────────────┘
```

**Claude Code Usage:**

```
User: "How do I reset my password?"

Claude Code:
1. Invokes: search_knowledge_base({ query: "reset password" })

2. Receives results:
   {
     results: [
       {
         type: "doc",
         title: "Password Reset Guide",
         content: "To reset your password: 1. Go to login page...",
         url: "https://docs.company.com/password-reset"
       },
       {
         type: "ticket",
         title: "Password reset not working",
         content: "Solution: Check spam folder for reset email...",
         votes: 45
       }
     ]
   }

3. Analyzes results and responds:
   "To reset your password:

   1. Go to the login page
   2. Click 'Forgot Password'
   3. Enter your email
   4. Check your inbox (and spam folder) for reset link
   5. Click the link and create a new password

   Full guide: https://docs.company.com/password-reset

   Common issue: If you don't receive the email, check your spam folder.
   This resolves the issue in 90% of cases."
```

---

### Example 8: Automated Meeting Scheduler

**Goal:** Claude schedules meetings by calling n8n workflow to check calendar and send invites.

**n8n Workflow (MCP Server):**

```
Workflow: "Schedule Meeting"

┌─────────────────────────────────────────────────────────────┐
│ 1. MCP Server Trigger                                       │
│    Tool: schedule_meeting                                   │
│    Parameters:                                              │
│      - participants (array of emails)                       │
│      - duration (number, minutes)                           │
│      - preferredDate (string, ISO)                          │
│      - title (string)                                       │
│      - description (string, optional)                       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Google Calendar: Check Availability                      │
│    For each participant:                                    │
│      Query free/busy for preferred date ± 3 days            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Function: Find Best Time Slot                            │
│    Code:                                                    │
│      const availability = $json.calendars;                  │
│      const duration = $json.duration;                       │
│                                                             │
│      // Find overlapping free slots                         │
│      const freeSlots = findCommonFreeTime(                  │
│        availability,                                        │
│        duration                                             │
│      );                                                     │
│                                                             │
│      // Pick closest to preferred date                      │
│      const bestSlot = freeSlots[0];                         │
│                                                             │
│      return { json: { slot: bestSlot } };                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Google Calendar: Create Event                            │
│    Summary: {{$json.title}}                                 │
│    Start: {{$json.slot.start}}                              │
│    End: {{$json.slot.end}}                                  │
│    Attendees: {{$json.participants}}                        │
│    Description: {{$json.description}}                       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. Email: Send Invitations                                  │
│    To: {{$json.participants}}                               │
│    Body: Meeting invite with calendar link                  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. Return Confirmation                                      │
│    {                                                        │
│      meetingId: "cal_12345",                                │
│      scheduledTime: "2025-10-21T14:00:00Z",                 │
│      participants: [...],                                   │
│      calendarUrl: "https://calendar.google.com/..."         │
│    }                                                        │
└─────────────────────────────────────────────────────────────┘
```

**Claude Code Usage:**

```
User: "Schedule a 30-minute design review with alice@company.com and bob@company.com for next week"

Claude Code:
1. Parses request:
   - Participants: ["alice@company.com", "bob@company.com"]
   - Duration: 30 minutes
   - Preferred: Next week (2025-10-27)
   - Title: "Design Review"

2. Invokes: schedule_meeting({
     participants: ["alice@company.com", "bob@company.com"],
     duration: 30,
     preferredDate: "2025-10-27",
     title: "Design Review"
   })

3. n8n workflow:
   - Checks calendars
   - Finds: Tuesday 10/28 at 2pm works for all
   - Creates calendar event
   - Sends invites

4. Receives response:
   {
     meetingId: "cal_12345",
     scheduledTime: "2025-10-28T14:00:00Z",
     participants: ["alice@company.com", "bob@company.com"]
   }

5. Responds:
   "I've scheduled the design review for Tuesday, October 28th at 2:00 PM.
    Invitations have been sent to Alice and Bob.
    Duration: 30 minutes
    Calendar link: https://calendar.google.com/event?eid=..."
```

---

## Multi-Agent Orchestration Examples

### Example 9: Content Creation Pipeline

**Goal:** Orchestrate research, writing, and SEO agents to create blog posts.

**Architecture:**

```
Orchestrator Agent (Claude Code)
        │
        ├─→ Research Agent → n8n: gather_research_data
        │       ↓
        │   Returns: research findings
        │
        ├─→ Writing Agent → n8n: generate_draft_content
        │       ↓
        │   Returns: blog post draft
        │
        ├─→ SEO Agent → n8n: optimize_for_seo
        │       ↓
        │   Returns: optimized content
        │
        └─→ n8n: publish_to_cms
            └→ Published blog post
```

**n8n Workflows:**

**Workflow 1: Gather Research Data**

```
┌─────────────────────────────────────────────────────────────┐
│ MCP Server Trigger: gather_research_data                    │
│ Params: { topic, sources, depth }                           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ HTTP Requests (parallel):                                   │
│   - Google Scholar API                                      │
│   - News API                                                │
│   - Internal knowledge base                                 │
│   - Competitor blogs                                        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Function: Consolidate and Summarize                         │
│ Returns: { facts, statistics, quotes, sources }             │
└─────────────────────────────────────────────────────────────┘
```

**Workflow 2: Generate Draft Content**

```
┌─────────────────────────────────────────────────────────────┐
│ MCP Server Trigger: generate_draft_content                  │
│ Params: { topic, research, targetAudience, tone }           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ HTTP Request: Call Claude API                               │
│ Prompt: Generate blog post using research data              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Function: Format and Structure                              │
│ Returns: { title, sections, wordCount, readingTime }        │
└─────────────────────────────────────────────────────────────┘
```

**Workflow 3: Optimize for SEO**

```
┌─────────────────────────────────────────────────────────────┐
│ MCP Server Trigger: optimize_for_seo                        │
│ Params: { content, targetKeywords, competitors }            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ HTTP Request: SEO Analysis API                              │
│ Analyze: keyword density, readability, meta tags            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Function: Apply SEO Improvements                            │
│   - Add meta description                                    │
│   - Optimize headings                                       │
│   - Add internal links                                      │
│   - Generate alt text for images                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Returns: { optimizedContent, seoScore, suggestions }        │
└─────────────────────────────────────────────────────────────┘
```

**Workflow 4: Publish to CMS**

```
┌─────────────────────────────────────────────────────────────┐
│ MCP Server Trigger: publish_to_cms                          │
│ Params: { content, metadata, images, schedule }             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ HTTP Request: Upload Images to CDN                          │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ WordPress: Create Post                                      │
│   - Title, content, excerpt                                 │
│   - Featured image                                          │
│   - Categories, tags                                        │
│   - SEO metadata                                            │
│   - Schedule publish date                                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Social Media: Auto-share                                    │
│   - Twitter                                                 │
│   - LinkedIn                                                │
│   - Facebook                                                │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Slack: Notify Marketing Team                                │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Returns: { postUrl, socialLinks, publishedAt }              │
└─────────────────────────────────────────────────────────────┘
```

**Claude Code Orchestration:**

```javascript
// Orchestrator Agent coordinates the entire pipeline
async function createBlogPost(topic, targetKeywords) {
  // Step 1: Research
  console.log("Starting research phase...");
  const research = await mcpCall('n8n', 'gather_research_data', {
    topic,
    sources: ['scholar', 'news', 'internal'],
    depth: 'comprehensive'
  });

  // Step 2: Writing
  console.log("Generating content...");
  const draft = await mcpCall('n8n', 'generate_draft_content', {
    topic,
    research: research.data,
    targetAudience: 'developers',
    tone: 'professional-friendly'
  });

  // Step 3: SEO Optimization
  console.log("Optimizing for SEO...");
  const optimized = await mcpCall('n8n', 'optimize_for_seo', {
    content: draft.content,
    targetKeywords,
    competitors: ['competitor-blog-urls']
  });

  // Step 4: Publish
  console.log("Publishing to CMS...");
  const published = await mcpCall('n8n', 'publish_to_cms', {
    content: optimized.content,
    metadata: {
      title: draft.title,
      excerpt: draft.excerpt,
      tags: optimized.suggestedTags
    },
    images: draft.images,
    schedule: 'tomorrow-9am'
  });

  return {
    success: true,
    postUrl: published.postUrl,
    seoScore: optimized.seoScore,
    socialLinks: published.socialLinks
  };
}

// Usage
const result = await createBlogPost(
  "Building Scalable APIs with FastAPI",
  ["fastapi", "python", "rest api", "microservices"]
);

console.log(`Blog post published: ${result.postUrl}`);
console.log(`SEO Score: ${result.seoScore}/100`);
```

---

### Example 10: Autonomous System Monitoring and Remediation

**Goal:** Continuous monitoring with AI-powered analysis and automated fixes.

**Architecture:**

```
┌─────────────────────────────────────────────────────────────┐
│ n8n: Monitoring Loop (every 5 minutes)                      │
│   1. Check system metrics                                   │
│   2. Detect anomalies                                       │
│   3. If anomaly → Call Claude via MCP                       │
└─────────────────────────────────────────────────────────────┘
                          ↓ Anomaly detected
┌─────────────────────────────────────────────────────────────┐
│ Claude Code (Remediation Agent)                             │
│   1. Analyze metrics and logs                               │
│   2. Identify root cause                                    │
│   3. Determine remediation strategy                         │
│   4. Call n8n: execute_remediation()                        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ n8n: Execute Remediation                                    │
│   1. Apply fix (restart, scale, clear cache)                │
│   2. Create incident ticket                                 │
│   3. Alert on-call engineer if needed                       │
│   4. Return results                                         │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Claude Code                                                 │
│   1. Verify fix successful                                  │
│   2. Document incident                                      │
│   3. Update runbook if new issue                            │
└─────────────────────────────────────────────────────────────┘
```

**n8n Monitoring Workflow:**

```
Workflow: "System Health Monitor"

┌─────────────────────────────────────────────────────────────┐
│ 1. Schedule Trigger: Every 5 minutes                        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Prometheus: Query Metrics                                │
│    Queries:                                                 │
│      - CPU usage                                            │
│      - Memory usage                                         │
│      - Request latency                                      │
│      - Error rate                                           │
│      - Database connections                                 │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Function: Detect Anomalies                               │
│    Code:                                                    │
│      const metrics = $json;                                 │
│      const anomalies = [];                                  │
│                                                             │
│      if (metrics.cpu > 80) {                                │
│        anomalies.push({                                     │
│          type: 'high_cpu',                                  │
│          value: metrics.cpu,                                │
│          threshold: 80                                      │
│        });                                                  │
│      }                                                      │
│                                                             │
│      if (metrics.errorRate > 5) {                           │
│        anomalies.push({                                     │
│          type: 'high_errors',                               │
│          value: metrics.errorRate,                          │
│          threshold: 5                                       │
│        });                                                  │
│      }                                                      │
│                                                             │
│      // Only continue if anomalies detected                 │
│      if (anomalies.length === 0) {                          │
│        return { json: { status: 'healthy' } };              │
│      }                                                      │
│                                                             │
│      return { json: { anomalies, metrics } };               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. IF: Anomalies Detected                                   │
│    Condition: {{$json.anomalies.length > 0}}                │
└─────────────────────────────────────────────────────────────┘
                          ↓ Yes
┌─────────────────────────────────────────────────────────────┐
│ 5. MCP Client Tool                                          │
│    Server: Claude API (via MCP)                             │
│    Tool: analyze_system_issue                               │
│    Parameters:                                              │
│      anomalies: {{$json.anomalies}}                         │
│      metrics: {{$json.metrics}}                             │
│      recentLogs: {{get_recent_logs()}}                      │
└─────────────────────────────────────────────────────────────┘
```

**Claude Analysis and Remediation:**

```javascript
// Claude receives MCP call from n8n
function analyzeSystemIssue({ anomalies, metrics, recentLogs }) {
  // Analyze the situation
  const analysis = {
    rootCause: "High CPU usage due to memory leak in worker process",
    severity: "high",
    recommendedAction: "restart_workers",
    reasoning: `
      Logs show gradual memory increase over past 2 hours.
      CPU spike correlates with memory usage.
      Pattern consistent with known memory leak in v2.3.1.
    `
  };

  // Call n8n to execute remediation
  return mcpCall('n8n', 'execute_remediation', {
    action: analysis.recommendedAction,
    severity: analysis.severity,
    reason: analysis.reasoning
  });
}
```

**n8n Remediation Workflow:**

```
Workflow: "Execute Remediation"

┌─────────────────────────────────────────────────────────────┐
│ 1. MCP Server Trigger                                       │
│    Tool: execute_remediation                                │
│    Parameters:                                              │
│      - action (enum: restart|scale|cache_clear|rollback)    │
│      - severity (enum: low|medium|high|critical)            │
│      - reason (string)                                      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Switch: Route by Action                                  │
└─────────────────────────────────────────────────────────────┘
          │
          ├─→ restart_workers:
          │   ┌─────────────────────────────────────────────┐
          │   │ Kubernetes: Rolling restart workers         │
          │   │ Wait for health check: 30s                  │
          │   │ Verify metrics improved                     │
          │   └─────────────────────────────────────────────┘
          │
          ├─→ scale_up:
          │   ┌─────────────────────────────────────────────┐
          │   │ Kubernetes: Scale replicas +2               │
          │   │ Monitor resource allocation                 │
          │   └─────────────────────────────────────────────┘
          │
          └─→ cache_clear:
              ┌─────────────────────────────────────────────┐
              │ Redis: FLUSHDB cache                        │
              │ Warm critical keys                          │
              └─────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Jira: Create Incident Ticket                             │
│    Priority: {{$json.severity}}                             │
│    Description: {{$json.reason}}                            │
│    Auto-assign: on-call engineer (if critical)              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. IF: Severity >= High                                     │
│    → PagerDuty: Alert on-call engineer                      │
│    → Slack: Post to #incidents channel                      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. Function: Verify Fix                                     │
│    Re-check metrics after 2 minutes                         │
│    Return success/failure status                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. Return to Claude                                         │
│    {                                                        │
│      remediationApplied: true,                              │
│      action: "restart_workers",                             │
│      metricsImproved: true,                                 │
│      incidentTicket: "INC-12345",                           │
│      duration: "3m 24s"                                     │
│    }                                                        │
└─────────────────────────────────────────────────────────────┘
```

---

## Production Examples

### Example 11: E-commerce Order Processing

**Goal:** End-to-end order processing with fraud detection and fulfillment.

**Complete Workflow:**

```
1. Order Placed (Webhook) → n8n

2. Parallel Processing:
   ├─→ MCP: Claude analyzes fraud risk
   ├─→ Check inventory availability
   └─→ Validate payment method

3. Decision Point:
   ├─→ High Fraud Risk:
   │   └─→ Flag for manual review
   │       └─→ Notify fraud team
   │
   └─→ Low Risk:
       ├─→ Process payment (Stripe)
       ├─→ Reserve inventory
       ├─→ Create shipment (ShipStation)
       ├─→ Send confirmation email
       └─→ Update CRM (Salesforce)
```

**n8n Implementation:**

```
Workflow: "Order Processing Pipeline"

┌─────────────────────────────────────────────────────────────┐
│ 1. Webhook: Order Placed                                    │
│    Body: { orderId, customerId, items, total, ... }         │
└─────────────────────────────────────────────────────────────┘
                          ↓
          ┌───────────────┴───────────────┬───────────────┐
          ↓                               ↓               ↓
┌───────────────────┐    ┌───────────────────┐  ┌───────────────────┐
│ 2a. MCP: Claude   │    │ 2b. Check         │  │ 2c. Validate      │
│ Fraud Analysis    │    │ Inventory         │  │ Payment           │
│                   │    │                   │  │                   │
│ Analyzes:         │    │ Query DB:         │  │ Stripe API:       │
│ - Order pattern   │    │ Available stock   │  │ Card valid        │
│ - Customer hist.  │    │ - Product 1: ✅    │  │ Funds sufficient  │
│ - Shipping addr.  │    │ - Product 2: ✅    │  │                   │
│ - Payment method  │    │                   │  │                   │
│                   │    │                   │  │                   │
│ Returns:          │    │ Returns:          │  │ Returns:          │
│ riskScore: 0.15   │    │ available: true   │  │ valid: true       │
│ reason: "Safe"    │    │                   │  │                   │
└───────────────────┘    └───────────────────┘  └───────────────────┘
          │                      │                      │
          └──────────────────────┴──────────────────────┘
                                 ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Function: Combine Results                                │
│    decision = {                                             │
│      proceedWithOrder: riskScore < 0.7 &&                   │
│                        inventory.available &&               │
│                        payment.valid,                       │
│      fraudRisk: riskScore >= 0.7,                           │
│      outOfStock: !inventory.available                       │
│    }                                                        │
└─────────────────────────────────────────────────────────────┘
                                 ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. IF: Fraud Risk Detected                                  │
└─────────────────────────────────────────────────────────────┘
          │
          ├─→ YES (High Risk):
          │   ┌─────────────────────────────────────────────┐
          │   │ - Flag order for manual review              │
          │   │ - Create Jira ticket for fraud team         │
          │   │ - Hold payment authorization                │
          │   │ - Email customer: verification needed       │
          │   │ - Slack notification to fraud team          │
          │   └─────────────────────────────────────────────┘
          │
          └─→ NO (Safe to Process):
              ┌─────────────────────────────────────────────┐
              │ 5. Process Payment (Stripe API)             │
              │    Charge: ${{order.total}}                 │
              │    Description: "Order #{{order.id}}"       │
              └─────────────────────────────────────────────┘
                          ↓
              ┌─────────────────────────────────────────────┐
              │ 6. Reserve Inventory (Database)             │
              │    UPDATE products                          │
              │    SET stock = stock - qty                  │
              │    WHERE product_id IN (...)                │
              └─────────────────────────────────────────────┘
                          ↓
              ┌─────────────────────────────────────────────┐
              │ 7. Create Shipment (ShipStation API)        │
              │    {                                        │
              │      orderId, items, address,               │
              │      carrier: "USPS",                       │
              │      service: "Priority Mail"               │
              │    }                                        │
              │    Returns: trackingNumber                  │
              └─────────────────────────────────────────────┘
                          ↓
              ┌─────────────────────────────────────────────┐
              │ 8. Email: Order Confirmation                │
              │    To: customer email                       │
              │    Template: order_confirmed                │
              │    Data: {                                  │
              │      orderNumber,                           │
              │      items,                                 │
              │      trackingNumber,                        │
              │      estimatedDelivery                      │
              │    }                                        │
              └─────────────────────────────────────────────┘
                          ↓
              ┌─────────────────────────────────────────────┐
              │ 9. Salesforce: Update Customer Record       │
              │    - Last purchase date                     │
              │    - Total spend                            │
              │    - Purchase history                       │
              │    - Customer segment                       │
              └─────────────────────────────────────────────┘
                          ↓
              ┌─────────────────────────────────────────────┐
              │ 10. Analytics: Track Conversion             │
              │     POST /api/events/purchase               │
              │     { orderId, total, items, source }       │
              └─────────────────────────────────────────────┘
                          ↓
              ┌─────────────────────────────────────────────┐
              │ 11. Respond with Success                    │
              │     200 OK                                  │
              │     {                                       │
              │       status: "processed",                  │
              │       orderNumber: "ORD-12345",             │
              │       trackingNumber: "1Z999AA1..."         │
              │     }                                       │
              └─────────────────────────────────────────────┘
```

**Claude Fraud Analysis Function:**

```javascript
// Called via MCP from n8n
function analyzeFraudRisk(order) {
  const riskFactors = [];
  let riskScore = 0;

  // Check 1: First-time customer with high-value order
  if (order.customer.orderCount === 0 && order.total > 500) {
    riskFactors.push("First-time high-value purchase");
    riskScore += 0.3;
  }

  // Check 2: Shipping address mismatch
  if (order.shipping.country !== order.billing.country) {
    riskFactors.push("International shipping");
    riskScore += 0.2;
  }

  // Check 3: Unusual order time
  const hour = new Date(order.createdAt).getHours();
  if (hour >= 2 && hour <= 5) {
    riskFactors.push("Unusual purchase time (2-5 AM)");
    riskScore += 0.1;
  }

  // Check 4: Multiple failed payment attempts
  if (order.paymentAttempts > 1) {
    riskFactors.push("Multiple payment attempts");
    riskScore += 0.25;
  }

  // Check 5: Velocity check (multiple orders in short time)
  if (order.customer.ordersLast24h > 3) {
    riskFactors.push("High order velocity");
    riskScore += 0.35;
  }

  return {
    riskScore: Math.min(riskScore, 1.0),
    riskLevel: riskScore > 0.7 ? "high" :
               riskScore > 0.4 ? "medium" : "low",
    factors: riskFactors,
    recommendation: riskScore > 0.7 ? "manual_review" : "approve"
  };
}
```

---

### Example 12: Customer Onboarding Automation

**Goal:** Fully automated customer onboarding with personalized welcome sequence.

**Full Workflow:**

```
Trigger: New User Signup
     ↓
1. Create user accounts across systems
   - Auth0: User identity
   - Stripe: Customer profile
   - Intercom: Support contact
   - Salesforce: CRM record
     ↓
2. MCP: Claude generates personalized welcome email
   - Based on signup source
   - Industry-specific content
   - Recommended getting started steps
     ↓
3. Send welcome email with onboarding checklist
     ↓
4. Create onboarding tasks in Linear
   - Day 1: Complete profile
   - Day 3: First project
   - Day 7: Team invitation
     ↓
5. Schedule follow-up emails (Drip campaign)
   - Day 2: Getting started guide
   - Day 5: Best practices
   - Day 10: Pro features
     ↓
6. Assign customer success manager
     ↓
7. Analytics: Track onboarding funnel
```

**(Full implementation continued in production documentation)**

---

## Advanced Patterns

### Example 13: Dynamic Workflow Generation

**Goal:** Claude Code generates n8n workflows on-the-fly based on user requirements.

**Pattern:**

```
User: "Create an automation that sends me a daily digest of unread GitHub PRs"

Claude Code:
1. Analyzes request and determines workflow structure
2. Calls n8n MCP tool: create_workflow()
3. Workflow is generated and activated
4. User receives confirmation with workflow URL
```

**Implementation details in advanced documentation...**

---

### Example 14: Human-in-the-Loop Approval Workflows

**Goal:** AI drafts actions but requires human approval before execution.

**Pattern:**

```
1. Claude analyzes support ticket and drafts response
2. Calls n8n: request_approval(draft)
3. n8n sends Slack message to manager with approval buttons
4. Manager clicks "Approve" or "Reject"
5. If approved: n8n sends email to customer
6. Claude receives confirmation and updates ticket
```

**(Full implementation in SKILL.md)**

---

### Example 15: Real-Time Collaborative Agents

**Goal:** Multiple AI agents collaborate in real-time via shared n8n workflows.

**Architecture:**

```
Multiple Claude Code instances → n8n Coordination Server
     ↓
n8n maintains shared context and orchestrates collaboration
     ↓
Agents negotiate task division and execution
     ↓
Combined results returned to user
```

**(Advanced pattern - see production documentation)**

---

## Complete Example Index

1. ✅ Simple Task Creator (Basic MCP Server)
2. ✅ Email Sender with Templates (Basic MCP Server)
3. ✅ Database Query Tool (Basic MCP Server)
4. ✅ Call External Analytics Service (Basic MCP Client)
5. ✅ Multi-MCP Server Orchestration (Basic MCP Client)
6. ✅ Support Ticket Creation with AI Triage (Claude Integration)
7. ✅ Knowledge Base Search (Claude Integration)
8. ✅ Automated Meeting Scheduler (Claude Integration)
9. ✅ Content Creation Pipeline (Multi-Agent)
10. ✅ System Monitoring & Remediation (Multi-Agent)
11. ✅ E-commerce Order Processing (Production)
12. ✅ Customer Onboarding Automation (Production)
13. ✅ Dynamic Workflow Generation (Advanced)
14. ✅ Human-in-the-Loop Approvals (Advanced)
15. ✅ Real-Time Collaborative Agents (Advanced)

---

**Next Steps:**

- Study examples sequentially (1 → 15)
- Implement basic examples in your n8n instance
- Experiment with Claude Code integration
- Build production workflows based on patterns
- Explore advanced multi-agent patterns

**Resources:**

- SKILL.md: Complete technical reference
- mcp-server-setup.md: Server configuration guide
- mcp-client-patterns.md: Client usage patterns
- README.md: Overview and quick start

---

**Version**: 1.0.0
**Last Updated**: October 2025
