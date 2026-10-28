/*
 * 建库脚本执行后的对象验收。
 * 用 sqlcmd -b 调用，任何缺失都以非零退出码结束。
 *
 * 为什么要有这一步：脚本"跑完没报错"不等于"东西都建出来了"。
 * 中间某条 CREATE 被静默跳过、或者改表名后忘了同步验证，都会在这里露出来。
 */
USE register;
GO

DECLARE @missing NVARCHAR(MAX) = N'';

/* 四张表 */
IF OBJECT_ID(N'dbo.患者1', N'U') IS NULL SET @missing += N'缺表 患者1; ';
IF OBJECT_ID(N'dbo.科室', N'U') IS NULL SET @missing += N'缺表 科室; ';
IF OBJECT_ID(N'dbo.医生', N'U') IS NULL SET @missing += N'缺表 医生; ';
IF OBJECT_ID(N'dbo.挂号', N'U') IS NULL SET @missing += N'缺表 挂号; ';

/* 两个索引。
   注意 IX_科室名称_科室地址 在脚本里被 sp_rename 重命名成了 IX_DENAME_DEADDRESS，
   所以这里验的是改名后的名字。 */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_患者姓名')
    SET @missing += N'缺索引 IX_患者姓名; ';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_DENAME_DEADDRESS')
    SET @missing += N'缺索引 IX_DENAME_DEADDRESS（原 IX_科室名称_科室地址）; ';

/* 两个视图 */
IF OBJECT_ID(N'dbo.VIEW_科室信息', N'V') IS NULL SET @missing += N'缺视图 VIEW_科室信息; ';
IF OBJECT_ID(N'dbo.VIEW_挂号', N'V') IS NULL SET @missing += N'缺视图 VIEW_挂号; ';

/* 存储过程与触发器 */
IF OBJECT_ID(N'dbo.PROC_医生', N'P') IS NULL SET @missing += N'缺存储过程 PROC_医生; ';
IF OBJECT_ID(N'dbo.TRIG_科室', N'TR') IS NULL SET @missing += N'缺触发器 TRIG_科室; ';

/* CHECK 约束：README 里点名了这几个 */
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_sex1')
    SET @missing += N'缺约束 CK_sex1; ';
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_age1')
    SET @missing += N'缺约束 CK_age1; ';
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_phone')
    SET @missing += N'缺约束 CK_phone; ';
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_money')
    SET @missing += N'缺约束 CK_money; ';
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_order')
    SET @missing += N'缺约束 CK_order; ';

IF @missing <> N''
    THROW 50001, @missing, 1;

PRINT N'✓ register：4 表 / 2 索引 / 2 视图 / 1 过程 / 1 触发器 / 5 约束 全部就位';
GO

/* 约束真的会拦人吗？塞一条非法数据试试，应该被拒 */
BEGIN TRY
    INSERT INTO 患者1 (患者编号, 患者姓名, 患者性别, 患者年龄)
    VALUES ('T999', N'测试', 'X', 30);
    THROW 50002, N'CK_sex1 没有拦住非法性别 X —— CHECK 约束失效了', 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50002 THROW;          -- 我们自己的断言失败，往上抛
    PRINT N'✓ CK_sex1 正常拦截非法性别';
END CATCH
GO

/* 视图能查（不是建了个空壳） */
DECLARE @cnt INT;
SELECT @cnt = COUNT(*) FROM VIEW_科室信息;
PRINT N'✓ VIEW_科室信息 可查询，当前 ' + CAST(@cnt AS NVARCHAR(10)) + N' 行';
GO
