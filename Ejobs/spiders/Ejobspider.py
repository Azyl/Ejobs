import scrapy
from Ejobs.items import EjobsJobAdscrapperItem
from time import gmtime, strftime


class LinkSpider(scrapy.Spider,):

    name = "LinkSpider"
    allowed_domanains = ["ejobs.ro"]
    start_urls = ["http://wwww.ejobs.ro/user/searchjobs?q=&oras[]=&departament[]=&industrie[]=&searchType=simple&time_span=&page_no=&page_results="]

    def __init__(self):
        self.i = 8

    def parse(self, response):
        """
        @returns items 1 100
        @scrapes JobTitle SourcePage ScrapeDate JobAddLink
        """
        JobAdsResponse = response

        for JobAd in JobAdsResponse.xpath(".//*[@id='content']/div/div[2][@class='despre']"):
            item = EjobsJobAdscrapperItem()
            item['JobTitle'] = JobAd.xpath("./div/a[2]/text()").extract()
            item['SourcePage'] = response.url
            item['ScrapeDate'] = strftime("%Y-%m-%d %H:%M:%S", gmtime())
            item['JobAddLink'] = JobAd.xpath("./div/a[2]/@href").extract()[0]
            # remove gmt for normal hour
            yield item

        nextPage = JobAdsResponse.xpath(".//*[@id='content']/div[1]/div[3]/div[1]/div/ul/li[@class='next']/a/@href").extract()
        # print ' ----- >>>>> ' + str(nextPage)


        if nextPage is not None:
            if self.i <= 10:
                self.i = self.i +1

                yield scrapy.Request(str(nextPage[0]), callback=self.parse, encoding='utf-8')