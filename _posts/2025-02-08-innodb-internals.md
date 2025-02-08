---
layout: post
title: "Innodb Internals"
date: 2025-02-08 09:00:00 +0800
categories: Learning
hidden: 1
---

> This post documents stuff about InnoDB, it's meant for me to recall all the details that I may forget over the years. It's not a complete guide to MySQL or InnoDB.

## Sources

- [MySQL 8.0 - InnoDB Introduction](https://dev.mysql.com/doc/refman/8.0/en/innodb-introduction.html)

## Features / Benefits

- Durability and Recovery, based on WAL (Binlog, Redo Log) and the Doublewrite Buffer.
- Large Buffer Pool for caching, improve processing speed (linked list of data pages using LRU algorithm).
- Change Buffer (also called Insert Buffer, part of the Buffer Pool) for optimizing write operations, cache changes to secondary indexes.
- Adaptive Hash Index (in Buffer Pool) for fast table lookup.
- Clustered Index and Secondary Index.
- Support Data Page Checksum.
- Online DDL (since 8.0).
- Monitor internals and performance through `INFORMATION_SCHEMA` and `PERFORMANCE_SCHEMA`.

## Basics


Check engines available, check if InnoDB is the default engine.

```sql
SHOW ENGINES;

SELECT * FROM INFORMATION_SCHEMA.ENGINES;
```

## ACID

InnoDB complies with ACID model (not 100%, but almost, there can be Phantom Read in certain corner cases):

- A: Atomicity
    - Transaction / Grouped Transaction, e.g., BEGIN, COMMIT, ROLLBACK
- C: Consistency
    - WAL, Doublewrite Buffer
- I: Isolation
    - Transaction Isolation
        - `READ UNCOMMITED`
        - `READ COMMITED`
        - `REPEATABLE READ`
        - `SERIALIZABLE`
- D: Durability
    - WAL (logs and the `innodb_flush_log_at_trx_commit` config), Doublewrite Buffer

## MVCC Multi-Versioning

InnoDB supports concurrent transactions using various locks and MVCC. MVCC stands for Multi-Version Concurrency Control, it's mainly used for Read operations, supporting Transaction Isolation and Read Consistency without using extra locks.

The core concept that MVCC introduces is the version / snapshot of data (rows). With MVCC, InnoDB keeps multiple snapshot (versions) of the same row. As rows are created, modified or deleted, all these relevent snapshots are kept in place to support the Consistent View.

Each transaction is associated with a version, and each transaction can *"only"* see the snapshots that were created during or before the transaction (not including `READ UNCOMMITED` of course). In certain Isolation Level, e.g., `REPEATABLE READ`, transactions always see the same snapshot of data since the begining of the transaction as if the rows are never modified.

## InnoDB MVCC Implementation





