# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class EjobsJobAdscrapperItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    SourcePage = scrapy.Field()
    ScrapeDate = scrapy.Field()
    JobTitle = scrapy.Field()
    JobAddLink = scrapy.Field()
    CompanyName = scrapy.Field()
    TipJob = scrapy.Field()
    Orase = scrapy.Field()
    NivelCariera = scrapy.Field()
    LimbiStraine = scrapy.Field()
    Oferta = scrapy.Field()
    Departament = scrapy.Field()
    JobAdStartDate = scrapy.Field()
    JobAdExpireDate = scrapy.Field()
    NrJoburi = scrapy.Field()
    JobAdApplicantsNr = scrapy.Field()
    JobAdDescription = scrapy.Field()
    JobAdSelectionCriteria = scrapy.Field()
    JobAdDescriptionImage = scrapy.Field()
    JobAdDriverLicence = scrapy.Field()

    # 1 normal Ejobs text add
    # 2 picture custom picture add
    JobAdType = scrapy.Field()


class EjobsScrappedJobAdItems(scrapy.Item):

    SourcePage = scrapy.Field()
    ScrapeDate = scrapy.Field()
    JobTitle = scrapy.Field()
    CompanyName = scrapy.Field()
    TipJob = scrapy.Field()
    Orase = scrapy.Field()
    NivelCariera = scrapy.Field()
    LimbiStraine = scrapy.Field()
    Oferta = scrapy.Field()
    Departament = scrapy.Field()
    JobAdStartDate = scrapy.Field()
    JobAdExpireDate = scrapy.Field()
    NrJoburi = scrapy.Field()
    JobAdApplicantsNr = scrapy.Field()
    JobAdDescription = scrapy.Field()
