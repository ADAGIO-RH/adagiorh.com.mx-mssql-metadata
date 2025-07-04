USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarFondosAhorroHistorialEmpleado](			
     @IDEmpleado int
	,@IDUsuario int
) as

    DECLARE
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')


    	IF OBJECT_ID('tempdb..#TempHistorialTipoNomina') IS NOT NULL DROP TABLE #TempHistorialTipoNomina;
        IF OBJECT_ID('tempdb..#TempFondoAhorro') IS NOT NULL DROP TABLE #TempFondoAhorro;

    
		Select 
		    PE.IDTipoNominaEmpleado,
			PE.IDEmpleado,
			c.IDCliente,
			JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente,
			PE.IDTipoNomina,
			P.Descripcion,
			PE.FechaIni,
			PE.FechaFin,
            DATEPART(YEAR,FechaIni) AS EjercicioFechaIni,
            DATEPART(YEAR,FechaFin) AS EjercicioFechaFin
		INTO #TempHistorialTipoNomina
        From RH.tblTipoNominaEmpleado PE with(nolock)
			Inner join Nomina.tblCatTipoNomina P with(nolock)
				on PE.IDTipoNomina = P.IDTipoNomina
			Inner join RH.tblCatClientes c  with(nolock)
				on p.IDCliente = c.IDCliente
		Where PE.IDEmpleado = @IDEmpleado
		ORDER BY PE.FechaIni Desc


    

	select 
		 cfa.IDFondoAhorro
		,c.IDCliente
		,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
		,cfa.IDTipoNomina
		,tn.Descripcion as TipoNomina
		,cfa.Ejercicio
		,cfa.IDPeriodoInicial
		,p.Descripcion as PeriodoInicial
		,isnull(cfa.IDPeriodoFinal,0) as IDPeriodoFinal
		,UPPER(isnull(pp.Descripcion,'SIN ASIGNAR')) as PeriodoFinal
		,isnull(cfa.IDPeriodoPago,0) IDPeriodoPago
		,UPPER(isnull(ppago.Descripcion,'SIN ASIGNAR')) as PeriodoDePago
		,isnull(ppago.Cerrado,cast(0 as bit)) as Pagado
		,isnull(cfa.FechaHora,getdate()) as FechaHora
		,cfa.IDUsuario
		,coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'') as Usuario
        ,ROW_NUMBER()OVER(Partition by IDFondoAhorro order by IDFondoAhorro) as RN
    INTO #TempFondoAhorro
	from Nomina.tblCatFondosAhorro cfa with(nolock)
		join Nomina.tblCatTipoNomina tn with(nolock) 
            on cfa.IDTipoNomina = tn.IDTipoNomina
		join RH.tblCatClientes c with(nolock) 
            on tn.IDCliente = c.IDCliente
		join Nomina.tblCatPeriodos p with(nolock) 
            on cfa.IDPeriodoInicial = p.IDPeriodo    
		left join Nomina.tblCatPeriodos pp with(nolock) 
            on cfa.IDPeriodoFinal = pp.IDPeriodo
		left join Nomina.tblCatPeriodos ppago with(nolock) 
            on cfa.IDPeriodoPago = ppago.IDPeriodo
		join Seguridad.tblUsuarios u  with(nolock) 
            on cfa.IDUsuario = u.IDUsuario
        join #TempHistorialTipoNomina TNE 
            ON TNE.IDTipoNomina=CFA.IDTipoNomina
    WHERE cfa.Ejercicio BETWEEN TNE.EjercicioFechaIni AND TNE.EjercicioFechaFin 
    Order by C.IDCliente DESC

    Delete from #TempFondoAhorro where RN <>1

    Select * from #TempFondoAhorro
GO
