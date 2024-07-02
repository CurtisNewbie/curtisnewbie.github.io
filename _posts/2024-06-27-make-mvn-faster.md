---
layout: post
title: "Make mvn faster"
date: 2024-06-27 17:00:00 +0800
categories: Learning
---

### 1. Brief

The followings are some of the tricks that I am using to make mvn run faster, all of these ideas are from the Internet, but unfortunately I forgot where they were from.

These tricks indeed work on my machine (Macbook Pro m2 and m3) with noticeable speedup, but I recommend you to always measure the result before you make any judgement.

How much these tricks improve the performance may also depend on your project, dependencies and so on.

### 2. Tricks

#### 2.1 Enable multi-threading

Compiling code with multiple threads may speed up the process a little bit, though it depends on whether your dependencies support multi-threading.

In the following example, we are compiling with `Num of Cores * 1` threads. E.g., `2C` is equivalent to `Num of Cores * 2`.

```sh
mvn compile -T 1C
```

You can also explicitly configure exactly how many threads you want to use:

```sh
# 2 threads
mvn compile -T 2
```

#### 2.2 Enable offline mode

Enable offline mode allows you to compile project without attempting to pull remote dependencies. It's useful if you know that you have already got the latest dependencies or you simply don't care. This can bring huge performance boost, especially if your network is unacceptably slow.

```sh
mvn compile -o
```

#### 2.3. Skip running tests

With this flag included, tests are compiled but not executed.

```sh
mvn compile -DskipTests
```

#### 2.4. Skip compiling tests

With this flag included, test artifacts for the project are not compiled at all.

```sh
mvn compile -Dmaven.test.skip=true
```

#### 2.5. Skip javadoc generation

If you are deploying packages to remote repository as dependencies, then you should almost always include JavaDoc in the generated packages.

However, if you are just compiling the code for testing or deployment (as an app), then you don't really need the javadoc. You can skip the javadoc generation as below to speed up the process.

```sh
mvn compile -Dmaven.javadoc.skip=true
```

You can also disable javadoc linting as below:

```sh
mvn compile -DadditionalJOption=-Xdoclint:none
```

#### 2.6. Disable mvn JVM TieredCompilation and increase heap size

As we all know that JVM uses JIT to optimize bytecode in runtime. During the Java program execution, JVM identifies hot spots and rewrites the bytecode to make things faster. In other words, JVM is frequently recompiling our code.

JIT is great for long-running Java program, but it's not gonna be very helpful for mvn. We can disable it as below:

```sh
export MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
```

We can also increase the size of the heap space for mvn to help it's compilation, which is a quite memory extensive task. Then, we have:

```sh
export MAVEN_OPTS="-Xmx1000m -XX:+TieredCompilation -XX:TieredStopAtLevel=1"
```

### 3. Result

Put them all together, we have following command:

```sh
export MAVEN_OPTS="-Xmx1000m -XX:+TieredCompilation -XX:TieredStopAtLevel=1"

mvn compile -T 1C -o -Dmaven.javadoc.skip=true -Dmaven.test.skip=true -DadditionalJOption=-Xdoclint:none -DskipTests
```

Below is a comparison between normal `mvn compile` and the one without all of the optimization mentioned above.

### 4. Experiment

The experiment only demonstrates the potential improvement these tricks bring, it may differ for different projects on different machines.

- Same maven project (classic spring-boot style webapp)
- MacBook Pro 2022 M2 16GB
- Three attempts for each.

Without optimization:

```sh
unset MAVEN_OPTS

mvn compile
```

1. 1st Attempt: `Total time:  13.380 s`
2. 2nd Attempt: `Total time:  13.373 s`
3. 3rd Attempt: `Total time:  13.178 s`

With all the optimization:

```sh
export MAVEN_OPTS="-Xmx1000m -XX:+TieredCompilation -XX:TieredStopAtLevel=1"

mvn compile -T 1C -o -Dmaven.javadoc.skip=true -Dmaven.test.skip=true -DadditionalJOption=-Xdoclint:none -DskipTests
```

1. 1st Attempt: `Total time:  7.032 s`
2. 2nd Attempt: `Total time:  6.979 s`
3. 3rd Attempt: `Total time:  7.182 s`

The `'Total time'` shown above is copied from the output of `mvn compile` command.

### 5. More on install and deploy

If you are installing / deploying a specific submodule in a project (e.g., submodule being a dependency for other apps), you can choose to install or deploy that specific submodule without recompiling other modules.

Imagine that our project is called `myapp`, and we are trying to install a submodule called `myapp-api`, then we can install this submodule using following command:

```sh
mvn install -pl myapp-api
```

It's the same if we are deploying the submodule:

```sh
mvn deploy -pl myapp-api
```

This can also speed up the process quite a lot.