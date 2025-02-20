---
layout: post
title: "Innodb Internals"
date: 2025-02-08 09:00:00 +0800
categories: Learning
hidden: 1
---

> This post documents stuff about InnoDB, it's meant for me to recall all the details that I may have forgetten over the years. It's not a complete guide to MySQL or InnoDB.

## 1. Sources

- [MySQL 8.0 - InnoDB Introduction](https://dev.mysql.com/doc/refman/8.0/en/innodb-introduction.html)

## 2. Basics

- Durability and Recovery, based on WAL (Binlog, Redo Log) and the Doublewrite Buffer.
- Large Buffer Pool for caching, improve processing speed (linked list of data pages using LRU algorithm).
- Change Buffer (also called Insert Buffer, part of the Buffer Pool) for optimizing write operations, cache changes to secondary indexes.
- Adaptive Hash Index (in Buffer Pool) for fast table lookup.
- Clustered Index and Secondary Index.
- Support Data Page Checksum.
- Online DDL (since 8.0).
- Monitor internals and performance through `INFORMATION_SCHEMA` and `PERFORMANCE_SCHEMA`.

#### Commands

Check engines available, check if InnoDB is the default engine.

```sql
SHOW ENGINES;

SELECT * FROM INFORMATION_SCHEMA.ENGINES;
```

Check InnoDB Status:

```sh
SHOW ENGINE INNODB STATUS
```

#### ACID

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

## 3. MVCC Multi-Versioning Concurrency Control

InnoDB supports concurrent transactions using various locks and MVCC. MVCC stands for Multi-Version Concurrency Control, it's mainly used to optimize Read operations, supporting Transaction Isolation and Read Consistency without using extra locks, though certain features in MVCC also help Transaction Rollback.

The core concept that MVCC introduces is the versioning / snapshoting data (rows). With MVCC, InnoDB keeps multiple snapshot of the same row. As rows are created, modified or deleted, all these relevent snapshots are kept in place to support the Consistent View.

Each transaction is associated with a version, and each transaction can *"only"* see the snapshots that were created during or before the transaction (not including `READ UNCOMMITED` of course). In certain Isolation Level, e.g., `REPEATABLE READ`, transactions always see the same snapshot of data since the begining of the transaction as if the rows are never modified.

#### InnoDB MVCC Implementation

InnoDB add three fields to each row:

- `DB_TRX_ID`: 6 byte field to indicate the last transaction_id that inserted or updated the row. Deletion is also treated as an update to a special bit in row that is marked as deleted.
- `DB_ROLL_PTR`: 7 byte field that points to a undo log record written to the rollback segment. Undo log record contains information about the row before it was updated.
- `DB_ROW_ID`: 6 byte field that contains a row id, if the table DDL doesn't specify the primary key for clustered index, then this field is not used.

Undo logs are divided into insert and update undo logs:

- Insert Undo Logs:
  - records inserted
- Update Undo Logs:
  - records updated
  - records deleted

Insert Undo Logs are only used to rollback transaction for the newly inserted rows, as soon as the transaction is commited, engine is freee to delete the Insert Undo Logs.

Update Undo Logs are used to build a snapshot of data for earlier versions. Rows deletion is implemented through fliping a special bit on each row, so row deletion is essentially the same as row updation. Update Undo Logs are kept until no transaction can build a consistent view for the associated snapshots of rows.

Each transaction is assigned to a transaction_id since the beginning of the transaction, and the transaction_id increases monotonically. At any moment, InnoDB knows what the minimum transaction_id is and thus can purge undo logs built by transactions prior to the minimum transaction_id. In InnoDB, rows are modified in place, so transaction either reads rows directly (e.g., if the rows are not modified or modified within the transaction) or builds snapshot based on the row data and the undo logs.

If transactions do not commit, the associated Undo Logs cannot be purged. Recall that Rows Deletion is implemented by fliping a special bit on the row, which means that the rows deleted are not immediately, physically removed from the database, they are still visible to transactions that have certain transaction_ids. These deleted rows are only physically purged (including indexes) when the associated Undo Logs are purged, which simply means that they are nolonger visible to any transcation. Rows are physically purged by a background thread called `Purge Thread`.

E.g.,

<!--

Tx -> InnoDB: query rows
InnoDB -> Storage: locate rows, check deletion mark, compare trx_id
Storage -> InnoDB: Undo Log ROLL_PTR
InnoDB -> Undo Log (Buffer Pool): compare trx_id, build snapshot
Undo Log (Buffer Pool) -> Undo Log (Disk): cache miss
InnoDB -> Tx: rows (visible snapshots)

-->

```
 ┌──┐                   ┌──────┐                                        ┌───────┐┌──────────────────────┐┌───────────────┐
 │Tx│                   │InnoDB│                                        │Storage││Undo Log (Buffer Pool)││Undo Log (Disk)│
 └┬─┘                   └──┬───┘                                        └───┬───┘└──────────┬───────────┘└───────┬───────┘
  │                        │                                                │               │                    │
  │       query rows       │                                                │               │                    │
  │───────────────────────>│                                                │               │                    │
  │                        │                                                │               │                    │
  │                        │locate rows, check deletion mark, compare trx_id│               │                    │
  │                        │───────────────────────────────────────────────>│               │                    │
  │                        │                                                │               │                    │
  │                        │               Undo Log ROLL_PTR                │               │                    │
  │                        │<───────────────────────────────────────────────│               │                    │
  │                        │                                                │               │                    │
  │                        │                 compare trx_id, build snapshot │               │                    │
  │                        │───────────────────────────────────────────────────────────────>│                    │
  │                        │                                                │               │                    │
  │                        │                                                │               │     cache miss     │
  │                        │                                                │               │───────────────────>│
  │                        │                                                │               │                    │
  │rows (visible snapshots)│                                                │               │                    │
  │<───────────────────────│                                                │               │                    │
 ┌┴─┐                   ┌──┴───┐                                        ┌───┴───┐┌──────────┴───────────┐┌───────┴───────┐
 │Tx│                   │InnoDB│                                        │Storage││Undo Log (Buffer Pool)││Undo Log (Disk)│
 └──┘                   └──────┘                                        └───────┘└──────────────────────┘└───────────────┘

```

#### Secondary Index

In Clustered Index, rows are updated in-place, historical snapshots are built by reading undo logs that the `DB_ROLL_PTR` points to. However, in Secondary Index, modified index records are always marked deleted, and new index records (the updated ones) are always inserted. So, physically, a Secondary Index Tree can contain duplicate index key values (for MVCC), even though the Secondary Index has Unique Constraint.

When InnoDB reads Secondary Index, in following circumstances, Convering Index Technique is not used:

- Secondary Index Record is marked deleted.
- Secondary Index Page is updated by a newer transaction.

In these cases, InnoDB performs normal table lookup on Clustered Index and Undo Logs, even though all columns are convered by the Secondary Index.

Since it's very likely that transactions need to read Clustered Index and Undo Logs to build snapshots, InnoDB optimize these operations by caching the Data Pages and Undo Log Pages using LRU algorithm. Then, for frequently accessed data (including the Undo Logs), the data look up might be performed completely in momery.

## 4. InnoDB Architecture

<img height="500px" src="https://dev.mysql.com/doc/refman/8.0/en/images/innodb-architecture-8-0.png" />

> image source: https://dev.mysql.com/doc/refman/8.0/en/innodb-architecture.html

- In-Memory
    - Buffer Pool
    - Change Buffer
    - Adaptive Hash Index
    - Log Buffer

- On-Disk
    - Tables
    - Indexes
    - Tablespaces
    - Doublewrite Buffer
    - Redo Logs
    - Undo Logs

#### In-Memory Buffer Pool

Buffer Pool caches frequently accessed table and index data (including both the index pages, data pages and Secondary Index pages), up to 80% of the physically memory is often assigned to this memory area. In Buffer Pool, data are divided into pages (just like the tables on disk), these pages are maintained using a linked list and LRU (Least Recently Used) algorithm.

<img height="400px" src="https://dev.mysql.com/doc/refman/8.0/en/images/innodb-buffer-pool-list.png"/>

> image source: https://dev.mysql.com/doc/refman/8.0/en/innodb-buffer-pool.html

The linked list is divided into two sublist, one named `New Sublist` that stores pages recently accessed, and another named `Old Sublist` that stores pages that were accessed less recently.

The head is the `New Sublist` with the most recently access pages, and the tail is the `Old Sublist` with the least recently access pages. By dault, 3/8 of the pool is assigned to the `Old Sublist` and the remaining 5/8 is assigned to `New Sublist`.

New Pages are inserted at the midpoint of the list (the head of the `Old Sublist`). As pages on the list are accessed, they are moved to the head of the list (also the head of the `New Sublist`), making them *"young"*. Then, naturally, the pages that are less recently accessed are moved towards the end the list as other pages are moved to the head of the list. This process is called aging.

If a page is never accessed, eventually, it will be moved to the tail of the linked list and then get evicted.

So, in essence, the Buffer Pool should be made as large as possible. Though a full table scan for a large table may easily break the Buffer Pool Cache.

Use `'SHOW ENGINE INNODB STATUS'` to check InnoDB Engine Status, About the Buffer Pool metrics: [https://dev.mysql.com/doc/refman/8.0/en/innodb-buffer-pool.html](https://dev.mysql.com/doc/refman/8.0/en/innodb-buffer-pool.html).


```sh
SHOW ENGINE INNODB STATUS

# ----------------------
# BUFFER POOL AND MEMORY
# ----------------------
# Total large memory allocated 0
# Dictionary memory allocated 24475827
# Buffer pool size   196539
# Free buffers       4096
# Database pages     192443
# Old database pages 70873
# Modified db pages  1559
# Pending reads      0
# Pending writes: LRU 0, flush list 0, single page 0, flush chunk 0
# Pages made young 316623327, not young 477690611
# 23.70 youngs/s, 64.04 non-youngs/s
# Pages read 9309080, created 7809533, written 125995449
# 3.89 reads/s, 0.71 creates/s, 7.84 writes/s
# Buffer pool hit rate 1000 / 1000, young-making rate 0 / 1000 not 2 / 1000
# Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
# LRU len: 192443, unzip_LRU len: 0
# I/O sum[4248]:cur[64], unzip sum[0]:cur[0]
```

`Total large memory allocated` can be 0 if Buffer Pool Size is very large:

```sql
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
```

#### In-Memory Change Buffer

Change Buffer caches changes to (Non-Unique) Secondary Index Pages if the page is not cached in Buffer Pool. If the index page is already cached in Buffer Pool, the changes can be applied directly to that cached page.

It's for the Secondary Index, thus doesn't contain actual rows and columns that are modified by transactions. Think of it as a cache created exclusively for Secondary Index Pages, while the Buffer Pool is a cache for both data and index pages (including Secondary Index).

<img height="300px" src="https://dev.mysql.com/doc/refman/8.0/en/images/innodb-change-buffer.png" />

> image source: https://dev.mysql.com/doc/refman/8.0/en/innodb-change-buffer.html

Change Buffer is periodically merged into Buffer Pool, since Buffer Pool caches all kinds of table and index data. This is primary to prevent substantial random access I/O while updating the Secondary Index on disk.

When a query needs to access data from Secondary Index Pages, InnoDB traverses the Secondary Index Tree, read the Buffer Pool cache (Read-Through Stragtegy) and load index pages from disk if necessary. While InnoDB reading the Secondary Index, it merges the pending changes in Change Buffer into the loaded Secondary Index Pages such that the not yet persisted changes to the Secondary Index are still visible.

In fact, same optimization strategy is also used for updating rows, where the newly updated rows are cached in Buffer Pool, and are periodically merged to disk by background threads. This way, write operations are less frequently performed, and some of content are written sequentially if the modified data resides in the same page. InnoDB can choose to merge Buffer Pool and Change Buffer when the server is nearly idle.

Incrase size of Change Buffer if there are lots of Secondary Indexses, but Change Buffer is part of the Buffer Pool thus may occupy some of the space, we may well just incrase size of both of them. By dault, Change Buffer at most occupies 25% of the space of Buffer Pool.

To check the status of Change Buffer:

```sh
SHOW ENGINE INNODB STATUS

# -------------------------------------
# INSERT BUFFER AND ADAPTIVE HASH INDEX
# -------------------------------------
# Ibuf: size 1, free list len 695, seg size 697, 43022 merges
# merged operations:
#  insert 62803, delete mark 4411134, delete 45335
# discarded operations:
#  insert 0, delete mark 0, delete 0
# Hash table size 103, node heap has 0 buffer(s)
# Hash table size 103, node heap has 0 buffer(s)
# Hash table size 103, node heap has 0 buffer(s)
# Hash table size 103, node heap has 0 buffer(s)
# Hash table size 103, node heap has 0 buffer(s)
# Hash table size 103, node heap has 0 buffer(s)
# Hash table size 103, node heap has 0 buffer(s)
# Hash table size 103, node heap has 0 buffer(s)
# 0.00 hash searches/s, 1076.91 non-hash searches/s
```

#### In-Memory Adaptive Hash Index

Adaptive Hash Index is for speeding up index lookup (both Clustered Index and Secondary Index). It's adaptive in that it monitors index searches, if it believes that building a hash structure for indexes can greatly improve query performance, it will create such data structure in memory (as part of Buffer Pool), trying to turn B+ Tree traversal to hash-based key-value lookup.

AHI is built using a prefix of the index key. AHI is built on demand only for the pages are frequently accessed.

For example, in a typical JOIN operation: `table_a JOIN table_b ON col_j`

We have the following Nested Loop Join:

<pre>
<b>FOR</b> ptr_a <b>IN</b> table_a:
    <b>WALK</b> table_b <b>FIND</b> ptr_a.col_j <b>AS</b> ptr_b:       <i style="color: green"># Traverse table_b's index tree</i>
        <b>YIELD</b> ptr_b
<b>END</b>
</pre>

Which can be optimized with Adaptive Hash Index like the following:

<pre>
<b>FOR</b> ptr_a <b>IN</b> table_a:
    ptr_B, ok = <span style="color: blue">HASH_FIND(</span> table_b, ptr_a.col_j <span style="color: blue">)</span> <i style="color: green"># Adaptive Hash Index Lookup</i>
    <b>IF</b> ok:                                        <i style="color: green"># Cache Hit</i>
        <b>YIELD</b> ptr_b
    <b>ELSE</b>:                                         <i style="color: green"># Cache Miss</i>
        <b>WALK</b> table_b <b>FIND</b> ptr_a.col_j <b>AS</b> ptr_b:   <i style="color: green"># Traverse table_b's index tree</i>
            <b>YIELD</b> ptr_b
<b>END</b>
</pre>

Adaptive Hash Index can also be a source of contention under heavy workloads, e.g., concurrent joins. In certain cases, AHI isn't very useful, e.g., range scans.

#### In-Memory Log Buffer (Redo Log)

Log Buffer contains Redo Log file data that has not yet been written to disk. By default, Log Buffer's size is 16 MB. The contents of the Log Buffer is periodically flushed to disk (based on configuration).

Variable `innodb_flush_log_at_trx_commit` controls when logs are written and flushed to disk, and `innodb_flush_log_at_timeout` controls log flushing frequency.

```sh
show variables like 'innodb_flush_log%';

# +--------------------------------+-------+
# | Variable_name                  | Value |
# +--------------------------------+-------+
# | innodb_flush_log_at_timeout    | 1     |
# | innodb_flush_log_at_trx_commit | 1     |
# +--------------------------------+-------+
```

Options available for variable `innodb_flush_log_at_trx_commit` :

- 0: written and flushed once per second
- 1: written and flushed at transaction commit (**default**)
- 2: written at transaction commit and flushed once per second

Variable `innodb_flush_log_at_timeout`, defaults to 1, controls how frequent the Log Buffer is written and flushed: *"write and flush logs every N seconds"*.

#### On-Disk Tables

By default, InnoDB creates table in file-per-table tablespaces.

To view status of a table:

```sql
SHOW TABLE STATUS FROM ... LIKE '...';
```

Tablespace:

- `innodb_file_per_table`, File Per Table Tablespace **(default)**


