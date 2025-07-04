USE [p_adagioRHIndustrialMefi]
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
	declare @IDIdioma varchar(20),
    @IDTipoArticulo int=0;

	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

    SELECT @IDTipoArticulo =cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposArticulos'),',')
	
    
    --if object_id('tempdb..#tempArticulos') is not null drop table #tempArticulos;
	if object_id('tempdb..#tempEstatusArticulos') is not null drop table #tempEstatusArticulos;

	select 
		--a.IDArticulo,
		a.IDTipoArticulo,
		ISNULL(da.IDDetalleArticulo, 0) as IDDetalleArticulo,
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
        FORMAT(a.FechaAlta,'dd/MM/yyyy') as FechaAlta,		
		--ISNULL(da.FechaCaducidad, GETDATE()) AS FechaCaducidad,
		ROW_NUMBER() over(partition by ea.IDDetalleArticulo order by ea.IDEstatusArticulo desc) RN
	INTO #tempEstatusArticulos
	from ControlEquipos.tblArticulos a
	left join ControlEquipos.tblMetodoDepreciacion md on md.IDMetodoDepreciacion = a.IDMetodoDepreciacion
	left join ControlEquipos.tblDetalleArticulos da on da.IDArticulo = a.IDArticulo
	left join ControlEquipos.tblCatTiposArticulos ta on ta.IDTipoArticulo = a.IDTipoArticulo
	right join ControlEquipos.tblEstatusArticulos ea on ea.IDDetalleArticulo = da.IDDetalleArticulo
	left join ControlEquipos.tblCatEstatusArticulos cea on cea.IDCatEstatusArticulo = ea.IDCatEstatusArticulo


IF @IDTipoArticulo >0
	BEGIN
    
    DECLARE @IDTipoArticuloStr NVARCHAR(10);
    SET @IDTipoArticuloStr = CAST(@IDTipoArticulo AS NVARCHAR(10));


        DECLARE @Columnas NVARCHAR(MAX)
        SELECT @Columnas = STRING_AGG(QUOTENAME(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre'))), ', ')
        FROM (SELECT DISTINCT Traduccion FROM ControlEquipos.tblCatPropiedades where IDTipoArticulo=@IDTipoArticulo) AS Propiedades;

        DECLARE @SQL NVARCHAR(MAX)

        SET @SQL = N'
        WITH PropiedadesPivot AS (
            SELECT 
                vp.IDDetalleArticulo, 
                cp.IDPropiedad, 
                JSON_VALUE(cp.Traduccion, FORMATMESSAGE(''$.%s.%s'', lower(replace(N''' + @IDIdioma + ''', ''-'', '''')), ''Nombre''))  as NombrePropiedad,
                vp.Valor,
                CP.IDTipoArticulo
            FROM ControlEquipos.tblValoresPropiedades vp
            INNER JOIN ControlEquipos.tblCatPropiedades cp ON vp.IDPropiedad = cp.IDPropiedad
        
        )
        SELECT * 
        INTO #tempPropiedadesArticulos
        FROM (
            SELECT IDDetalleArticulo, NombrePropiedad, Valor
            FROM PropiedadesPivot
        ) AS Fuente
        PIVOT (
            MAX(Valor) FOR NombrePropiedad IN (' + @Columnas + N')
        ) AS pvt;

        SELECT 
            e.TipoArticulo,
            e.MetodoDepreciacion,
            e.Nombre,
            e.Descripcion,
            e.Etiqueta,
            e.EstatusArticulo,
            e.Existencias,
            e.UsoCompartido,
            e.Stock,
            e.TieneCaducidad,
            e.FechaAlta,           
            p.' + @Columnas + N'
        FROM #tempEstatusArticulos e
        LEFT JOIN #tempPropiedadesArticulos p ON e.IDDetalleArticulo = p.IDDetalleArticulo
        WHERE RN = 1
        AND IDTipoArticulo ='+ @IDTipoArticuloStr +';'

        EXEC sp_executesql @SQL;

     END ELSE
    BEGIN
      
        select 
            TipoArticulo,
            MetodoDepreciacion,
            Nombre,
            Descripcion,
            Etiqueta,
            EstatusArticulo,
            Existencias,
            UsoCompartido,
            Stock,
            TieneCaducidad,
            FechaAlta
         from #tempEstatusArticulos where RN = 1
    END


end
GO
