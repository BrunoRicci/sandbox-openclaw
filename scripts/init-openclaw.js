const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const CONFIG_PATH = './.openclaw-config.json';

console.log('🔧 Initializing OpenClaw...');

// Leer o crear config
let config = {};
if (fs.existsSync(CONFIG_PATH)) {
  config = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf8'));
}

// Generar token nuevo
const token = crypto.randomBytes(32).toString('hex');
config.gateway = config.gateway || {};
config.gateway.auth = config.gateway.auth || {};
config.gateway.auth.token = token;

// Guardar config
fs.writeFileSync(CONFIG_PATH, JSON.stringify(config, null, 2));

console.log('\n\nnew token -->  ' + token + ' \n\n');