USE [p_adagioRHSimensGamesa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Onboarding].[spBorrarPlantilla](    
    @IDPlantilla int,
    @IDUsuario int = NULL
)
as 
    BEGIN

        delete from [Onboarding].[tblPlantillas]
        where IDPlantilla = @IDPlantilla

         delete from tareas.tblTareas where IDTipoTablero=2 and IDReferencia= @IDPlantilla

    END
GO
