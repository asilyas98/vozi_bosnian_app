import fs from 'node:fs';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';
process.chdir(fileURLToPath(new URL('../', import.meta.url)));

const config = JSON.parse(fs.readFileSync('capacitor.config.json', 'utf8'));
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
const lock = JSON.parse(fs.readFileSync('package-lock.json', 'utf8'));
for (const section of ['dependencies', 'devDependencies']) {
  assert.deepEqual(pkg[section], lock.packages[''][section], `${section} and lockfile must match`);
}
for (const file of [
  'ios/App/App.xcodeproj/project.pbxproj',
  'ios/App/App.xcodeproj/xcshareddata/xcschemes/App.xcscheme',
  'ios/App/CapApp-SPM/Package.swift',
  'www/index.html',
  'ios/App/App/public/index.html',
  'www/vendor/leaflet.js',
  'www/vendor/leaflet.css',
]) assert.ok(fs.existsSync(file), `Missing file: ${file}`);
const pbx = fs.readFileSync('ios/App/App.xcodeproj/project.pbxproj', 'utf8');
assert.ok(pbx.includes(`PRODUCT_BUNDLE_IDENTIFIER = ${config.appId};`), 'Bundle ID differs between Capacitor and Xcode');
const html = fs.readFileSync('www/index.html', 'utf8');
assert.equal(html, fs.readFileSync('ios/App/App/public/index.html', 'utf8'), 'Run npm run sync:ios after changing www');
const scripts = [...html.matchAll(/<script(?:\s[^>]*)?>([\s\S]*?)<\/script>/g)];
for (const [, script] of scripts) if (script.trim()) new vm.Script(script);
console.log(`Preflight passed: ${config.appName}, ${config.appId}; native/web inputs and JavaScript valid.`);
