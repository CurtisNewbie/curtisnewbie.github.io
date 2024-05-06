---
layout: post
title:  "Random Ideas"
date:   2024-04-15 19:00:00 +0800
categories: Ideas
---

List of random ideas:

- [ ] Implement a mini version of Git to understand how it works.
- [ ] Implement a simple B+ tree based database.
- [ ] Implement a mini-redis using java like the [curtisnewbie/mini-redis](https://github.com/curtisnewbie/mini-redis) one in golang.
    - Call it mini-jredis maybe, just try to be more familiar with socket programming in java.
- [ ] Have a look at netflix/conductor, understand roughly how it works and implement a mini workflow engine.
    - It does seem like a workflow engine is roughly a distributed queue + an orchestrator service + some definitions of worker.
    - https://github.com/Netflix/conductor
    - https://github.com/conductor-sdk/conductor-examples/tree/main
    - https://orkes.io/content/
- [ ] Document how to use pprof in golang.
- [ ] Write something about jvm performance evaluation. Document all the means to identify performance issue, e.g., CPU/IO/GC and so on.
- [x] Implement a simple CI/CD application.
    - [https://github.com/curtisnewbie/chill](https://github.com/curtisnewbie/chill)
- [ ] Implement a rule engine.
    - [https://github.com/curtisnewbie/octopus](https://github.com/curtisnewbie/octopus)