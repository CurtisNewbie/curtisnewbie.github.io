---
layout: post
title: "Extract Chrome Cookies"
date: 2025-02-20 09:00:00 +0800
categories: Learning
hidden: 0
---

<!-- ## Why

Some websites store secrets and tokens in cookies that are not easily retrieved with a few simple http requests.

We as the developer, sometimes, need to write simple automation scripts to scrape the data from the website to make life a bit easier, and this post documents how to do it using Python.

## How -->

# How

Install Python3 dependency `browser-cookie3`:

e.g.,

```sh
python3.11 -m pip install browser-cookie3
```

Import `browser_cookies3` dependency, and read cookies for a domain:

```py
import browser_cookie3

cookies = browser_cookie3.chrome(domain_name='google.com')
```

Notice that cookies are sometimes associated with different paths, you may need cookies for the sub-domains as well, in which case, you may will just call `browser_cookie3.chrome(...)` multiple times.

e.g.,

```py
cookies = browser_cookie3.chrome(domain_name='xxx.google.com')
```

The most useful fields are `name` and `value`, we can iterate the cookies and use them in requests:

```py
import browser_cookie3

joined = []
for c in browser_cookie3.chrome(domain_name='google.com'):
    joined.append(f"{c.name}={c.value}")
cookie = "; ".join(joined)

res = requests.get("https://www.google.com", headers={ 'cookie': cookie })
print(res.code)
print(res.text)
```

If you run the Python script, and the OS asks for password, it's okay, becuase cookies are sensitive data stored in place protected by the OS.

# Links

- [github.com/borisbabic/browser_cookie3](https://github.com/borisbabic/browser_cookie3)