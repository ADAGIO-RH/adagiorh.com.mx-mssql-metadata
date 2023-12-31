USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc Evaluacion360.spIUObjetivo(
	@IDObjetivo int = 0,
	@Nombre varchar(500),
	@Descripcion varchar(max),
	@IDCicloMedicionObjetivo int,
	@IDTipoMedicionObjetivo int,
	@IDEstatusObjetivo int,
	@IDUsuario int 
) as
	DECLARE 
		@OldJSON varchar(Max),
		@NewJSON varchar(Max),
		@IDIdioma varchar(20)
	;

	set @Nombre = UPPER(@Nombre)

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	if (isnull(@IDObjetivo, 0) = 0)
	begin
		insert Evaluacion360.tblCatObjetivos(Nombre, Descripcion, IDCicloMedicionObjetivo, IDTipoMedicionObjetivo, IDEstatusObjetivo, IDUsuario)
		values(@Nombre, @Descripcion, @IDCicloMedicionObjetivo, @IDTipoMedicionObjetivo, @IDEstatusObjetivo, @IDUsuario)

		set @IDObjetivo = @@IDENTITY

		select @NewJSON = a.JSON 
		from (
			select 
				o.IDObjetivo
				,o.Nombre
				,o.Descripcion
				,o.IDCicloMedicionObjetivo
				,UPPER(cmo.Nombre) as CicloMedicion	
				,o.IDTipoMedicionObjetivo
				,JSON_VALUE(tmo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as TipoMedicionObjetivo
				,o.IDEstatusObjetivo
				,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as EstatusObjetivo
				,o.IDUsuario
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
				,o.FechaHoraReg
			from Evaluacion360.tblCatObjetivos o with (nolock)
				join Evaluacion360.tblCatCiclosMedicionObjetivos cmo with (nolock) on cmo.IDCicloMedicionObjetivo = o.IDCicloMedicionObjetivo
				join Evaluacion360.tblCatTiposMedicionesObjetivos tmo with (nolock) on tmo.IDTipoMedicionObjetivo = o.IDTipoMedicionObjetivo
				join Evaluacion360.tblCatEstatusObjetivos eo with (nolock) on eo.IDEstatusObjetivo = o.IDEstatusObjetivo
				join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = o.IDUsuario
			where o.IDObjetivo = @IDObjetivo 
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'Evaluacion360.tblCatObjetivos',' Evaluacion360.spIUObjetivo','INSERT',@NewJSON,''
	end else
	begin
		select @OldJSON = a.JSON 
		from (
			select 
				o.IDObjetivo
				,o.Nombre
				,o.Descripcion
				,o.IDCicloMedicionObjetivo
				,UPPER(cmo.Nombre) as CicloMedicion	
				,o.IDTipoMedicionObjetivo
				,JSON_VALUE(tmo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as TipoMedicionObjetivo
				,o.IDEstatusObjetivo
				,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as EstatusObjetivo
				,o.IDUsuario
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
				,o.FechaHoraReg
			from Evaluacion360.tblCatObjetivos o with (nolock)
				join Evaluacion360.tblCatCiclosMedicionObjetivos cmo with (nolock) on cmo.IDCicloMedicionObjetivo = o.IDCicloMedicionObjetivo
				join Evaluacion360.tblCatTiposMedicionesObjetivos tmo with (nolock) on tmo.IDTipoMedicionObjetivo = o.IDTipoMedicionObjetivo
				join Evaluacion360.tblCatEstatusObjetivos eo with (nolock) on eo.IDEstatusObjetivo = o.IDEstatusObjetivo
				join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = o.IDUsuario
			where o.IDObjetivo = @IDObjetivo 
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		update Evaluacion360.tblCatObjetivos
			set
				Nombre			= @Nombre,
				Descripcion		= @Descripcion,
				IDCicloMedicionObjetivo	= @IDCicloMedicionObjetivo,
				IDTipoMedicionObjetivo	= @IDTipoMedicionObjetivo,
				IDEstatusObjetivo		= @IDEstatusObjetivo
		where IDObjetivo = @IDObjetivo

		select @NewJSON = a.JSON 
		from (
			select 
				o.IDObjetivo
				,o.Nombre
				,o.Descripcion
				,o.IDCicloMedicionObjetivo
				,UPPER(cmo.Nombre) as CicloMedicion	
				,o.IDTipoMedicionObjetivo
				,JSON_VALUE(tmo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as TipoMedicionObjetivo
				,o.IDEstatusObjetivo
				,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Nombre')) as EstatusObjetivo
				,o.IDUsuario
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
				,o.FechaHoraReg
			from Evaluacion360.tblCatObjetivos o with (nolock)
				join Evaluacion360.tblCatCiclosMedicionObjetivos cmo with (nolock) on cmo.IDCicloMedicionObjetivo = o.IDCicloMedicionObjetivo
				join Evaluacion360.tblCatTiposMedicionesObjetivos tmo with (nolock) on tmo.IDTipoMedicionObjetivo = o.IDTipoMedicionObjetivo
				join Evaluacion360.tblCatEstatusObjetivos eo with (nolock) on eo.IDEstatusObjetivo = o.IDEstatusObjetivo
				join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = o.IDUsuario
			where o.IDObjetivo = @IDObjetivo 
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'Evaluacion360.tblCatObjetivos',' Evaluacion360.spIUObjetivo','UPDATE',@NewJSON,@OldJSON
	end

	exec Evaluacion360.spBuscarObjetivos @IDObjetivo=@IDObjetivo, @IDUsuario=@IDUsuario
GO
