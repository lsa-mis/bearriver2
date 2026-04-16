const fs = require('fs')
const path = require('path')

const cssPath = path.join(__dirname, '..', 'app', 'assets', 'builds', 'application.css')

let css = fs.readFileSync(cssPath, 'utf8')

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

fs.writeFileSync(cssPath, css)
