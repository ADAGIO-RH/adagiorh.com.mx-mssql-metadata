USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Actualizar alergias empleado
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-06-11
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
2018-07-06		Jose Roman	 	Se agrega Procedure para proceso de Sincronizacion
2018-07-11		Aneudy Abreu		Agregué el upper case al update e insert
***************************************************************************************************/
CREATE proc [RH].[spAgregarAlergiasEmpleado](
    @IDEmpleado int
    ,@Alergias nvarchar(max)
	,@IDUsuario int
) as
    declare @IDSaludEmpleado int = 0;

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

    if exists (select top 1 1 from [RH].[tblSaludEmpleado] where IDEmpleado = @IDEmpleado)
    BEGIN
	
	   	select @OldJSON = a.JSON from [RH].[tblSaludEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE  IDEmpleado = @IDEmpleado

			update [RH].[tblSaludEmpleado] 
			set Alergias = upper(@Alergias)
			where IDEmpleado = @IDEmpleado

		
	   	select @NewJSON = a.JSON from [RH].[tblSaludEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE  IDEmpleado = @IDEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblSaludEmpleado]','[RH].[spAgregarAlergiasEmpleado]','UPDATE',@NewJSON,@OldJSON

    end ELSE
    BEGIN
	   insert into [RH].[tblSaludEmpleado] (IDEmpleado, Alergias)
	   select @IDEmpleado, upper(@Alergias)

	   	select @NewJSON = a.JSON from [RH].[tblSaludEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE  IDEmpleado = @IDEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblSaludEmpleado]','[RH].[spAgregarAlergiasEmpleado]','INSERT',@NewJSON,''

    end;

	EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
GO
