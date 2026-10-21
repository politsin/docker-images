#!/bin/sh
set -eu
# A sibling of /var/www exercises imports without touching mounted projects.
work=$(mktemp -d /var/frontend-smoke.XXXXXX)
trap 'rm -rf "$work"' EXIT
cd "$work"
node - <<'EOF'
const sass = require('sass');
const result = sass.compileString('$c: red; .test {color: $c}');
if (!result.css.includes('color: red')) process.exit(1);
for (const name of ['gulp', 'gulp-watch', 'gulp-plumber', 'gulp-touch-cmd', 'gulp-sourcemaps', 'gulp-sass', 'node-sass']) require(name);
EOF
cat > eslint.config.mjs <<'EOF'
import js from '@eslint/js';
import globals from 'globals';
export default [{languageOptions: {globals: globals.browser}, rules: js.configs.recommended.rules}];
EOF
printf 'console.log("ok");\n' > valid.js
eslint valid.js
printf 'unknownVariable();\n' > invalid.js
if eslint invalid.js; then echo 'ESLint missed an error' >&2; exit 1; fi
cat > stylelint.config.mjs <<'EOF'
export default {
  extends: ['stylelint-config-recommended-scss'],
  plugins: ['stylelint-order'],
  rules: {'order/properties-alphabetical-order': true},
};
EOF
printf '$color: red;\n.example { color: $color; }\n' > valid.scss
stylelint valid.scss
printf '.example { unknown-property: red; }\n' > invalid.scss
if stylelint invalid.scss; then echo 'Stylelint missed an error' >&2; exit 1; fi
printf 'root = true\n[*]\nindent_style = space\nindent_size = 2\ninsert_final_newline = true\ntrim_trailing_whitespace = true\n' > .editorconfig
editorconfig-checker valid.js
printf 'text  \n' > invalid.txt
if editorconfig-checker invalid.txt; then echo 'EditorConfig checker missed trailing whitespace' >&2; exit 1; fi
echo FRONTEND_SMOKE_OK
