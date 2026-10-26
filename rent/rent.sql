IF DB_ID('rent') IS NULL
BEGIN
    PRINT '数据库 rent 不存在，请先执行建库脚本';
    RETURN;
END
GO

USE rent
GO
ALTER TABLE 租车公司
ADD CONSTRAINT UQ_租车公司名称 UNIQUE (租车公司名称)
GO

ALTER     TABLE 汽车
ADD    CONSTRAINT    DF_价格 DEFAULT   1000   FOR 价格
GO

ALTER     TABLE 租赁
ADD CONSTRAINT CK_时间 CHECK (租赁时间>='1')
GO

USE rent
GO
DECLARE @num smallint
IF   EXISTS(SELECT*FROM 租车公司 WHERE 租车公司名称 LIKE'艺博租车%')
BEGIN
SELECT @num=COUNT(*)
FROM 汽车
WHERE 租车公司编号 IN
       (SELECT 租车公司编号 FROM 租车公司 WHERE 租车公司名称 LIKE '艺博租车%')
PRINT'该租车公司拥有的汽车数：'+str(@num)
END
ELSE
PRINT'数据库中没有此租车公司'
GO

USE  rent
GO
SELECT  客户编号,汽车编号,租赁时间等级=
CASE
WHEN 租赁时间>=360 THEN '钻石卡'
WHEN 租赁时间>=180 AND 租赁时间<360 THEN '白金卡' WHEN 租赁时间>=90 AND 租赁时间<180 THEN  '金卡'
WHEN 租赁时间>=30 AND 租赁时间<90 THEN  '银卡' ELSE '普卡'
END
FROM 租赁
GO

DECLARE  @sum  int,@x  int
SET  @sum=0
SET  @x=1
WHILE @x<100
BEGIN
SET   @sum=@sum+@x
SET  @x=@x+1
END
PRINT'sum='+STR(@sum,5)
GO

USE rent
GO
EXECUTE sp_help
GO
EXECUTE sp_help '客户'
GO
EXECUTE sp_helpdb 'rent'
GO
EXECUTE sp_helpdb
GO
EXECUTE sp_helpfile
GO
EXECUTE sp_tables
GO
EXECUTE sp_columns @table_name='租车公司' , @table_owner='dbo'
GO


