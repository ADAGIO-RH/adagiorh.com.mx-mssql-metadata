USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatPuestos]
(
	@IDPuesto int,
	@IDUsuario int
)
AS
BEGIN

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = (SELECT IDPuesto
                                ,Codigo
                                ,SueldoBase
                                ,TopeSalarial
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatPuestos]
                            WHERE IDPuesto = @IDPuesto FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        


		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatPuestos]','[RH].[spBorrarCatPuestos]','DELETE','',@OldJSON



    exec [RH].[spBuscarCatPuestos] @IDPuesto;

    BEGIN TRY  
	   DELETE [RH].[tblCatPuestos]
	   WHERE IDPuesto = @IDPuesto

	    EXEC [Seguridad].[spBorrarFiltrosUsuariosMasivoCatalogo] 
		 @IDFiltrosUsuarios  = 0  
		 ,@IDUsuario  = @IDUsuario   
		 ,@Filtro = 'Puestos'  
		 ,@ID = @IDPuesto   
		 ,@Descripcion = ''
		 ,@IDUsuarioLogin = @IDUsuario 

    END TRY  
    BEGIN CATCH  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    END CATCH ;
END
GO
