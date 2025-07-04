USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Tzdb].[AddZone]
    @Name varchar(50)
AS
DECLARE @id int
SELECT @id = [Id] FROM [Tzdb].[Zones] WHERE [Name] = @Name
IF @id is null
BEGIN
    INSERT INTO [Tzdb].[Zones] ([Name]) VALUES (@Name)
    SET @id = SCOPE_IDENTITY()
END
SELECT @id as [Id]
GO
