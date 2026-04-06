from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import MarkdownHeaderTextSplitter, RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_chroma import Chroma
from pathlib import Path
import os
import time
import sys

# 设置标准输出编码为 UTF-8，避免 Windows 下的编码问题
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

# 配置
MARKDOWN_DIR = "./markdown_output"  # Markdown 文件目录
PERSIST_DIR = "./chroma_md_1"       # 数据库目录

# Embedding配置
EMBEDDING_CONFIG = {
    "model": "text-embedding-ada-002",
    "openai_api_base": "https://api.chatanywhere.tech/v1",
    "openai_api_key": "sk-kAdG9GbVDmNvTe2QAyaiyzDezCZKk8c7qy3it8Y01ug8oj0s"
}

print("=" * 60)
print("知识库更新工具")
print("=" * 60)

print(f"\n1. 检查现有数据库...")
embedding_model = OpenAIEmbeddings(**EMBEDDING_CONFIG)
vectordb = Chroma(persist_directory=PERSIST_DIR, embedding_function=embedding_model)
existing_count = vectordb._collection.count()
print(f"   现有文档: {existing_count} 个片段")

print(f"\n2. 扫描 {MARKDOWN_DIR} 目录...")
md_dir = Path(MARKDOWN_DIR)
if not md_dir.exists():
    print(f"[错误] 目录不存在: {MARKDOWN_DIR}")
    exit(1)

md_files = list(md_dir.glob("*.md"))
print(f"   找到 {len(md_files)} 个 Markdown 文件")

# 显示找到的文件
for i, md_file in enumerate(md_files, 1):
    print(f"   {i}. {md_file.name} ({md_file.stat().st_size} 字节)")

if len(md_files) == 0:
    print("[警告] 没有找到任何 Markdown 文件，退出")
    exit(0)

print(f"\n3. 处理文档...")
all_docs = []

# 先用 Markdown 标题分割，再用字符分割
header_splitter = MarkdownHeaderTextSplitter(
    headers_to_split_on=[
        ("#", "Header 0"),
        ("##", "Header 1"),
        ("###", "Header 2"),
        ("####", "Header 3"),
        ("#####", "Header 4")
    ],
    strip_headers=False
)

# 字符分割器，使用更大的 chunk_size
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=3000,  # 增加到 3000 字符
    chunk_overlap=300,  # 增加重叠到 300 字符
    separators=["\n\n", "\n", "。", "！", "？", "，", " ", ""]
)

for md_file in md_files:
    print(f"\n   正在处理: {md_file.name}")
    try:
        loader = TextLoader(str(md_file), encoding="utf-8")
        documents = loader.load()
        text = documents[0].page_content

        # 先按 Markdown 标题分割
        header_docs = header_splitter.split_text(text)
        print(f"   标题分割: {len(header_docs)} 个片段")

        # 再对每个标题片段进行字符分割
        for doc in header_docs:
            text_docs = text_splitter.split_documents([doc])
            # 添加源文件元数据
            for text_doc in text_docs:
                text_doc.metadata["source"] = md_file.name
            all_docs.extend(text_docs)

        print(f"   当前总共: {len(all_docs)} 个片段")
    except Exception as e:
        print(f"   [错误] 处理失败: {e}")
        import traceback
        traceback.print_exc()
        continue

print(f"\n   总共需要处理: {len(all_docs)} 个文档片段")

# 跳过已经存在的文档
if existing_count > 0:
    print(f"\n4. 跳过已存在的文档...")
    all_docs = all_docs[existing_count:]
    print(f"   剩余需要添加: {len(all_docs)} 个片段")

if len(all_docs) == 0:
    print("\n[完成] 数据库已经是最新状态，无需更新")
    exit(0)

print(f"\n5. 添加新文档到向量数据库...")
batch_size = 100
total_batches = (len(all_docs) + batch_size - 1) // batch_size
added_count = 0
start_time = time.time()

for i in range(0, len(all_docs), batch_size):
    batch = all_docs[i:i + batch_size]
    batch_num = i // batch_size + 1
    progress = (i / len(all_docs)) * 100

    print(f"\n   进度: {progress:.1f}% - 第 {batch_num}/{total_batches} 批 ({len(batch)} 个文档)")

    try:
        vectordb.add_documents(batch)
        added_count += len(batch)
        elapsed = time.time() - start_time
        avg_time = elapsed / batch_num if batch_num > 0 else 0
        remaining_batches = total_batches - batch_num
        eta = avg_time * remaining_batches
        print(f"   ✓ 成功 (预计剩余: {eta:.0f} 秒)")
    except Exception as e:
        print(f"   ✗ 失败: {e}")
        continue

total_time = time.time() - start_time

print(f"\n" + "=" * 60)
print(f"[成功] 知识库更新完成！")
print(f"  新增文档: {added_count} 个片段")
print(f"  总计文档: {existing_count + added_count} 个片段")
print(f"  本次耗时: {total_time:.1f} 秒 ({total_time/60:.1f} 分钟)")
print(f"  平均速度: {added_count/total_time:.1f} 片段/秒")
print("=" * 60)