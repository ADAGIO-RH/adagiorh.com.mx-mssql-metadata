USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatAreas]
(
	@IDArea int,
	@IDUsuario int
)
AS
BEGIN

		SELECT 
			IDArea
			,Codigo
			,Descripcion
			,CuentaContable
			,isnull(IDEmpleado,0) as IDEmpleado
			,JefeArea
		FROM [RH].[tblCatArea]
		WHERE IDArea = @IDArea
	
		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = (SELECT IDArea
                                ,Codigo
                                ,CuentaContable
                                ,JefeArea
                                ,IDEmpleado                              
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatArea]
                            WHERE IDArea = @IDArea FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)


		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatArea]','[RH].[spBorrarCatAreas]','DELETE','',@OldJSON

	
    BEGIN TRY  
	DELETE RH.tblCatArea
	WHERE IDArea = @IDArea
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;

END
GO
