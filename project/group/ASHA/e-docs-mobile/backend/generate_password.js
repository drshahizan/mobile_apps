const bcrypt = require('bcrypt');

const passwords = {
  'admin123': null,
  'user123': null
};

async function generateHashes() {
  console.log('Generating password hashes...\n');
  
  for (const [password, _] of Object.entries(passwords)) {
    const hash = await bcrypt.hash(password, 10);
    console.log(`Password: ${password}`);
    console.log(`Hash: ${hash}\n`);
  }
}

generateHashes();
