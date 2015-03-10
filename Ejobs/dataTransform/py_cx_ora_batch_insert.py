import datetime

__author__ = 'AndreiTataru'
import cx_Oracle

# build rows for each date and add to a list of rows we'll use to insert as a batch
rows = []
numberOfYears = endYear - startYear + 1
for i in range(numberOfYears):
    for j in range(12):
        # make a date for the first day of the month
        dateValue = datetime.date(startYear + i, j + 1, 1)
        index = (i * 12) + j
        row = (stationId, dateValue, temps[index], precips[index])
        rows.append(row)

# insert all of the rows as a batch and commit
ip = '192.1.2.3'
port = 1521
SID = 'my_sid'
dsn = cx_Oracle.makedsn(ip, port, SID)
connection = cx_Oracle.connect('username', 'password', dsn)
cursor = cx_Oracle.Cursor(connection)
cursor.prepare('insert into ' + database_table_name + ' (id, record_date, temp, precip) values (:1, :2, :3, :4)')
cursor.executemany(None, rows)
connection.commit()
cursor.close()
connection.close()