USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Evaluacion360].[spIUObjetivoEmpleado](
	@IDObjetivoEmpleado int = 0,
	@IDObjetivo int,
	@IDEmpleado int,
	@Objetivo varchar(max),
	@Actual varchar(max),
	@Peso decimal(18,2),
	@IDEstatusObjetivoEmpleado int,
	@IDUsuario int
) as

	DECLARE 
		@OldJSON varchar(Max),
		@NewJSON varchar(Max),
		@IDIdioma varchar(20),
		@PorcentajeAlcanzado decimal(18,2),
		@IDCicloMedicionObjetivo int,
		@IDTipoMedicionObjetivo int,
		@FechaInicio date
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	select 
		@IDTipoMedicionObjetivo = o.IDTipoMedicionObjetivo,
		@FechaInicio = cmo.FechaInicio,
		@IDCicloMedicionObjetivo = o.IDCicloMedicionObjetivo
	from Evaluacion360.tblCatObjetivos o with (nolock)
		join Evaluacion360.tblCatCiclosMedicionObjetivos cmo with (nolock) on cmo.IDCicloMedicionObjetivo = o.IDCicloMedicionObjetivo
	where o.IDObjetivo = @IDObjetivo

	set @PorcentajeAlcanzado = Evaluacion360.fnCalcularPorcentaje(@IDTipoMedicionObjetivo, @Objetivo, @Actual, @FechaInicio)

	if (isnull(@IDObjetivoEmpleado, 0) = 0)
	begin
		insert Evaluacion360.tblObjetivosEmpleados(
			IDObjetivo
			,IDEmpleado
			,Objetivo
			,Actual
			,Peso
			,PorcentajeAlcanzado
			,IDEstatusObjetivoEmpleado
			,IDUsuario
			,UltimaActualizacion
		)
		values (
			 @IDObjetivo
			,@IDEmpleado
			,@Objetivo
			,@Actual
			,@Peso
			,isnull(@PorcentajeAlcanzado, 0)
			,@IDEstatusObjetivoEmpleado
			,@IDUsuario
			,getdate()
		)

		set @IDObjetivoEmpleado = @@IDENTITY

		select @NewJSON = a.JSON 
		from (
			select 
				 oe.IDObjetivoEmpleado
				,oe.IDObjetivo
				,(
					select 
						o.IDObjetivo
						,o.Nombre
						,o.Descripcion
					from Evaluacion360.tblCatObjetivos o with (nolock)
					where o.IDObjetivo = oe.IDObjetivo
					for json path, without_array_wrapper
				) as CatObjetivo
				,oe.IDEmpleado
				,(
					select 
						e.IDEmpleado,
						e.ClaveEmpleado,
						e.NOMBRECOMPLETO as Colaborador
					from RH.tblEmpleadosMaster e
					where e.IDEmpleado = oe.IDEmpleado
					for json path, without_array_wrapper
				) as Colaborador
				,oe.Objetivo
				,oe.Actual
				,oe.Peso
				,oe.PorcentajeAlcanzado
				,oe.IDEstatusObjetivoEmpleado
				,(
					select top 1
						eo.IDEstatusObjetivoEmpleado
						,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre 
						,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion 
						,eo.Orden
					from Evaluacion360.tblCatEstatusObjetivosEmpleado eo
					where (eo.IDEstatusObjetivoEmpleado = oe.IDEstatusObjetivoEmpleado) 
					for json path, without_array_wrapper
				) as EstatusObjetivoEmpleado
				,oe.IDUsuario
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
				,oe.FechaHoraReg
			from Evaluacion360.tblObjetivosEmpleados oe
				join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = oe.IDUsuario
			where (oe.IDObjetivoEmpleado = @IDObjetivoEmpleado)
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'Evaluacion360.tblObjetivosEmpleados',' Evaluacion360.spIUObjetivoEmpleado','INSERT',@NewJSON,''
	end else
	begin
		select @OldJSON = a.JSON 
		from (
			select 
				 oe.IDObjetivoEmpleado
				,oe.IDObjetivo
				,(
					select 
						o.IDObjetivo
						,o.Nombre
						,o.Descripcion
					from Evaluacion360.tblCatObjetivos o with (nolock)
					where o.IDObjetivo = oe.IDObjetivo
					for json path, without_array_wrapper
				) as CatObjetivo
				,oe.IDEmpleado
				,(
					select 
						e.IDEmpleado,
						e.ClaveEmpleado,
						e.NOMBRECOMPLETO as Colaborador
					from RH.tblEmpleadosMaster e
					where e.IDEmpleado = oe.IDEmpleado
					for json path, without_array_wrapper
				) as Colaborador
				,oe.Objetivo
				,oe.Actual
				,oe.Peso
				,oe.PorcentajeAlcanzado
				,oe.IDEstatusObjetivoEmpleado
				,(
					select top 1
						eo.IDEstatusObjetivoEmpleado
						,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre 
						,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion 
						,eo.Orden
					from Evaluacion360.tblCatEstatusObjetivosEmpleado eo
					where (eo.IDEstatusObjetivoEmpleado = oe.IDEstatusObjetivoEmpleado) 
					for json path, without_array_wrapper
				) as EstatusObjetivoEmpleado
				,oe.IDUsuario
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
				,oe.FechaHoraReg
			from Evaluacion360.tblObjetivosEmpleados oe
				join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = oe.IDUsuario
			where (oe.IDObjetivoEmpleado = @IDObjetivoEmpleado)
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		update Evaluacion360.tblObjetivosEmpleados
			set
				 Objetivo				= @Objetivo
				,Actual					= @Actual
				,Peso					= @Peso
				,PorcentajeAlcanzado		= isnull(@PorcentajeAlcanzado, 0)
				,IDEstatusObjetivoEmpleado	= case when @PorcentajeAlcanzado > 0 and IDEstatusObjetivoEmpleado = 1 then 2 else @IDEstatusObjetivoEmpleado end
				,UltimaActualizacion	= getdate()
		where IDObjetivoEmpleado=@IDObjetivoEmpleado

		select @NewJSON = a.JSON 
		from (
			select 
				 oe.IDObjetivoEmpleado
				,oe.IDObjetivo
				,(
					select 
						o.IDObjetivo
						,o.Nombre
						,o.Descripcion
					from Evaluacion360.tblCatObjetivos o with (nolock)
					where o.IDObjetivo = oe.IDObjetivo
					for json path, without_array_wrapper
				) as CatObjetivo
				,oe.IDEmpleado
				,(
					select 
						e.IDEmpleado,
						e.ClaveEmpleado,
						e.NOMBRECOMPLETO as Colaborador
					from RH.tblEmpleadosMaster e
					where e.IDEmpleado = oe.IDEmpleado
					for json path, without_array_wrapper
				) as Colaborador
				,oe.Objetivo
				,oe.Actual
				,oe.Peso
				,oe.PorcentajeAlcanzado
				,oe.IDEstatusObjetivoEmpleado
				,(
					select top 1
						eo.IDEstatusObjetivoEmpleado
						,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre 
						,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion 
						,eo.Orden
					from Evaluacion360.tblCatEstatusObjetivosEmpleado eo
					where (eo.IDEstatusObjetivoEmpleado = oe.IDEstatusObjetivoEmpleado) 
					for json path, without_array_wrapper
				) as EstatusObjetivoEmpleado
				,oe.IDUsuario
				,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
				,oe.FechaHoraReg
			from Evaluacion360.tblObjetivosEmpleados oe
				join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = oe.IDUsuario
			where (oe.IDObjetivoEmpleado = @IDObjetivoEmpleado)
		) b
			cross apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'Evaluacion360.tblObjetivosEmpleados',' Evaluacion360.spIUObjetivoEmpleado','UPDATE',@NewJSON,@OldJSON
	end

	exec Evaluacion360.spUProgresoObjetivo @IDObjetivo=@IDObjetivo, @IDUsuario=@IDUsuario
	exec Evaluacion360.spUProgresoObjetivo @IDObjetivo=@IDObjetivo, @IDUsuario=@IDUsuario
	exec Evaluacion360.spUProgresoGeneralPorCicloEmpleado @IDCicloMedicionObjetivo=@IDCicloMedicionObjetivo, @IDEmpleado = @IDEmpleado

	exec Evaluacion360.spBuscarObjetivosEmpleados 
		@IDObjetivoEmpleado=@IDObjetivoEmpleado, 
		@IDUsuario=@IDUsuario
GO
