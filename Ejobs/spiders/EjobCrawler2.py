from time import strftime, gmtime
from Ejobs.items import EjobsJobAdscrapperItem
from scrapy.exceptions import CloseSpider

__author__ = 'Azyl'
import scrapy



class EjobSpiderFull(scrapy.Spider,):

    name = "BestjobLinkSpiderFull"
    allowed_domanains = ["ejobs.ro"]
    start_urls = ["http://www.ejobs.ro/locuri-de-munca/"]

    def __init__(self):
        self.i = 1
        self.maxDepth = 2
        self.runFree = True
        self.page = 1

    def parse(self, response):
        """
        @returns items 1 100
        @scrapes JobTitle SourcePage ScrapeDate JobAddLink
        """
        JobAdsResponse = response

        for JobAd in JobAdsResponse.xpath(".//*[@class='jobitem-inner clearfix']"):
            item = EjobsJobAdscrapperItem()
            item['JobTitle'] = JobAd.xpath(".//a[@class='title']/text()").extract()
            item['CompanyName'] = JobAd.xpath(".//a[@class='company']/text()").extract()
            item['SourcePage'] = response.url
            item['ScrapeDate'] = strftime("%Y-%m-%d %H:%M:%S", gmtime())
            item['JobAddLink'] = JobAd.xpath(".//a[@class='title']/@href").extract()
            item['NrJoburi'] = JobAd.xpath(".//span[@class='fact-count']/text()").extract()[0]
            item['JobAdApplicantsNr'] = JobAd.xpath(".//span[@class='fact-count']/text()").extract()[1]
            item['JobAdStartDate'] = JobAd.xpath(".//*[@class='jobitem-inner clearfix']//div[@class='jobitem-date']/text()").extract()
            item['Orase'] = JobAd.xpath(".//*[@class='jobitem-inner clearfix']//span[@class='jobitem-cities-list hidden-gridview']/text()").extract()


            # remove gmt for normal hour

            request = scrapy.Request(str(JobAd.xpath(".//a[@class='title']/@href").extract()[0]), callback=self.parseDetails, encoding='utf-8')
            request.meta['item'] = item
            yield request

        nextPage = JobAdsResponse.xpath(".//li[@class='next']/a[@rel='next']/@href").extract()

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


        try:
            if not item['JobAdStartDate']:
                item['JobAdStartDate'] = response.xpath(".//span[@itemprop='datePosted']/strong/text()").extract()[0]
            if not item.get('JobAdExpireDate'):
                item['JobAdExpireDate'] = response.xpath(".//span[@itemprop='datePosted']/following-sibling::strong/text()").extract()[0]
        except IndexError:
            if not item['JobAdStartDate']:
                if response.xpath(".//div[@class='company alert alert-grey']/span[2]/strong[1]/text()"):
                    item['JobAdStartDate'] = response.xpath(".//div[@class='company alert alert-grey']/span[2]/strong[1]/text()").extract()[0]
                else:
                    item['JobAdStartDate'] = response.xpath("//span[@class='date']/text()").extract()[0]


            if not item.get('JobAdExpireDate'):
                try:
                    item['JobAdExpireDate'] = response.xpath(".//div[@class='company alert alert-grey']/span[2]/strong[3]/text()").extract()[0]
                except IndexError:
                    pass

        item['JobAdDescription'] = response.xpath(".//div[@class='job-content']").extract()

        item['JobAdSelectionCriteria'] = response.xpath(".//ul[@itemprop='experienceRequirements']/li/text()").extract()
        item['LimbiStraine'] = response.xpath(".//ul[@data-singular='limba straina']/li/text()").extract()
        item['JobAdDriverLicence'] = response.xpath(".//h3[contains(text(),'Permis conducere:')]/parent::div/text()").extract()




        yield item