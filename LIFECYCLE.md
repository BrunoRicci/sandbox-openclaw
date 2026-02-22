# OpenClaw Codespace Lifecycle

## Automatic Startup (postCreateCommand only)

### First Time Creation
When you create the Codespace:

```
Container spins up
  ↓
postCreateCommand runs (once):
  • npm install                           (install dependencies)
  • node scripts/init-openclaw.js         (generate gateway auth token)
  ↓
Ready — gateway is NOT started automatically
```

**Result:** Dependencies and token are ready. You start the gateway manually.

---

## Manual Steps Required

### 1. Start the Gateway

```bash
npm run gateway
```

**What happens:**
- Starts the OpenClaw gateway in the foreground on port 18789
- Keep this terminal open, or open a new terminal for next steps

---

### 2. Open Dashboard & Approve Device

```bash
npm start
```

**What happens:**
- Opens `.openclaw-config.json` in VSCode (for reference)
- Prints dashboard URL in terminal
- Auto-opens URL in browser (if available)
- **Watches for device connection** (polls every 2 seconds for 2 minutes)
- **Auto-approves** when the dashboard connects from your browser
- Done ✅

No ENTER key needed — the script detects and approves automatically.

---

### 3. Connect Your Model Provider

```bash
npm run setup
```

Or directly:
```bash
npx openclaw configure --section model
```

**What happens:**
- Interactive wizard appears
- Select your provider (OpenAI, Anthropic, Azure, Bedrock, Ollama, GitHub Copilot, etc.)
- Enter API key(s) when prompted
- Provider is registered in `.openclaw-state/agents/main/agent/models.json`
- Credentials stored securely (as env vars or in encrypted auth profiles)

**Available providers:**
```
1. OpenAI (GPT-4o, GPT-4, GPT-3.5...)          → OPENAI_API_KEY
2. Anthropic (Claude 3.5, Claude 3...)         → ANTHROPIC_API_KEY
3. Azure OpenAI                                 → AZURE_OPENAI_API_KEY + endpoint
4. AWS Bedrock                                  → AWS credentials + region
5. Ollama (local)                               → no key required
6. GitHub Copilot                               → no key required
```

---

## Full Timeline

| When | What | Manual? |
|------|------|---------|
| Codespace creates | npm install + token gen | ❌ Auto |
| You run `npm run gateway` | Gateway starts on port 18789 | ✅ Each session |
| You run `npm start` | Dashboard URL shown, device auto-approved | ✅ Run once |
| You run `npm run setup` | Configure model provider | ✅ Run once |
| You open dashboard | Connected to OpenClaw UI | ✅ Open browser |

---

## Verification

Check everything is working:

```bash
npm run health           # Check gateway status
npx openclaw status      # Show detailed system status
```

---

## Key Files

- **`.openclaw-config.json`** — Gateway port, token, mode (do not edit manually)
- **`.openclaw-state/`** — Device identity, auth profiles, models, sessions
- **`.openclaw/`** — Agent personality, memory, workspace rules
- **`scripts/start-openclaw.js`** — Dashboard launcher + device auto-approval
- **`scripts/init-openclaw.js`** — Token generator (runs once on create)

---

## Troubleshooting

**Gateway not running?**
```bash
npm run gateway          # Start gateway (foreground)
```

**Dashboard won't connect?**
```bash
npm run init             # Regenerate token
npm start                # Get new URL with token
```

**Model provider not recognized?**
- Run `npm run setup` again
- Check `.openclaw-state/agents/main/agent/models.json`
- Ensure API key is valid in environment

---

## Environment Variables (Optional)

For **GitHub Codespaces**, set these as **Codespace Secrets** (Settings → Codespaces → Secrets):
```
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1
AZURE_OPENAI_API_KEY=...
AZURE_OPENAI_ENDPOINT=https://...
```

They'll be injected automatically (see `devcontainer.json` `remoteEnv` section).

For **local VMs**, create `.env` in project root:
```bash
cp .env.example .env
# edit .env with your credentials
```

These are gitignored and not committed.

---

## Done

You now have:
- ✅ Running gateway (manual start)
- ✅ Connected device (auto-approved)
- ✅ Model provider configured (one command)
- ✅ Ready to use OpenClaw

Go to the dashboard and start building agents!
