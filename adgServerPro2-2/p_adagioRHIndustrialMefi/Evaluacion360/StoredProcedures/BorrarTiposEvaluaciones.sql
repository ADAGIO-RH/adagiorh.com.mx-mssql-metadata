USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE  Evaluacion360.BorrarTiposEvaluaciones
	@IDTipoEvaluacion int = 0,
	@IDUsuario int
    as 

    delete [Evaluacion360].[tblCatTiposEvaluaciones] 
	where IDTipoEvaluacion = @IDTipoEvaluacion
GO
