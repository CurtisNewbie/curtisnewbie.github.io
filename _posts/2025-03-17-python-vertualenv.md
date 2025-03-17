---
layout: post
title: "python virtualenv"
date: 2025-03-17 09:00:00 +0800
categories: Learning
hidden: 0
---

# How

1. install pip
2. install virtualenv

```sh
python3.11 -m pip install virtualenv
```

3. mkdir for new project (e.g.,, 'myproject')

```sh
mkdir myproject
cd myproject
```

4. create virtualenv (named 'myproject')

```sh
virtualenv myproject
```

5. activate virtualenv ('myproject')

```sh
source ./bin/activate
```

6. install stuff using pip, e.t.c.,

```sh
python3.11 -m pip install ...
```

7. All installed libraries are located at: ./lib/python***/site-packages

8. deactivate virtualenv

```sh
deactivate
```

9. if you to delete the entire virtual environment

```sh
sudo rm -rf myproject
```

# Source

- https://stackoverflow.com/questions/35017160/how-to-use-virtualenv-with-python
