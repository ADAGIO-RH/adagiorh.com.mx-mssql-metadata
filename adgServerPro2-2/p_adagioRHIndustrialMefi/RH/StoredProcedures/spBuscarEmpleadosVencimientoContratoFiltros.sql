USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Buscar Empleados para Vencimiento de Contratos
** Autor			: Javier Peña
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2024-01-04
** Paremetros		:    
	@dtFiltros: Contiene los filtros que el procedimiento utilizará para la busqueda
    @IDUsuario: Recibe el identificador del usuario que ejecutó el procedimiento 
	 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE PROCEDURE [RH].[spBuscarEmpleadosVencimientoContratoFiltros](    
	@dtFiltros [Nomina].[dtFiltrosRH] READONLY,
    @IDUsuario int = 0
)
AS
BEGIN
	SET QUERY_GOVERNOR_COST_LIMIT 0;        
	SET FMTONLY OFF;    

	DECLARE 
		@dtEmpleados [RH].[dtEmpleados],
		@QuerySelect Varchar(Max) = '',
		@QuerySelect2 Varchar(Max) = '',
		@QueryFrom Varchar(Max) = '',
		@QueryFrom2 Varchar(Max) = '',
		@QueryWhere Varchar(Max) = '',
		@LenFrom int,
		@IDIdioma varchar(20),
        @FechaIni date,
        @FechaFin date,
        @TiposContratacion varchar(max),
		@ExcluirColaboradoresSinContrato bit = 0,
        @dtFiltrosParaBusqueda [Nomina].[dtFiltrosRH],
        @QueryString NVARCHAR(MAX)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
    if object_id('tempdb..#tempContra') is not null drop table #tempContra          

    INSERT INTO @dtFiltrosParaBusqueda
    SELECT *
    FROM @dtFiltros
    WHERE Catalogo<>'TiposContratacion'
		
    select top 1 @FechaIni = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'FechaIni'),',')    
    select top 1 @FechaFin = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'FechaFin'),',')    
	Select top 1 @TiposContratacion = [value] from @dtFiltros where Catalogo = 'TiposContratacion'
	select top 1 @ExcluirColaboradoresSinContrato = case when [value] = 'true' then 1 else 0 end 
	from @dtFiltros where Catalogo = 'ExcluirColaboradoresSinContrato'

    insert into @dtEmpleados
    exec [RH].[spBuscarEmpleadosMaster] @IDUsuario=1,@dtFiltros=@dtFiltrosParaBusqueda

    if object_id('tempdb..#tempContra') is not null drop table #tempContra      

  	select  ContratoEmpleado.IDContratoEmpleado
		   ,ContratoEmpleado.IDEmpleado
		   ,Isnull(documentos.IDDocumento,0) as IDDocumento             
		   ,UPPER(Isnull(documentos.Descripcion,'')) as Documento             
		   ,Isnull(tipoContrato.IDTipoContrato,0) as IDTipoContrato             
		   ,UPPER(Isnull(tipoContrato.Descripcion,'')) as TipoContrato            
		   ,isnull(ContratoEmpleado.FechaIni,'1900-01-01') as FechaIniContrato          
		   ,isnull(ContratoEmpleado.FechaFin,'1900-01-01') as FechaFinContrato 
		   , RN = ROW_NUMBER()Over(partition by ContratoEmpleado.IDEmpleado order by ContratoEmpleado.FechaFin desc )
	into #tempContra
	from [RH].[tblContratoEmpleado] ContratoEmpleado WITH(NOLOCK)
		inner JOIN [RH].[tblCatDocumentos] documentos WITH(NOLOCK)
			ON ContratoEmpleado.IDDocumento = documentos.IDDocumento          
				and documentos.EsContrato = 1
		inner JOIN [sat].[tblCatTiposContrato] tipoContrato WITH(NOLOCK)
			ON ContratoEmpleado.IDTipoContrato = tipoContrato.IDTipoContrato    
	where ContratoEmpleado.IDEmpleado in (select IDEmpleado from @dtEmpleados where Vigente = 1)

    delete from #tempContra where RN>1
        
    if object_id('tempdb..#tempEmpleados') is not null drop table #tempEmpleados

    SELECT *
    INTO #tempEmpleados
    FROM @dtEmpleados

	update e
		set
			e.IDDocumento = c.IDDocumento,	
			e.Documento = c.Documento,	
			e.IDTipoContrato = c.IDTipoContrato,	
			e.TipoContrato = c.TipoContrato,	
			e.FechaIniContrato = c.FechaIniContrato,	
			e.FechaFinContrato = c.FechaFinContrato	
	from #tempEmpleados e
		join #tempContra c on c.IDEmpleado = e.IDEmpleado

    if object_id('tempdb..#tempFiltros') is not null drop table #tempFiltros

    SELECT *
    INTO #tempFiltros
    FROM @dtFiltros
    where [Value] is not null  or [Value]<>''

    SET @QueryString = N'
        SELECT  e.*,
                Utilerias.GetInfoUsuarioEmpleadoFotoAvatar(e.IDEmpleado, 0) AS UsuarioEmpleadoFotoAvatar
        FROM #tempEmpleados e
        LEFT JOIN #tempContra contratos ON contratos.IDEmpleado = e.IDEmpleado      
        WHERE   e.Vigente = 1 AND 
                (contratos.FechaFinContrato BETWEEN ''' + FORMAT(@FechaIni,'yyyy-MM-dd')+ + ''' AND ''' + FORMAT(@FechaFin,'yyyy-MM-dd')+ 
		CASE WHEN ISNULL(@ExcluirColaboradoresSinContrato, 0) = 0 then ''' OR contratos.FechaFinContrato IS NULL)' else ''')' end+
        CASE WHEN ISNULl(@TiposContratacion, '') != '' THEN ' and ((contratos.IDTipoContrato in (Select item from App.Split('''+@TiposContratacion+''','','')))) ' ELSE '' END 

    print (@QueryString) 
    exec (@QueryString) 
END
GO
