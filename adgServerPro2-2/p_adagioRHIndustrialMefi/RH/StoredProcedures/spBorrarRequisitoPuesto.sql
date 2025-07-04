USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc RH.spBorrarRequisitoPuesto(
	@IDRequisitoPuesto int,
	@IDUsuario int
) as

	BEGIN TRY  
		DELETE RH.tblRequisitosPuestos
		WHERE IDRequisitoPuesto = @IDRequisitoPuesto
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
GO
