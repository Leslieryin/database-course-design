IF DB_ID('register') IS NOT NULL
BEGIN
    ALTER DATABASE register SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE register;
END
GO

CREATE    DATABASE    register 
ON PRIMARY
(NAME=register_data,FILENAME='C:\SQLData\register_data.mdf',
SIZE=5MB,FILEGROWTH=10%,MAXSIZE=15MB),
(NAME=register_data1,FILENAME='C:\SQLData\register_data1.ndf',
SIZE=5MB,FILEGROWTH=0MB)
LOG ON
(NAME=register_log,FILENAME='C:\SQLData\register_log.ldf',
SIZE=4MB,FILEGROWTH=15%),
(NAME=register_log2,FILENAME='C:\SQLData\register_log2.1df',
SIZE=3MB,FILEGROWTH=1MB)
GO

ALTER DATABASE register
ADD FILE
(NAME=register_data2,FILENAME='C:\SQLData\register_data2.ndf',
SIZE=5MB,MAXSIZE=50MB,FILEGROWTH=1MB)
GO

USE register 
GO
CREATE TABLE 患者1 
(
患者编号 CHAR(4)PRIMARY KEY, 
患者姓名 NCHAR(10)NOT NULL,
患者性别 CHAR(1)NOT NULL,
患者年龄 SMALLINT,
CONSTRAINT CK_sex1
    CHECK(患者性别 in('M','F')),
CONSTRAINT CK_age1
    CHECK(患者年龄>0 and 患者年龄<130)
)
CREATE TABLE 科室
(
科室编号 CHAR(4)PRIMARY KEY,
科室名称 NCHAR(30)NOT NULL,
科室电话 CHAR(8)NOT NULL,
科室地址 VARCHAR(30)NOT NULL,
CONSTRAINT CK_phone
    CHECK(科室电话 LIKE'[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
)
CREATE TABLE 医生 
(
医生编号 CHAR(4)PRIMARY KEY, 
医生姓名 NCHAR(10)NOT NULL,
医生电话 CHAR(11)NOT NULL,
月工资 FLOAT NOT NULL,
科室编号 CHAR(4)NOT NULL, 
职称 NCHAR(10)NOT NULL,
FOREIGN KEY(科室编号)REFERENCES 科室(科室编号), 
CONSTRAINT CK_money CHECK(月工资>0),
CONSTRAINT CK_phone1
    CHECK(医生电话 LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') 
)
CREATE TABLE 挂号
(
患者编号 CHAR(4)NOT NULL, 
医生编号 CHAR(4)NOT NULL, 
排队号 CHAR(4)NOT NULL,
时间 VARCHAR(30)NOT NULL,
PRIMARY KEY(患者编号,医生编号),
FOREIGN KEY(患者编号)REFERENCES 患者1(患者编号),
FOREIGN KEY(医生编号)REFERENCES 医生(医生编号), 
CONSTRAINT CK_order CHECK(排队号>0)
)
GO
USE register
GO
ALTER TABLE 患者1 ADD 患者电话 VARCHAR(15)NULL
GO
EXECUTE sp_help 患者1
GO
ALTER  TABLE 科室
ALTER  COLUMN 科室地址 VARCHAR(50)
GO
EXECUTE sp_help 科室
GO

USE  register
GO
INSERT INTO 患者1(患者编号,患者姓名,患者性别,患者年龄)
VALUES('P001','陈诚','M',25)
INSERT INTO 患者1(患者编号,患者姓名,患者性别,患者年龄)
VALUES('P002','王俊文','M',46)
INSERT INTO 患者1(患者编号,患者姓名,患者性别,患者年龄)
VALUES('P003','李浩','M',37)
INSERT INTO 患者1(患者编号,患者姓名,患者性别,患者年龄)
VALUES('P004','夏圆圆','F',18)
INSERT INTO 患者1(患者编号,患者姓名,患者性别,患者年龄)
VALUES('P005','邱雨','F',5)
INSERT INTO 患者1(患者编号,患者姓名,患者性别,患者年龄)
VALUES('P006','杨菲尔','F',63)
INSERT INTO 患者1(患者编号,患者姓名,患者性别,患者年龄)
VALUES('P007','邓晨','M',72)
INSERT INTO 患者1(患者编号,患者姓名,患者性别,患者年龄)
VALUES('P008','王冉','F',83)
INSERT INTO 患者1(患者编号,患者姓名,患者性别,患者年龄)
VALUES('P009','沈倩','F',52)
INSERT INTO 患者1(患者编号,患者姓名,患者性别,患者年龄)
VALUES('P010','赵卓','M',69)
GO
SELECT*FROM  患者1
GO
INSERT INTO 科室(科室编号,科室名称,科室电话,科室地址)
VALUES('R001','内科','24302158','内科楼')
INSERT INTO 科室(科室编号,科室名称,科室电话,科室地址)
VALUES('R002', '外科','24322478','外科大楼')
INSERT INTO 科室(科室编号,科室名称,科室电话,科室地址)
VALUES('R003', '儿科','24314590','门诊楼')
INSERT INTO 科室(科室编号,科室名称,科室电话,科室地址)
VALUES('R004', '妇产科','24340831','门诊楼')
INSERT INTO 科室(科室编号,科室名称,科室电话,科室地址)
VALUES('R005', '中医科','24333427','中医楼') 
GO
SELECT*FROM    科室
GO
INSERT  INTO 医生(医生编号,医生姓名,医生电话,月工资,科室编号,职称)
VALUES('D001','白立新','13800000001',9000,'R002', '住院医师')
INSERT  INTO 医生(医生编号,医生姓名,医生电话,月工资,科室编号,职称)
VALUES('D002','沈青','13800000002',15000,'R003',  '主治医师')
INSERT  INTO 医生(医生编号,医生姓名,医生电话,月工资,科室编号,职称)
VALUES('D003','卢静','13800000003',7000,'R001','副主任医师')
INSERT  INTO 医生(医生编号,医生姓名,医生电话,月工资,科室编号,职称)
VALUES('D004', '鲁宁','13800000004',12000,'R002',  '主治医师')
INSERT  INTO 医生(医生编号,医生姓名,医生电话,月工资,科室编号,职称)
VALUES('D005', '石磊','13800000005',8000,'R001','住院医师')
INSERT  INTO 医生(医生编号,医生姓名,医生电话,月工资,科室编号,职称)
VALUES('D006', '王岚','13800000006',8500,'R004', '副主任医师')
INSERT  INTO 医生(医生编号,医生姓名,医生电话,月工资,科室编号,职称)
VALUES('D007','宋爽','13800000007',10000,'R005','主治医师')
INSERT  INTO 医生(医生编号,医生姓名,医生电话,月工资,科室编号,职称)
VALUES('D008','伊佳佳','13800000008',8500,'R005',  '住院医师')
INSERT  INTO 医生(医生编号,医生姓名,医生电话,月工资,科室编号,职称)
VALUES('D009', '王伟','13800000009',9500,'R002','副主任医师')
INSERT  INTO 医生(医生编号,医生姓名,医生电话,月工资,科室编号,职称)
VALUES('D010', '丁琳','13800000010',9000,'R003', '住院医师')
GO
SELECT*FROM 医生
GO
INSERT INTO 挂号(患者编号,医生编号,排队号,时间)
VALUES('P001','D003','0001','2020年1月5日8:00—8:30')
INSERT INTO 挂号(患者编号,医生编号,排队号,时间)
VALUES('P002','D005','0002','2020年1月5日8:30—9:00')
INSERT INTO 挂号(患者编号,医生编号,排队号,时间)
VALUES('P003','D003','0003','2020年1月5日9:00—9:30')
INSERT INTO 挂号(患者编号,医生编号,排队号,时间)
VALUES('P004','D004','0004','2020年1月5日9:30—10:00')
INSERT INTO 挂号(患者编号,医生编号,排队号,时间)
VALUES('P005','D002','0005','2020年1月5日10:00—10:30')
INSERT INTO 挂号(患者编号,医生编号,排队号,时间)
VALUES('P006','D001','0006','2020年1月5日10:30—11:00')
INSERT INTO 挂号(患者编号,医生编号,排队号,时间)
VALUES('P007','D005','0007','2020年1月5日11:00—11:30')
INSERT INTO 挂号(患者编号,医生编号,排队号,时间)
VALUES('P008','D006','0008','2020年1月5日13:00—13:30')
INSERT INTO 挂号(患者编号,医生编号,排队号,时间)
VALUES('P009','D003','0009','2020年1月5日13:30—14:00')
INSERT INTO 挂号(患者编号,医生编号,排队号,时间)
VALUES('P010','D007','0010','2020年1月5日14:00—14:30')
GO
SELECT*FROM  挂号
GO

USE register
GO
SELECT*FROM 科室
GO

SELECT 科室名称,科室电话
FROM 科室
WHERE 科室地址='门诊楼'
GO

SELECT 医生编号,医生姓名,科室名称 FROM 医生,科室
WHERE 职称='住院医师'AND 月工资>8000
        AND 医生.科室编号=科室.科室编号 
ORDER BY 月工资 DESC
GO

SELECT 患者姓名,排队号,时间
FROM 患者1,医生,挂号
WHERE 医生姓名 = '卢静' AND  患者1.患者编号=挂号.患者编号
AND 医生.医生编号=挂号.医生编号
GO

SELECT 医生编号,COUNT(*) AS 数量
FROM 挂号
GROUP BY 医生编号
GO

SELECT    医生编号,医生电话,职称
FROM 医生,科室
WHERE 科室名称='中医科'AND 医生.科室编号=科室.科室编号 
GO

USE register
GO
SELECT*FROM 科室
GO
UPDATE 科室 SET 科室地址='外科大楼'
WHERE 科室名称='妇产科'
GO
SELECT*FROM   科室
GO

SELECT*FROM 医生
WHERE 科室编号 IN
(SELECT 科室编号 FROM 科室 WHERE 科室名称='内科')
GO
UPDATE 医生 SET 月工资=月工资*1.1
WHERE 科室编号 IN
 (SELECT 科室编号 FROM 科室 WHERE 科室名称='内科')
 GO
SELECT*FROM 医生
WHERE 科室编号 IN
(SELECT 科室编号 FROM 科室 WHERE 科室名称='内科') 
GO

USE register
GO
SELECT*FROM 挂号
GO
DELETE FROM 挂号
WHERE 患者编号 IN
(SELECT 患者编号 FROM 患者1 WHERE 患者姓名='陈诚')
GO
SELECT*FROM   挂号
GO


USE     register
GO
CREATE INDEX IX_患者姓名 ON 患者1(患者姓名)
GO
CREATE   INDEX IX_科室名称_科室地址 ON 科室(科室名称 ASC,  科室地址 DESC)
GO

USE register
GO
ALTER INDEX IX_患者姓名 ON 患者1 DISABLE
GO
ALTER INDEX IX_患者姓名 ON 患者1 REBUILD
GO
EXECUTE sp_rename '科室.IX_科室名称_科室地址','IX_DENAME_DEADDRESS','INDEX'
GO

USE register
GO
CREATE VIEW VIEW_科室信息
AS
SELECT 科室名称,医生姓名,职称
FROM 科室 INNER  JOIN 医生 ON 医生.科室编号=科室.科室编号
GO
SELECT*FROM VIEW_科室信息
GO

CREATE  VIEW VIEW_挂号
AS
SELECT 挂号.医生编号,COUNT(*)AS 挂号人数
FROM 医生 INNER  JOIN 挂号 ON 医生.医生编号=挂号.医生编号 
GROUP  BY 挂号.医生编号
GO
SELECT*FROM VIEW_挂号
GO

USE register
GO
SELECT*FROM    VIEW_挂号
GO
ALTER VIEW  VIEW_挂号
AS
SELECT  挂号.医生编号, COUNT(*)AS    挂号人数
FROM 医生 INNER  JOIN 挂号 ON 医生.医生编号=挂号.医生编号
WHERE 医生姓名='卢静'
GROUP  BY 挂号.医生编号
GO
SELECT*FROM    VIEW_挂号
GO

USE register
GO
CREATE RULE RL_职称
AS @职称 IN ( '住院医师','主治医师','副主任医师')
GO
EXECUTE sp_bindrule 'RL_职称','医生.职称'
GO

USE register
GO
CREATE DEFAULT DF_职称 AS'副主任医师'
GO
EXECUTE sp_bindefault 'DF_职称','医生.职称'
GO

USE rent
GO
DECLARE @var1 varchar(10)
SELECT @var1=租车公司名称 FROM 租车公司 WHERE 租车公司编号='F001' 
SELECT @var1 AS'租车公司名称'
GO

USE rent
GO
DECLARE @var1 varchar(10)
SELECT @var1=租车公司名称 FROM 租车公司 ORDER BY 租车公司编号
SELECT @var1 AS'租车公司名称'
GO

USE rent
GO
DECLARE @var1 varchar(10)
SET @var1='艺博租车'
SELECT 租车公司编号,租车公司名称 FROM 租车公司 WHERE 租车公司名称=@var1 
GO

SELECT @@version AS 版本号
GO

DECLARE    @String    CHAR(10)
SET @String=ASCII('ABC')
SELECT @String
GO

DECLARE @var     char
SET @var=CHAR('66')
SELECT   @var
GO

DECLARE    @String    CHAR(10)
SET @String='student'
SELECT SUBSTRING(@String,4,4)
GO

DECLARE @String CHAR(10)
SET @String='student'
SELECT LEFT(@String,3)
GO

CREATE PROCEDURE PROC_医生 @医生编号 CHAR(4)=NULL
AS
 IF @医生编号 IS NULL
BEGIN
   PRINT '请输入医生编号'
    END
ELSE
  BEGIN
    SELECT @医生编号 AS 医生编号,COUNT(*)AS 挂号总数量
    FROM 挂号
    WHERE @医生编号=医生编号
    GROUP BY 医生编号
   END
GO
EXECUTE PROC_医生 'D003'
GO

ALTER PROCEDURE PROC_医生 @医生姓名 CHAR(20)=NULL
AS
IF @医生姓名 IS  NULL
BEGIN
PRINT '请输入医生姓名'
END
ELSE
BEGIN
SELECT @医生姓名 AS 医生姓名,COUNT(*)AS 挂号总数量
FROM 挂号
WHERE  医生编号 IN
(SELECT   医生编号 FROM 医生 WHERE @医生姓名=医生姓名)
END
GO
EXECUTE PROC_医生'卢静'
GO

USE register
GO
IF OBJECT_ID ('TRIG_科室' , 'TR') IS NOT NULL
DROP TRIGGER TRIG_科室
GO
CREATE TRIGGER TRIG_科室
ON 科室
AFTER INSERT,UPDATE
AS RAISERROR('Insert or Update Notify 科室 Relations',16,10)
GO
INSERT  INTO 科室(科室编号,科室名称,科室电话,科室地址)
VALUES('R006', '耳鼻喉科','24390457','内科楼')
GO

ALTER TRIGGER TRIG_科室
ON 科室
AFTER DELETE
AS RAISERROR('Delete Notifys 科室 Relations',16,10) 
GO
DELETE FROM 科室 WHERE 科室编号='R006'
GO
DISABLE TRIGGER TRIG_科室 ON  科室
GO
ENABLE TRIGGER TRIG_科室 ON  科室
GO
