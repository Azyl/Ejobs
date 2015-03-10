import os
import csv

__author__ = 'AndreiTataru'


class MasterDataSetup():

    def __init__(self):
        #self.con = cx_Oracle.connect('c##azyl/azyl@azyl13.no-ip.org:1522/pdbazyl13')
        #self.test_con(self.con)
        self.outputdir = 'OutputSqls'


    def countryMasterData(self):
         file_name = 'coduri countries.csv'
         delimiter = ';'
         quote_character = '"'
         csv_fp = open(file_name, 'rb')
         csv_reader = csv.DictReader(csv_fp, fieldnames=[], restkey='undefined-fieldnames', delimiter=delimiter, quotechar=quote_character)
         current_row = 0

         f = open(os.path.join(self.outputdir, 'T_country.sql'),'w')

         for row in csv_reader:
             current_row += 1
             # Use heading rows as field names for all other rows.
             if current_row == 1:
                 csv_reader.fieldnames = row['undefined-fieldnames']
                 continue

             a = "insert into T_country (countryId, countryName, isoCountryCodeA2, isoCountryCodeA3) values (q'!%s!',q'!%s!',q'!%s!',q'!%s!');" % (row['Number'],row['Country'],row['A 2'], row['A 3'])
             f.write(a+'\n')

    def countyMasterData(self):
        file_name = 'coduri counties.csv'
        delimiter = ';'
        quote_character = '"'
        csv_fp = open(file_name, 'rb')
        csv_reader = csv.DictReader(csv_fp, fieldnames=[], restkey='undefined-fieldnames', delimiter=delimiter, quotechar=quote_character)
        current_row = 0
        f = open(os.path.join(self.outputdir, 'T_county.sql'),'w')

        for row in csv_reader:
            current_row += 1
            # Use heading rows as field names for all other rows.
            if current_row == 1:
                csv_reader.fieldnames = row['undefined-fieldnames']
                continue

            a = "insert into T_county (countyId, countyName, countryId, countyCapital) values (q'!%s!',q'!%s!',%i,q'!%s!');" % (row['ISO'],row['County'],642, row['Capital'])
            f.write(a+'\n')

    def cityMasterData(self):
        file_name = 'coduri siruta Romania.csv'
        delimiter = ';'
        quote_character = '"'
        csv_fp = open(file_name, 'rb')
        csv_reader = csv.DictReader(csv_fp, fieldnames=[], restkey='undefined-fieldnames', delimiter=delimiter, quotechar=quote_character)
        current_row = 0
        f = open(os.path.join(self.outputdir, 'T_city.sql'),'w')

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


            a = "insert into T_city (cityId, cityType, cityName, cityNameAlt, parentCityName,countyId,countryId) values (q'!%s!',q'!%s!',q'!%s!',q'!%s!',q'!%s!',q'!%s!',%i);" % (row['Cod SIRUTA'],mediu,row['Numele localitatii'],'',row['Numele localitatii superioare'],row['Cod judet'],642)
            f.write(a+'\n')

    def industryMasterData(self):
        file_name = 'Industry.csv'
        delimiter = ';'
        quote_character = '"'
        csv_fp = open(file_name, 'rb')
        csv_reader = csv.DictReader(csv_fp, fieldnames=[], restkey='undefined-fieldnames', delimiter=delimiter, quotechar=quote_character)
        current_row = 0
        f = open(os.path.join(self.outputdir, 'T_industry.sql'),'w')

        for row in csv_reader:
            current_row += 1
            # Use heading rows as field names for all other rows.
            if current_row == 1:
                csv_reader.fieldnames = row['undefined-fieldnames']
                continue

            a = "insert into T_industry (industryId,industryName,industryNameAlt) values (%i,q'!%s!',q'!%s!');" % (int(row['IndustryId']),row['Industry'],row['IndustryAlt'])
            f.write(a+'\n')

    def departmentsMasterData(self):
        file_name = 'Departments.csv'
        delimiter = ';'
        quote_character = '"'
        csv_fp = open(file_name, 'rb')
        csv_reader = csv.DictReader(csv_fp, fieldnames=[], restkey='undefined-fieldnames', delimiter=delimiter, quotechar=quote_character)
        current_row = 0
        f = open(os.path.join(self.outputdir, 'T_departments.sql'),'w')

        for row in csv_reader:
            current_row += 1
            # Use heading rows as field names for all other rows.
            if current_row == 1:
                csv_reader.fieldnames = row['undefined-fieldnames']
                continue

            a = "insert into T_departments(departmentId,departmentName,departmentNameAlt) values (%i,q'!%s!',q'!%s!');" % (int(row['DepartmentId']),str(row['Department']).replace('&','CHR(38)'),str(row['DepartmentAlt']).replace('&','CHR(38)'))
            f.write(a+'\n')

    def careerLevelMasterData(self):
        file_name = 'Carrer Levels.csv'
        delimiter = ';'
        quote_character = '"'
        csv_fp = open(file_name, 'rb')
        csv_reader = csv.DictReader(csv_fp, fieldnames=[], restkey='undefined-fieldnames', delimiter=delimiter, quotechar=quote_character)
        current_row = 0
        f = open(os.path.join(self.outputdir, 'T_careerLevel.sql'),'w')
        for row in csv_reader:
            current_row += 1
            # Use heading rows as field names for all other rows.
            if current_row == 1:
                csv_reader.fieldnames = row['undefined-fieldnames']
                continue

            a = "insert into T_careerLevel(careerLevelId,careerLevelName,careerLevelNameAlt) values (%i,q'!%s!',q'!%s!');" % (int(row['CarrerLevelId']),row['CarrerLevel'],row['CarrerLevelAlt'])
            f.write(a+'\n')

    def driverLicenceMasterData(self):
        file_name = 'Driver licences.csv'
        delimiter = ';'
        quote_character = '"'
        csv_fp = open(file_name, 'rb')
        csv_reader = csv.DictReader(csv_fp, fieldnames=[], restkey='undefined-fieldnames', delimiter=delimiter, quotechar=quote_character)
        current_row = 0
        f = open(os.path.join(self.outputdir, 'T_driverLicence.sql'),'w')
        for row in csv_reader:
            current_row += 1
            # Use heading rows as field names for all other rows.
            if current_row == 1:
                csv_reader.fieldnames = row['undefined-fieldnames']
                continue

            a = "insert into T_driverLicence(driverLicenceId,driverLicenceDescription,driverLicenceDescriptionAlt) values (q'!%s!',q'!%s!',q'!%s!');" % (row['DriverLicenceId'],row['DriverLicenceDescription'],'')
            f.write(a+'\n')

    def jobTypeMasterData(self):
        file_name = 'Job Types.csv'
        delimiter = ';'
        quote_character = '"'
        csv_fp = open(file_name, 'rb')
        csv_reader = csv.DictReader(csv_fp, fieldnames=[], restkey='undefined-fieldnames', delimiter=delimiter, quotechar=quote_character)
        current_row = 0
        f = open(os.path.join(self.outputdir, 'T_jobType.sql'),'w')
        for row in csv_reader:
            current_row += 1
            # Use heading rows as field names for all other rows.
            if current_row == 1:
                csv_reader.fieldnames = row['undefined-fieldnames']
                continue

            a = "insert into T_jobType(jobAdTypeId,jobAdTypeName) values (q'!%s!',q'!%s!');" % (int(row['JobAdTypeId']),row['JobAdTypeName'])
            f.write(a+'\n')

    def languageMasterData(self):
        file_name = 'Language.csv'
        delimiter = ';'
        quote_character = '"'
        csv_fp = open(file_name, 'rb')
        csv_reader = csv.DictReader(csv_fp, fieldnames=[], restkey='undefined-fieldnames', delimiter=delimiter, quotechar=quote_character)
        current_row = 0
        f = open(os.path.join(self.outputdir, 'T_language.sql'),'w')
        for row in csv_reader:
            current_row += 1
            # Use heading rows as field names for all other rows.
            if current_row == 1:
                csv_reader.fieldnames = row['undefined-fieldnames']
                continue

            a = "insert into T_language(languageId,languageName,languageNameAlt) values (%i,q'!%s!',q'!%s!');" % (int(row['LanguageId']),row['LanguageName'],row['LanguageNameAlt'])
            f.write(a+'\n')

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


    ora = MasterDataSetup()
    ora.countryMasterData()
    ora.countyMasterData()
    ora.cityMasterData()
    ora.industryMasterData()
    ora.departmentsMasterData()
    ora.careerLevelMasterData()
    ora.driverLicenceMasterData()
    ora.jobTypeMasterData()
    ora.languageMasterData()