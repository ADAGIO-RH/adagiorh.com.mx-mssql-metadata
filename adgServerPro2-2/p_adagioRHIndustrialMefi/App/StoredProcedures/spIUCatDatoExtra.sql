USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create   proc App.spIUCatDatoExtra(
	@IDDatoExtra int = 0,
	@IDTipoDatoExtra varchar(100),
	@IDInputType varchar(100),
	@Traduccion varchar(max),
	@Data varchar(max),
	@IDUsuario int
) as 
	DECLARE 
		@OldJSON varchar(Max),
		@NewJSON varchar(Max),
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	if (isnull(@IDDatoExtra, 0) = 0)
	begin
		insert App.tblCatDatosExtras(IDTipoDatoExtra, IDInputType, Traduccion, [Data], IDUsuario)
		values(@IDTipoDatoExtra, @IDInputType, @Traduccion, @Data, @IDUsuario)

		set @IDDatoExtra = @@IDENTITY

		select @NewJSON = a.JSON 
		from (
			select 
				de.IDDatoExtra
				,de.IDTipoDatoExtra
				,de.IDInputType
				,de.Traduccion
				,JSON_VALUE(de.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as Nombre
				,de.[Data]
				,de.IDUsuario
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
				,de.FechaHoraReg
			from App.tblCatDatosExtras de
				join Seguridad.tblUsuarios u on u.IDUsuario = de.IDUsuario
			where IDDatoExtra = @IDDatoExtra
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'App.tblCatDatosExtras',' App.spIUCatDatoExtra','INSERT',@NewJSON,''
		
	end else
	begin
		select @OldJSON = a.JSON 
		from (
			select 
				de.IDDatoExtra
				,de.IDTipoDatoExtra
				,de.IDInputType
				,de.Traduccion
				,JSON_VALUE(de.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as Nombre
				,de.[Data]
				,de.IDUsuario
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
				,de.FechaHoraReg
			from App.tblCatDatosExtras de
				join Seguridad.tblUsuarios u on u.IDUsuario = de.IDUsuario
			where IDDatoExtra = @IDDatoExtra
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		update App.tblCatDatosExtras
			set
				Traduccion = @Traduccion,
				[Data] = @Data
		where IDDatoExtra = @IDDatoExtra

		select @NewJSON = a.JSON 
		from (
			select 
				de.IDDatoExtra
				,de.IDTipoDatoExtra
				,de.IDInputType
				,de.Traduccion
				,JSON_VALUE(de.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as Nombre
				,de.[Data]
				,de.IDUsuario
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
				,de.FechaHoraReg
			from App.tblCatDatosExtras de
				join Seguridad.tblUsuarios u on u.IDUsuario = de.IDUsuario
			where IDDatoExtra = @IDDatoExtra
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'App.tblCatDatosExtras',' App.spIUCatDatoExtra','UPDATE',@NewJSON,@OldJSON
	end

	exec App.spBuscarCatDatosExtras @IDDatoExtra=@IDDatoExtra, @IDUsuario=@IDUsuario
GO
