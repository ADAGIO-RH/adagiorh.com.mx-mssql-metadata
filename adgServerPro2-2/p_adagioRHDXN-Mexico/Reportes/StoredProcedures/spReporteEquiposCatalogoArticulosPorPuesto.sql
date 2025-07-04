USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para generar reporte del catalogo de puestos con sus articulos
** Autor			: Justin Davila
** Email			: jdavila@adagio.com.mx
** FechaCreacion	: 2024/02/27
** Paremetros		:              
	@dtFiltros  	: 
	@IDUsuario      :

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE   proc [Reportes].[spReporteEquiposCatalogoArticulosPorPuesto](
	@dtFiltros Nomina.dtFiltrosRH readonly,
	@IDusuario int
)
as 
begin
	declare  
		@IDIdioma varchar(20),
		@IDArticulosPorPuesto int = 0,
		@IDPuesto int = 0
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select 
		p.Codigo+' - '+JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Puesto
		,ta.Codigo+' - '+JSON_VALUE(ta.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoArticulo
		,a.Nombre as Articulo
		,a.Descripcion as DescripcionArticulo
        ,app.Cantidad as CantidadArticulo
	from ControlEquipos.tblArticulosPorPuesto app
		join RH.tblCatPuestos p on p.IDPuesto = app.IDPuesto
		join ControlEquipos.tblArticulos a on a.IDArticulo = app.IDArticulo
		join ControlEquipos.tblCatTiposArticulos ta on ta.IDTipoArticulo = a.IDTipoArticulo
	where (app.IDArticulosPorPuesto = @IDArticulosPorPuesto or isnull(@IDArticulosPorPuesto, 0) = 0)
		and (app.IDPuesto = @IDPuesto or isnull(@IDPuesto, 0) = 0)
end


--select IDPuesto, Puesto from RH.tblEmpleadosMaster where IDEmpleado = 21021
--select * from ControlEquipos.tblArticulosPorPuesto
--exec [ControlEquipos].[spBuscarArticulosPorPuesto]
--	@IDArticulosPorPuesto = 0
--	,@IDPuesto = 0
--	,@IDUsuario = 1
GO
