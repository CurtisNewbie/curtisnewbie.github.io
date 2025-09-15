---
layout: post
title: "LLM-Resources"
date: 2025-09-05 09:00:00 +0800
categories: Learning
hidden: 0
---

## Websites

- [Pinecone, Chunking Strategies for LLM Applications](https://www.pinecone.io/learn/chunking-strategies/)
- [Ilya Rice: How I Won the Enterprise RAG Challenge](https://abdullin.com/ilya/how-to-build-best-rag/)
- [Anthropic, Introducing Contextual Retrieval](https://www.anthropic.com/news/contextual-retrieval)
- [GPT Researcher, How we built GPT Researcher](https://docs.gptr.dev/blog/building-gpt-researcher)
- [Reddit, Summarize this conversation in a way that can be...](https://www.reddit.com/r/LocalLLaMA/comments/1d9wdp6/summarize_this_conversation_in_a_way_that_can_be/)
    - About Memory Compression
- [Langchain, Adding Long Term Memory to OpenGPTs](https://blog.langchain.com/adding-long-term-memory-to-opengpts/)
    - (https://github.com/langchain-ai/opengpts)[https://github.com/langchain-ai/opengpts]
    - Memory
        - Semantic Memory
        - Generative Agents
    - Questions That Determine How We Implement Memory.
        - What is the state that's tracked?
        - How is the state updated?
        - How is the state used?
- [thakkarparth007.github.io, Copilot Internals](https://thakkarparth007.github.io/copilot-explorer/posts/copilot-internals)
    - [https://github.com/thakkarparth007/copilot-explorer](https://github.com/thakkarparth007/copilot-explorer)
- [Github, Copilot Analysis](https://github.com/mengjian-github/copilot-analysis)

## Tools / Frameworks

### Document Processing

- [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR)
- [Docling](https://github.com/docling-project/docling)
- [MinerU](https://github.com/opendatalab/MinerU)
- [PyMuPDF](https://github.com/pymupdf/PyMuPDF)
- [pypdfium2](https://github.com/pypdfium2-team/pypdfium2)
    - Python binding for [Pdfium](https://pdfium.googlesource.com/pdfium/)
    - Used by Dify as default extractor for PDF content.
- [EasyOCR](https://github.com/JaidedAI/EasyOCR)
    - Used by Docling as the default OCR Engine.
- [LangExtract](https://github.com/google/langextract)
    - Data Extraction

### Deep Research

- [LangChain, Open Deep Research](https://github.com/langchain-ai/open_deep_research)
- [dzhng, Deep Research](https://github.com/dzhng/deep-research)
- [Jina AI, Deep Research](https://github.com/jina-ai/node-DeepResearch)
- [guy-hartstein, Agentic Company Researcher](https://github.com/guy-hartstein/company-research-agent)
    - Internally used Tavily AI.
- [GPT Researcher](https://github.com/assafelovic/gpt-researcher)

## LLM Papers

- [Large Language Models (LLMs) on Tabular Data: Prediction, Generation, and Understanding - A Survey](https://arxiv.org/pdf/2402.17944)
    - About excel/csv cleaning
    - About Table Serialization, Row-wise Serialization, Attribute-Value Pairing

- [Plan-and-Solve Prompting: Improving Zero-Shot Chain-of-Thought Reasoning by Large Language Models](https://arxiv.org/pdf/2305.04091)
    - About LLM Plan and Solve
    - [https://github.com/AGI-Edgerunners/Plan-and-Solve-Prompting](https://github.com/AGI-Edgerunners/Plan-and-Solve-Prompting)
    - Better CoT, especially in Math.

- [Measuring and Narrowing the Compositionality Gap in Language Models](https://ofir.io/self-ask.pdf)
    - [https://github.com/ofirpress/self-ask](https://github.com/ofirpress/self-ask)
    - About LLM Self-Ask
    - Solve Multi-Hop Questions

- [ReAct: Synergizing Reasoning and Acting in Language Models](https://arxiv.org/abs/2210.03629)
    - LLM ReAct

- [Generative Agents: Interactive Simulacra of Human Behavior](https://arxiv.org/abs/2304.03442)
    - About Long Term Memory, Generative Agent (Memory)

- [Self-RAG: Learning to Retrieve, Generate, and Critique through Self-Reflection](https://arxiv.org/abs/2310.11511)
    - Self-RAG
    - Reflection Tokens
        - Retrieve (need for retrieval)
            - Retrieve: when to retrieve X
        - Critique (generation quality)
            - IsREL (relevant): X provides useful info to solve Y
            - IsSUP (supported): all verification-worth statement in X is supported by Y
            - IsUSE (useful): X is useful response to Y
    - https://selfrag.github.io/
    - https://github.com/SauravP97/AI-Engineering-101/tree/main/self-rag

- [The Prompt Report: A Systematic Survey of Prompt Engineering Techniques](https://arxiv.org/pdf/2406.06608)
    - Over 58 different types of Prompting Technique?