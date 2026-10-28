/*
 * 给 rent.sql 造一个最小可用的桩库。
 *
 * 为什么需要这一步：rent.sql 开头会检查 rent 库是否存在，不存在就 RETURN。
 * 不造库直接跑它，永远"成功"——那是假绿，什么都没验证。
 *
 * 桩的表结构是从 rent.sql 实际引用到的字段反推出来的（租车公司编号/名称、
 * 汽车编号/价格、租赁时间、客户编号）。原课设的建表在 SSMS 图形界面做的，
 * 仓库里没有 DDL，所以这里只求"能让约束和查询语句跑起来"，不追求与原库一致。
 */
IF DB_ID('rent') IS NOT NULL
BEGIN
    ALTER DATABASE rent SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE rent;
END
GO

CREATE DATABASE rent;
GO

USE rent;
GO

CREATE TABLE 租车公司
(
    租车公司编号 CHAR(4) PRIMARY KEY,
    租车公司名称 VARCHAR(50) NOT NULL
);

CREATE TABLE 客户
(
    客户编号 CHAR(4) PRIMARY KEY,
    客户姓名 VARCHAR(20)
);

CREATE TABLE 汽车
(
    汽车编号 CHAR(4) PRIMARY KEY,
    租车公司编号 CHAR(4) NULL,
    价格 DECIMAL(10, 2) NULL
);

CREATE TABLE 租赁
(
    客户编号 CHAR(4),
    汽车编号 CHAR(4),
    租赁时间 INT
);
GO

PRINT N'✓ rent 桩库就绪（4 表）';
GO
