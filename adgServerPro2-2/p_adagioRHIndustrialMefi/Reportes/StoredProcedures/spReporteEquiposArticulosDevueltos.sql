USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para generar reporte de artículos  devuletos por el colaborador
** Autor			: Justin Davila
** Email			: jdavila@adagio.com.mx
** FechaCreacion	: 2024/02/29
** Paremetros		:              
	@dtFiltros  	: 
	@IDUsuario      :

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE   proc [Reportes].[spReporteEquiposArticulosDevueltos](
	@dtFiltros Nomina.dtFiltrosRH readonly,
	@IDusuario int = 1
)
as
begin
	SET FMTONLY OFF;
	declare @IDIdioma varchar(20), @Empleado VARCHAR(40), @TotalPaginas int = 0, @TotalRegistros int, @IDEmpleado int = 21021;
	DECLARE @ID_CAT_ESTATUS_ARTICULO_ASIGNADO INT = 2, @ID_CAT_ESTATUS_ARTICULO_DEVUELTO INT = 6, @ID_CAT_ESTATUS_ARTICULO_EN_TRANSITO INT = 3, @ID_CAT_ESTATUS_ARTICULO_STOCK INT = 1
	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	if object_id('tempdb..#ArticulosDevueltos') is not null drop table #ArticulosDevueltos;

	select 
		da.Etiqueta,
		a.Nombre as NombreArticulo,
		a.Descripcion,
		cea.Nombre as NombreEstatusArticulo,
		(
			select STRING_AGG(NOMBRECOMPLETO, ', ')
			from RH.tblEmpleadosMaster
			where IDEmpleado in 
			(
				select * 
				from OPENJSON(hea.Empleados, '$')
				with (
						IDEmpleado int
					)   
			)
		)  as Devolvio,
		hea.FechaHora as FechaHoraRecibido,
		U.Nombre as Recibio
	into #ArticulosDevueltos
	from ControlEquipos.tblEstatusArticulos hea
	left join ControlEquipos.tblCatEstatusArticulos cea on cea.IDCatEstatusArticulo = hea.IDCatEstatusArticulo
	inner join Seguridad.tblUsuarios U on U.IDUsuario = hea.IDUsuario
	inner join RH.tblEmpleadosMaster em on em.IDEmpleado = @IDEmpleado
	join ControlEquipos.tblDetalleArticulos da on da.IDDetalleArticulo = hea.IDDetalleArticulo
	join ControlEquipos.tblArticulos a on a.IDArticulo = da.IDArticulo
	where hea.IDCatEstatusArticulo <> @ID_CAT_ESTATUS_ARTICULO_ASIGNADO and hea.IDCatEstatusArticulo <> @ID_CAT_ESTATUS_ARTICULO_STOCK and hea.IDCatEstatusArticulo <> @ID_CAT_ESTATUS_ARTICULO_EN_TRANSITO
	order by hea.FechaHora desc

	select * from #ArticulosDevueltos where Devolvio is not null order by FechaHoraRecibido desc
end
GO
