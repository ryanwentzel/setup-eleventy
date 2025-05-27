#!/bin/bash

# Exit on error
set -e

# Initialize npm and create default package.json
echo ">> Initializing npm"
npm init -y
npm pkg set type="module"

# Install tailwindcss + postcss
echo ">> Installing tailwindcss + postcss and friends"
npm install -D tailwindcss @tailwindcss/postcss postcss postcss-cli autoprefixer cssnano postcss-import

# Install Eleventy
echo ">> Installing @11ty/eleventy"
npm install -D @11ty/eleventy

# Install build tools
echo ">> Installing build tools..."
npm install -D rimraf npm-run-all

# Configure npm scripts
npm pkg set scripts.clean="npx rimraf ./dist"
npm pkg set scripts.css:watch="npx postcss ./src/assets/css/styles.css -o ./dist/assets/css/styles.css --watch --verbose",
npm pkg set scripts.css:build="NODE_ENV=production npx postcss ./src/assets/css/styles.css -o ./dist/assets/css/styles.css --verbose",
npm pkg set scripts.eleventy="npx @11ty/eleventy"
npm pkg set scripts.eleventy:serve="npx @11ty/eleventy --serve"
npm pkg set scripts.dev="npm run clean && npx npm-run-all -p css:watch eleventy:serve"
npm pkg set scripts.build="npx npm-run-all clean css:build eleventy"
npm pkg delete scripts.test

# Create a basic Eleventy config file
echo ">> Creating eleventy.config.js"
cat > eleventy.config.js <<EOF
export default async function(eleventyConfig) {
    eleventyConfig.setInputDirectory("src");
    eleventyConfig.setIncludesDirectory("_includes");
    eleventyConfig.setLayoutsDirectory("_layouts");
    eleventyConfig.setOutputDirectory("dist");

    eleventyConfig.addWatchTarget("./src/assets/css/styles.css");
};

export const config = {
    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk"
};
EOF

# Create postcss config
echo ">> Creating postcss.config.mjs"
cat > postcss.config.mjs <<EOF
export default {  
    plugins: {
        "postcss-import": {},
        "autoprefixer": {},
        "@tailwindcss/postcss": {},
        "cssnano": {}  
    }
}
EOF

# Create default src directory and index file
mkdir -p src
cat > src/index.md <<EOF
---
layout: default.njk
title: Hello, Eleventy!
---
Build something already.

EOF

mkdir -p src/_layouts
cat > src/_layouts/default.njk <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ title or "Document" }}</title>
    <link rel="stylesheet" href="/assets/css/styles.css">
</head>
<body class="min-h-screen bg-lime-500 p-8 md:p-16">
    <div class="md:container md:mx-auto bg-white p-8 md:p-16">
        <h1 class="text-3xl">{{ title }}</h1>
        <div class="mt-5">
            {{ content | safe }}
        </div>
    </div>
</body>
</html>
EOF

mkdir -p src/assets/css
cat > src/assets/css/styles.css <<EOF
@import "tailwindcss";

@layer base {
    body {
        font-family: monospace;
    }
    h1 {
        font-size: 2.5rem;
    }
}

EOF

# Create gitignore
echo ">> Creating .gitignore"
cat > .gitignore <<EOF
node_modules/
dist/

EOF

echo ">> Eleventy project setup complete in $(pwd)"
