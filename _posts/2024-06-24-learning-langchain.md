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
- [HuggingFace Discussion - LLaMA 7B GPU Memory Requirement](https://discuss.huggingface.co/t/llama-7b-gpu-memory-requirement/34323/7)

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

Load hugging face model (TinyLlama/TinyLlama-1.1B-Chat-v1.0, 1.1b model)

```py
from langchain_huggingface import HuggingFacePipeline

hf = HuggingFacePipeline.from_model_id(
    model_id="TinyLlama/TinyLlama-1.1B-Chat-v1.0",
    task="text-generation",
    pipeline_kwargs={"max_new_tokens": 150},
)
```

Task is what that the model can and will handle. In this case, we are using a `text-generation` model. Which task should we specify depends on what we are doing and what task the model can handle, a model may be capable of multiple tasks.

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

A working example:

gist: https://gist.github.com/CurtisNewbie/2b25f811b5b177548207488b2b409dbf

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


## Terminology

- `HF Format`: Hugging Face Format
