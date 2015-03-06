import kombu
import kombu.entity
# import cx_Oracle
from scrapy.utils.serialize import ScrapyJSONEncoder
from scrapy.conf import settings

import csv

__author__ = 'AndreiTataru'




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

    def connect(self,routing_key):
        self.q_connection.connect()
        self.exchange = self.exchange(self.q_connection.channel())
        self.exchange.declare()
        self.queue = kombu.entity.Queue(name='JobAdsP', exchange=self.exchange, routing_key=routing_key)
        self.queue = self.queue(self.q_connection.channel())
        self.queue.declare()

        self.consumer = self.q_connection.Consumer(queues=self.queue,callbacks=[self.messageHandler])

        # self.producer = self.q_connection.Producer(exchange=self.exchange, routing_key=spider.name)
        # self.producer = self.q_connection.Producer(exchange=self.exchange)

    def messageHandler(self,b,m):
        print b,m
        item = dict(m.decode())

        #for field, possible_values in item.iteritems():
        #    print field, possible_values

        print "------->><<<>><<>><>>-------"

        if item['JobAdType'] == 1:
            print item['Oferta']
        elif item['JobAdType'] == 2:
            pass
        else:
            raise Exception("item['JobAdType'] is null")

class MasterDataSetup():

    def __init__(self):
        #self.con = cx_Oracle.connect('c##azyl/azyl@azyl13.no-ip.org:1522/pdbazyl13')
        #self.test_con(self.con)
        pass


    def countryMasterData(self):
         file_name = 'coduri countries.csv'
         delimiter = ';'
         quote_character = '"'
         csv_fp = open(file_name, 'rb')
         csv_reader = csv.DictReader(csv_fp, fieldnames=[], restkey='undefined-fieldnames', delimiter=delimiter, quotechar=quote_character)
         current_row = 0
         for row in csv_reader:
             current_row += 1
             # Use heading rows as field names for all other rows.
             if current_row == 1:
                 csv_reader.fieldnames = row['undefined-fieldnames']
                 continue

             print 'insert into T-country (countryId, countryName, isoCountryCodeA2, isoCountryCodeA2) values (%s,%s,%s,%s)' % (row['Number'],row['Country'],row['A 2'], row['A 3'])


    def countyMasterData(self):
        file_name = 'coduri counties.csv'
        delimiter = ';'
        quote_character = '"'
        csv_fp = open(file_name, 'rb')
        csv_reader = csv.DictReader(csv_fp, fieldnames=[], restkey='undefined-fieldnames', delimiter=delimiter, quotechar=quote_character)
        current_row = 0
        for row in csv_reader:
            current_row += 1
            # Use heading rows as field names for all other rows.
            if current_row == 1:
                csv_reader.fieldnames = row['undefined-fieldnames']
                continue

            print 'insert into T-county (countyId, countyName, countryId, countyCapital) values (%s,%s,%i,%s)' % (row['ISO'],row['County'],642, row['Capital'])

    def cityMasterData(self):
        file_name = 'coduri siruta Romania.csv'
        delimiter = ';'
        quote_character = '"'
        csv_fp = open(file_name, 'rb')
        csv_reader = csv.DictReader(csv_fp, fieldnames=[], restkey='undefined-fieldnames', delimiter=delimiter, quotechar=quote_character)
        current_row = 0
        for row in csv_reader:
            current_row += 1
            # Use heading rows as field names for all other rows.
            if current_row == 1:
                csv_reader.fieldnames = row['undefined-fieldnames']
                continue
            if row['Mediu']=='Urban':
                mediu='U'
            else:
                mediu='R'

            print 'insert into T-city (cityId, cityType, cityName, cityNameAlt, parentCityName,countyId,countryId) values (%s,%s,%s,%s,%s,%s,%i)' % (row['Cod SIRUTA'],mediu,row['Numele localitatii'],'',row['Numele localitatii superioare'],row['Cod judet'],642)


    def test_con(self,con):
        cur = con.cursor()
        cur.execute('select * from dual')
        for row in cur:
            print(row)
        print 'works'

    # def __exit__(self):
    #     self.cur.close()
    #     self.con.close()

if __name__ == "__main__":
    # rabbit = RabbitmqConsumer()
    # rabbit.connect(routing_key='')
    # rabbit.consumer.consume(no_ack=False)
    #
    # print 'Waiting for messages'
    # while(True):
    #     rabbit.q_connection.drain_events()

    # with rabbit.consumer:
    #    rabbit.q_connection.drain_events(timeout=1)

    ora = MasterDataSetup()
    #
    ora.countryMasterData()
    ora.countyMasterData()
    ora.cityMasterData()