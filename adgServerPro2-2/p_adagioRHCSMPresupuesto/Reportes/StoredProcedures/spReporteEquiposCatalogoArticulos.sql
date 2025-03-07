USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para generar reporte del catalogo de Artículos con sus detalles existentes
** Autor			: Justin Davila
** Email			: jdavila@adagio.com.mx
** FechaCreacion	: 2024/02/26
** Paremetros		:              
	@dtFiltros  	: 
	@IDUsuario      :

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE   proc [Reportes].[spReporteEquiposCatalogoArticulos](
	@dtFiltros Nomina.dtFiltrosRH readonly,
	@IDusuario int
)
as
begin
	SET FMTONLY OFF;
	declare @IDIdioma varchar(20);

	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	--if object_id('tempdb..#tempArticulos') is not null drop table #tempArticulos;
	if object_id('tempdb..#tempEstatusArticulos') is not null drop table #tempEstatusArticulos;

	select 
		--a.IDArticulo,
		--a.IDTipoArticulo,
		--ISNULL(da.IDDetalleArticulo, 0) as IDDetalleArticulo,
		JSON_VALUE(ta.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoArticulo,
		--a.IDMetodoDepreciacion,
		md.Nombre as MetodoDepreciacion,
		UPPER(a.Nombre) as Nombre,
		UPPER(a.Descripcion) as Descripcion,
		ISNULL(da.Etiqueta, '') as Etiqueta,
		--ISNULL(ea.IDEstatusArticulo,0) as IDEstatusArticulo,
		--ISNULL(ea.IDCatEstatusArticulo, 0) as IDCatEstatusArticulo,
		ISNULL(cea.Nombre,'No aplica') as EstatusArticulo,
		--ISNULL(ea.Empleados, '[]') as Empleados,
		ISNULL(CAST(da.IDGenero as varchar(3)), 'N/A') as IDGenero,
		--a.Costo,
		a.Cantidad as Existencias,
		a.UsoCompartido,
		ISNULL(a.Stock, 0) as Stock,
		--CAST(ISNULL(a.FechaHoraUltimaActualizaciónStock, '9999-01-01') as date)  FechaHoraUltimaActualizaciónStock,
		a.TieneCaducidad,
		a.FechaAlta,
		--ISNULL(da.FechaCaducidad, GETDATE()) AS FechaCaducidad,
		ROW_NUMBER() over(partition by ea.IDDetalleArticulo order by ea.IDEstatusArticulo desc) RN
	INTO #tempEstatusArticulos
	from ControlEquipos.tblArticulos a
	left join ControlEquipos.tblMetodoDepreciacion md on md.IDMetodoDepreciacion = a.IDMetodoDepreciacion
	left join ControlEquipos.tblDetalleArticulos da on da.IDArticulo = a.IDArticulo
	left join ControlEquipos.tblCatTiposArticulos ta on ta.IDTipoArticulo = a.IDTipoArticulo
	right join ControlEquipos.tblEstatusArticulos ea on ea.IDDetalleArticulo = da.IDDetalleArticulo
	left join ControlEquipos.tblCatEstatusArticulos cea on cea.IDCatEstatusArticulo = ea.IDCatEstatusArticulo

	select * from #tempEstatusArticulos where RN = 1
end
GO
