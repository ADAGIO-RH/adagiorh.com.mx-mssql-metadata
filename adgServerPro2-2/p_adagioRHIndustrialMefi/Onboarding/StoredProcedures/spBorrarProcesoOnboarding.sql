USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Onboarding].[spBorrarProcesoOnboarding](
    @IDProcesoOnboarding int,
    @IDUsuario int
)
as 
BEGIN
    DELETE FROM [Onboarding].[tblProcesosOnboarding] 
        where IDProcesoOnboarding =@IDProcesoOnboarding
        
        delete from tareas.tblTareas where IDTipoTablero=3 and IDReferencia= @IDProcesoOnboarding

END
GO
