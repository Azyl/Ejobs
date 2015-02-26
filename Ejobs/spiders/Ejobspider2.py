import scrapy
from Ejobs.items import EjobsJobAdscrapperItem
from time import gmtime, strftime
from scrapy.contrib.loader import ItemLoader

class LinkSpiderItemLoader(scrapy.Spider):

    name = "LinkSpider2"
    allowed_domanains = ["ejobs.ro"]
    start_urls = ["http://wwww.ejobs.ro/user/searchjobs?q=&oras[]=&departament[]=&industrie[]=&searchType=simple&time_span=&page_no=&page_results="]

    def parse(self, response):
        """
        @returns items 1 100
        @scrapes JobTitle SourcePage ScrapeDate JobAddLink
        """
        JobAdsResponse = response
        URLs = JobAdsResponse.url
        for JobAd in JobAdsResponse.xpath(".//*[@id='content']/div/div[2][@class='despre']"):

            l = ItemLoader(item=EjobsJobAdscrapperItem(), response=JobAd)
            l.add_xpath('JobTitle', "./div/a[2]/text()")
            l.add_value('SourcePage', URLs)
            l.add_value('ScrapeDate',  strftime("%Y-%m-%d %H:%M:%S", gmtime()))
            l.add_xpath('JobAddLink', "./div/a[2]/@href")
            # remove gmt for normal hour
            return l.load_item()
