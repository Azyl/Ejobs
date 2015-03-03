from time import strftime, gmtime
from Ejobs.items import EjobsJobAdscrapperItem

__author__ = 'AndreiTataru'
import scrapy



class LinkSpiderFull(scrapy.Spider,):

    name = "LinkSpiderFull"
    allowed_domanains = ["ejobs.ro"]
    start_urls = ["http://wwww.ejobs.ro/user/searchjobs?q=&oras[]=&departament[]=&industrie[]=&searchType=simple&time_span=&page_no=&page_results="]

    def __init__(self):
        self.i = 10



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
            #yield item

        nextPage = JobAdsResponse.xpath(".//*[@id='content']/div[1]/div[3]/div[1]/div/ul/li[@class='next']/a/@href").extract()
        # print ' ----- >>>>> ' + str(nextPage)


        if nextPage is not None:
            if self.i <= 10:
                self.i = self.i +1

                yield scrapy.Request(str(nextPage[0]), callback=self.parse, encoding='utf-8')

    def parseDetails(self, response):
        print "asdasdasdas adsadsa das dsa d->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"


        item = response.meta['item']
        item['CompanyName'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[2]/div[1]/div[1]/div[2]/a/text()").extract()[0]
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
        item['JobAdDescription'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[1]/div[4]/div[1]/p/text()").extract()
        item['JobAdSelectionCriteria'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[1]/div[3]/ul/li/text()").extract()

        print str(item)


