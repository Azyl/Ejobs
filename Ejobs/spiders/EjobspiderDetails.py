import scrapy
from Ejobs.items import EjobsJobAdscrapperItem
from time import gmtime, strftime
import kombu
import kombu.entity

class LinkSpider(scrapy.Spider,):

    name = "LinkSpiderDetails"
    allowed_domanains = ["ejobs.ro"]
    start_urls = ["http://wwww.ejobs.ro/user/searchjobs?q=&oras[]=&departament[]=&industrie[]=&searchType=simple&time_span=&page_no=&page_results="]

    def __init__(self):
        self.i = 1

        # rabbit mq
        self.q_connection = kombu.Connection('amqp://'+userid+':'+password+'@'+host_name+':'+str(port)+'/'+virtual_host)
        self.exchange = kombu.entity.Exchange(name='JobAds', durable=True)
        self.q_connection.connect()
        self.exchange = self.exchange(self.q_connection.channel())
        self.exchange.declare()
        self.inqueu = kombu.entity.Queue(name='JobAdsP', exchange=self.exchange, routing_key='LinkSpider')
        self.inqueu = self.inqueu(self.q_connection.channel())
        self.inqueu.declare()

    @classmethod
    def from_settings(cls, settings):
        host_name = settings.get('BROKER_HOST')
        port = settings.get('BROKER_PORT')
        userid = settings.get('BROKER_USERID')
        password = settings.get('BROKER_PASSWORD')
        virtual_host = settings.get('BROKER_VIRTUAL_HOST')
        # encoder_class = settings.get('MESSAGE_Q_SERIALIZER', Scrapy

    def parse(self, response):
        """
        @returns items 1 100
        @scrapes JobTitle SourcePage ScrapeDate JobAddLink
        """
        JobAdsResponse = response

    def __exit__(self):
        pass
