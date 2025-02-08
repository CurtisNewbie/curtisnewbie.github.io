---
layout: post
title: "How to patch node_module source code"
date: 2024-09-10 15:39:00 +0800
categories: Learning
---

**Credits:**

- https://stackoverflow.com/questions/72820625/what-is-the-proper-way-to-patch-a-node-modules-module

Install all your dependencies, make sure `/node_modules` is properly installed:

```sh
npm ci
```

Install patche-packages and postinstall dependencies:

```sh
npm install patch-package postinstall-postinstall
```

Modify `package.json` to automatically apply patches after install:

```json
{
  // ...
  "scripts": {
    // ...
    "postinstall": "patch-package"
  }

  // ...
}
```

Modify code in `/node_modules`, e.g., Changing `highlight.js` source code as below:

```ts
// before the change
regex: {
    concat: (...args: (RegExp | string)[]) => string,
    lookahead: (re: RegExp | string) => string,
    either: (...args: (RegExp | string)[] | any) => string,
    optional: (re: RegExp | string) => string,
    anyNumberOfTimes: (re: RegExp | string) => string
}
newInstance: () => HLJSApi

// after the change
regex: {
    concat: (...args: (RegExp | string)[]) => string,
    lookahead: (re: RegExp | string) => string,
    either: (...args: (RegExp | string)[] | any) => string, // <<<<<<<< Change this
    optional: (re: RegExp | string) => string,
    anyNumberOfTimes: (re: RegExp | string) => string
}
newInstance: () => HLJSApi
```

Create patch using `npx`:

```sh
npx patch-package highlight.js
```

Patch file is created at `/patches` folder, it looks this:

Filename: `highlight.js+11.9.0.patch`

```
diff --git a/node_modules/highlight.js/types/index.d.ts b/node_modules/highlight.js/types/index.d.ts
index 1941e61..8b4d959 100644
--- a/node_modules/highlight.js/types/index.d.ts
+++ b/node_modules/highlight.js/types/index.d.ts
@@ -53,7 +53,7 @@ declare module 'highlight.js' {
         regex: {
             concat: (...args: (RegExp | string)[]) => string,
             lookahead: (re: RegExp | string) => string,
-            either: (...args: (RegExp | string)[] | [...(RegExp | string)[], RegexEitherOptions]) => string,
+            either: (...args: any) => string, // <<<<<<<< Change this
             optional: (re: RegExp | string) => string,
             anyNumberOfTimes: (re: RegExp | string) => string
         }
```
