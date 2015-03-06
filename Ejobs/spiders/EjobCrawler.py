from time import strftime, gmtime
from Ejobs.items import EjobsJobAdscrapperItem

__author__ = 'Azyl'
import scrapy



class LinkSpiderFull(scrapy.Spider,):

    name = "LinkSpiderFull"
    allowed_domanains = ["ejobs.ro"]
    start_urls = ["http://wwww.ejobs.ro/user/searchjobs?q=&oras[]=&departament[]=&industrie[]=&searchType=simple&time_span=&page_no=&page_results="]

    def __init__(self):
        self.i = 1
        self.maxDepth = 1
        self.runFree = False

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

            request = scrapy.Request(str(JobAd.xpath("./div/a[2]/@href").extract()[0]), callback=self.parseDetails, encoding='utf-8')
            request.meta['item'] = item
            yield request

        for JobAd in JobAdsResponse.xpath(".//*[contains(@class, 'anuntMic')]"):
            item = EjobsJobAdscrapperItem()
            item['JobTitle'] = JobAd.xpath("./div[2]/div[1]/a[2]/text()").extract()
            item['SourcePage'] = response.url
            item['ScrapeDate'] = strftime("%Y-%m-%d %H:%M:%S", gmtime())
            item['JobAddLink'] = JobAd.xpath("./div/div/a[2]/@href").extract()[0]
            # remove gmt for normal hour

            request = scrapy.Request(str(JobAd.xpath("./div/div/a[2]/@href").extract()[0]), callback=self.parseDetails, encoding='utf-8')
            request.meta['item'] = item
            yield request

        nextPage = JobAdsResponse.xpath(".//*[@id='content']/div[1]/div[3]/div[1]/div/ul/li[@class='next']/a/@href").extract()

        if nextPage is not None:
            if (self.i <= self.maxDepth) or self.runFree:
                self.i = self.i +1

                if nextPage:
                    yield scrapy.Request(str(nextPage[0]), callback=self.parse, encoding='utf-8')
                else:
                    print 'no more links to crawl :)'

    def parseDetails(self, response):

        item = response.meta['item']

        if response.xpath(".//*[@id='job-page-left']/div[3]/div[2]/div[1]/div[1]/div[2]/a/text()") or not (response.xpath(".//*[@id='job-page-left']/div[2]/div[3]/img/@src") or response.xpath(".//*[@id='job-page-left']/div[2]/div[3]/a/img/@src")):
            item['JobAdType'] = 1

            item['CompanyName'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[2]/div[1]/div[1]/div[2]/a/text()").extract()
            item['TipJob'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[2]/div[1]/div[2]/div[2]/ul/li/text()").extract()
            item['Orase'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[2]/div[1]/div[2]/div[3]/ul/li/a/text()").extract()
            item['NivelCariera'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[2]/div[1]/div[2]/div[4]/ul/li/text()").extract()
            item['LimbiStraine'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[2]/div[1]/div[2]/div[5]/ul/li/text()").extract()
            item['Oferta'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[2]/div[1]/div[2]/div[6]/span/text()").extract()
            item['Departament'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[2]/div[1]/div[2]/div[1]/ul/li/a/text()").extract()
            item['JobAdStartDate'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[1]/div[1]/span/strong/text()").extract()[0]
            item['JobAdExpireDate'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[1]/div[1]/strong/text()").extract()[0]
            item['NrJoburi'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[1]/div[2]/div/div[1]/div[2]/text()").extract()[0]
            item['JobAdApplicantsNr'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[1]/div[2]/div/div[2]/div[2]/text()").extract()[0]
            item['JobAdDescription'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[1]/div[4]/div[1]/p").extract()
            if not item['JobAdDescription']:
                item['JobAdDescription'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[1]/div[3]").extract()
            item['JobAdSelectionCriteria'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[1]/div[3]/ul/li/text()").extract()
            item['JobAdDriverLicence'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[2]/div[1]/div[2]/div[7]/text()").extract()
            if item['JobAdDriverLicence']:
                item['JobAdDriverLicence'] = item['JobAdDriverLicence'][1]
        else:
            item['JobAdType'] = 2
            try:
                item['JobAdDescriptionImage'] = response.xpath(".//*[@id='job-page-left']/div[2]/div[3]/img/@src").extract()[0]
            except IndexError:
                item['JobAdDescriptionImage'] = response.xpath(".//*[@id='job-page-left']/div[2]/div[3]/a/img/@src").extract()[0]

        yield item


