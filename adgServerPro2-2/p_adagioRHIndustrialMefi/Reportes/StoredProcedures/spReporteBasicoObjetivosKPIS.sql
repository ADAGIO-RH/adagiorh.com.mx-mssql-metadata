USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Reportes].[spReporteBasicoObjetivosKPIS](
	 @CicloMedicionObjetivo varchar(max) = '0'
	,@TipoNomina varchar(max) = '0'
	,@ClaveEmpleadoInicial Varchar(20) = '0'
	,@ClaveEmpleadoFinal Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ' 
	,@Cliente Varchar(max) = ''
	,@Departamentos Varchar(max) = ''
	,@Sucursales Varchar(max) = ''
	,@Puestos Varchar(max) = ''
	,@RazonesSociales Varchar(max) = ''
	,@RegPatronales Varchar(max) = ''
	,@Divisiones Varchar(max) = ''
	,@Prestaciones Varchar(max) = ''
	,@IDUsuario int

) as
	SET FMTONLY OFF;  

    DECLARE 
    @dtFiltros [Nomina].[dtFiltrosRH]
	,@dtEmpleados [RH].[dtEmpleados]
    ,@IDIdioma varchar(20)
	,@IDTipoNomina int
    ,@IDCicloMedicionObjetivo int

    insert into @dtFiltros(Catalogo,Value)
	values('Departamentos',@Departamentos)
		,('Sucursales',@Sucursales)
		,('Puestos',@Puestos)
		,('RazonesSociales',@RazonesSociales)
		,('RegPatronales',@RegPatronales)
		,('Divisiones',@Divisiones)
		,('Prestaciones',@Prestaciones)
		,('Clientes',@Cliente)

	SET @ClaveEmpleadoInicial = CASE WHEN ISNULL(@ClaveEmpleadoInicial,'') = '' THEN '0' ELSE  @ClaveEmpleadoInicial END
	SET @ClaveEmpleadoFinal = CASE WHEN ISNULL(@ClaveEmpleadoFinal,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  @ClaveEmpleadoFinal END
    SET @IDCicloMedicionObjetivo=(Select top 1 CAST(ITEM as int) from App.Split(isnull(@CicloMedicionObjetivo,'0'),','))
    -- SET @IDCicloMedicionObjetivo=1
	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
    

    insert into @dtEmpleados
	EXEC [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,
                                  @EmpleadoIni = @ClaveEmpleadoInicial,
                                  @EmpleadoFin = @ClaveEmpleadoFinal,
                                  @dtFiltros = @dtFiltros,
                                  @IDUsuario = @IDUsuario
			
	
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

    SELECT 
    DISTINCT(empleados.ClaveEmpleado)
   ,empleados.NOMBRECOMPLETO
    ,ISNULL((
            SELECT TOP 1 CONCAT(E.NOMBRECOMPLETO,' ',E.ClaveEmpleado)
            FROM RH.tblJefesEmpleados JE
                INNER JOIN RH.tblEmpleadosMaster E
                ON JE.IDJefe=E.IDEmpleado
                WHERE empleados.IDEmpleado=JE.IDEmpleado
                ORDER BY IDJefeEmpleado DESC
    ),'SIN ASIGNAR') AS NombreClaveJefe
    ,CMO.IDCicloMedicionObjetivo
    ,CMO.Nombre AS CicloMedicion
    ,empleados.Departamento
    ,OE.IDEmpleado
    ,@IDUsuario AS IDUsuario
    FROM @dtEmpleados empleados
        INNER JOIN Evaluacion360.tblObjetivosEmpleados OE
            ON OE.IDEmpleado=empleados.IDEmpleado
        INNER JOIN [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios] dfe 
            on dfe.IDEmpleado = oe.IDEmpleado 
            and dfe.IDUsuario = @IDUsuario    
        INNER JOIN Evaluacion360.tblCatCiclosMedicionObjetivos CMO
            ON CMO.IDCicloMedicionObjetivo=OE.IDCicloMedicionObjetivo
    WHERE (OE.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo or isnull(@IDCicloMedicionObjetivo, 0) = 0)
GO
