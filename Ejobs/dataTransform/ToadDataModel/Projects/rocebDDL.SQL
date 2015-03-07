/*
Created: 3/5/2015
Modified: 3/7/2015
Model: Oracle 12c
Database: Oracle 12c
*/




-- Create tables section -------------------------------------------------

-- Table T_company

CREATE TABLE "T_company"(
  "companyId" Integer GENERATED ALWAYS AS IDENTITY(
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOMINVALUE
    CACHE 20) NOT NULL,
  "companyName" Varchar2(50 ) NOT NULL,
  "Attribute2" Char(20 ),
  "countryId" Integer NOT NULL
)
/

-- Add keys for table T_company

ALTER TABLE "T_company" ADD CONSTRAINT "PK_company" PRIMARY KEY ("companyId","countryId")
/

-- Table T_country

CREATE TABLE "T_country"(
  "countryId" Integer NOT NULL,
  "countryName" Varchar2(30 ) NOT NULL,
  "isoCountryCodeA2" Varchar2(2 ),
  "isoCountryCodeA3" Varchar2(3 )
)
/

-- Add keys for table T_country

ALTER TABLE "T_country" ADD CONSTRAINT "PK_country" PRIMARY KEY ("countryId")
/

-- Table T_county

CREATE TABLE "T_county"(
  "countyId" Varchar2(3 ) NOT NULL,
  "countyName" Varchar2(30 ),
  "countryId" Integer NOT NULL,
  "countyCapital" Varchar2(20 )
)
/

-- Add keys for table T_county

ALTER TABLE "T_county" ADD CONSTRAINT "PK_county" PRIMARY KEY ("countyId","countryId")
/

-- Table T_jobAd

CREATE TABLE "T_jobAd"(
  "jobAdId" Integer GENERATED ALWAYS AS IDENTITY(
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOMINVALUE
    CACHE 20) NOT NULL,
  "jodTitle" Varchar2(100 ),
  "jobAdStarDate" Date,
  "jobAdEndDate" Date,
  "jobAdPositionsNr" Integer,
  "jobAdApplicantsNr" Integer,
  "Attribute6" Char(20 ),
  "Attribute7" Char(20 ),
  "companyId" Integer NOT NULL,
  "countryId" Integer NOT NULL
)
/

-- Add keys for table T_jobAd

ALTER TABLE "T_jobAd" ADD CONSTRAINT "PK_jobAd" PRIMARY KEY ("jobAdId","companyId","countryId")
/

-- Table T_departements

CREATE TABLE "T_departements"(
  "departmentId" Integer GENERATED ALWAYS AS IDENTITY(
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOMINVALUE
    CACHE 20) NOT NULL,
  "departmentName" Varchar2(30 ),
  "departmentNameAlt" Varchar2(30 )
)
/

-- Add keys for table T_departements

ALTER TABLE "T_departements" ADD CONSTRAINT "PK_departments" PRIMARY KEY ("departmentId")
/

-- Table T_activeJobAdsDepartments

CREATE TABLE "T_activeJobAdsDepartments"(
  "jobAdId" Integer NOT NULL,
  "companyId" Integer NOT NULL,
  "countryId" Integer NOT NULL,
  "departmentId" Integer NOT NULL
)
/

-- Add keys for table T_activeJobAdsDepartments

ALTER TABLE "T_activeJobAdsDepartments" ADD CONSTRAINT "FK_activeJobAdsDepartments" PRIMARY KEY ("jobAdId","companyId","countryId","departmentId")
/

-- Table T_industry

CREATE TABLE "T_industry"(
  "industryId" Integer GENERATED ALWAYS AS IDENTITY(
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOMINVALUE
    CACHE 20) NOT NULL,
  "industryName" Varchar2(30 ),
  "industryNameAlt" Varchar2(30 )
)
/

-- Add keys for table T_industry

ALTER TABLE "T_industry" ADD CONSTRAINT "PK_industry" PRIMARY KEY ("industryId")
/

-- Table T_jobAdIndustry

CREATE TABLE "T_jobAdIndustry"(
  "industryId" Integer NOT NULL,
  "jobAdId" Integer NOT NULL,
  "companyId" Integer NOT NULL,
  "countryId" Integer NOT NULL
)
/

-- Add keys for table T_jobAdIndustry

ALTER TABLE "T_jobAdIndustry" ADD CONSTRAINT "FK_jobAdIndustry" PRIMARY KEY ("industryId","jobAdId","companyId","countryId")
/

-- Table T_jobType

