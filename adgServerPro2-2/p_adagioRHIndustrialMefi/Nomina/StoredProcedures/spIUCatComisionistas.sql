USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure Nomina.spIUCatComisionistas(
	@IDCatComisionista int = 0,
	@Identificador varchar(255),
	@NombreCompleto Varchar(500),
	@IDUsuario int
)
AS
BEGIN

	set @Identificador = UPPER(@Identificador)
	set @NombreCompleto = UPPER(@NombreCompleto)

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	if CHARINDEX(' ',@Identificador) > 0   
	begin  
	   raiserror('Se ha producido un error. El Identificador no puede contener espacios.',16,1);
	   return
	end;  

	IF(isnull(@IDCatComisionista,0) = 0)
	BEGIN
		insert into Nomina.tblCatComisionistas(Identificador,NombreCompleto)
		values(@Identificador,@NombreCompleto)

		set @IDCatComisionista = @@IDENTITY
		select @NewJSON = a.JSON from [Nomina].[tblCatComisionistas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatComisionista = @IDCatComisionista

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[tblCatComisionistas]','[Nomina].[spIUCatComisionistas]','INSERT',@NewJSON,''
	END
	ELSE
	BEGIN

		select @OldJSON = a.JSON from [Nomina].[tblCatComisionistas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatComisionista = @IDCatComisionista

		UPDATE Nomina.tblCatComisionistas
			set Identificador = @Identificador,
				NombreCompleto = @NombreCompleto
		WHERE IDCatComisionista = @IDCatComisionista

		select @NewJSON = a.JSON from [Nomina].[tblCatComisionistas]  b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatComisionista = @IDCatComisionista

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[tblCatComisionistas]','[Nomina].[spIUCatComisionistas]','UPDATE',@NewJSON,@OldJSON
	END
END
GO
