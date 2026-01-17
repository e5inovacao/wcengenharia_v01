const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'mirror', 'index.html');
let content = fs.readFileSync(filePath, 'utf8');

// 1. Replace generic URLs in text
content = content.replace(/https:\/\/wcengenharia\.eng\.br/g, '');
content = content.replace(/https:\\\/\\\/wcengenharia\.eng\.br/g, '');

// 2. Fix Elementor Lightbox Base64 hashes
// Pattern: data-e-action-hash="#elementor-action%3Aaction%3Dlightbox%26settings%3D...BASE64..."
const regex = /data-e-action-hash="([^"]+)"/g;

content = content.replace(regex, (match, hash) => {
    try {
        const decodedHash = decodeURIComponent(hash);
        const settingsMatch = decodedHash.match(/settings=([^&]+)/);
        
        if (settingsMatch && settingsMatch[1]) {
            const base64Settings = settingsMatch[1];
            const jsonString = Buffer.from(base64Settings, 'base64').toString('utf8');
            
            // Check if it contains the domain
            if (jsonString.includes('wcengenharia.eng.br')) {
                const newJsonString = jsonString.replace(/https:\\\/\\\/wcengenharia\.eng\.br/g, '');
                const newBase64 = Buffer.from(newJsonString).toString('base64');
                
                const newDecodedHash = decodedHash.replace(base64Settings, newBase64);
                // Elementor hash seems to be encoded simply with encodeURIComponent
                // but usually the hash itself in HTML is just the string. 
                // The match variable includes data-e-action-hash="...".
                // We need to return `data-e-action-hash="${encodeURIComponent(newDecodedHash)}"` 
                // BUT wait, the original was URI encoded in the HTML attribute?
                // Let's look at the file content: 
                // data-e-action-hash="#elementor-action%3Aaction%3Dlightbox%26settings%3DeyJ..."
                // Yes, it is URI encoded.
                // However, the '#' at the start is NOT encoded in the attribute value usually? 
                // In the file: data-e-action-hash="#elementor-action%3Aaction%3Dlightbox%26settings%3DeyJ..."
                // decodeURIComponent("#elementor-action%3Aaction%3Dlightbox%26settings%3D...") 
                // -> "#elementor-action:action=lightbox&settings=..."
                
                // So we reconstruct:
                // 1. Replace base64 in the DECODED string.
                // 2. Encode it back (except the #).
                
                // Let's be careful. The original string `hash` is what was inside quotes.
                // We decoded it. We replaced the base64 part.
                // Now we need to re-encode.
                
                // The 'hash' starts with #. encodeURIComponent encodes # as %23.
                // But typically browsers/Elementor expects # to be there?
                // Looking at the source: `data-e-action-hash="#elementor-action%3A..."`
                // So the # is literal. The rest is encoded.
                
                // Actually, let's just replace the substring in the original `hash` if possible?
                // No, base64 length changes.
                
                // Correct approach:
                // 1. Decode `hash`.
                // 2. Replace base64.
                // 3. Re-encode.
                
                // But `decodeURIComponent` might not handle the # if it's just at the start.
                // Let's strip # first.
                const hasHashPrefix = hash.startsWith('#');
                const cleanHash = hasHashPrefix ? hash.substring(1) : hash;
                const decodedClean = decodeURIComponent(cleanHash);
                
                const newDecodedClean = decodedClean.replace(base64Settings, newBase64);
                
                // Elementor seems to encode everything after #.
                // But wait, the original string in file has `%3A` etc.
                // So yes, we encode.
                
                const newEncoded = encodeURIComponent(newDecodedClean)
                    .replace(/%3D/g, '=') // Sometimes = is not encoded? No, in the file it WAS encoded as %3D.
                    // Let's just use encodeURIComponent and see.
                    // Wait, check the original: "action%3Aaction%3Dlightbox"
                    // : -> %3A, = -> %3D. Correct.
                    // What about &? %26.
                    
                // However, `encodeURIComponent` encodes `&`, `=`, `:`, `,` etc.
                // The # should remain.
                
                return `data-e-action-hash="#${newEncoded}"`;
            }
        }
    } catch (e) {
        console.error('Error processing hash:', e);
    }
    return match;
});

fs.writeFileSync(filePath, content, 'utf8');
console.log('Done processing index.html');
