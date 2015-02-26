import kombu
import kombu.entity
import kombu.connection

if __name__ == "__main__":

    con = kombu.Connection('amqp://azyl:azyl@azyl13.no-ip.org:5672//')
    con.connect()
    chanelc = con.channel()

    exc = kombu.entity.Exchange(name='JobAds',durable=True)
    excb = exc(chanelc)
    excb.declare()

    que = kombu.entity.Queue(name='JobAdsP', exchange=excb)
    queb = que(chanelc)
    queb.declare()


    prod = con.Producer(exchange=excb)
    prod.publish(' tewt ')
