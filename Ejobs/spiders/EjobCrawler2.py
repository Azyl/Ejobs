from time import strftime, gmtime
from Ejobs.items import EjobsJobAdscrapperItem
from scrapy.exceptions import CloseSpider

__author__ = 'Azyl'
import scrapy



class EjobSpiderFull(scrapy.Spider,):

    name = "BestjobLinkSpiderFull"
    allowed_domanains = ["ejobs.ro"]
    start_urls = ["http://http://www.ejobs.ro/locuri-de-munca/"]

    def __init__(self):
        self.i = 1
        self.maxDepth = 2
        self.runFree = False
        self.page = 1

    def parse(self, response):
        """
        @returns items 1 100
        @scrapes JobTitle SourcePage ScrapeDate JobAddLink
        """
        JobAdsResponse = response

        for JobAd in JobAdsResponse.xpath(".//*[@class='jobitem-inner clearfix']"):
            item = EjobsJobAdscrapperItem()
            item['JobTitle'] = JobAd.xpath("./a[@class='title']/text()").extract()[0]
            item['CompanyName'] = JobAd.xpath("./a[@class='company']/text()").extract()[0]
            item['SourcePage'] = response.url
            item['ScrapeDate'] = strftime("%Y-%m-%d %H:%M:%S", gmtime())
            item['JobAddLink'] = JobAd.xpath(".a[@class='title']/@href").extract()[0]
            item['NrJoburi'] = response.xpath(".//span[@class='fact-count']/text()").extract()[0]
            item['JobAdApplicantsNr'] = response.xpath(".//span[@class='fact-count']/text()").extract()[1]
            item['JobAdStartDate'] = JobAd.xpath(".//*[@class='jobitem-inner clearfix']//div[@class='jobitem-date']/text()").extract()[0].trim()
            item['Orase'] = JobAd.xpath(".//*[@class='jobitem-inner clearfix']//span[@class='jobitem-cities-list hidden-gridview']/text()").extract()[0]


            # remove gmt for normal hour

            request = scrapy.Request(str(JobAd.xpath(".a[@class='title']/@href").extract()[0]), callback=self.parseDetails, encoding='utf-8')
            request.meta['item'] = item
            yield request

        nextPage = JobAdsResponse.xpath(".//*[@id='paginare']/ul/li[5]/a/@href").extract()

        if nextPage is not None:
           if (self.i <= self.maxDepth) or self.runFree:
               self.i = self.i +1

               if nextPage:
                   yield scrapy.Request(str(nextPage[0]), callback=self.parse, encoding='utf-8')
               else:
                   print 'no more links to crawl :)'

    def parseDetails(self, response):

        item = response.meta['item']
        if not item['JobTitle']:
            try:
                item['JobTitle'] = response.xpath(".//h1[@class='job-title']/text()").extract()[0].trim()
            # except IndexError:
            #     item['JobTitle'] = response.xpath(".//div[@class='jd-title']/table//td[@valign='middle']/div/h1/text()").extract()[0]

        item['JobAdType'] = 1

        item['TipJob'] = response.xpath(".//ul[@itemprop='employmentType']/li/text()").extract()
        item['NivelCariera'] = response.xpath(".//ul[@itemprop='educationRequirements']/li/text()").extract()

        if not  item['Orase']:
            item['Orase'] = response.xpath(".//ul[@itemprop='addressLocality']/li/a/text()").extract()

        item['Departament'] = response.xpath(".//ul[@itemprop='department']/li/a/text()").extract()
        item['Oferta'] = response.xpath(".//span[@itemprop='baseSalary']/text()").extract()
        item['Industry'] = response.xpath(".//ul[@itemprop='industry']/li/text()").extract()

        item['JobAdStartDate'] = response.xpath(".//span[@itemprop='datePosted']/strong/text()").extract()[0]
        item['JobAdExpireDate'] = response.xpath(".//span[@itemprop='datePosted']/following-sibling::strong/text()").extract()[0]

        item['JobAdDescription'] = response.xpath(".//div[@class='job-content']").extract()

        item['JobAdSelectionCriteria'] = response.xpath(".//ul[@itemprop='experienceRequirements']/li/text()").extract()

        yield item