USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [App].[spIUValorDatoExtra](
	@IDValorDatoExtra int = 0,
	@IDDatoExtra int,
	@IDReferencia int,
	@Valor varchar(max),
	@IDUsuario int
) as
	DECLARE 
		@OldJSON varchar(Max),
		@NewJSON varchar(Max),
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	if (isnull(@IDValorDatoExtra, 0) = 0)
	begin
		insert App.tblValoresDatosExtras(IDDatoExtra, IDReferencia, Valor)
		values(@IDDatoExtra, @IDReferencia, @Valor)

		set @IDValorDatoExtra = @@IDENTITY

		select @NewJSON = a.JSON 
		from (
			select 
				vde.IDValorDatoExtra
				,vde.IDDatoExtra
				,JSON_VALUE(de.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as Nombre
				,vde.IDReferencia
				,vde.Valor
			from App.tblValoresDatosExtras vde with (nolock)
				join App.tblCatDatosExtras de with (nolock) on de.IDDatoExtra = vde.IDDatoExtra
				join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = de.IDUsuario
			where vde.IDDatoExtra = @IDDatoExtra
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'App.tblValoresDatosExtras',' App.spIUValoreDatoExtra','INSERT',@NewJSON,''
	end else
	begin 
		select @OldJSON = a.JSON 
		from (
			select 
				vde.IDValorDatoExtra
				,vde.IDDatoExtra
				,JSON_VALUE(de.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as Nombre
				,vde.IDReferencia
				,vde.Valor
			from App.tblValoresDatosExtras vde with (nolock)
				join App.tblCatDatosExtras de with (nolock) on de.IDDatoExtra = vde.IDDatoExtra
				join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = de.IDUsuario
			where vde.IDDatoExtra = @IDDatoExtra
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		update App.tblValoresDatosExtras
			set
				Valor = @Valor
		where IDValorDatoExtra = @IDValorDatoExtra

		select @NewJSON = a.JSON 
		from (
			select 
				vde.IDValorDatoExtra
				,vde.IDDatoExtra
				,JSON_VALUE(de.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as Nombre
				,vde.IDReferencia
				,vde.Valor
			from App.tblValoresDatosExtras vde with (nolock)
				join App.tblCatDatosExtras de with (nolock) on de.IDDatoExtra = vde.IDDatoExtra
				join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = de.IDUsuario
			where vde.IDDatoExtra = @IDDatoExtra
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'App.tblValoresDatosExtras',' App.spIUValoreDatoExtra','INSERT',@NewJSON,@OldJSON
	end

	exec App.spBuscarValoresDatoExtra
		@IDValorDatoExtra = @IDValorDatoExtra, 
		@IDReferencia = @IDReferencia,
		@IDUsuario = @IDUsuario
GO
