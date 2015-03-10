__author__ = 'AndreiTataru'


import kombu
import kombu.entity
import cx_Oracle
from scrapy.utils.serialize import ScrapyJSONEncoder
from scrapy.conf import settings


class OraLoad():

    def __init__(self):
        self.connection = cx_Oracle.connect('c##azyl/azyl@azyl13.no-ip.org:1522/pdbazyl13')

    def __exit__(self):
        self.connection.close()

    def bulkLoad(self):
        pass

    def insertPayload(self,payload):
        cursor = cx_Oracle.Cursor(self.connection)
        cursor.execute('insert into ')

    def testCon(self):
        cursor = cx_Oracle.Cursor(self.connection)
        cursor.execute('select * from DUAL')
        for row in cursor:
            print row


class RabbitmqConsumer():

    def __init__(self):
        host_name = settings.get('BROKER_HOST')
        port = settings.get('BROKER_PORT')
        userid = settings.get('BROKER_USERID')
        password = settings.get('BROKER_PASSWORD')
        virtual_host = settings.get('BROKER_VIRTUAL_HOST')
        encoder_class = settings.get('MESSAGE_Q_SERIALIZER', ScrapyJSONEncoder)
        self.q_connection = kombu.Connection('amqp://'+userid+':'+password+'@'+host_name+':'+str(port)+'/'+virtual_host)
        self.exchange = kombu.entity.Exchange(name='JobAds', durable=True)
        self.encoder = encoder_class()

    def __exit__(self):
        self.consumer.close()
        self.q_connection.close()

    def connect(self, routing_key):
        self.q_connection.connect()
        self.exchange = self.exchange(self.q_connection.channel())
        self.exchange.declare()
        self.queue = kombu.entity.Queue(name='JobAdsP', exchange=self.exchange, routing_key=routing_key)
        self.queue = self.queue(self.q_connection.channel())
        self.queue.declare()

        self.consumer = self.q_connection.Consumer(queues=self.queue, callbacks=[self.messageHandler])

        # self.producer = self.q_connection.Producer(exchange=self.exchange, routing_key=spider.name)
        # self.producer = self.q_connection.Producer(exchange=self.exchange)

    def messageHandler(self, b, m):
        print b, m
        item = dict(m.decode())

        # for field, possible_values in item.iteritems():
        #    print field, possible_values

        print "------->><<<>><<>><>>-------"

        if item['JobAdType'] == 1:
            print item['Oferta']
        elif item['JobAdType'] == 2:
            pass
        else:
            raise Exception("item['JobAdType'] is null")

if __name__ == "__main__":

    # rabbit = RabbitmqConsumer()
    # rabbit.connect(routing_key='')
    # rabbit.consumer.consume(no_ack=False)
    # print 'Waiting for messages'
    # while True:
    #     rabbit.q_connection.drain_events()
    # with rabbit.consumer:
    #     rabbit.q_connection.drain_events(timeout=1)

    oraClient = OraLoad()
    oraClient.insertRow()