USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spIUNotaEmpleado](
	 @IDNotaEmpleado int = 0		
	,@IDEmpleado int			
	,@Fecha date
	,@Nota nvarchar(max)
	,@IDUsuario int			
) as

	set @Nota = UPPER(@Nota)

	 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

	if (@IDNotaEmpleado = 0)
	begin
		insert into RH.tblNotasEmpleados(IDEmpleado,Fecha,Nota,IDUsuario)
		select @IDEmpleado,@Fecha,@Nota,@IDUsuario

		set @IDNotaEmpleado = @@IDENTITY

		select @NewJSON = a.JSON from [RH].[tblNotasEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDNotaEmpleado = @IDNotaEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblNotasEmpleados]','[RH].[spIUNotaEmpleado]','INSERT',@NewJSON,''

	end else
	begin

	select @OldJSON = a.JSON from [RH].[tblNotasEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDNotaEmpleado = @IDNotaEmpleado

		update  RH.tblNotasEmpleados
			set Fecha = @Fecha
				,Nota = @Nota
		where IDNotaEmpleado = @IDNotaEmpleado

		select @NewJSON = a.JSON from [RH].[tblNotasEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDNotaEmpleado = @IDNotaEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblNotasEmpleados]','[RH].[spIUNotaEmpleado]','UPDATE',@NewJSON,@OldJSON


	end;

	exec [RH].[spBuscarNotasEmpleado] @IDNotaEmpleado = @IDNotaEmpleado,@IDUsuario = @IDUsuario
GO
