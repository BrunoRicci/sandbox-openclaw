# 🚀 Get Started — 3 Steps

## 1️⃣ Start the Gateway

```bash
npm run gateway
```
→ Gateway running on port 18789
→ Keep this terminal open (or open a new one for next steps)

---

## 2️⃣ Connect Dashboard

```bash
npm start
```
→ Opens URL in browser
→ Auto-approves device
→ Done ✅

---

## 3️⃣ Connect your model provider

Choose provider: **OpenAI** | **Anthropic** | **Azure** | **Bedrock** | **Ollama** | **Copilot**
→ Enter API key
→ Done ✅

```bash
npm run setup
```

---
---

## 🎉 You're Set!

| What | Command |
|------|---------|
| Start gateway | `npm run gateway` |
| Dashboard URL | `npm start` |
| Configure model | `npm run setup` |
| Check status | `npm run health` |
| Regenerate token | `npm run init` |

---

## 🆘 Quick Fix

| Problem | Fix |
|---------|-----|
| Dashboard won't open | `npm run health` → `npm start` |
| Model not working | `npm run setup` |
| Gateway crashed | `npm run gateway` |

---

📖 **More details:** [LIFECYCLE.md](LIFECYCLE.md) | [README.md](README.md)
