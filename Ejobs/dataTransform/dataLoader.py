import csv

__author__ = 'AndreiTataru'

import json
import kombu
import kombu.entity
import cx_Oracle
import traceback
import hashlib
from scrapy.utils.serialize import ScrapyJSONEncoder
from scrapy.conf import settings


class OraLoad():

    def __init__(self):
        self.connection = cx_Oracle.connect('azyl/azyl@azyl13.no-ip.org:1522/pdbazyl13')

    def __exit__(self):
        self.connection.close()

    def bulkLoad(self):
        pass

    def gensha1(self,payload):
        m = hashlib.sha1()
        m.update(payload)
        return m.hexdigest()

    def insertPayload(self,payload):
        cursor = cx_Oracle.Cursor(self.connection)
        ins_sql=('insert into T_SCRAPPEDADS (JOBADJSON,JSONTYPEID,PARSED,SCRAPESESSIONID) values (:1,:2,:3,:4)')

        try:
            cursor.execute(ins_sql, (payload,1,'N',1))
        except:
            print traceback.format_exc()
            self.connection.rollback()

    def insertPayload2(self,payload,items):
        cursor = cx_Oracle.Cursor(self.connection)
        ins_sql=('insert into T_EXPANDED_SCRAPPEDADS (scrapeid,sourceid,scrapesessionid,jobadjson,jobadtype,sourcepage,scrapedate,jobtitle,jobaddlink,companyname,tipjob,orase,nivelcariera,limbistraine,oferta,departament,industry,jobadstartdate,jobadexpiredate,nrjoburi,jobadapplicantsnr,jobaddescription,jobadselectioncriteria,jobaddescriptionimage,jobaddriverlicence ) values (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,:20,:21,:22,:23,:24,:25)')


        try:
            cursor.execute(ins_sql,( self.gensha1(items.get('JobAddLink')),1,1,payload,items.get('JobAdType'),items.get('SourcePage')
                           ,items.get('ScrapeDate'),items.get('JobTitle'),items.get('JobAddLink'),items.get('CompanyName'),items.get('TipJob')
                           ,items.get('Orase'),items.get('NivelCariera'),items.get('LimbiStraine'),items.get('Oferta'),items.get('Departament'),items.get('Industry')
                           # ,datetime.strptime(items.get('JobAdStartDate'), "%Y-%m-%d %H:%M:%S"),datetime.strptime(items.get('JobAdExpireDate'), "%Y-%m-%d %H:%M:%S")
                           ,items.get('JobAdStartDate'),items.get('JobAdExpireDate')
                           ,items.get('NrJoburi'),items.get('JobAdApplicantsNr'),items.get('JobAdDescription'),items.get('JobAdSelectionCriteria'),items.get('JobAdDescriptionImage'),items.get('JobAdDriverLicence'))
                           )
        except:
            print traceback.format_exc()
            self.connection.rollback()

    def generatePayload(self,payload,items):

        with open('t_expanded_scrapeads.csv', 'wb') as f:  # Just use 'w' mode in 3.x
            w = csv.DictWriter(f,items.keys())
            w.writeheader()
            w.writerow(items)


    def insertPayload3(self,payload,items):

        cursor = cx_Oracle.Cursor(self.connection)
        ins_sql=('insert into T_SCRAPPEDADS (SCRAPEID,JOBADJSON,JSONTYPEID,PARSED,SCRAPESESSIONID) values (:1,:2,:3,:4,:5)')

        try:
            cursor.execute(ins_sql, (self.gensha1(items['JobAddLink']),payload,1,'N',2))
        except:
            print traceback.format_exc()
            self.connection.rollback()

    def insertPayload4(self,payload,items):

            cursor = cx_Oracle.Cursor(self.connection)
            ins_sql=('insert into T_SCRAPPEDADS (SCRAPEID,JOBADJSON,JSONTYPEID,PARSED,SCRAPESESSIONID) values (:1,:2,:3,:4,:5)')

            try:
                cursor.execute(ins_sql, (self.gensha1(items['JobAddLink']),payload,2,'N',2))
            except:
                print traceback.format_exc()
                self.connection.rollback()


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

        self.oraClient = OraLoad()
        self.consumer = self.q_connection.Consumer(queues=self.queue, callbacks=[self.messageHandler])

        # self.producer = self.q_connection.Producer(exchange=self.exchange, routing_key=spider.name)
        # self.producer = self.q_connection.Producer(exchange=self.exchange)

    def messageHandler(self, b, m , ):
        print b, m

        item = dict(m.decode()) 
        #self.oraClient.insertPayload(json.dumps(item))
        # self.oraClient.insertPayload3(json.dumps(item),item['JobAddLink'])


        # self.oraClient.insertPayload3(json.dumps(item),item)
        # or
        self.oraClient.insertPayload4(json.dumps(item),item)






        # self.oraClient.generatePayload(json.dumps(item),item)
        self.oraClient.connection.commit()
        # m.ack()
        # for field, possible_values in item.iteritems():
        #    print field, possible_values

        print "------->><<<>><<>><>>-------"

        # if item['JobAdType'] == 1:
        #     print item['Oferta']
        # elif item['JobAdType'] == 2:
        #     pass
        # else:
        #     raise Exception("item['JobAdType'] is null")

if __name__ == "__main__":



    rabbit = RabbitmqConsumer()
    rabbit.connect(routing_key='')
    rabbit.consumer.consume(no_ack=False)
    print 'Waiting for messages'
    i = 0
    try:
        while True:
            rabbit.q_connection.drain_events()
            i=i+1
        with rabbit.consumer:
            rabbit.q_connection.drain_events(timeout=1)
    except KeyboardInterrupt:
        print i
        print('done')

    # oraClient = OraLoad()
    # oraClient.insertPayload(payload='asda asd asda TEST')
    # oraClient.connection.commit()