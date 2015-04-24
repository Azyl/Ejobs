from time import strftime, gmtime
from Ejobs.items import EjobsJobAdscrapperItem
from scrapy.exceptions import CloseSpider

__author__ = 'Azyl'
import scrapy



class BestjobSpiderFull(scrapy.Spider,):

    name = "BestjobLinkSpiderFull"
    allowed_domanains = ["bestjobs.ro"]
    start_urls = ["http://www.bestjobs.ro/"]

    def __init__(self):
        self.i = 1
        self.maxDepth = 100
        self.runFree = True
        self.page = 1

    def parse(self, response):
        """
        @returns items 1 100
        @scrapes JobTitle SourcePage ScrapeDate JobAddLink
        """
        JobAdsResponse = response

        for JobAd in JobAdsResponse.xpath(".//*[@class='job-card-inner']"):
            item = EjobsJobAdscrapperItem()
            item['JobTitle'] = JobAd.xpath("./a[3]/text()").extract()
            item['CompanyName'] = JobAd.xpath("./a[2]/text()").extract()
            item['SourcePage'] = response.url
            item['ScrapeDate'] = strftime("%Y-%m-%d %H:%M:%S", gmtime())
            item['JobAddLink'] = JobAd.xpath("./a[3]/@href").extract()[0]
            # remove gmt for normal hour

            request = scrapy.Request(str(JobAd.xpath("./a[3]/@href").extract()[0]), callback=self.parseDetails, encoding='utf-8')
            request.meta['item'] = item
            yield request

            #        if self.page <= 10 or self.runTrue:

            if JobAdsResponse.xpath(".//*[@class='job-card-inner']"):

                self.page = self.page+1

                # yield scrapy.Request(url="http://www.bestjobs.ro/searchParams=%s?page=%d" % (response.meta['searchParams'],self.page),
                #           headers={"Referer": "http://www.bestjobs.ro/", "X-Requested-With": "XMLHttpRequest"},
                #           callback=self.parse,
                #           dont_filter=False)
                yield scrapy.Request(url="http://www.bestjobs.ro/search/_getmorejobs?page=%d" % self.page,
                          headers={"Referer": "http://www.bestjobs.ro/", "X-Requested-With": "XMLHttpRequest"},
                          callback=self.parse,
                          dont_filter=False)



                #http://www.bestjobs.ro/search/_getmorejobs?page=2&searchParams=YToxNDp7czo3OiJjYWNoZWl0IjtiOjE7czo3OiJrZXl3b3JkIjtzOjA6IiI7czo1OiJvcmRlciI7czowOiIiO3M6NjoiaWRvcmFzIjthOjA6e31zOjExOiJtYWluZG9tYWlucyI7YTowOnt9czo4OiJuY2FyaWVyYSI7YTowOnt9czo3OiJ0eXBlQXJyIjtpOjA7czo2OiJzdHJpY3QiO2k6MDtzOjExOiJ2aXNpdGVkSm9icyI7TjtzOjE3OiJjb250YWN0ZWRJZG9mZXJ0ZSI7TjtzOjY6Imlnbm9yZSI7aTowO3M6MTU6ImJsb2NrZWRBY2NvdW50cyI7YTowOnt9czo4OiJzaW1pbGFycyI7YTowOnt9czo2OiJmYWNldHMiO2I6MTt9

                # yield scrapy.FormRequest.from_response(response,
                #                 formdata={'page=':str(self.page)},
                #                 callback=self.parse,
                #                 dont_filter=True)
            else:
                #if self.page == 10:
                 raise CloseSpider("No more jobAds!")


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


        if item['JobTitle']:
            try:
                item['JobTitle'] = response.xpath(".//div[@class='jd-title']/table//td[@valign='middle']/h1/text()").extract()[0]
            except IndexError:
                item['JobTitle'] = response.xpath(".//div[@class='jd-title']/table//td[@valign='middle']/div/h1/text()").extract()[0]


        # tipjob .//*[@class='jd-header']//*[@class='jd-content']/b[contains(text(),'Tip oferta')]/../following-sibling::td[2]/text()
        item['JobAdType'] = 3

        item['TipJob'] = response.xpath(".//*[@class='jd-header']//*[@class='jd-content']/b[contains(text(),'Tip oferta')]/../following-sibling::td[2]/text()").extract()
        item['NivelCariera'] = response.xpath(".//*[@class='jd-header']//*[@class='jd-content']/b[contains(text(),'Nivel cariera')]/../following-sibling::td[2]/text()").extract()
        # item['Orase'] = response.xpath(".//*[@class='jd-header']//*[@class='jd-content']/b[contains(text(),'Oras(e)')]/../following-sibling::td[2]/text()").extract()
        item['Orase'] = response.xpath(".//*[@class='jd-header']//*[@class='jd-content']/b[contains(text(),'Oras(e)')]/../following-sibling::td[2]/span/a[not(@onclick)]/text()").extract()
        if not item['Orase']:
            item['Orase'] = response.xpath(".//*[@class='jd-header']//*[@class='jd-content']/b[contains(text(),'Oras(e)')]/../following-sibling::td[2]/span/text()").extract()



        item['Departament'] = response.xpath(".//*[@class='jd-header']//*[@class='jd-content']/b[contains(text(),'Domenii oferta')]/../following-sibling::td[2]//*[@href]/strong").extract()

        try:
            item['JobAdStartDate'] = response.xpath(".//*[@class='jd-main-job clearfix']//*[@class='jd-application'][1]//*[@style='width:330px;float:right;padding-left:14px;text-align:right;']/div[2]/b[1]/text()").extract()[0]
            item['JobAdExpireDate'] = response.xpath(".//*[@class='jd-main-job clearfix']//*[@class='jd-application'][1]//*[@style='width:330px;float:right;padding-left:14px;text-align:right;']/div[2]/b[2]/text()").extract()[0]
        except IndexError:
            item['JobAdStartDate'] = response.xpath(".//*[@class='jd-main-job clearfix']//*[@class='jd-application'][1]//*[@style='width:330px;float:right;padding-left:14px;text-align:right;']/div[2]/text()").extract()[0].split(',')[0]
            item['JobAdExpireDate'] = response.xpath(".//*[@class='jd-main-job clearfix']//*[@class='jd-application'][1]//*[@style='width:330px;float:right;padding-left:14px;text-align:right;']/div[2]/strong/text()").extract()[0]


        #width:330px;float:right;padding-left:14px;text-align:right;
        try:
            item['JobAdApplicantsNr'] = response.xpath(".//*[@class='jd-main-job clearfix']//*[@class='jd-application'][1]//*[@style='width:330px;float:right;padding-left:14px;text-align:right;']/div[1]/text()").extract()[0] #.replace('La acest job au mai aplicat ','').replace(' persoane.','')
        except IndexError:
            item['JobAdApplicantsNr']=None

        item['JobAdDescription'] = response.xpath(".//*[@class='jd-main-job clearfix']//*[@class='jd-body'][1]").extract()




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

        yield item