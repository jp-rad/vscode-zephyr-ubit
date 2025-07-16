const fs = require('fs');
const { createUniversalHex } = require('@microbit/microbit-universal-hex');

function checkHex(path) {
  if (!fs.existsSync(path)) {
    throw new Error('HEX file not found: ' + path);
  }
  const data = fs.readFileSync(path, 'utf8');
  if (!data.trim()) {
    throw new Error('HEX file is empty: ' + path);
  }
  return data;
}

const [,, V1_HEX, V2_HEX, OUT] = process.argv;

const v1 = V1_HEX || './builds/bbc_microbit/zephyr/zephyr.hex';
const v2 = V2_HEX || './builds/bbc_microbit_v2/zephyr/zephyr.hex';
const out = OUT || './microbit-universal.hex';

console.log('🧩 Generating Universal HEX...');
console.log('  V1_HEX:', v1);
console.log('  V2_HEX:', v2);

const hexV1 = checkHex(v1);
const hexV2 = checkHex(v2);

// Provide boardId for each hex (V1: 0x9900, V2: 0x9903)
const universalHex = createUniversalHex([
  { hex: hexV1, boardId: 0x9900 },
  { hex: hexV2, boardId: 0x9903 }
]);
fs.writeFileSync(out, universalHex);

console.log('✅ Universal HEX created at:', out);
