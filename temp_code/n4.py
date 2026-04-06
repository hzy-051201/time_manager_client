import requests, html2text, os
from lxml import etree, html
html_parser = etree.HTMLParser()
html2text_converter = html2text.HTML2Text()
news_website = "https://cise.njtech.edu.cn/index/tzgg.htm"
def get_html(url):
    response = requests.get(url)
    response.encoding = 'utf-8'
    return response.text
def get_news_list():
    html_content = get_html(news_website)
    tree = etree.fromstring(html_content, html_parser)
    hrefs = tree.xpath('//div[@class="txt"]/ul/li/a/@href')
    parent_url = os.path.dirname(news_website)
    urls = [f"{parent_url}/{href}" for href in hrefs]
    return urls
def get_news(url):
    html_content = get_html(url)
    tree = etree.fromstring(html_content, html_parser)
    title = tree.xpath('//div[@class="title"]')[0].text
    content = tree.xpath('//div[@class="main_article wrap"]')[0]
    raw_content = html.tostring(content, encoding='unicode')
    markdown_content = html2text_converter.handle(raw_content)
    return title, markdown_content