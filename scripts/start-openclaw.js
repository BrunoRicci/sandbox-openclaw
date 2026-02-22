const { execSync } = require('child_process');
const fs = require('fs');

const CONFIG_PATH = './.openclaw-config.json';
const PORT = 18789;
const POLL_INTERVAL_MS = 2000;
const POLL_TIMEOUT_MS = 120000;

function printBanner(url) {
  const banner = `
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║  🌐 Open in browser: ${url}  ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
  `;
  console.log('\x1b[46m\x1b[30m' + banner + '\x1b[0m');
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function waitForDevice() {
  console.log('👀 Waiting for device connection (up to 2 min)...\n');
  const deadline = Date.now() + POLL_TIMEOUT_MS;

  while (Date.now() < deadline) {
    await sleep(POLL_INTERVAL_MS);
    try {
      const out = execSync('npx openclaw devices list --json', { stdio: 'pipe' }).toString();
      const { pending } = JSON.parse(out);
      if (pending && pending.length > 0) {
        console.log(`\n🔐 Device pending — approving...`);
        execSync('npx openclaw devices approve --latest', { stdio: 'inherit' });
        console.log('✅ Device approved');
        return;
      }
    } catch (_) {}
  }

  console.log('⏱  No device connected within timeout. Run `npx openclaw devices approve --latest` manually.');
}

(async () => {
  try {
    execSync(`code ${CONFIG_PATH}`);
  } catch (_) {}

  const config = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf8'));
  const token = config.gateway.auth.token;

  if (!token) {
    console.log('⚠️  No token found in config. Run `npm run init`.');
    process.exit(1);
  }

  const codespace = process.env.CODESPACE_NAME;
  const domain = process.env.GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN;

  const publicUrl = codespace && domain
    ? `https://${codespace}-${PORT}.${domain}/#token=${token}`
    : `http://localhost:${PORT}/#token=${token}`;

  printBanner(publicUrl);

  try {
    execSync(`open "${publicUrl}"`);
  } catch (_) {}

  await waitForDevice();
})();
