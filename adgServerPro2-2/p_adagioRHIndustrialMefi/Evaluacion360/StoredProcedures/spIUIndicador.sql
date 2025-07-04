USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Evaluacion360].[spIUIndicador](
	 @IDIndicador	int = 0
	,@Nombre		varchar(255)
	,@Descripcion	varchar(max)
	,@IsDefault		bit
	,@NombreIcono	varchar(255)
	,@IDUsuario int
) as

	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

	if (isnull(@IDIndicador, 0) = 0)
	begin
		insert Evaluacion360.tblCatIndicadores(Nombre, Descripcion, IsDefault, NombreIcono)
		values(@Nombre, @Descripcion, isnull(@IsDefault, 0), @NombreIcono)

		set  @IDIndicador = SCOPE_IDENTITY()

		select @NewJSON = a.JSON from Evaluacion360.tblCatIndicadores b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDIndicador=@IDIndicador;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Evaluacion360].[tblCatIndicadores]','[Evaluacion360].[spIUIndicador]','INSERT',@NewJSON,''
	end else
	begin

		select @OldJSON =  a.JSON from Evaluacion360.tblCatIndicadores b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDIndicador=@IDIndicador;

		update Evaluacion360.tblCatIndicadores
			set
				Nombre = @Nombre,
				Descripcion = @Descripcion,
				NombreIcono = @NombreIcono
		where IDIndicador = @IDIndicador

		select @NewJSON = a.JSON from Evaluacion360.tblCatIndicadores b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDIndicador=@IDIndicador;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Evaluacion360].[tblCatIndicadores]','[Evaluacion360].[spIUIndicador]','UPDATE',@NewJSON,@OldJSON
	end


	select @IDIndicador IDIndicador
GO