CREATE TABLE "T_jobType"(
  "jobTypeId" Integer GENERATED ALWAYS AS IDENTITY(
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOMINVALUE
    CACHE 20) NOT NULL,
  "jobAdTypeName" Varchar2(30 )
)
/

-- Add keys for table T_jobType

ALTER TABLE "T_jobType" ADD CONSTRAINT "PK_jobType" PRIMARY KEY ("jobTypeId")
/

-- Table T_careerLevel

CREATE TABLE "T_careerLevel"(
  "careerLevelId" Integer NOT NULL,
  "careerLevelName" Varchar2(30 ),
  "careerLevelNameAlt" Varchar2(30 )
)
/

-- Add keys for table T_careerLevel

ALTER TABLE "T_careerLevel" ADD CONSTRAINT "PK_carrerLevel" PRIMARY KEY ("careerLevelId")
/

-- Table T_language

CREATE TABLE "T_language"(
  "languageId" Integer NOT NULL,
  "languageName" Varchar2(30 ),
  "languageNameAlt" Varchar2(30 )
)
/

-- Add keys for table T_language

ALTER TABLE "T_language" ADD CONSTRAINT "PK_language" PRIMARY KEY ("languageId")
/

-- Table T_city

CREATE TABLE "T_city"(
  "cityId" Integer NOT NULL,
  "cityType" Varchar2(1 ),
  "cityName" Varchar2(30 ),
  "cityNameAlt" Varchar2(30 ),
  "parentCityName" Varchar2(30 ),
  "countyId" Varchar2(2 ),
  "countyId1" Varchar2(3 ) NOT NULL,
  "countryId" Integer NOT NULL
)
/

-- Add keys for table T_city

ALTER TABLE "T_city" ADD CONSTRAINT "PK_city" PRIMARY KEY ("cityId","countyId1","countryId")
/

-- Table T_jobAdCareerLevel

CREATE TABLE "T_jobAdCareerLevel"(
  "careerLevelId" Integer NOT NULL,
  "jobAdId" Integer NOT NULL,
  "companyId" Integer NOT NULL,
  "countryId" Integer NOT NULL
)
/

-- Add keys for table T_jobAdCareerLevel

ALTER TABLE "T_jobAdCareerLevel" ADD CONSTRAINT "FK_jobAdCareerLevel" PRIMARY KEY ("careerLevelId","jobAdId","companyId","countryId")
/

-- Table T_driverLicence

CREATE TABLE "T_driverLicence"(
  "driveLicenceId" Varchar2(5 ) NOT NULL,
  "driverLicenceDescription" Varchar2(150 ),
  "driverLicenceDescriptionAlt" Varchar2(150 )
)
/

-- Add keys for table T_driverLicence

ALTER TABLE "T_driverLicence" ADD CONSTRAINT "PK_driverLicence" PRIMARY KEY ("driveLicenceId")
/

-- Table T_jobAdDriverLicence

CREATE TABLE "T_jobAdDriverLicence"(
  "jobAdId" Integer NOT NULL,
  "companyId" Integer NOT NULL,
  "countryId" Integer NOT NULL,
  "driveLicenceId" Varchar2(5 ) NOT NULL
)
/

-- Add keys for table T_jobAdDriverLicence

ALTER TABLE "T_jobAdDriverLicence" ADD CONSTRAINT "FK_jobAdDriverLicence" PRIMARY KEY ("jobAdId","companyId","countryId","driveLicenceId")
/

-- Table T_jobAdCity

CREATE TABLE "T_jobAdCity"(
  "jobAdId" Integer NOT NULL,
  "companyId" Integer NOT NULL,
  "countryId" Integer NOT NULL,
  "cityId" Integer NOT NULL,
  "countyId" Varchar2(3 ) NOT NULL,
  "countryId1" Integer NOT NULL
)
/

-- Add keys for table T_jobAdCity

ALTER TABLE "T_jobAdCity" ADD CONSTRAINT "FK_jobAdCity" PRIMARY KEY ("jobAdId","companyId","countryId","cityId","countyId","countryId1")
/

-- Table T_jobAdJobType

CREATE TABLE "T_jobAdJobType"(
  "jobTypeId" Integer NOT NULL,
  "jobAdId" Integer NOT NULL,
  "companyId" Integer NOT NULL,
  "countryId" Integer NOT NULL
)
/

-- Add keys for table T_jobAdJobType

ALTER TABLE "T_jobAdJobType" ADD CONSTRAINT "FK_jobAdJobType" PRIMARY KEY ("jobTypeId","jobAdId","companyId","countryId")
/

-- Table T_jobAdLanguage

