USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Tareas].[spUICatStyleBackground]
(
	@IDStyleBackground int,
    @BackgroundTypes varchar(10),
    @Value varchar(max)
)
-- CREATE TABLE Tareas.tblCatStylesBackground (
--     IDStyleBackground int , 
--     BackgroundTypes varchar(10),
--     Value varchar(max)
-- )

AS
BEGIN
	
 
    INSERT INTO Tareas.tblCatStylesBackground(BackgroundTypes,Value)
    VALUES(@BackgroundTypes,@Value)


    select * from Tareas.tblCatStylesBackground where IDStyleBackground=@@IDENTITY;
	-- IF(@IDStyleBackground = 0)
	-- 	BEGIN
		
		
	-- 	END
	-- ELSE
	-- BEGIN
		

	-- END	

END
GO
