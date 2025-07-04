USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatRegiones]
(
	@IDRegion int,
	@IDUsuario int
)
AS
BEGIN

	Select 
	   IDRegion
	   ,Codigo
	   ,Descripcion
	   ,CuentaContable
	   ,isnull(IDEmpleado,0) as IDEmpleado
	   ,JefeRegion
	   ,ROW_NUMBER()over(ORDER BY IDRegion)as ROWNUMBER
    FROM RH.tblCatRegiones
    Where IDRegion = @IDRegion

			DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = (SELECT IDRegion
                                ,Codigo
                                ,CuentaContable
                                ,JefeRegion
                                ,IDEmpleado                              
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatRegiones]
                            WHERE IDRegion = @IDRegion FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
                            
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatRegiones]','[RH].[spBorrarCatRegiones]','DELETE','',@OldJSON



    BEGIN TRY  
	   Delete RH.tblCatRegiones
	   where IDRegion = @IDRegion
    END TRY  
    BEGIN CATCH  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    END CATCH ;


END
GO
