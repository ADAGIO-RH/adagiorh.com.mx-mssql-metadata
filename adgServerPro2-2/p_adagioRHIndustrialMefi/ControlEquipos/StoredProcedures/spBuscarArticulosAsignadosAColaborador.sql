USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spBuscarArticulosAsignadosAColaborador](
	@IDEmpleado varchar(20),	--ejemplo quemado  = '4356'
	@IDUsuario int
)
as
begin
	DECLARE 
		@IDIdioma varchar(20),
		@Empleado VARCHAR(40)
	;
	DECLARE @ID_CAT_ESTATUS_ARTICULO_ASIGNADO INT = 2
	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	IF OBJECT_ID('tempdb..#TempEstatusArticulo') IS NOT NULL DROP TABLE #TempEstatusArticulo;

	select *,
		ROW_NUMBER()over(partition by ea.IDDetalleArticulo order by ea.IDDetalleArticulo, ea.FechaHora desc) RN
	into #TempEstatusArticulo
	from ControlEquipos.tblEstatusArticulos ea
	where @IDEmpleado in (
	select *
	from OPENJSON(Empleados, '$')
	with (
		IDEmpleado int
		)
	)
    
	select da.IDArticulo,
	   ta.IDTipoArticulo,
	   JSON_VALUE(ta.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) AS [TipoArticulo],
	   UPPER(Etiqueta) as Etiqueta,
	   a.Nombre,
	   a.Descripcion,
	   a.Costo,
	   ea.IDEstatusArticulo,
	   ea.IDCatEstatusArticulo,
	   cea.Nombre as Estatus,
	   ea.Empleados,
	   ea.FechaHora,
	   --ea.IsAsignado,
	   (
	   	select 
	   		JSON_VALUE(cp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) AS [NombrePropiedad],
	   		CASE
	   		WHEN ISJSON(cp.[Data]) = 1 THEN
	   			(
	   				SELECT JSON_VALUE(item.Value, '$.Nombre') 
	   				FROM OPENJSON(cp.[Data]) AS item
	   				WHERE JSON_VALUE(item.Value, '$.ID') = vp.Valor
	   			)
	   		ELSE
	   			ISNULL(vp.Valor,'') -- o cualquier otro valor por defecto que desees cuando [Data] no sea un JSON válido
	   	END AS [ValorPropiedad]
	   	from [ControlEquipos].[tblCatPropiedades] cp
	   		left join [ControlEquipos].[tblValoresPropiedades] vp on vp.IDPropiedad = cp.IDPropiedad and vp.IDDetalleArticulo = da.IDDetalleArticulo
	   	where cp.IDTipoArticulo = ta.IDTipoArticulo
	   	for json auto
	   ) as Propiedades
	   from ControlEquipos.tblDetalleArticulos da
	   	left join #TempEstatusArticulo ea on ea.IDDetalleArticulo = da.IDDetalleArticulo
		inner join ControlEquipos.tblArticulos a on a.IDArticulo = da.IDArticulo
		left join [ControlEquipos].[tblCatTiposArticulos] ta on ta.IDTipoArticulo = a.IDTipoArticulo
		left join [ControlEquipos].[tblCatEstatusArticulos] cea on cea.IDCatEstatusArticulo = ea.IDCatEstatusArticulo
	   	where ea.IDCatEstatusArticulo = @ID_CAT_ESTATUS_ARTICULO_ASIGNADO and ea.RN = 1
		
end


/*

*/
GO
