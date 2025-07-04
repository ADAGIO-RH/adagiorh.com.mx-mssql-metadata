USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatRegPatronal]--1,1
(
	@IDRegPatronal int
	,@IDUsuario int
)
AS
BEGIN

	IF EXISTS(Select Top 1 1 from IMSS.tblMovAfiliatorios where IDRegPatronal = @IDRegPatronal)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END
	IF EXISTS(Select Top 1 1 from Nomina.tblHistorialesEmpleadosPeriodos where IDRegPatronal = @IDRegPatronal)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END
	IF EXISTS(Select Top 1 1 from RH.tblHistorialPrimaRiesgo where IDRegPatronal = @IDRegPatronal)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END
	IF EXISTS(Select Top 1 1 from RH.tblRegPatronalEmpleado where IDRegPatronal = @IDRegPatronal)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END

			DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[tblCatRegPatronal] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRegPatronal = @IDRegPatronal

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatRegPatronal]','[RH].[spBorrarCatRegPatronal]','DELETE','',@OldJSON


	
	
	 BEGIN TRY  
	Delete [RH].[tblCatRegPatronal] 
	WHERE IDRegPatronal = @IDRegPatronal

	    EXEC [Seguridad].[spBorrarFiltrosUsuariosMasivoCatalogo] 
		 @IDFiltrosUsuarios  = 0  
		 ,@IDUsuario  = @IDUsuario   
		 ,@Filtro = 'RegPatronales'  
		 ,@ID = @IDRegPatronal   
		 ,@Descripcion = ''
		 ,@IDUsuarioLogin = @IDUsuario 

    END TRY  
    BEGIN CATCH  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    END CATCH ;


	
		
END

--select * from [RH].[tblCatRegPatronal] 
GO
