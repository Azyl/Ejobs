# project_name/pipelines.py

from scrapy import signals
from scrapy.exceptions import DropItem
from scrapy.utils.serialize import ScrapyJSONEncoder
from scrapy.xlib.pydispatch import dispatcher
from twisted.internet.threads import deferToThread
# import json as simplejson
# import settings
import kombu
import kombu.entity

class MessageQueuePipeline(object):

    """Emit processed items to a RabbitMQ exchange/queue"""
    def __init__(self, host_name, port, userid, password, virtual_host, encoder_class):
        self.urls_seen = set()


        # rabbit mq
        self.q_connection = kombu.Connection('amqp://'+userid+':'+password+'@'+host_name+':'+str(port)+'/'+virtual_host)
        self.exchange = kombu.entity.Exchange(name='JobAds', durable=True)
        self.encoder = encoder_class()
        dispatcher.connect(self.spider_opened, signals.spider_opened)
        dispatcher.connect(self.spider_closed, signals.spider_closed)


    @classmethod
    def from_settings(cls, settings):
        host_name = settings.get('BROKER_HOST')
        port = settings.get('BROKER_PORT')
        userid = settings.get('BROKER_USERID')
        password = settings.get('BROKER_PASSWORD')
        virtual_host = settings.get('BROKER_VIRTUAL_HOST')
        encoder_class = settings.get('MESSAGE_Q_SERIALIZER', ScrapyJSONEncoder)
        return cls(host_name, port, userid, password, virtual_host, encoder_class)

    def spider_opened(self, spider):
        self.q_connection.connect()
        self.exchange = self.exchange(self.q_connection.channel())
        self.exchange.declare()
        self.queue = kombu.entity.Queue(name='JobAdsP', exchange=self.exchange, routing_key=spider.name)
        self.queue = self.queue(self.q_connection.channel())
        self.queue.declare()
        # self.producer = self.q_connection.Producer(exchange=self.exchange, routing_key=spider.name)
        self.producer = self.q_connection.Producer(exchange=self.exchange)

    def spider_closed(self, spider):
        self.producer.close()
        self.q_connection._close()

    def process_item(self, item, spider):
        # return deferToThread(self._process_item, item, spider)
        self.producer.publish(body=dict(item), routing_key=spider.name)
        print str(item)
        return item

    def _process_item(self, item, spider):

        # print '-------- >>>>> ' + str(item['JobAddLink'])
        # if str(item['JobAddLink']) in self.urls_seen:
        #     raise DropItem("Duplicate item found: %s" % item)
        # else:
        #     self.urls_seen.add(str(item['JobAddLink']))
        #     self.producer.publish(body=dict(item))
        #     return item

        # self.producer.publish(body=dict(item))
        # print str(item)
        # return item
        pass




