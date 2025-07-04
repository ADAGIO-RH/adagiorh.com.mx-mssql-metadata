USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spValidarImportacionArticulos](
	@dtArticulos [ControlEquipos].[dtArticulos] readonly,
	@IDUsuario int 
)
as
begin
	declare @tempMessages as table(
		ID int,
		[Message] varchar(500),
		Valid bit
	);
	declare @IDIdioma varchar(20)
	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');
	if object_id('tempdb..#tempValidaciones') is not null drop table #tempValidaciones;

	insert @tempMessages(ID, [Message], Valid)
	values
		(1, 'Datos Correctos', 1),
		(2, 'El tipo de artículo ingresado no existe', 0),
		(3, 'No puedes dejar vacio el campo nombre', 0),
		(4, 'No puedes dejar vacio el campo Tipo_Articulo', 0),
		(5, 'No puedes dejar vacio el campo Estatus_Articulo', 0),
		(6, 'El Estatus_Articulo ingresado no existe', 0),
		(7, 'El Estatus_Articulo ingresado no es valido para artículos nuevos', 0),
		(8, 'Cantidad_Articulos no puede estar vacio ni ser menor o igual a 0', 0),
		(9, 'El Metodo_Depreciacion ingresado no existe', 0),
		(10, 'El Campo Uso_Compartido vacio por defecto se tomará como 0', 1),
		(11, 'Uso_Compartido solo puede ser 0 o 1', 0);

	select
		info.*,
        (
			SELECT M.[Message] AS [Message],
					CAST(M.Valid AS BIT) AS Valid
			FROM @tempMessages M
			WHERE ID IN (SELECT ITEM FROM app.split(INFO.IDMensaje, ',') ) FOR JSON PATH ) AS Msg,
			-- SUB-CONSULTA QUE OBTIENE VALIDACION DEL MENSAJE
			CAST(CASE
					WHEN EXISTS((SELECT M.Valid AS [Message] FROM @tempMessages M WHERE ID IN(SELECT ITEM FROM APP.SPLIT(INFO.IDMensaje, ',')) AND Valid = 0))
						THEN 0
						ELSE 1
				END AS BIT
		) AS Valid
	into #tempValidaciones
	from (
		select 
			ISNULL(A.Nombre, '') as Nombre,
			ISNULL(A.Descripcion, '') as Descripcion,
			ISNULL(A.TipoArticulo, '') as TipoArticulo,
			ISNULL(A.MetodoDepreciacion, '') as MetodoDepreciacion,
			ISNULL(A.CantidadArticulos, 0) as CantidadArticulos,
			ISNULL(A.EstatusArticulo, '') as EstatusArticulo,
			ISNULL(A.UsoCompartido, 0) as UsoCompartido,
			IDMensaje = 
						case when not exists(select 
													TA.IDTipoArticulo
												from ControlEquipos.tblCatTiposArticulos TA
												where JSON_VALUE(TA.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) = 
												(
													select top 1 AA.TipoArticulo from @dtArticulos AA where AA.TipoArticulo = A.TipoArticulo
												)
											) then '2,' else '' end
						+ case when ISNULL((select top 1 AA.Nombre from @dtArticulos AA where AA.Nombre = A.Nombre), '') = '' then '3,' else '' end
						+ case when ISNULL((select top 1 AA.TipoArticulo from @dtArticulos AA where AA.TipoArticulo = A.TipoArticulo), '') = '' then '4,' else '' end
						+ case when ISNULL((select top 1 AA.EstatusArticulo from @dtArticulos AA where AA.EstatusArticulo = A.EstatusArticulo), '') = '' then '5,' else '' end
						+ case when not exists(
												select top 1 1 from --ControlEquipos.tblCatEstatusArticulos CE where CE.Nombre = ''
												(
													select top 1 CE.Nombre from ControlEquipos.tblCatEstatusArticulos CE
													where CE.Nombre = 
														(
															select top 1 AA.EstatusArticulo from @dtArticulos AA where AA.EstatusArticulo = A.EstatusArticulo
														)
												) as AB
											) then '6,' else '' end
						+ case when ISNULL(
											(
												select top 1 AB.IDCatEstatusArticulo 
												from (
														select top 1 CE.IDCatEstatusArticulo from ControlEquipos.tblCatEstatusArticulos CE
														where CE.Nombre = 
															(
																select top 1 AA.EstatusArticulo from @dtArticulos AA where AA.EstatusArticulo = A.EstatusArticulo
															)
													) as AB where AB.IDCatEstatusArticulo in (1, 3, 8) -- estatus de articulos disponibles para la creación de nuevos articulos
											), 0) = 0 then '7,' else '' end 
						+ case when ISNULL((select top 1 AA.CantidadArticulos from @dtArticulos AA where AA.CantidadArticulos = A.CantidadArticulos), 0) <= 0 then '8,' else '' end
						+ case when not exists(
												  select top 1 1 from
												(
													select top 1 MD.Nombre from ControlEquipos.tblMetodoDepreciacion MD
													where MD.Nombre = 
														(
															select top 1 AA.MetodoDepreciacion from @dtArticulos AA where AA.MetodoDepreciacion = A.MetodoDepreciacion
														)
												) as AB
											  ) then '9,' else '' end
						+ case when ISNULL((select top 1 AA.UsoCompartido from @dtArticulos AA where AA.UsoCompartido = A.UsoCompartido), 0) not in (0, 1) then '10,' else '' end
						+ case when ISNULL((select top 1 AA.UsoCompartido from @dtArticulos AA where AA.UsoCompartido = A.UsoCompartido), 0) < 0 then '11,' else '' end
		from @dtArticulos A
	) info

	update #tempValidaciones
		set
			Msg = '[{"Message":"Datos Correctos","Valid":true}]',
			IDMensaje = '1,'
		where Msg is null

	select *,
			ISNULL((
				select top 1 TA.IDTipoArticulo
				from ControlEquipos.tblCatTiposArticulos TA
				where JSON_VALUE(TA.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) = TV.TipoArticulo
			), 0) as IDTipoArticulo,
			ISNULL((
				select top 1 CE.IDCatEstatusArticulo 
				from ControlEquipos.tblCatEstatusArticulos CE
				where CE.Nombre = TV.EstatusArticulo
			), 0) as IDCatEstatusArticulo,
			ISNULL((
				select top 1 MD.IDMetodoDepreciacion 
				from ControlEquipos.tblMetodoDepreciacion MD
				where MD.Nombre = TV.MetodoDepreciacion
			), 0) as IDMetodoDepreciacion 
	from #tempValidaciones TV
end
GO
