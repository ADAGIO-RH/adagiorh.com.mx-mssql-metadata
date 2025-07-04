USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: valida la proximidad de la fecha de vencimiento de los articulos
** Autor			: Justin Davila
** Email			: jdavila@adagio.com.mx
** FechaCreacion	: 2024-02-29
** Paremetros		:              
	

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2024-03-05			Justin Davila		Creamos la tabla de HTML con los articulos proximos a caducar
2024-03-06			Justin Davila		Correccion del cuerpo del correo, envio del correo, pendiente
										cambiar el destinatario previo a produccion
2024-03-12			Justin Davila		Validamos que haya articulos proximos a caducar antes en enviar
										el correo
2024-03-28			JustinDavila		Validamos la fecha de caducidad de los artículos segun su tipo,
										ya sea vida útil o fecha de caducidad fija
***************************************************************************************************/
CREATE   proc [ControlEquipos].[spValidarFechaCaducidadArticulo]
as
begin
	declare @i int, 
			@tableHeaders nvarchar(max), 
			@tableRows nvarchar(max) = '', 
			@Etiqueta nvarchar(12), 
			@Nombre nvarchar(100), 
			@FechaCaducidad datetime, 
			@ColaboradorAsignado nvarchar(max),
			@bodyCorreo nvarchar(max),
			@IDTipoNotificacion varchar(100) = 'ArticulosPorCaducar',
			@subjectColaborador varchar(300),
			@Cantidad int,
			@MES_EN_SEGUNDOS INT = 2419200,
			@ANNIO_EN_SEGUNDOS INT = 29030400,
			@ID_CAT_ESTATUS_ARTICULO_ASIGNADO INT = 2,
			@ID_CAT_TIPO_CADUCIDAD_VIDA_UTIL INT = 1,
			@IDNotificacion int,
			@IDUsuario int = 1,
			@IDIdioma varchar(20);
	if object_id('tempdb..#tempArticulos') is not null drop table #tempArticulos;
	set @tableHeaders = N'<thead><tr><th>Etiqueta</th><th>Nombre</th><th>Fecha de caducidad</th><th>Colaborador asignado</th></tr></thead>'
	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')	--incluir IDUsuario a la ejecucion del sp mas adelante
	
	/*
		hacer correccion de fecha de caducidad mas adelante
	*/
	select 
			da.IDDEtalleArticulo,
			da.IDArticulo,
			da.Etiqueta,
			da.FechaAlta,
			da.IDGenero,
			a.Nombre,
			ea.Empleados,
			ea.FechaHora,
			ea.IDCatEstatusArticulo,
			ISNULL((
				select STRING_AGG(NOMBRECOMPLETO, ', ')
				from RH.tblEmpleadosMaster
				where IDEmpleado in (
				select * from OPENJSON(ea.Empleados, '$')
				with (
						IDEmpleado int
					)   
				)
			),'Sin asignar')  as ColaboradorAsignado,
			da.IDUnidadDeTiempo,
			udt.Nombre as UnidadDeTiempo,
			udt.TiempoEnSegundos,
			da.IDCatTipoCaducidad,
			JSON_VALUE(ctc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoCaducidad,
			da.Tiempo,
			(
				case when da.IDCatTipoCaducidad = @ID_CAT_TIPO_CADUCIDAD_VIDA_UTIL
					then
						case when ea.IDCatEstatusArticulo = @ID_CAT_ESTATUS_ARTICULO_ASIGNADO
							then
								DATEDIFF(S, getdate(), 
										dateadd(S, (udt.TiempoEnSegundos*da.Tiempo), (
																						select top 1 FechaHora 
																						from ControlEquipos.tblEstatusArticulos 
																						where IDDetalleArticulo = da.IDDetalleArticulo 
																						order by FechaHora desc
																					)
												)
										)
							else
								DATEDIFF(S, getdate(), dateadd(S, (@ANNIO_EN_SEGUNDOS*3), getdate()))
						end
					else
						DATEDIFF(S, getdate(), dateadd(S, (udt.TiempoEnSegundos*da.Tiempo), getdate()))
				end
			) as Diferencia,
			ROW_NUMBER() OVER(PARTITION BY ea.IDDetalleArticulo ORDER BY ea.FechaHora desc) as RN
	into #tempArticulos
	from ControlEquipos.tblDetalleArticulos da
	inner join ControlEquipos.tblArticulos a on a.IDArticulo = da.IDArticulo
	inner join ControlEquipos.tblEstatusArticulos ea on ea.IDDetalleArticulo = da.IDDetalleArticulo
	inner join App.tblCatUnidadesDeTiempo udt on udt.IDUnidadDeTiempo = da.IDUnidadDeTiempo
	inner join ControlEquipos.tblCatTiposCaducidad ctc on ctc.IDCatTipoCaducidad = da.IDCatTipoCaducidad
	
	select @i = min(IDDetalleArticulo),
		   @Cantidad = count(IDDetalleArticulo)
	from #tempArticulos where Diferencia <= @MES_EN_SEGUNDOS and RN = 1

	--select * from #tempArticulos where Diferencia <= @MES_EN_SEGUNDOS and RN = 1
	--select @Cantidad
	--return

	WHILE exists(select top 1 1 from #tempArticulos where IDDetalleArticulo >= @i)
    BEGIN
		select top 1
			@Etiqueta = a.Etiqueta,
			@Nombre =  a.Nombre,
			@FechaCaducidad = dateadd(S, a.Diferencia, getdate()), --REVISAR FECHA, AUN SIN FUNCIONAR
			@ColaboradorAsignado = a.ColaboradorAsignado
		from #tempArticulos a
		where a.IDDetalleArticulo = @i
		order by a.FechaHora desc

		set @tableRows = @tableRows + N'<tr><td>'+ @Etiqueta + N'</td><td>' + @Nombre + N'</td><td>'+ cast(@FechaCaducidad as nvarchar(12)) + N'</td><td>' + @ColaboradorAsignado + N'</td></tr>'
		select @i = min(IDDetalleArticulo) from #tempArticulos where IDDetalleArticulo > @i and Diferencia <= @MES_EN_SEGUNDOS and RN = 1
	end

	--select @tableRows
	--return

	set @subjectColaborador = 'Control de equipos, artículos a caducar'
	set @bodyCorreo = N'
						<p>
							Estimado admin de RRHH, el siguiente correo es para notificarle sobre la proxima fecha de caducidad de los siguientes articulos o esta por terminar su tiempo de vida útil:
						</p>
						<table id=''table-detalle''>'
							+ @tableHeaders +
						N'<tbody>'
							+ @tableRows +
						N'</tbody>
						</table>
						<h4>
							Por favor cominicate con los colaboradores asignados a estos artículos y tomen las acciones necesarias.
					  </h4>
					  <h4>
							No es necesario confirmar de recibido
					  </h4>'

	if @Cantidad > 0
	begin
		insert into [App].[tblNotificaciones](IDTipoNotificacion,Parametros)  
		SELECT @IDTipoNotificacion,'{ "subject":"'+@subjectColaborador+'", "body": "'+@bodyCorreo+'"}'

		set @IDNotificacion = @@IDENTITY  
		insert [App].[tblEnviarNotificacionA](  
			IDNotifiacion  
			,IDMedioNotificacion  
			,Destinatario
			,Adjuntos) 
		select 
			@IDNotificacion  
			,templateNot.IDMedioNotificacion  
			,case when templateNot.IDMedioNotificacion = 'Email' then 'jdavila@adagio.com.mx' else null end  -- quitar el correo antes de pasar a produccion!!!
			,NULL 
		from [App].[tblTiposNotificaciones] tn  
			INNER JOIN [App].[tblTemplateNotificaciones] templateNot on tn.IDTipoNotificacion = templateNot.IDTipoNotificacion  
		where tn.IDTipoNotificacion = @IDTipoNotificacion
	end
	else
	begin
		select 1
	end
end
GO
