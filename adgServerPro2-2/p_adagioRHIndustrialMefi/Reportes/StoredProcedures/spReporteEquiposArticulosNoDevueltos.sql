USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para generar reporte de artículos no devuletos por el colaborador
** Autor			: Justin Davila
** Email			: jdavila@adagio.com.mx
** FechaCreacion	: 2024/02/27
** Paremetros		:              
	@dtFiltros  	: 
	@IDUsuario      :
	@IDEmpleado     :

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2024-03-07			Justin Davila		Removimos campo IDGenero
2024-05-23			Justin Davila		Quitamos columna da.FechaCaducidad y agregamos columna da.Costo
***************************************************************************************************/
CREATE   proc [Reportes].[spReporteEquiposArticulosNoDevueltos](
	@dtFiltros Nomina.dtFiltrosRH readonly,
	@IDusuario int = 1
)
as
begin
	SET FMTONLY OFF;
	DECLARE 
		@IDIdioma varchar(20);

	DECLARE @ID_CAT_ESTATUS_ARTICULO_ASIGNADO INT = 2;
	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	IF OBJECT_ID('tempdb..#TempLastEstatusArticulos') IS NOT NULL DROP TABLE #TempLastEstatusArticulos;
    IF OBJECT_ID('tempdb..#TempDetallesArticulos') IS NOT NULL DROP TABLE #TempDetallesArticulos;
    IF object_id('tempdb..#TempDetallesArticulosEmpleados') is not null drop table #TempDetallesArticulosEmpleados;

	SELECT
          *,
          ROW_NUMBER() OVER (PARTITION BY IDDetalleArticulo ORDER BY FechaHora desc) AS RN
	into #TempLastEstatusArticulos
    FROM ControlEquipos.tblEstatusArticulos

	select *
	into #TempDetallesArticulos
	from #TempLastEstatusArticulos
	where RN = 1 and IDCatEstatusArticulo = @ID_CAT_ESTATUS_ARTICULO_ASIGNADO

	select 
	   JSON_VALUE(ta.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) AS [TipoArticulo],
	   UPPER(Etiqueta) as Etiqueta,
	   a.Nombre,
	   a.Descripcion,
	   da.Costo,
	   cea.Nombre as Estatus,
	   ea.FechaHora,	   
       (
			case when a.TieneCaducidad = 1
				then 'Si'
				else 'No'
			end
	   ) as TieneCaducidad,
       (
			case when a.UsoCompartido = 1
				then 'Si'
				else 'No'
			end
	   ) as UsoCompartido,
	   (
			select STRING_AGG(NOMBRECOMPLETO, ', ')
			from RH.tblEmpleadosMaster
			where IDEmpleado in (
            select * from OPENJSON(Empleados, '$')
            with (
                IDEmpleado int
            )   
        )
	   ) as ColaboradorAsignado,
       ISNULL(JSON_VALUE(cg.Traduccion, FORMATMESSAGE('$.%s.%s', '' + lower(replace(@IDIdioma, '-','')) + '', 'Descripcion')), 'N/A') as Genero
       --da.FechaCaducidad
    INTO #TempDetallesArticulosEmpleados
    from #TempDetallesArticulos ea 
    inner join  ControlEquipos.tblDetalleArticulos da on da.IDDetalleArticulo=ea.IDDetalleArticulo
    inner join ControlEquipos.tblArticulos a on a.IDArticulo = da.IDArticulo
	inner  join [ControlEquipos].[tblCatTiposArticulos] ta on ta.IDTipoArticulo = a.IDTipoArticulo        
	inner join [ControlEquipos].[tblCatEstatusArticulos] cea on cea.IDCatEstatusArticulo = ea.IDCatEstatusArticulo
    left join RH.tblCatGeneros cg on cg.IDGenero = da.IDGenero

	select *
	from #TempDetallesArticulosEmpleados	
end
GO
