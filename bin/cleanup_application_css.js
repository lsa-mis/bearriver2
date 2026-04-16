'use strict'

const fs = require('fs')
const path = require('path')

const cssPath = path.join(__dirname, '..', 'app', 'assets', 'builds', 'application.css')

function fail(message, err) {
  console.error(`cleanup_application_css: ${message}`)
  if (err && err.message) console.error(err.message)
  process.exit(1)
}

if (!fs.existsSync(cssPath)) {
  fail(`CSS file not found: ${cssPath}`)
}

let css
try {
  css = fs.readFileSync(cssPath, 'utf8')
} catch (err) {
  fail(`failed to read ${cssPath}`, err)
}

css = css.replace(/^\s*-webkit-text-size-adjust:\s*100%;\n/m, '')
css = css.replace(/^\s*text-size-adjust:\s*100%;\n/m, '')
css = css.replace(/::-moz-focus-inner\s*\{[^}]*\}\s*/g, '')
css = css.replace(/\.form-range::-moz-focus-outer\s*\{[^}]*\}\s*/g, '')
css = css.replace(/\.form-range:focus::-webkit-slider-thumb\s*\{[^}]*\}\s*/g, '')
css = css.replace(/\.form-range::-webkit-slider-thumb\s*\{[^}]*\}\s*/g, '')
css = css.replace(/\.form-range::-webkit-slider-runnable-track\s*\{[^}]*\}\s*/g, '')
css = css.replace(/\.form-range::-webkit-slider-thumb:active\s*\{[^}]*\}\s*/g, '')
css = css.replace(/\.form-range:disabled::-webkit-slider-thumb\s*\{[^}]*\}\s*/g, '')
css = css.replace(/@media\s*\(prefers-reduced-motion:\s*reduce\)\s*\{\s*\.form-range::-webkit-slider-thumb\s*\{[^}]*\}\s*\}\s*/g, '')
css = css.replace(/@media\s*\(prefers-reduced-motion:\s*reduce\)\s*\{\s*\}\s*/g, '')

try {
  fs.writeFileSync(cssPath, css)
} catch (err) {
  fail(`failed to write ${cssPath}`, err)
}
