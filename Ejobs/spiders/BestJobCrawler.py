from time import strftime, gmtime
from Ejobs.items import EjobsJobAdscrapperItem

__author__ = 'Azyl'
import scrapy



class BestjobSpiderFull(scrapy.Spider,):

    name = "BestjobLinkSpiderFull"
    allowed_domanains = ["bestjobs.ro"]
    start_urls = ["http://wwww.ejobs.ro/user/searchjobs?q=&oras[]=&departament[]=&industrie[]=&searchType=simple&time_span=&page_no=&page_results="]

    def __init__(self):
        self.i = 1
        self.maxDepth = 100
        self.runFree = True

    def parse(self, response):
        """
        @returns items 1 100
        @scrapes JobTitle SourcePage ScrapeDate JobAddLink
        """
        JobAdsResponse = response

        for JobAd in JobAdsResponse.xpath(".//*[@class='job-card-inner']"):
            item = EjobsJobAdscrapperItem()
            item['JobTitle'] = JobAd.xpath(".a[3]/text()").extract()
            item['CompanyName'] = JobAd.xpath(".a[2]/text()").extract()
            item['SourcePage'] = response.url
            item['ScrapeDate'] = strftime("%Y-%m-%d %H:%M:%S", gmtime())
            item['JobAddLink'] = JobAd.xpath("./a[3]/@href").extract()[0]
            # remove gmt for normal hour

            request = scrapy.Request(str(JobAd.xpath("./a[3]/@href").extract()[0]), callback=self.parseDetails, encoding='utf-8')
            request.meta['item'] = item
            yield request

        
        #nextPage = JobAdsResponse.xpath(".//*[@id='content']/div[1]/div[3]/div[1]/div/ul/li[@class='next']/a/@href").extract()

        #if nextPage is not None:
        #    if (self.i <= self.maxDepth) or self.runFree:
        #        self.i = self.i +1

        #        if nextPage:
        #            yield scrapy.Request(str(nextPage[0]), callback=self.parse, encoding='utf-8')
        #        else:
        #            print 'no more links to crawl :)'

    def parseDetails(self, response):


        item = response.meta['item']


        if not item['JobTitle']:
            item['JobTitle'] = response.xpath(".//*[@id='job-page-left']/div/div/h1[@class='job-title']/text()").extract()
            # tipjob .//*[@class='jd-header']//*[@class='jd-content']/b[contains(text(),'Tip oferta')]/../following-sibling::td[2]/text()
            item['JobAdType'] = 1

            item['TipJob'] = response.xpath(".//*[@class='jd-header']//*[@class='jd-content']/b[contains(text(),'Tip oferta')]/../following-sibling::td[2]/text()").extract()
            item['NivelCariera'] = response.xpath(".//*[@class='jd-header']//*[@class='jd-content']/b[contains(text(),'Nivel cariera')]/../following-sibling::td[2]/text()").extract()
            item['Orase'] = response.xpath(".//*[@class='jd-header']//*[@class='jd-content']/b[contains(text(),'Oras(e)')]/../following-sibling::td[2]/text()").extract()
            item['Departament'] = response.xpath(".//*[@class='jd-header']//*[@class='jd-content']/b[contains(text(),'Domenii oferta')]/../following-sibling::td[2]//*[@href]/strong").extract()
            
        
            item['JobAdDescription'] = response.xpath("//*[@class='jd-main-job clearfix']//*[@class='jd-body'][1]").extract()

            


        #    if response.xpath(".//*[@id='job-page-left']/div[3]/div[2]/div[1]/div[1]/div[2]/a"):
        #        item['CompanyName'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[2]/div[1]/div[1]/div[2]/a/text()").extract()
        #    else:
        #        item['CompanyName'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[2]/div[1]/div[1]/div[2]/text()").extract()

        
        #    if response.xpath(".//*[@id='job-page-left']/div/div/div/div/div/ul[@itemprop='educationRequirements']"):
        #        item['NivelCariera'] = response.xpath(".//*[@id='job-page-left']/div/div/div/div/div/ul[@itemprop='educationRequirements']/li/text()").extract()

        #    if response.xpath(".//*[@id='job-page-left']/div/div/div/div/div/ul[@data-plural='foreign languages']"):
        #        item['LimbiStraine'] = response.xpath(".//*[@id='job-page-left']/div/div/div/div/div/ul[@data-plural='foreign languages']/li/text()").extract()

        #    if response.xpath(".//*[@id='job-page-left']/div/div/div/div/div/ul[@data-plural='limbi straine']"):
        #        item['LimbiStraine'] = response.xpath(".//*[@id='job-page-left']/div/div/div/div/div/ul[@data-plural='limbi straine']/li/text()").extract()

        #    if response.xpath(".//*[@id='job-page-left']/div/div/div/div/div/*[@itemprop='baseSalary']"):
        #        item['Oferta'] = response.xpath(".//*[@id='job-page-left']/div/div/div/div/div/*[@itemprop='baseSalary']/text()").extract()

        #    if response.xpath(".//*[@id='job-page-left']/div/div/div/div/div/*[@itemprop='industry']"):
        #        item['Industry'] = response.xpath(".//*[@id='job-page-left']/div/div/div/div/div/*[@itemprop='industry']/li/text()").extract()

        #    if response.xpath(".//*[@id='job-page-left']/div/div/div/div/div/ul[@itemprop='department']"):
        #        item['Departament'] = response.xpath(".//*[@id='job-page-left']/div/div/div/div/div/ul[@itemprop='department']/li/a/text()").extract()

        #    item['JobAdStartDate'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[1]/div[1]/span/strong/text()").extract()[0]
        #    item['JobAdExpireDate'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[1]/div[1]/strong/text()").extract()[0]
        #    item['NrJoburi'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[1]/div[2]/div/div[1]/div[2]/text()").extract()[0]
        #    item['JobAdApplicantsNr'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[1]/div[2]/div/div[2]/div[2]/text()").extract()[0]
        #    item['JobAdDescription'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[1]/div[4]/div[1]/p").extract()
        
        #    item['JobAdSelectionCriteria'] = response.xpath(".//*[@id='job-page-left']/div[3]/div[1]/div[3]/ul/li/text()").extract()

        #    if response.xpath(".//*[@id='job-page-left']/div/div/div/div/div/*[contains(text(),'Driving')]"):
        #        item['JobAdDriverLicence'] = response.xpath(".//*[@id='job-page-left']/div/div/div/div/div/*[contains(text(),'Driving')]/parent::*/text()").extract()

        #else:
        #    item['JobAdType'] = 2
        #    try:
        #        item['JobAdDescriptionImage'] = response.xpath(".//*[@id='job-page-left']/div[2]/div[3]/img/@src").extract()[0]
        #    except IndexError:
        #        item['JobAdDescriptionImage'] = response.xpath(".//*[@id='job-page-left']/div[2]/div[3]/a/img/@src").extract()[0]

        #yield item