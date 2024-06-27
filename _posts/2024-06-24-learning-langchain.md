---
layout: post
title: "Learning LangChain"
date: 2024-06-24 00:00:00 +0800
categories: Learning
---

## Relevant Sites

- [LangChain v0.2 Doc](https://python.langchain.com/v0.2/docs/introduction/)
- [LangChain Github](https://github.com/langchain-ai/langchain)
- [Download HuggingFace Model](https://huggingface.co/docs/hub/en/models-downloading)
- [HuggingFace - Microsoft/Phi-3-mini-4k-instruct](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct)
- [Blog - HuggingFace LangChain Partner Package](https://huggingface.co/blog/langchain)
- [HuggingFace - TinyLlama/TinyLlama-1.1B-Chat-v1.0](https://huggingface.co/TinyLlama/TinyLlama-1.1B-Chat-v1.0)
- [HuggingFace - TinyLlama/TinyLlama_v1.1](https://huggingface.co/TinyLlama/TinyLlama_v1.1)
- [HuggingFace - TinyLlama/TinyLlama_v1.1_chinese](https://huggingface.co/TinyLlama/TinyLlama_v1.1_chinese)
- [HuggingFace Discussion - LLaMA 7B GPU Memory Requirement](https://discuss.huggingface.co/t/llama-7b-gpu-memory-requirement/34323/7)
- [HuggingFace - Download Modesl](https://huggingface.co/docs/hub/en/models-downloading)
- [LangChain - Chatbot](https://python.langchain.com/v0.2/docs/tutorials/chatbot/)
- [LangChain - Conversational RAG](https://python.langchain.com/v0.2/docs/tutorials/qa_chat_history/)
- [LangChain - Build a Retrieval Augmented Generation (RAG) App](https://python.langchain.com/v0.2/docs/tutorials/rag/)
- [LangChain - Chroma (Vector Store)](https://python.langchain.com/v0.2/docs/integrations/vectorstores/chroma/)
- [LangChain - Vector Stores](https://python.langchain.com/v0.1/docs/modules/data_connection/vectorstores/)
- [HuggingFace - Qwen/Qwen-1_8B-Chat-Int4](https://huggingface.co/Qwen/Qwen-1_8B-Chat-Int4)
- [Github - QwenLM/Qwen](https://github.com/QwenLM/Qwen?tab=readme-ov-file#quantization)
- [Gist CurtisNewbie - Qwen/Qwen-1_8B-Chat-Int4 Demo](https://gist.github.com/CurtisNewbie/9d220701b4dd7f3ce00e728317ca1436)
- [HuggingFace - 4bit Quantization](https://huggingface.co/blog/4bit-transformers-bitsandbytes)
- [HuggingFace - bitsandbytes for Quantization](https://huggingface.co/docs/bitsandbytes/main/en/installation)
- [LangChain - Vector store-backed retriever](https://python.langchain.com/v0.1/docs/modules/data_connection/retrievers/vectorstore/)

## Getting Started

Install langchain

```bash
python3 -m pip install langchain
```

Setup langsmith (https://smith.langchain.com/), but it's not really needed, we may well just skip this.

```bash
export LANGCHAIN_TRACING_V2="true"
export LANGCHAIN_API_KEY="..."
```

Use LangChain with HuggingFace

- https://python.langchain.com/v0.2/docs/integrations/platforms/huggingface/

```bash
python3 -m pip install langchain-huggingface
python3 -m pip install --upgrade --quiet  transformers --quiet
```

Load the HuggingFace model locally (TinyLlama/TinyLlama-1.1B-Chat-v1.0), it's a 1.1b model, I am running it on Macbook Pro M2 16GB. My laptop cannot handle Model with over 3b parameters.

```py
from langchain_huggingface import HuggingFacePipeline

hf = HuggingFacePipeline.from_model_id(
    model_id="TinyLlama/TinyLlama-1.1B-Chat-v1.0",
    task="text-generation",
    pipeline_kwargs={"max_new_tokens": 150},
)
```

Task is what the model can handle. In this case, we are using a `text-generation` model. Which task should we specify depends on what we are doing, a model may be capable of multiple tasks.

![assets/images/hugging-face-search-task.png](/assets/images/hugging-face-search-task.png)

> Searching models based on tasks on HuggingFace.

Create Prompt Template (will get much better response):

```py
from langchain_core.prompts import PromptTemplate

# prompt template
template = """Question: {question}

Answer: Let's think step by step."""
prompt = PromptTemplate.from_template(template)

# bind local langchain to the prompt
chain = prompt | hf.bind()

q = "How to brew coffee?"
print(chain.invoke({"question": q}))
```

We can also invoke the model directly without PromptTemplate, but the response is worse:

```py
print(hf.invoke("How to brew coffee?"))
```

A working example is available at: [github.com/CurtisNewbie/llm_stuff/blob/main/tinyllama.py](https://github.com/CurtisNewbie/llm_stuff/blob/main/tinyllama.py)

```py
from langchain_core.prompts import PromptTemplate
import sys
import readline
from langchain_huggingface import HuggingFacePipeline

hf = HuggingFacePipeline.from_model_id(
    model_id="TinyLlama/TinyLlama-1.1B-Chat-v1.0",
    task="text-generation",
    pipeline_kwargs={
        "max_new_tokens": 150,
    },
    model_kwargs={
        "temperature": 0.7,
        "top_k": 50,
        "top_p": 0.95,
        "do_sample": True,
    },
)

template = """Question: {question}

Answer: Let's think step by step."""
prompt = PromptTemplate.from_template(template)

chain = prompt | hf.bind()

while True:
    try:
        print("Enter your question:")
        q = sys.stdin.readline().strip()
        if not q: continue
        resp = chain.invoke({"question": q})
        print(f"\n\n> model: '{resp}'\n")

    except InterruptedError:
        sys.exit()
    except Exception as e:
        print(f"Exception caught {e}")
```

If the model supports streaming, we can change the code like the following. If the model doesn't support streaming then the method call is simply blocked returning only one single chunk:

```py
for chunk in chain.stream({"question": q}):
    print(chunk, flush=True)
```

## Retrieval Augmented Generation (RAG)

- [LangChain - Build a Retrieval Augmented Generation (RAG) App](https://python.langchain.com/v0.2/docs/tutorials/rag/)
- [LangChain - Chroma (Vector Store)](https://python.langchain.com/v0.2/docs/integrations/vectorstores/chroma/)

RAG is a way to connect LLM model with external sources. In LangChain's RAG tutorial, an OpenAI model is used and connected to a online document parsed using bs4.

In essence, RAG involves indexing the data (documents), storing the indexes in vector database, retrieving the context from the vector database (based on similarity,
i.e., Similarity Search) for the question, and finally adding the context to the prompt that is passed to the LLM model.

The following images are from LangChain.

<img src="https://python.langchain.com/v0.2/assets/images/rag_indexing-8160f90a90a33253d0154659cf7d453f.png" height="350px">


<img src="https://python.langchain.com/v0.2/assets/images/rag_retrieval_generation-1046a4668d6bb08786ef73c56d4f228a.png" height="350px">

Install relevant dependencies. Chroma is a vector database.

```py
python3 -m pip install langchain langchain_community langchain_chroma
```

First of all, we create a LangChain pipeline for the model:

```py
from langchain_core.prompts import PromptTemplate
import re
import traceback
import sys
import readline
from langchain_huggingface import HuggingFacePipeline

# template = """Question: {question}

# Answer: Let's think step by step."""

max_new_tokens=300
task="text-generation"
model="TinyLlama/TinyLlama-1.1B-Chat-v1.0"

hf = HuggingFacePipeline.from_model_id(
    model_id=model,
    task=task,
    pipeline_kwargs={
        "max_new_tokens": max_new_tokens,
    },
    model_kwargs={
        "temperature": 0.7,
        "top_k": 50,
        "top_p": 0.95,
        "do_sample": True,
    },
)
```

Import DocumentLoader to load external documents. Import Splitter to break documents into chunks. Import Embeddings to create a vector representation of text that is stored in a vector database.

In the following code, the retriever is created from the vector database. Retriever is simply a concept that accepts a string query and returns a list of documents,
in this case, it's doing similarity search based on the question asked.

```py
from langchain_chroma import Chroma
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import CharacterTextSplitter
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_core.runnables import RunnablePassthrough

# load the local document
files = ["about_onecafe.txt"]
documents = []
for f in files: documents.extend(TextLoader(f).load())

# split documents into chunks
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

# create Embedding function to convert each piece of text to vector
embed = HuggingFaceEmbeddings()

# store documents into Chroma (in memory)
vec = Chroma.from_documents(docs, embed)

# create retriever from the vector database
retriever = vec.as_retriever(search_kwargs={"k": 1}) # default: k is 4
```

With all the Loader, Splitter, Embeddings, Vector Database and Retriever setup, we can construct a chain that automatically complete the context for the LLM model.

The prompt template is slightly different, it now contains a context section for the LLM model (It's copied from LangSmith). The content of `{context}` actually comes from the vector database using the Retriever that we just created.

The `RunnablePassthrough()` does nothing, it just passes the query to `{question}` section.

```py
def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

template = """You are an assistant for question-answering tasks. Use the following pieces of retrieved context to answer the question. If you don't know the answer, just say that you don't know. Use three sentences maximum and keep the answer concise.

Question: {question}

Context: {context}

Answer:"""
prompt = PromptTemplate.from_template(template)

chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | hf.bind()
)
```

Finally, we just invoke the chain with our question:

```py
print(resp = chain.invoke("What is LLM model?"))
```

A working example is available at: [github.com/CurtisNewbie/llm_stuff/blob/main/tinyllama_rag.py](https://github.com/CurtisNewbie/llm_stuff/blob/main/tinyllama_rag.py)

```py
from langchain_core.prompts import PromptTemplate
import re
import traceback
import sys
import readline
from langchain_huggingface import HuggingFacePipeline

max_new_tokens=300
task="text-generation"
model="TinyLlama/TinyLlama-1.1B-Chat-v1.0"

hf = HuggingFacePipeline.from_model_id(
    model_id=model,
    task=task,
    pipeline_kwargs={
        "max_new_tokens": max_new_tokens,
    },
    model_kwargs={
        "temperature": 0.7,
        "top_k": 50,
        "top_p": 0.95,
        "do_sample": True,
    },
)

from langchain_chroma import Chroma
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import CharacterTextSplitter
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_core.runnables import RunnablePassthrough

# load the document and split it into chunks
files = ["about_onecafe.txt"]
documents = []
for f in files:
    documents.extend(TextLoader(f).load())

# split it into chunks
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

# create the open-source embedding function (also a model)
embed = HuggingFaceEmbeddings()

# load it into Chroma
vec = Chroma.from_documents(docs, embed)
reti = vec.as_retriever(search_kwargs={"k": 1}) # default: k is 4

def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

template = """You are an assistant for question-answering tasks. Use the following pieces of retrieved context to answer the question. If you don't know the answer, just say that you don't know. Use three sentences maximum and keep the answer concise.

Question: {question}

Context: {context}

Answer:"""
prompt = PromptTemplate.from_template(template)

chain = (
    {"context": reti | format_docs, "question": RunnablePassthrough()}
    | prompt
    | hf.bind()
)

print(chain.invoke("Tell me about onecafe"))
```

## Quantization

- [HuggingFace - 4bit Quantization](https://huggingface.co/blog/4bit-transformers-bitsandbytes)
- [HuggingFace - bitsandbytes for Quantization](https://huggingface.co/docs/bitsandbytes/main/en/installation)

With Quantization (e.g., 4bit), we can reduce the usage of memory, making LLM runs faster. Some models on HuggingFace have already done it without extra configuration, but those may require CUDA support.

Quantization only works on GPU (kinda), include `load_in_4bit=True` and `device_map=auto` to enable the quantization, but model should support it in the first place.

Quantization needs bitsandbytes:

```py
python3 -m pip install bitsandbytes
```

When we create the model, include the args mentioned above:

```py
hf = HuggingFacePipeline.from_model_id(
    model_id=model,
    task=task,
    pipeline_kwargs={
        "max_new_tokens": max_new_tokens,
    },
    model_kwargs={
        "temperature": 0.7,
        "top_k": 50,
        "top_p": 0.95,
        "do_sample": True,
        "load_in_4bit": True, # 4bit quantization
        "device_map":"auto",
    },
)
```

## Conceptual Guide

- [LangChain - Conceptual Guide](https://python.langchain.com/v0.2/docs/concepts)

TODO:

## Conversational RAG

Conversational RAG maintains history of conversation.

- [LangChain - Conversational RAG](https://python.langchain.com/v0.2/docs/tutorials/qa_chat_history/)

TODO: How to remmeber the chat history

## Terminology

- `HF Format`: Hugging Face Format
