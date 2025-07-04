USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Eliminar Familiar y benificiario
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-06-08
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [RH].[spBorrarFamiliarBeneficiario](
    @IDFamiliarBenificiarioEmpleado int  = 0 ,    
    @IDUsuario int  
) as

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[TblFamiliaresBenificiariosEmpleados] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDFamiliarBenificiarioEmpleado = @IDFamiliarBenificiarioEmpleado
    	

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblFamiliaresBenificiariosEmpleados]','[RH].[spBorrarFamiliarBeneficiario]','DELETE','',@OldJSON



    delete from [RH].[TblFamiliaresBenificiariosEmpleados]
    where IDFamiliarBenificiarioEmpleado = @IDFamiliarBenificiarioEmpleado
GO