CREATE TABLE "T_jobAdLanguage"(
  "languageId" Integer NOT NULL,
  "jobAdId" Integer NOT NULL,
  "companyId" Integer NOT NULL,
  "countryId" Integer NOT NULL
)
/

-- Add keys for table T_jobAdLanguage

ALTER TABLE "T_jobAdLanguage" ADD CONSTRAINT "FK_jobAdLanguage" PRIMARY KEY ("languageId","jobAdId","companyId","countryId")
/

-- Create relationships section ------------------------------------------------- 

ALTER TABLE "T_activeJobAdsDepartments" ADD CONSTRAINT "jobAd_to_departments" FOREIGN KEY ("jobAdId", "companyId", "countryId") REFERENCES "T_jobAd" ("jobAdId", "companyId", "countryId")
/

ALTER TABLE "T_jobAd" ADD CONSTRAINT "Relationship6" FOREIGN KEY ("companyId", "countryId") REFERENCES "T_company" ("companyId", "countryId")
/

ALTER TABLE "T_jobAdIndustry" ADD CONSTRAINT "industry_to_jobAds" FOREIGN KEY ("industryId") REFERENCES "T_industry" ("industryId")
/

ALTER TABLE "T_county" ADD CONSTRAINT "counties_to_country" FOREIGN KEY ("countryId") REFERENCES "T_country" ("countryId")
/

ALTER TABLE "T_city" ADD CONSTRAINT "cities_to_counties" FOREIGN KEY ("countyId1", "countryId") REFERENCES "T_county" ("countyId", "countryId")
/

ALTER TABLE "T_company" ADD CONSTRAINT "country_to_companies" FOREIGN KEY ("countryId") REFERENCES "T_country" ("countryId")
/

ALTER TABLE "T_jobAdIndustry" ADD CONSTRAINT "jobAd_to_industryies" FOREIGN KEY ("jobAdId", "companyId", "countryId") REFERENCES "T_jobAd" ("jobAdId", "companyId", "countryId")
/

ALTER TABLE "T_activeJobAdsDepartments" ADD CONSTRAINT "department_to_jobAds" FOREIGN KEY ("departmentId") REFERENCES "T_departements" ("departmentId")
/

ALTER TABLE "T_jobAdCareerLevel" ADD CONSTRAINT "careerLevel_to_jobAds" FOREIGN KEY ("careerLevelId") REFERENCES "T_careerLevel" ("careerLevelId")
/

ALTER TABLE "T_jobAdCareerLevel" ADD CONSTRAINT "jobAd_to_carrerLevels" FOREIGN KEY ("jobAdId", "companyId", "countryId") REFERENCES "T_jobAd" ("jobAdId", "companyId", "countryId")
/

ALTER TABLE "T_jobAdDriverLicence" ADD CONSTRAINT "jobAd_to_driverLicencesses" FOREIGN KEY ("jobAdId", "companyId", "countryId") REFERENCES "T_jobAd" ("jobAdId", "companyId", "countryId")
/

ALTER TABLE "T_jobAdDriverLicence" ADD CONSTRAINT "driverLicence_to_jobAds" FOREIGN KEY ("driveLicenceId") REFERENCES "T_driverLicence" ("driveLicenceId")
/

ALTER TABLE "T_jobAdCity" ADD CONSTRAINT "jobAds_to_city" FOREIGN KEY ("jobAdId", "companyId", "countryId") REFERENCES "T_jobAd" ("jobAdId", "companyId", "countryId")
/

ALTER TABLE "T_jobAdCity" ADD CONSTRAINT "cities_to_jobAd" FOREIGN KEY ("cityId", "countyId", "countryId1") REFERENCES "T_city" ("cityId", "countyId1", "countryId")
/

ALTER TABLE "T_jobAdJobType" ADD CONSTRAINT "jobType_to_jobAds" FOREIGN KEY ("jobTypeId") REFERENCES "T_jobType" ("jobTypeId")
/

ALTER TABLE "T_jobAdJobType" ADD CONSTRAINT "jobAds_to_jobType" FOREIGN KEY ("jobAdId", "companyId", "countryId") REFERENCES "T_jobAd" ("jobAdId", "companyId", "countryId")
/

ALTER TABLE "T_jobAdLanguage" ADD CONSTRAINT "language_to_jobAds" FOREIGN KEY ("languageId") REFERENCES "T_language" ("languageId")
/

ALTER TABLE "T_jobAdLanguage" ADD CONSTRAINT "jobAd_to_languagesses" FOREIGN KEY ("jobAdId", "companyId", "countryId") REFERENCES "T_jobAd" ("jobAdId", "companyId", "countryId")
/





