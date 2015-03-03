import scrapy
from Ejobs.items import EjobsJobAdscrapperItem
from time import gmtime, strftime
import kombu
import kombu.entity
from scrapy.conf import settings

class LinkSpider(scrapy.Spider,):


    def __init__(self):
        self.i = 1


        host_name = settings.get('BROKER_HOST')
        port = settings.get('BROKER_PORT')
        userid = settings.get('BROKER_USERID')
        password = settings.get('BROKER_PASSWORD')
        virtual_host = settings.get('BROKER_VIRTUAL_HOST')
        # rabbit mq
        print 'amqp://'+userid+':'+password+'@'+host_name+':'+str(port)+'/'+virtual_host
        self.q_connection = kombu.Connection('amqp://'+userid+':'+password+'@'+host_name+':'+str(port)+'/'+virtual_host)
        self.exchange = kombu.entity.Exchange(name='JobAds', durable=True)
        self.q_connection.connect()
        self.exchange = self.exchange(self.q_connection.channel())
        self.exchange.declare()
        self.inqueu = kombu.entity.Queue(name='JobAdsP', exchange=self.exchange, routing_key='LinkSpider')
        self.inqueu = self.inqueu(self.q_connection.channel())
        self.inqueu.declare()
        self.consumer = self.q_connection.Consumer(queues=self.inqueu)

    def getLinktoCrawl(self):

        self.message = self.consumer.consume()



    def parse(self, response):

        JobAdsResponse = response
        print response
        self.getLinktoCrawl()

    def __exit__(self):
        self.consumer.close()
        self.q_connection.release()
        self.q_connection.close()


    name = "LinkSpiderDetails"
    allowed_domanains = ["ejobs.ro"]
    start_urls = ["http://wwww.ejobs.ro/user/searchjobs?q=&oras[]=&departament[]=&industrie[]=&searchType=simple&time_span=&page_no=&page_results="]