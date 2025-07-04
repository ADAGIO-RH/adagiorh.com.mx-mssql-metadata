USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Onboarding].[spIUPlantilla](
    @IDPlantilla int,
    @NombrePlantilla varchar(255),
    @IDsPlaza varchar(max),
    @IDUsuario int

)
AS BEGIN
    IF(ISNULL(@IDPlantilla,0)=0)
        BEGIN
            INSERT INTO Onboarding.tblPlantillas(
        
                    NombrePlantilla,                   
                    IDsPlaza
                   
                )
                values (
                       
                        @NombrePlantilla,                      
                        @IDsPlaza
                      
                )
                set @IDPlantilla=@@IDENTITY
    END ELSE
        BEGIN
            UPDATE Onboarding.tblPlantillas
            SET                   
                    
                    NombrePlantilla=@NombrePlantilla,                    
                    IDsPlaza=@IDsPlaza
            WHERE IDPlantilla = @IDPlantilla
        END        
exec [Onboarding].[spBuscarPlantillas] @IDPlantilla= @IDPlantilla, @IDUsuario=@IDUsuario
    
END;
GO
