USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA BORRAR CATALOGO DE RUTAS
** Autor			: JOSE ROMAN
** Email			: JROMAN@ADAGIO.COM.MX
** FechaCreacion	: 2022-01-12
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [Enrutamiento].[spBorrarCatRutas]
(
	@IDCatRuta int    
	,@IDUsuario int 
)
AS
BEGIN
	 

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [Enrutamiento].[tblCatRutas] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDCatRuta = @IDCatRuta

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Enrutamiento].[tblCatRutas]','[Enrutamiento].[spBorrarCatRutas]','DELETE','',@OldJSON

    BEGIN TRY  
	    DELETE [Enrutamiento].[tblCatRutas] 
	    WHERE IDCatRuta = @IDCatRuta
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
END
GO
